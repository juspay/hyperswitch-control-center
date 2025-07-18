let tableHeadingClass = "font-bold text-xl text-black text-opacity-75 dark:text-white dark:text-opacity-75"
type view = Table | Card

let visibilityColFunc = (
  ~dateFormatConvertor: string => option<JSON.t>,
  ~jsonVal: option<JSON.t>,
  ~tableCell: Table.cell,
) => {
  switch tableCell {
  | Label(x) | ColoredText(x) => (x.title->JSON.Encode.string->Some, jsonVal) // wherever we are doing transformation only that transformed value for serch
  | Text(x) | EllipsisText(x, _) | CustomCell(_, x) => (x->JSON.Encode.string->Some, jsonVal)
  | Date(x) => (dateFormatConvertor(x), dateFormatConvertor(x))
  | StartEndDate(start, end) => (
      `${dateFormatConvertor(start)
        ->Option.getOr(""->JSON.Encode.string)
        ->String.make} ${dateFormatConvertor(end)
        ->Option.getOr(""->JSON.Encode.string)
        ->String.make}`
      ->JSON.Encode.string
      ->Some,
      dateFormatConvertor(end),
    )
  | _ => (jsonVal, jsonVal) // or else taking the value from the actual json
  }
}

let useDateFormatConvertor = () => {
  let dateFormat = React.useContext(DateFormatProvider.dateFormatContext)
  let isoStringToCustomTimeZone = TimeZoneHook.useIsoStringToCustomTimeZoneInFloat()
  let dateFormatConvertor = dateStr => {
    try {
      let customTimeZone = isoStringToCustomTimeZone(dateStr)
      TimeZoneHook.formattedDateTimeFloat(customTimeZone, dateFormat)->JSON.Encode.string->Some
    } catch {
    | _ => None
    }
  }
  dateFormatConvertor
}

let filteredData = (
  actualData: array<Nullable.t<'t>>,
  columnFilter: Dict.t<array<JSON.t>>,
  visibleColumns: option<array<'colType>>,
  entity: EntityType.entityType<'colType, 't>,
  dateFormatConvertor: string => option<JSON.t>,
) => {
  let selectedFiltersKeys = columnFilter->Dict.keysToArray
  if selectedFiltersKeys->Array.length > 0 {
    actualData->Array.filter(item => {
      switch item->Nullable.toOption {
      | Some(row) =>
        // either to take this row or not if any filter is present then take row or else drop
        let rowDict = row->Identity.genericTypeToDictOfJson
        let anyMatch = selectedFiltersKeys->Array.find(keys => {
          // Selected fitler
          switch Dict.get(columnFilter, keys) {
          | Some(selectedArr) => {
              // selected value of the fitler
              let jsonVal = Dict.get(
                rowDict->JSON.Encode.object->JsonFlattenUtils.flattenObject(false),
                keys,
              )
              let visibleColumns =
                visibleColumns
                ->Option.getOr(entity.defaultColumns)
                ->Belt.Array.keepMap(
                  item => {
                    let columnEntity = entity.getHeading(item)
                    let entityKey = entity.getHeading(item).key
                    let dataType = columnEntity.dataType
                    entityKey === keys ? Some((dataType, item)) : None
                  },
                )

              switch visibleColumns[0] {
              | Some(ele) => {
                  let (visibleColumns, item) = ele

                  let jsonVal = visibilityColFunc(
                    ~dateFormatConvertor,
                    ~jsonVal,
                    ~tableCell=entity.getCell(row, item),
                  )

                  switch visibleColumns {
                  | DropDown => {
                      let selectedArr =
                        selectedArr
                        ->Belt.Array.keepMap(item => item->JSON.Decode.string)
                        ->Array.map(String.toLowerCase)

                      let currVal = switch jsonVal {
                      | (Some(transformed), _) => transformed->String.make->String.toLowerCase
                      | (None, _) => ""
                      }
                      !(selectedArr->Array.includes(currVal))
                    }

                  | LabelType | TextType => {
                      let selectedArr1 =
                        selectedArr->Belt.Array.keepMap(item => item->JSON.Decode.string)

                      let currVal = switch jsonVal {
                      | (Some(transformed), _) => transformed->String.make
                      | (None, _) => ""
                      }

                      let searchedText = selectedArr1->Array.get(0)->Option.getOr("")
                      !String.includes(
                        searchedText->String.toUpperCase,
                        currVal->String.toUpperCase,
                      )
                    }

                  | MoneyType | NumericType | ProgressType => {
                      let selectedArr =
                        selectedArr->Belt.Array.keepMap(item => item->JSON.Decode.float)
                      let currVal = switch jsonVal {
                      | (_, Some(actualVal)) => actualVal->String.make->Js.Float.fromString
                      | _ => 0.
                      }
                      !(
                        currVal >= selectedArr[0]->Option.getOr(0.) &&
                          currVal <= selectedArr[1]->Option.getOr(0.)
                      )
                    }
                  }
                }

              | None => false
              }
            }

          | None => false
          }
        })

        anyMatch->Option.isNone
      | None => false
      }
    })
  } else {
    actualData
  }
}

