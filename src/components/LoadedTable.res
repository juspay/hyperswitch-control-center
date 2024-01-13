external toJson: Js.Nullable.t<'a> => Js.Json.t = "%identity"
open DynamicTableUtils
open NewThemeUtils
type sortTyp = ASC | DSC
type sortOb = {
  sortKey: string,
  sortType: sortTyp,
}

type checkBoxProps = {
  showCheckBox: bool,
  selectedData: Js.Array2.t<Js.Json.t>,
  setSelectedData: (Js.Array2.t<Js.Json.t> => Js.Array2.t<Js.Json.t>) => unit,
}

let checkBoxPropDefaultVal: checkBoxProps = {
  showCheckBox: false,
  selectedData: [],
  setSelectedData: _ => (),
}

let sortAtom: Recoil.recoilAtom<Js.Dict.t<sortOb>> = Recoil.atom(. "sortAtom", Dict.make())

let backgroundClass = "bg-gray-50 dark:bg-jp-gray-darkgray_background"

let useSortedObj = (title: string, defaultSort) => {
  let (dict, setDict) = Recoil.useRecoilState(sortAtom)
  let filters = Dict.get(dict, title)

  let (sortedObj, setSortedObj) = React.useState(_ => defaultSort)
  React.useEffect0(() => {
    switch filters {
    | Some(filt) =>
      let sortObj: Table.sortedObject = {
        key: filt.sortKey,
        order: switch filt.sortType {
        | DSC => Table.DEC
        | _ => Table.INC
        },
      }
      setSortedObj(_ => sortObj->Some)
    | None => ()
    }

    None
  })

  // Adding new
  React.useEffect1(() => {
    switch sortedObj {
    | Some(obj: Table.sortedObject) =>
      let sortOb = {
        sortKey: obj.key,
        sortType: switch obj.order {
        | Table.DEC => DSC
        | _ => ASC
        },
      }

      setDict(.dict => {
        let nDict = Dict.fromArray(Dict.toArray(dict))
        Dict.set(nDict, title, sortOb)
        nDict
      })
    | _ => ()
    }
    None
  }, [sortedObj])

  (sortedObj, setSortedObj)
}
let sortArray = (originalData, key, sortOrder: Table.sortOrder) => {
  let getValue = val => {
    switch val {
    | Some(x) =>
      switch x->Js.Json.classify {
      | JSONString(str) => str->Js.String.toLowerCase->Js.Json.string
      | JSONNumber(_num) => x
      | JSONFalse => "false"->Js.Json.string
      | JSONTrue => "true"->Js.Json.string
      | _ => ""->Js.Json.string
      }
    | None => ""->Js.Json.string
    }
  }
  let sortedArrayByOrder = {
    let _ = originalData->Js.Array2.sortInPlaceWith((i1, i2) => {
      let item1 = i1->Js.Json.stringifyAny->Option.getWithDefault("")->LogicUtils.safeParse
      let item2 = i2->Js.Json.stringifyAny->Option.getWithDefault("")->LogicUtils.safeParse
      // flatten items and get data

      let val1 =
        JsonFlattenUtils.flattenObject(item1, true)
        ->Js.Json.object_
        ->Js.Json.decodeObject
        ->Option.flatMap(dict => dict->Dict.get(key))
      let val2 =
        JsonFlattenUtils.flattenObject(item2, true)
        ->Js.Json.object_
        ->Js.Json.decodeObject
        ->Option.flatMap(dict => dict->Dict.get(key))
      let value1 = getValue(val1)
      let value2 = getValue(val2)
      if value1 === ""->Js.Json.string || value2 === ""->Js.Json.string {
        if value1 === value2 {
          0
        } else if value2 === ""->Js.Json.string {
          sortOrder === DEC ? 1 : -1
        } else if sortOrder === DEC {
          -1
        } else {
          1
        }
      } else if value1 === value2 {
        0
      } else if value1 > value2 {
        sortOrder === DEC ? 1 : -1
      } else if sortOrder === DEC {
        -1
      } else {
        1
      }
    })
    originalData
  }
  sortedArrayByOrder
}
type pageDetails = {
  offset: int,
  resultsPerPage: int,
}

let table_pageDetails: Recoil.recoilAtom<Js.Dict.t<pageDetails>> = Recoil.atom(.
  "table_pageDetails",
  Dict.make(),
)