let convertStrCellToFloat = (dataType: Table.cellType, str: string) => {
  switch dataType {
  | DropDown | LabelType | TextType => str->JSON.Encode.string
  | MoneyType | NumericType | ProgressType =>
    str->Float.fromString->Option.getOr(0.)->JSON.Encode.float
  }
}

let convertFloatCellToStr = (dataType: Table.cellType, num: float) => {
  switch dataType {
  | DropDown | LabelType | TextType => num->Float.toString->JSON.Encode.string
  | MoneyType | NumericType | ProgressType => num->JSON.Encode.float
  }
}

let defaultRefetchFn = () => {Js.log("This is default refetch")}
let refetchContext = React.createContext(defaultRefetchFn)

module RefetchContextProvider = {
  let make = React.Context.provider(refetchContext)
}

module TableHeading = {
  @react.component
  let make = (~title, ~noVerticalMargin=false, ~description=?, ~titleTooltip=false) => {
    let tooltipFlexDir = titleTooltip ? `flex-row` : `flex-col`
    let marginClass = if noVerticalMargin {
      ""
    } else {
      "lg:mb-4 lg:mt-8"
    }
    if title->LogicUtils.isNonEmptyString || description->Option.isSome {
      <div className={`flex ${tooltipFlexDir} ${marginClass}`}>
        {if title->LogicUtils.isNonEmptyString {
          <AddDataAttributes attributes=[("data-table-heading-title", title)]>
            <div className=tableHeadingClass> {React.string(title)} </div>
          </AddDataAttributes>
        } else {
          React.null
        }}
        {switch description {
        | Some(desc) =>
          switch titleTooltip {
          | true =>
            <div className="text-sm text-gray-500 mx-2">
              <ToolTip description={desc} toolTipPosition={ToolTip.Bottom} />
            </div>
          | _ =>
            <AddDataAttributes attributes=[("data-table-heading-desc", desc)]>
              <div className="text-base text-jp-gray-700 dark:text-jp-gray-800">
                {React.string(desc)}
              </div>
            </AddDataAttributes>
          }
        | None => React.null
        }}
      </div>
    } else {
      React.null
    }
  }
}

module TableLoadingErrorIndicator = {
  @react.component
  let make = (
    ~title,
    ~titleSize: NewThemeUtils.headingSize=Large,
    ~showFilterBorder=false,
    ~fetchSuccess,
    ~filters,
    ~buttonType: Button.buttonType=Primary,
    ~hideTitle=false,
  ) => {
    let isMobileView = MatchMedia.useMobileChecker()
    let filtersBorder = if !isMobileView && showFilterBorder {
      "p-2 bg-white dark:bg-black border border-jp-2-light-gray-400 rounded-lg"
    } else {
      ""
    }

    <div className={`flex flex-col w-full`}>
      <RenderIf condition={!hideTitle}>
        <TableHeading title />
      </RenderIf>
      <TableFilterSectionContext isFilterSection=true>
        <div className=filtersBorder> {filters} </div>
      </TableFilterSectionContext>
      <div className={`flex flex-col py-16 text-center items-center`}>
        {fetchSuccess
          ? <>
              <div className="animate-spin mb-10">
                <Icon name="spinner" />
              </div>
              {React.string("Loading...")}
            </>
          : <>
              <div className="mb-4 text-xl">
                {React.string("Oops, Something Went Wrong! Try again Later.")}
              </div>
              <Button
                text="Refresh"
                leftIcon={FontAwesome("sync-alt")}
                onClick={_ => Window.Location.reload()}
                buttonType
              />
            </>}
      </div>
    </div>
  }
}
module TableDataLoadingIndicator = {
  @react.component
  let make = (~showWithData=true) => {
    let padding = showWithData ? "py-8 rounded-b" : "py-56 rounded"
    <div
      className={`flex flex-col ${padding} justify-center space-x-2 items-center bg-white shadow-md dark:bg-jp-gray-lightgray_background dark:shadow-md`}>
      <div className="animate-spin mb-4">
        <Icon name="spinner" />
      </div>
      <div className="text-gray-500"> {React.string("Loading...")} </div>
    </div>
  }
}

module ChooseColumns = {
  @react.component
  let make = (
    ~entity: EntityType.entityType<'colType, 't>,
    ~totalResults,
    ~defaultColumns,
    ~activeColumnsAtom: Recoil.recoilAtom<array<'colType>>,
    ~setShowColumnSelector,
    ~showColumnSelector,
    ~isModalView=true,
    ~sortingBasedOnDisabled=true,
    ~orderdColumnBasedOnDefaultCol: bool=false,
    ~showSerialNumber=true,
    ~mandatoryOptions=[],
    ~isDraggable=false,
    ~title="",
  ) => {
    open LoadedTableWithCustomColumnsUtils
    let (visibleColumns, setVisibleColumns) = Recoil.useRecoilState(activeColumnsAtom)

    let {getHeading, allColumns} = entity
    let getHeadingCol = text => {
      switch allColumns {
      | Some(cols) =>
        let index =
          cols
          ->Array.map(head => getHeading(head).title)
          ->Array.indexOf(text)
        cols->Array.get(index)
      | None => None
      }
    }

    let colTypeArray = retrieveColumnValueFromLocalStorage(title)->Belt.Array.keepMap(getHeadingCol)

    let setColumns = React.useCallback(fn => {
      setVisibleColumns(fn)
      setShowColumnSelector(_ => false)
    }, [setVisibleColumns])

    React.useEffect(() => {
      if !{colTypeArray->Array.length === 0} {
        setColumns(_ => colTypeArray)
      }
      None
    }, [])

    if entity.allColumns->Option.isSome && totalResults > 0 {
      <CustomizeTableColumns
        showModal=showColumnSelector
        setShowModal=setShowColumnSelector
        allHeadersArray=?entity.allColumns
        visibleColumns
        setColumns
        getHeading
        defaultColumns
        isModalView
        sortingBasedOnDisabled
        orderdColumnBasedOnDefaultCol
        showSerialNumber
        isDraggable
        title
      />
    } else {
      React.null
    }
  }
}

module ChooseColumnsWrapper = {
  @react.component
  let make = (
    ~entity: EntityType.entityType<'colType, 't>,
    ~totalResults,
    ~defaultColumns,
    ~activeColumnsAtom as optionalActiveColumnsAtom,
    ~setShowColumnSelector,
    ~showColumnSelector,
    ~isModalView=true,
    ~sortingBasedOnDisabled=true,
    ~showSerialNumber=true,
    ~setShowDropDown=_ => (),
    ~isDraggable=false,
    ~title="",
  ) => {
    switch optionalActiveColumnsAtom {
    | Some(activeColumnsAtom) =>
      <AddDataAttributes attributes=[("data-table", "dynamicTableChooseColumn")]>
        <ChooseColumns
          entity
          activeColumnsAtom
          isModalView
          totalResults
          defaultColumns
          setShowColumnSelector
          showColumnSelector
          sortingBasedOnDisabled
          showSerialNumber
          isDraggable
          title
        />
      </AddDataAttributes>
    | None => React.null
    }
  }
}