@react.component
let make = (
  ~visibleColumns=?,
  ~defaultSort=?,
  ~title,
  ~titleSize: NewThemeUtils.headingSize=Large,
  ~description=?,
  ~tableActions=?,
  ~isTableActionBesideFilters=false,
  ~hideFilterTopPortals=true,
  ~rightTitleElement=React.null,
  ~clearFormattedDataButton=?,
  ~bottomActions=?,
  ~showSerialNumber=false,
  ~actualData,
  ~totalResults,
  ~resultsPerPage,
  ~offset,
  ~setOffset,
  ~handleRefetch=?,
  ~entity: EntityType.entityType<'colType, 't>,
  ~onEntityClick=?,
  ~onEntityDoubleClick=?,
  ~onExpandClickData=?,
  ~currrentFetchCount,
  ~filters=?,
  ~showFilterBorder=false,
  ~headBottomMargin="mb-6 mobile:mb-4",
  ~removeVerticalLines: option<bool>=?,
  ~removeHorizontalLines=false,
  ~evenVertivalLines=false,
  ~showPagination=true,
  ~downloadCsv=?,
  ~ignoreUrlUpdate=false,
  ~hideTitle=false,
  ~ignoreHeaderBg=false,
  ~tableDataLoading=false,
  ~dataLoading=false,
  ~advancedSearchComponent=?,
  ~setData=?,
  ~setSummary=?,
  ~customGetObjects: option<Js.Json.t => array<'a>>=?,
  ~dataNotFoundComponent=?,
  ~renderCard=?,
  ~tableLocalFilter=false,
  ~tableheadingClass="",
  ~tableBorderClass="",
  ~tableDataBorderClass="",
  ~collapseTableRow=false,
  ~getRowDetails=?,
  ~onMouseEnter=?,
  ~onMouseLeave=?,
  ~frozenUpto=?,
  ~heightHeadingClass=?,
  ~highlightText="",
  ~enableEqualWidthCol=false,
  ~clearFormatting=false,
  ~rowHeightClass="",
  ~allowNullableRows=false,
  ~titleTooltip=false,
  ~isAnalyticsModule=false,
  ~rowCustomClass="",
  ~isHighchartLegend=false,
  ~filterObj=?,
  ~setFilterObj=?,
  ~headingCenter=false,
  ~filterIcon=?,
  ~filterDropdownClass=?,
  ~maxTableHeight="",
  ~showTableOnMobileView=false,
  ~labelMargin="",
  ~customFilterRowStyle="",
  ~noDataMsg="No Data Available",
  ~tableActionBorder="",
  ~isEllipsisTextRelative=true,
  ~customMoneyStyle="",
  ~ellipseClass="",
  ~checkBoxProps: checkBoxProps=checkBoxPropDefaultVal,
  ~selectedRowColor=?,
  ~paginationClass="",
  ~lastHeadingClass="",
  ~lastColClass="",
  ~fixLastCol=false,
  ~headerCustomBgColor=?,
  ~alignCellContent=?,
  ~minTableHeightClass="",
  ~setExtFilteredDataLength=?,
  ~filterDropdownMaxHeight=?,
  ~showResultsPerPageSelector=true,
  ~customCellColor=?,
  ~defaultResultsPerPage=true,
  ~noScrollbar=false,
  ~tableDataBackgroundClass="",
  ~customBorderClass=?,
  ~showborderColor=?,
  ~tableHeadingTextClass="",
) => {
  let showPopUp = PopUpState.useShowPopUp()
  React.useEffect0(_ => {
    if title === "" && GlobalVars.isLocalhost {
      showPopUp({
        popUpType: (Denied, WithIcon),
        heading: `Title cannot be empty!`,
        description: React.string(`Please put valid title and use hideTitle prop to hide the title as offset recoil uses title`),
        handleConfirm: {text: "OK"},
      })
    }
    None
  })
  let resultsPerPage =
    resultsPerPage > 10 ? defaultResultsPerPage ? 10 : resultsPerPage : resultsPerPage
  let customizeColumnNewTheme = None
  let defaultValue: pageDetails = {offset, resultsPerPage}
  let (firstRender, setFirstRender) = React.useState(_ => true)
  let setPageDetails = Recoil.useSetRecoilState(table_pageDetails)
  let pageDetailDict = Recoil.useRecoilValueFromAtom(table_pageDetails)
  let pageDetail = pageDetailDict->Dict.get(title)->Belt.Option.getWithDefault(defaultValue)

  let (
    selectAllCheckBox: option<TableUtils.multipleSelectRows>,
    setSelectAllCheckBox,
  ) = React.useState(_ => None)

  let newSetOffset = offsetVal => {
    let value = switch pageDetailDict->Dict.get(title) {
    | Some(val) => {offset: offsetVal(0), resultsPerPage: val.resultsPerPage}

    | None => {offset: offsetVal(0), resultsPerPage: defaultValue.resultsPerPage}
    }

    let newDict = pageDetailDict->Dict.toArray->Dict.fromArray

    newDict->Dict.set(title, value)
    setOffset(_ => offsetVal(0))
    setPageDetails(._ => newDict)
  }
  let url = RescriptReactRouter.useUrl()

  React.useEffect1(_ => {
    setFirstRender(_ => false)
    setOffset(_ => pageDetail.offset)
    None
  }, [url.path->Belt.List.toArray->Array.joinWith("/")])

  React.useEffect1(_ => {
    if pageDetail.offset !== offset && !firstRender {
      let value = switch pageDetailDict->Dict.get(title) {
      | Some(val) => {offset, resultsPerPage: val.resultsPerPage}
      | None => {offset, resultsPerPage: defaultValue.resultsPerPage}
      }

      let newDict = pageDetailDict->Dict.toArray->Dict.fromArray
      newDict->Dict.set(title, value)
      setPageDetails(._ => newDict)
    }
    None
  }, [offset])

  let setLocalResultsPerPageOrig = localResultsPerPage => {
    let value = switch pageDetailDict->Dict.get(title) {
    | Some(val) =>
      if totalResults > val.offset || tableDataLoading {
        {offset: val.offset, resultsPerPage: localResultsPerPage(0)}
      } else {
        {offset: 0, resultsPerPage}
      }
    | None => {offset: defaultValue.offset, resultsPerPage: localResultsPerPage(0)}
    }
    let newDict = pageDetailDict->Dict.toArray->Dict.fromArray

    newDict->Dict.set(title, value)
    setPageDetails(._ => newDict)
  }

  let (columnFilter, setColumnFilterOrig) = React.useState(_ => Dict.make())
  let isMobileView = MatchMedia.useMobileChecker()
  let url = RescriptReactRouter.useUrl()
  let dateFormatConvertor = useDateFormatConvertor()
  let (dataView, setDataView) = React.useState(_ =>
    isMobileView && !showTableOnMobileView ? Card : Table
  )

  let localResultsPerPage = pageDetail.resultsPerPage

  let setColumnFilter = React.useMemo1(() => {
    (filterKey, filterValue: array<Js.Json.t>) => {
      setColumnFilterOrig(oldFitlers => {
        let newObj = oldFitlers->Dict.toArray->Dict.fromArray
        let filterValue = filterValue->Array.filter(
          item => {
            let updatedItem = item->Js.String.make
            updatedItem !== ""
          },
        )
        if filterValue->Array.length === 0 {
          newObj
          ->Dict.toArray
          ->Array.filter(
            entry => {
              let (key, _value) = entry
              key !== filterKey
            },
          )
          ->Dict.fromArray
        } else {
          Dict.set(newObj, filterKey, filterValue)
          newObj
        }
      })
    }
  }, [setColumnFilterOrig])

  React.useEffect1(_ => {
    if columnFilter != Dict.make() {
      newSetOffset(_ => 0)
    }
    None
  }, [columnFilter])

  let filterValue = React.useMemo2(() => {
    (columnFilter, setColumnFilter)
  }, (columnFilter, setColumnFilter))

  let (isFilterOpen, setIsFilterOpenOrig) = React.useState(_ => Dict.make())
  let setIsFilterOpen = React.useMemo1(() => {
    (filterKey, value: bool) => {
      setIsFilterOpenOrig(oldFitlers => {
        let newObj = oldFitlers->DictionaryUtils.copyOfDict
        newObj->Dict.set(filterKey, value)
        newObj
      })
    }
  }, [setColumnFilterOrig])
  let filterOpenValue = React.useMemo2(() => {
    (isFilterOpen, setIsFilterOpen)
  }, (isFilterOpen, setIsFilterOpen))

  let heading =
    visibleColumns->Belt.Option.getWithDefault(entity.defaultColumns)->Array.map(entity.getHeading)

  let handleRemoveLines = removeVerticalLines->Belt.Option.getWithDefault(true)
  if showSerialNumber {
    heading
    ->Array.unshift(
      Table.makeHeaderInfo(~key="serial_number", ~title="S.No", ~dataType=NumericType, ()),
    )
    ->ignore
  }

  if checkBoxProps.showCheckBox {
    heading
    ->Array.unshift(
      Table.makeHeaderInfo(~key="select", ~title="", ~showMultiSelectCheckBox=true, ()),
    )
    ->ignore
  }

  let setLocalResultsPerPage = React.useCallback1(fn => {
    setLocalResultsPerPageOrig(prev => {
      let newVal = prev->fn
      if newVal == 0 {
        localResultsPerPage
      } else {
        newVal
      }
    })
  }, [setLocalResultsPerPageOrig])

  let {getShowLink, searchFields, searchUrl, getObjects} = entity
  let (sortedObj, setSortedObj) = useSortedObj(title, defaultSort)

  React.useEffect1(() => {
    setDataView(_prev => isMobileView && !showTableOnMobileView ? Card : Table)
    None
  }, [isMobileView])

  let defaultOffset = totalResults / localResultsPerPage * localResultsPerPage

  let offsetVal = offset < totalResults ? offset : defaultOffset
  let offsetVal = ignoreUrlUpdate ? offset : offsetVal

  React.useEffect4(() => {
    if offset > currrentFetchCount && offset <= totalResults && !tableDataLoading {
      switch handleRefetch {
      | Some(fun) => fun()
      | None => ()
      }
    }
    None
  }, (offset, currrentFetchCount, totalResults, tableDataLoading))

  let originalActualData = actualData
  let actualData = React.useMemo5(() => {
    if tableLocalFilter {
      filteredData(actualData, columnFilter, visibleColumns, entity, dateFormatConvertor)
    } else {
      actualData
    }
  }, (actualData, columnFilter, visibleColumns, entity, dateFormatConvertor))

  let columnFilterRow = React.useMemo4(() => {
    if tableLocalFilter {
      let columnFilterRow =
        visibleColumns
        ->Belt.Option.getWithDefault(entity.defaultColumns)
        ->Array.map(item => {
          let headingEntity = entity.getHeading(item)
          let key = headingEntity.key
          let dataType = headingEntity.dataType
          let filterValueArray = []
          let columnFilterCopy = columnFilter->DictionaryUtils.deleteKey(key)

          let actualData =
            columnFilter->Dict.keysToArray->Array.includes(headingEntity.key)
              ? originalActualData
              : actualData

          actualData
          ->filteredData(columnFilterCopy, visibleColumns, entity, dateFormatConvertor)
          ->Belt.Array.forEach(
            rows => {
              switch rows->Js.Nullable.toOption {
              | Some(rows) =>
                let value = switch entity.getCell(rows, item) {
                | CustomCell(_, str)
                | EllipsisText(str, _)
                | Link(str)
                | Date(str)
                | DateWithoutTime(str)
                | Text(str) =>
                  convertStrCellToFloat(dataType, str)
                | Label(x)
                | ColoredText(x) =>
                  convertStrCellToFloat(dataType, x.title)
                | DeltaPercentage(num, _) | Currency(num, _) | Numeric(num, _) =>
                  convertFloatCellToStr(dataType, num)
                | Progress(num) => convertFloatCellToStr(dataType, num->Js.Int.toFloat)
                | StartEndDate(_) | InputField(_) | TrimmedText(_) | DropDown(_) =>
                  convertStrCellToFloat(dataType, "")
                }
                filterValueArray->Array.push(value)->ignore
              | None => ()
              }
            },
          )

          switch dataType {
          | DropDown => Table.DropDownFilter(key, filterValueArray) // TextDropDownColumn
          | LabelType | TextType => Table.TextFilter(key)
          | MoneyType | NumericType | ProgressType => {
              let newArr =
                filterValueArray->Array.map(
                  item => item->Js.Json.decodeNumber->Belt.Option.getWithDefault(0.),
                )

              if newArr->Array.length >= 1 {
                Table.Range(key, Js.Math.minMany_float(newArr), Js.Math.maxMany_float(newArr))
              } else {
                Table.Range(key, 0.0, 0.0)
              }
            }
          }
        })

      Some(
        showSerialNumber && tableLocalFilter
          ? Array.concat(
              [Table.Range("s_no", 0., actualData->Array.length->Belt.Int.toFloat)],
              columnFilterRow,
            )
          : columnFilterRow,
      )
    } else {
      None
    }
  }, (actualData, totalResults, visibleColumns, columnFilter))

  let filteredDataLength =
    columnFilter->Dict.keysToArray->Array.length !== 0 ? actualData->Array.length : totalResults

  React.useEffect1(() => {
    switch setExtFilteredDataLength {
    | Some(fn) => fn(_ => filteredDataLength)
    | _ => ()
    }
    None
  }, [filteredDataLength])

  let filteredData = React.useMemo4(() => {
    switch sortedObj {
    | Some(obj: Table.sortedObject) => sortArray(actualData, obj.key, obj.order)
    | None => actualData
    }
  }, (sortedObj, customGetObjects, actualData, getObjects))

  React.useEffect2(() => {
    let selectedRowDataLength = checkBoxProps.selectedData->Array.length
    let isCompleteDataSelected = selectedRowDataLength === filteredData->Array.length
    if isCompleteDataSelected {
      setSelectAllCheckBox(_ => Some(ALL))
    } else if checkBoxProps.selectedData->Array.length === 0 {
      setSelectAllCheckBox(_ => None)
    } else {
      setSelectAllCheckBox(_ => Some(PARTIAL))
    }

    None
  }, (checkBoxProps.selectedData, filteredData))

  React.useEffect1(() => {
    if selectAllCheckBox === Some(ALL) {
      checkBoxProps.setSelectedData(_ => {
        filteredData->Array.map(
          ele => {
            ele->toJson
          },
        )
      })
    } else if selectAllCheckBox === None {
      checkBoxProps.setSelectedData(_ => [])
    }
    None
  }, [selectAllCheckBox])

  let sNoArr = Dict.get(columnFilter, "s_no")->Belt.Option.getWithDefault([])
  // filtering for SNO
  let nullableRows = filteredData->Array.mapWithIndex((nullableItem, index) => {
    let actualRows = switch nullableItem->Js.Nullable.toOption {
    | Some(item) => {
        let visibleCell =
          visibleColumns
          ->Belt.Option.getWithDefault(entity.defaultColumns)
          ->Array.map(colType => {
            entity.getCell(item, colType)
          })
        let startPoint = sNoArr->Belt.Array.get(0)->Belt.Option.getWithDefault(1.->Js.Json.number)
        let endPoint = sNoArr->Belt.Array.get(1)->Belt.Option.getWithDefault(1.->Js.Json.number)
        let jsonIndex = (index + 1)->Belt.Int.toFloat->Js.Json.number
        sNoArr->Array.length > 0
          ? {
              startPoint <= jsonIndex && endPoint >= jsonIndex ? visibleCell : []
            }
          : visibleCell
      }

    | None => []
    }

    let setIsSelected = isSelected => {
      if isSelected {
        checkBoxProps.setSelectedData(prev => prev->Array.concat([nullableItem->toJson]))
      } else {
        checkBoxProps.setSelectedData(prev =>
          prev->Array.filter(item => item !== nullableItem->toJson)
        )
      }
    }

    if actualRows->Array.length > 0 {
      if showSerialNumber {
        actualRows
        ->Array.unshift(
          Numeric(
            (1 + index)->Belt.Int.toFloat,
            (val: float) => {
              val->Belt.Float.toString
            },
          ),
        )
        ->ignore
      }
      if checkBoxProps.showCheckBox {
        let selectedRowIndex =
          checkBoxProps.selectedData->Array.findIndex(item => item === nullableItem->toJson)
        actualRows
        ->Array.unshift(
          CustomCell(
            <div onClick={ev => ev->ReactEvent.Mouse.stopPropagation}>
              <CheckBoxIcon
                isSelected={selectedRowIndex !== -1} setIsSelected checkboxDimension="h-4 w-4"
              />
            </div>,
            (selectedRowIndex !== -1)->LogicUtils.getStringFromBool,
          ),
        )
        ->ignore
      }
    }

    actualRows
  })

  let rows = if allowNullableRows {
    nullableRows
  } else {
    nullableRows->Belt.Array.keepMap(item => {
      item->Array.length == 0 ? None : Some(item)
    })
  }

  let dataExists = rows->Array.length > 0
  let heading = heading->Array.mapWithIndex((head, index) => {
    let getValue = row =>
      row->Belt.Array.get(index)->Belt.Option.mapWithDefault("", Table.getTableCellValue)

    let default = switch rows[0] {
    | Some(ele) => getValue(ele)
    | None => ""
    }
    let head: Table.header = {
      ...head,
      showSort: head.showSort &&
      dataExists && (
        totalResults == Array.length(rows)
          ? rows->Array.some(row => getValue(row) !== default)
          : true
      ),
    }
    head
  })

  let paginatedData =
    filteredData->Array.slice(~start=offsetVal, ~end={offsetVal + localResultsPerPage})
  let rows = rows->Array.slice(~start=offsetVal, ~end={offsetVal + localResultsPerPage})

  let handleRowClick = React.useCallback4(index => {
    let actualVal = switch filteredData[index] {
    | Some(ele) => ele->Js.Nullable.toOption
    | None => None
    }
    switch actualVal {
    | Some(value) =>
      switch onEntityClick {
      | Some(fn) => fn(value)
      | None =>
        switch getShowLink {
        | Some(fn) => {
            let link = fn(value)
            let finalUrl = url.search->String.length > 0 ? `${link}?${url.search}` : link
            RescriptReactRouter.push(finalUrl)
          }

        | None => ()
        }
      }
    | None => ()
    }
  }, (filteredData, getShowLink, onEntityClick, url.search))

  let onRowDoubleClick = React.useCallback4(index => {
    let actualVal = switch filteredData[index] {
    | Some(ele) => ele->Js.Nullable.toOption
    | None => None
    }
    switch actualVal {
    | Some(value) =>
      switch onEntityDoubleClick {
      | Some(fn) => fn(value)
      | None =>
        switch getShowLink {
        | Some(fn) => {
            let link = fn(value)
            let finalUrl = url.search->String.length > 0 ? `${link}?${url.search}` : link
            RescriptReactRouter.push(finalUrl)
          }

        | None => ()
        }
      }
    | None => ()
    }
  }, (filteredData, getShowLink, onEntityDoubleClick, url.search))

  let handleMouseEnter = React.useCallback4(index => {
    let actualVal = switch filteredData[index] {
    | Some(ele) => ele->Js.Nullable.toOption
    | None => None
    }
    switch actualVal {
    | Some(value) =>
      switch onMouseEnter {
      | Some(fn) => fn(value)
      | None => ()
      }
    | None => ()
    }
  }, (filteredData, getShowLink, onMouseEnter, url.search))

  let handleMouseLeaeve = React.useCallback4(index => {
    let actualVal = switch filteredData[index] {
    | Some(ele) => ele->Js.Nullable.toOption
    | None => None
    }
    switch actualVal {
    | Some(value) =>
      switch onMouseLeave {
      | Some(fn) => fn(value)
      | None => ()
      }
    | None => ()
    }
  }, (filteredData, getShowLink, onMouseLeave, url.search))

  let (loadedTableUI, paginationUI) = if totalResults > 0 {
    let paginationUI = if showPagination {
      <AddDataAttributes attributes=[("data-paginator", "dynamicTablePaginator")]>
        <Paginator
          totalResults=filteredDataLength
          offset=offsetVal
          resultsPerPage=localResultsPerPage
          setOffset=newSetOffset
          ?handleRefetch
          currrentFetchCount
          ?downloadCsv
          actualData
          tableDataLoading
          setResultsPerPage=setLocalResultsPerPage
          paginationClass
          showResultsPerPageSelector
        />
      </AddDataAttributes>
    } else {
      React.null
    }
    let isMinHeightRequired =
      noScrollbar || (tableLocalFilter && rows->Array.length <= 5 && frozenUpto->Belt.Option.isNone)

    let scrollBarClass =
      isFilterOpen->Dict.valuesToArray->Array.reduce(false, (acc, item) => item || acc)
        ? ""
        : `${isMinHeightRequired ? noScrollbar ? "" : "overflow-x-scroll" : "overflow-scroll"}`
    let loadedTable =
      <div className={`no-scrollbar ${scrollBarClass}`}>
        {switch dataView {
        | Table => {
            let children =
              <Table
                title
                heading
                rows
                ?filterObj
                ?setFilterObj
                onRowClick=handleRowClick
                onRowDoubleClick
                onRowClickPresent={onEntityClick->Belt.Option.isSome ||
                  getShowLink->Belt.Option.isSome}
                offset=offsetVal
                setSortedObj
                ?sortedObj
                removeVerticalLines=handleRemoveLines
                evenVertivalLines
                ?columnFilterRow
                tableheadingClass
                tableBorderClass
                tableDataBorderClass
                enableEqualWidthCol
                collapseTableRow
                ?getRowDetails
                ?onExpandClickData
                actualData
                onMouseEnter=handleMouseEnter
                onMouseLeave=handleMouseLeaeve
                highlightText
                clearFormatting
                ?heightHeadingClass
                ?frozenUpto
                rowHeightClass
                isMinHeightRequired
                rowCustomClass
                isHighchartLegend
                headingCenter
                ?filterIcon
                ?filterDropdownClass
                maxTableHeight
                labelMargin
                customFilterRowStyle
                ?selectAllCheckBox
                setSelectAllCheckBox
                isEllipsisTextRelative
                customMoneyStyle
                ellipseClass
                ?selectedRowColor
                lastHeadingClass
                showCheckbox={checkBoxProps.showCheckBox}
                lastColClass
                fixLastCol
                ?headerCustomBgColor
                ?alignCellContent
                ?customCellColor
                minTableHeightClass
                ?filterDropdownMaxHeight
                ?customizeColumnNewTheme
                removeHorizontalLines
                ?customBorderClass
                ?showborderColor
                tableHeadingTextClass
              />
            switch tableLocalFilter {
            | true =>
              <DatatableContext value={filterValue}>
                <DataTableFilterOpenContext value={filterOpenValue}>
                  children
                </DataTableFilterOpenContext>
              </DatatableContext>
            | false => children
            }
          }

        | Card =>
          switch renderCard {
          | Some(renderer) =>
            <div className="overflow-auto flex flex-col">
              {paginatedData
              ->Belt.Array.keepMap(Js.Nullable.toOption)
              ->Array.mapWithIndex((item, rowIndex) => {
                renderer(~index={rowIndex + offset}, ~item, ~onRowClick=handleRowClick)
              })
              ->React.array}
            </div>
          | None =>
            <CardTable heading rows onRowClick=handleRowClick offset=offsetVal isAnalyticsModule />
          }
        }}
      </div>

    (loadedTable, paginationUI)
  } else if totalResults === 0 && !tableDataLoading {
    let noDataTable = switch dataNotFoundComponent {
    | Some(comp) => comp
    | None => <NoDataFound customCssClass={"my-6"} message=noDataMsg renderType=Painting />
    }
    (noDataTable, React.null)
  } else {
    (React.null, React.null)
  }

  let tableActionBorder = if !isMobileView {
    if showFilterBorder {
      "p-2 bg-white dark:bg-black border border-jp-2-light-gray-400 rounded-lg"
    } else {
      ""
    }
  } else {
    tableActionBorder
  }
  let filterBottomPadding = isMobileView ? "" : "pb-3"
  let filtersOuterMargin = if hideTitle {
    ""
  } else {
    "my-2"
  }

  let tableActionElements =
    <div className="flex flex-row">
      {switch advancedSearchComponent {
      | Some(x) =>
        <AdvancedSearchComponent entity ?setData ?setSummary> {x} </AdvancedSearchComponent>
      | None =>
        <UIUtils.RenderIf condition={searchFields->Array.length > 0}>
          <AdvancedSearchModal searchFields url=searchUrl entity />
          // <PaymentLinkAdvancedSearch searchFields url=searchUrl />
        </UIUtils.RenderIf>
      }}
      <DesktopView>
        {switch tableActions {
        | Some(actions) =>
          <LoadedTableContext value={actualData->LoadedTableContext.toInfoData}>
            <div className=filterBottomPadding> actions </div>
          </LoadedTableContext>
        | None => React.null
        }}
      </DesktopView>
    </div>

  let customizeColumsButtons =
    <div className=filterBottomPadding>
      {switch clearFormattedDataButton {
      | Some(clearFormattedDataButton) =>
        <div className={`flex flex-row mobile:gap-7 desktop:gap-10`}>
          clearFormattedDataButton
          <Portal to={""}> rightTitleElement </Portal>
        </div>
      | _ => <Portal to={""}> rightTitleElement </Portal>
      }}
    </div>

  let addDataAttributesClass = if isHighchartLegend {
    `visibility: hidden`
  } else {
    `${ignoreHeaderBg ? "" : backgroundClass} empty:hidden`
  }
  let dataId = title->Js.String2.split("-")->Belt.Array.get(0)->Belt.Option.getWithDefault("")
  <AddDataAttributes attributes=[("data-loaded-table", dataId)]>
    <div className="w-full">
      <div className=addDataAttributesClass style={ReactDOMStyle.make(~zIndex="2", ())}>
        //removed "sticky" -> to be tested with master

        <div
          className={`flex flex-row justify-between items-center` ++ (
            hideTitle ? "" : ` mt-4 mb-2`
          )}>
          <div className="w-full">
            <UIUtils.RenderIf condition={!hideTitle}>
              <NewThemeHeading
                heading=title
                headingSize=titleSize
                outerMargin=""
                ?description
                rightActions={<UIUtils.RenderIf
                  condition={!isMobileView && !isTableActionBesideFilters}>
                  {tableActionElements}
                </UIUtils.RenderIf>}
              />
            </UIUtils.RenderIf>
          </div>
        </div>
        <UIUtils.RenderIf condition={!hideFilterTopPortals}>
          <div className="flex justify-between items-center">
            <PortalCapture
              key={`tableFilterTopLeft-${title}`}
              name={`tableFilterTopLeft-${title}`}
              customStyle="flex items-center gap-x-2"
            />
            <PortalCapture
              key={`tableFilterTopRight-${title}`}
              name={`tableFilterTopRight-${title}`}
              customStyle="flex flex-row-reverse items-center gap-x-2"
            />
          </div>
        </UIUtils.RenderIf>
        <div
          className={`flex flex-row mobile:flex-wrap items-center ${tableActionBorder} ${filtersOuterMargin}`}>
          <TableFilterSectionContext isFilterSection=true>
            <div className={`flex-1 ${tableDataBackgroundClass}`}>
              {switch filters {
              | Some(filterSection) =>
                filterSection->React.Children.map(element => {
                  if element === React.null {
                    React.null
                  } else {
                    <div className=filterBottomPadding> element </div>
                  }
                })

              | None => React.null
              }}
              <PortalCapture key={`extraFilters-${title}`} name={`extraFilters-${title}`} />
            </div>
          </TableFilterSectionContext>
          <UIUtils.RenderIf condition={isTableActionBesideFilters || isMobileView || hideTitle}>
            {tableActionElements}
          </UIUtils.RenderIf>
          customizeColumsButtons
        </div>
      </div>
      {if dataLoading {
        <TableDataLoadingIndicator showWithData={rows->Array.length !== 0} />
      } else {
        loadedTableUI
      }}
      <UIUtils.RenderIf condition={tableDataLoading && !dataLoading}>
        <TableDataLoadingIndicator showWithData={rows->Array.length !== 0} />
      </UIUtils.RenderIf>
      <div
        className={`${tableActions->Js.Option.isSome && isMobileView
            ? `flex flex-row-reverse justify-between mb-10 ${tableDataBackgroundClass}`
            : tableDataBackgroundClass}`}>
        paginationUI
        {
          let topBottomActions = if bottomActions->Js.Option.isSome || !isMobileView {
            bottomActions
          } else {
            tableActions
          }

          switch topBottomActions {
          | Some(actions) =>
            <LoadedTableContext value={actualData->LoadedTableContext.toInfoData}>
              actions
            </LoadedTableContext>

          | None => React.null
          }
        }
      </div>
    </div>
  </AddDataAttributes>
}
