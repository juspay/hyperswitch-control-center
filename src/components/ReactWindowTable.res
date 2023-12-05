open TableUtils
external toJson: Js.Nullable.t<'a> => Js.Json.t = "%identity"
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
module FilterRow = {
  @react.component
  let make = (
    ~item: filterRow,
    ~hideFilter,
    ~removeVerticalLines,
    ~tableDataBorderClass,
    ~isLast,
    ~cellIndex,
    ~cellWidth,
  ) => {
    <div
      className={`flex flex-row group h-full border-t dark:border-jp-gray-960 ${cellWidth} bg-white dark:bg-jp-gray-lightgray_background hover:bg-jp-gray-table_hover dark:hover:bg-jp-gray-100 dark:hover:bg-opacity-10 transition duration-300 ease-in-out text-fs-13 text-jp-gray-900 text-opacity-75 dark:text-jp-gray-text_darktheme dark:text-opacity-75`}>
      {
        let paddingClass = "py-3 px-3"

        let borderClass = if isLast {
          ` border-jp-gray-light_table_border_color dark:border-jp-gray-960`
        } else if removeVerticalLines {
          ` border-jp-gray-light_table_border_color dark:border-jp-gray-960`
        } else {
          ` border-r border-jp-gray-light_table_border_color dark:border-jp-gray-960`
        }

        {
          if hideFilter {
            React.null
          } else {
            <div
              key={string_of_int(cellIndex)}
              className={`h-full p-0 align-top ${borderClass} ${tableDataBorderClass} ${cellWidth}`}>
              <div className={`h-full box-border ${paddingClass}`}>
                <TableFilterCell cell=item />
              </div>
            </div>
          }
        }
      }
    </div>
  }
}
module NewCell = {
  @react.component
  let make = (
    ~item: array<cell>,
    ~rowIndex,
    ~onRowClick,
    ~onRowClickPresent,
    ~removeVerticalLines,
    ~highlightEnabledFieldsArray,
    ~tableDataBorderClass="",
    ~collapseTableRow=false,
    ~expandedRow: _ => React.element,
    ~onMouseEnter,
    ~onMouseLeave,
    ~style,
    ~setExpandedIndexArr,
    ~expandedIndexArr,
    ~handleExpand,
    ~highlightText="",
    ~columnWidthArr,
    ~showSerialNumber=false,
    ~customSerialNoColumn=false,
    ~customCellColor="",
    ~showCheckBox=false,
  ) => {
    open Window

    let onClick = React.useCallback2(_ev => {
      let isRangeSelected = getSelection().\"type" == "Range"
      switch (onRowClick, isRangeSelected) {
      | (Some(fn), false) => fn(rowIndex)
      | _ => ()
      }
    }, (onRowClick, rowIndex))

    let isCurrentRowExpanded = React.useMemo1(() => {
      expandedIndexArr->Js.Array2.includes(rowIndex)
    }, [expandedIndexArr])

    let onMouseEnter = React.useCallback2(_ev => {
      switch onMouseEnter {
      | Some(fn) => fn(rowIndex)
      | _ => ()
      }
    }, (onMouseEnter, rowIndex))

    let onMouseLeave = React.useCallback2(_ev => {
      switch onMouseLeave {
      | Some(fn) => fn(rowIndex)
      | _ => ()
      }
    }, (onMouseLeave, rowIndex))
    let colsLen = item->Js.Array2.length
    let cursorClass = onRowClickPresent ? "cursor-pointer" : ""

    let customcellColouredCellCheck =
      item
      ->Js.Array2.map((obj: cell) => {
        switch obj {
        | CustomCell(_, x) => x->Js.String2.split(",")->Js.Array2.includes("true")
        | _ => false
        }
      })
      ->Js.Array2.includes(true)

    let customcellColouredCell =
      customcellColouredCellCheck && customCellColor !== ""
        ? customCellColor
        : "bg-white hover:bg-jp-gray-table_hover dark:hover:bg-jp-gray-850"

    <div
      className={`h-full ${customcellColouredCell} border-t border-jp-gray-light_table_border_color dark:border-jp-gray-960 dark:bg-jp-gray-lightgray_background transition duration-300 ease-in-out `}
      style>
      <div
        className={`flex flex-row group rounded-md ${cursorClass}  text-fs-13 text-jp-gray-900 dark:text-jp-gray-text_darktheme dark:text-opacity-75 overflow-hidden break-words`}
        onClick
        onMouseEnter
        onMouseLeave>
        {item
        ->Js.Array2.mapi((obj: cell, cellIndex) => {
          let cellWidth = if cellIndex === colsLen - 1 {
            "w-full"
          } else if (
            (showCheckBox && cellIndex === 0) ||
            showSerialNumber && cellIndex === 0 ||
            (showSerialNumber && showCheckBox && cellIndex === 1)
          ) {
            "w-24"
          } else {
            columnWidthArr
            ->Belt.Array.get(cellIndex)
            ->Belt.Option.getWithDefault(
              `${cellIndex === 0 && customSerialNoColumn ? "w-24" : "w-64"}`,
            )
          }

          let overflowStyle = cellIndex === colsLen ? "overflow-hidden" : ""

          let isLast = cellIndex === colsLen - 1

          let paddingClass = switch obj {
          | Link(_) => "pt-2"
          | _ => "py-3"
          }

          let highlightCell = highlightEnabledFieldsArray->Js.Array2.includes(cellIndex)

          let borderClass = if isLast || removeVerticalLines {
            `border-jp-gray-light_table_border_color dark:border-jp-gray-960`
          } else {
            `border-r border-jp-gray-light_table_border_color dark:border-jp-gray-960`
          }
          let cursorI = cellIndex == 0 ? "cursor-pointer" : ""

          <div
            key={string_of_int(cellIndex)}
            className={`${cellWidth} ${overflowStyle}  h-auto align-top ${borderClass}  ${highlightCell
                ? "hover:font-bold"
                : ""} ${tableDataBorderClass} 
                ${collapseTableRow ? cursorI : ""}`}
            onClick={_ => {
              if collapseTableRow && cellIndex == 0 {
                handleExpand(rowIndex, true)
                if !isCurrentRowExpanded {
                  setExpandedIndexArr(prev => {
                    prev->Js.Array2.concat([rowIndex])
                  })
                } else {
                  setExpandedIndexArr(prev => {
                    prev->Js.Array2.filter(item => item != rowIndex)
                  })
                }
              }
            }}>
            <div className={`${cellWidth} h-full box-border pl-4 ${paddingClass}`}>
              {if collapseTableRow {
                <div className="flex flex-row gap-4 items-center">
                  {if cellIndex === 0 {
                    <Icon name={isCurrentRowExpanded ? "caret-down" : "caret-right"} size=14 />
                  } else {
                    React.null
                  }}
                  <TableCell cell=obj highlightText hideShowMore=true />
                </div>
              } else {
                <TableCell cell=obj highlightText />
              }}
            </div>
          </div>
        })
        ->React.array}
      </div>
      {if isCurrentRowExpanded {
        <div className="dark:border-jp-gray-dark_disable_border_color ml-10"> {expandedRow()} </div>
      } else {
        React.null
      }}
    </div>
  }
}
module ReactWindowTableComponent = {
  @react.component
  let make = (
    ~heading=[],
    ~rows,
    ~onRowClick=?,
    ~onRowClickPresent=false,
    ~fullWidth,
    ~removeVerticalLines=true,
    ~showScrollBar=false,
    ~setSortedObj=?,
    ~sortedObj=?,
    ~columnFilterRow=?,
    ~tableheadingClass="",
    ~tableBorderClass="",
    ~tableDataBorderClass="",
    ~collapseTableRow=false,
    ~getRowDetails=?,
    ~getIndex=?,
    ~rowItemHeight=100,
    ~selectAllCheckBox=?,
    ~setSelectAllCheckBox=?,
    ~actualData=?,
    ~onMouseEnter=?,
    ~onMouseLeave=?,
    ~highlightText="",
    ~tableHeight,
    ~columnWidth,
    ~showSerialNumber=false,
    ~customSerialNoColumn=false,
    ~customCellColor="",
    ~showCheckBox=false,
  ) => {
    let actualData: option<Js.Array2.t<Js.Nullable.t<'t>>> = actualData

    let getRowDetails = (rowIndex: int) => {
      switch actualData {
      | Some(actualData) =>
        switch getRowDetails {
        | Some(fn) =>
          fn(actualData->Belt.Array.get(rowIndex)->Belt.Option.getWithDefault(Js.Nullable.null))
        | None => React.null
        }
      | None => React.null
      }
    }
    let getIndex = (rowIndex: int) => {
      switch getIndex {
      | Some(fn) => fn(rowIndex)
      | None => ()
      }
    }

    let fn = React.useRef((_, _) => ())
    let rowInfo: array<array<cell>> = rows
    let (expandedIndexArr, setExpandedIndexArr) = React.useState(_ => [])
    let handleExpand = (index, bool) => fn.current(index, bool)

    React.useEffect1(() => {
      setExpandedIndexArr(_ => [])
      handleExpand(0, true)
      None
    }, [rowInfo->Js.Array2.length])

    let headingsLen = heading->Js.Array2.length

    let widthClass = if fullWidth {
      "min-w-full"
    } else {
      ""
    }
    let scrollBarClass = if showScrollBar {
      "show-scrollbar"
    } else {
      "no-scrollbar"
    }

    let filterPresent = heading->Js.Array2.find(head => head.showFilter)->Js.Option.isSome
    let highlightEnabledFieldsArray = heading->Js.Array2.reducei((acc, item, index) => {
      if item.highlightCellOnHover {
        let _ = Js.Array2.push(acc, index)
      }
      acc
    }, [])
    let colFilt = columnFilterRow->Belt.Option.getWithDefault([])
    let colFilter = showCheckBox ? [TextFilter("")]->Js.Array2.concat(colFilt) : colFilt
    let arr = switch columnWidth {
    | Some(arr) => arr
    | _ =>
      heading->Js.Array2.mapi((_, i) => {
        i === 0 && customSerialNoColumn ? "w-24" : "w-64"
      })
    }

    let headingReact = if heading->Js.Array2.length !== 0 {
      <div className="sticky z-10 top-0 ">
        <div className="flex flex-row">
          {heading
          ->Js.Array2.mapi((item, i) => {
            let isFirstCol = i === 0
            let isLastCol = i === headingsLen - 1
            let cellWidth = if i === heading->Js.Array2.length - 1 {
              "w-full"
            } else if (
              (showCheckBox && i === 0) ||
              showSerialNumber && i === 0 ||
              (showSerialNumber && showCheckBox && i === 1)
            ) {
              "w-24"
            } else {
              arr
              ->Belt.Array.get(i)
              ->Belt.Option.getWithDefault(
                `${isFirstCol && customSerialNoColumn ? "w-24" : "w-64"}`,
              )
            }

            let roundedClass = if isFirstCol {
              "rounded-tl"
            } else if isLastCol {
              "rounded-tr"
            } else {
              ""
            }
            let borderClass = if isLastCol {
              ""
            } else if removeVerticalLines {
              "border-jp-gray-500 dark:border-jp-gray-960"
            } else {
              "border-r border-jp-gray-500 dark:border-jp-gray-960"
            }
            let (isAllSelected, isSelectedStateMinus, checkboxDimension) = (
              selectAllCheckBox->Belt.Option.isSome,
              selectAllCheckBox === Some(PARTIAL),
              "h-4 w-4",
            )

            let setIsSelected = isAllSelected => {
              switch setSelectAllCheckBox {
              | Some(fn) =>
                fn(_ => {
                  if isAllSelected {
                    Some(ALL)
                  } else {
                    None
                  }
                })
              | None => ()
              }
            }

            <div
              key={string_of_int(i)}
              className={` ${cellWidth} ${borderClass} justify-between items-center  bg-white dark:bg-jp-gray-darkgray_background text-opacity-75 dark:text-jp-gray-text_darktheme dark:text-opacity-75 whitespace-pre select-none ${roundedClass} ${tableheadingClass}`}>
              <div
                className={`flex flex-row ${cellWidth} pl-2 py-4 bg-gradient-to-b from-jp-gray-450 to-jp-gray-350 dark:from-jp-gray-950  dark:to-jp-gray-950 text-jp-gray-900`}>
                <div className="">
                  <div className="flex flex-row">
                    <div className="font-bold text-fs-13"> {React.string(item.title)} </div>
                    <UIUtils.RenderIf condition={item.description->Belt.Option.isSome}>
                      <div className="text-sm text-gray-500 mx-2">
                        <ToolTip
                          description={item.description->Belt.Option.getWithDefault("")}
                          toolTipPosition={ToolTip.Bottom}
                        />
                      </div>
                    </UIUtils.RenderIf>
                  </div>
                  <UIUtils.RenderIf
                    condition={item.showMultiSelectCheckBox->Belt.Option.getWithDefault(false)}>
                    <div className=" mt-1 mr-2">
                      <CheckBoxIcon
                        isSelected={isAllSelected}
                        setIsSelected
                        isSelectedStateMinus
                        checkboxDimension
                      />
                    </div>
                  </UIUtils.RenderIf>
                  <UIUtils.RenderIf condition={item.data->Belt.Option.isSome}>
                    <div
                      className="flex justify-start font-bold text-fs-10 whitespace-pre text-ellipsis overflow-x-hidden">
                      {React.string(item.data->Belt.Option.getWithDefault(""))}
                    </div>
                  </UIUtils.RenderIf>
                </div>
                {if item.showFilter || item.showSort {
                  <div className={`flex flex-row items-center`}>
                    {item.showSort
                      ? {
                          <AddDataAttributes attributes=[("data-table", "tableSort")]>
                            {
                              let order: sortOrder = switch sortedObj {
                              | Some(obj: sortedObject) =>
                                obj.key === item.key ? obj.order : TableUtils.NONE
                              | None => TableUtils.NONE
                              }
                              <div
                                className="cursor-pointer text-gray-300 pl-4"
                                onClick={_ev => {
                                  switch setSortedObj {
                                  | Some(fn) =>
                                    fn(_ => Some({
                                      key: item.key,
                                      order: order === DEC ? INC : DEC,
                                    }))
                                  | None => ()
                                  }
                                }}>
                                <SortIcons order size=13 />
                              </div>
                            }
                          </AddDataAttributes>
                        }
                      : React.null}
                  </div>
                } else {
                  React.null
                }}
              </div>
              <div>
                {
                  let len = colFilter->Js.Array2.length
                  switch colFilter->Belt.Array.get(i) {
                  | Some(fitlerRows) =>
                    <FilterRow
                      item=fitlerRows
                      hideFilter={showCheckBox && isFirstCol}
                      removeVerticalLines
                      tableDataBorderClass
                      isLast={i === len - 1 ? true : false}
                      cellIndex=i
                      cellWidth
                    />
                  | None => React.null
                  }
                }
              </div>
            </div>
          })
          ->React.array}
        </div>
      </div>
    } else {
      React.null
    }

    let rows = index => {
      rowInfo->Js.Array2.length == 0
        ? React.null
        : {
            let rowIndex = index->LogicUtils.getInt("index", 0)
            getIndex(rowIndex)

            let item = rowInfo->Belt.Array.get(rowIndex)->Belt.Option.getWithDefault([])

            let style = index->LogicUtils.getJsonObjectFromDict("style")->toReactDOMStyle

            <>
              <NewCell
                key={string_of_int(rowIndex)}
                item
                rowIndex
                onRowClick
                onRowClickPresent
                removeVerticalLines
                highlightEnabledFieldsArray
                tableDataBorderClass
                collapseTableRow
                expandedRow={_ => getRowDetails(rowIndex)}
                onMouseEnter
                onMouseLeave
                style
                setExpandedIndexArr
                expandedIndexArr
                handleExpand
                highlightText
                columnWidthArr=arr
                showSerialNumber
                customSerialNoColumn
                customCellColor
                showCheckBox
              />
            </>
          }
    }

    let getHeight = index => {
      if expandedIndexArr->Js.Array2.includes(index) {
        500
      } else {
        rowItemHeight
      }
    }

    <div
      className={` overflow-x-scroll ${scrollBarClass}`}
      style={ReactDOMStyle.make(~minHeight={filterPresent ? "30rem" : ""}, ())}>
      <div
        className={`w-max	${widthClass} h-full border border-jp-gray-940 border-opacity-50 dark:border-jp-gray-960 rounded-lg ${tableBorderClass}`}
        colSpan=0>
        <div className="bg-white dark:bg-jp-gray-lightgray_background">
          {headingReact}
          <ReactWindow.VariableSizeList
            ref={el => {
              open ReactWindow.ListComponent
              fn.current = el->resetAfterIndex
            }}
            itemSize={index => getHeight(index)}
            height=tableHeight
            overscanCount=6
            itemCount={rowInfo->Js.Array2.length}>
            {rows}
          </ReactWindow.VariableSizeList>
        </div>
      </div>
    </div>
  }
}

open DynamicTableUtils
type sortTyp = ASC | DSC
type sortOb = {
  sortKey: string,
  sortType: sortTyp,
}

let sortAtom: Recoil.recoilAtom<Js.Dict.t<sortOb>> = Recoil.atom(. "sortAtom", Js.Dict.empty())

let useSortedObj = (title: string, defaultSort) => {
  let (dict, setDict) = Recoil.useRecoilState(sortAtom)
  let filters = Js.Dict.get(dict, title)

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
        let nDict = Js.Dict.fromArray(Js.Dict.entries(dict))
        Js.Dict.set(nDict, title, sortOb)
        nDict
      })
    | _ => ()
    }
    None
  }, [sortedObj])

  (sortedObj, setSortedObj)
}
let useSortArray = () => {
  (originalData, key, sortOrder: Table.sortOrder) => {
    let getValue = val => {
      switch val {
      | Some(x) =>
        switch x->Js.Json.classify {
        | JSONString(_str) => x
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
        let item1 = i1->Js.Json.stringifyAny->Belt.Option.getWithDefault("")->LogicUtils.safeParse
        let item2 = i2->Js.Json.stringifyAny->Belt.Option.getWithDefault("")->LogicUtils.safeParse
        // flatten items and get data

        let val1 = item1->Js.Json.decodeObject->Belt.Option.flatMap(dict => dict->Js.Dict.get(key))

        let val2 = item2->Js.Json.decodeObject->Belt.Option.flatMap(dict => dict->Js.Dict.get(key))

        let value1 = getValue(val1)
        let value2 = getValue(val2)
        if value1 === value2 {
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
}

@react.component
let make = (
  ~actualData: Js.Array2.t<Js.Nullable.t<'t>>,
  ~defaultSort=?,
  ~title,
  ~visibleColumns=?,
  ~description=?,
  ~tableActions=?,
  ~rightTitleElement=React.null,
  ~bottomActions=?,
  ~showSerialNumber=false,
  ~totalResults,
  ~entity: EntityType.entityType<'colType, 't>,
  ~onEntityClick=?,
  ~removeVerticalLines=true,
  ~downloadCsv=?,
  ~hideTitle=false,
  ~tableDataLoading=false,
  ~customGetObjects: option<Js.Json.t => array<'a>>=?,
  ~dataNotFoundComponent=?,
  ~tableLocalFilter=false,
  ~tableheadingClass="",
  ~tableBorderClass="",
  ~tableDataBorderClass="",
  ~collapseTableRow=false,
  ~getRowDetails=?,
  ~getIndex=?,
  ~rowItemHeight=100,
  ~checkBoxProps: checkBoxProps=checkBoxPropDefaultVal,
  ~showScrollBar=false,
  ~onMouseEnter=?,
  ~onMouseLeave=?,
  ~activeColumnsAtom=?,
  ~highlightText="",
  ~tableHeight=500,
  ~columnWidth=?,
  ~customSerialNoColumn=false,
  ~customCellColor=?,
  ~filterWithIdOnly=false,
  ~fullWidth=true,
) => {
  let (columnFilter, setColumnFilterOrig) = React.useState(_ => Js.Dict.empty())
  let url = RescriptReactRouter.useUrl()
  let dateFormatConvertor = useDateFormatConvertor()

  let (showColumnSelector, setShowColumnSelector) = React.useState(() => false)

  let chooseCols =
    <ChooseColumnsWrapper
      entity
      totalResults
      defaultColumns=entity.defaultColumns
      activeColumnsAtom
      setShowColumnSelector
      showColumnSelector
    />
  let filterSection = <div className="flex flex-row gap-4"> {chooseCols} </div>
  let customizeColumnButtonType: Button.buttonType = SecondaryFilled
  let customizeButtonTextStyle = ""
  let customizeColumn = if (
    Some(activeColumnsAtom)->Js.Option.isSome &&
    entity.allColumns->Js.Option.isSome &&
    actualData->Js.Array2.length > 0
  ) {
    <Button
      text="Customize Columns"
      leftIcon={CustomIcon(<Icon name="vertical_slider" size=15 className="mr-1" />)}
      textStyle=customizeButtonTextStyle
      buttonType=customizeColumnButtonType
      buttonSize=Small
      onClick={_ => {
        setShowColumnSelector(_ => true)
      }}
      customButtonStyle=""
      showBorder={false}
    />
  } else {
    React.null
  }

  let setColumnFilter = React.useMemo1(() => {
    (filterKey, filterValue: array<Js.Json.t>) => {
      setColumnFilterOrig(oldFitlers => {
        let newObj = oldFitlers->Js.Dict.entries->Js.Dict.fromArray
        let filterValue = filterValue->Js.Array2.filter(
          item => {
            let updatedItem = item->Js.String.make
            updatedItem !== ""
          },
        )
        if filterValue->Js.Array.length === 0 {
          newObj
          ->Js.Dict.entries
          ->Js.Array2.filter(
            entry => {
              let (key, _value) = entry
              key !== filterKey
            },
          )
          ->Js.Dict.fromArray
        } else {
          Js.Dict.set(newObj, filterKey, filterValue)
          newObj
        }
      })
    }
  }, [setColumnFilterOrig])

  let filterValue = React.useMemo2(() => {
    (columnFilter, setColumnFilter)
  }, (columnFilter, setColumnFilter))

  let (isFilterOpen, setIsFilterOpenOrig) = React.useState(_ => Js.Dict.empty())
  let setIsFilterOpen = React.useMemo1(() => {
    (filterKey, value: bool) => {
      setIsFilterOpenOrig(oldFitlers => {
        let newObj = oldFitlers->DictionaryUtils.copyOfDict
        newObj->Js.Dict.set(filterKey, value)
        newObj
      })
    }
  }, [setColumnFilterOrig])
  let filterOpenValue = React.useMemo2(() => {
    (isFilterOpen, setIsFilterOpen)
  }, (isFilterOpen, setIsFilterOpen))

  let heading =
    visibleColumns
    ->Belt.Option.getWithDefault(entity.defaultColumns)
    ->Js.Array2.map(entity.getHeading)

  if showSerialNumber {
    heading
    ->Js.Array2.unshift(
      Table.makeHeaderInfo(~key="serial_number", ~title="S.No", ~dataType=NumericType, ()),
    )
    ->ignore
  }
  if checkBoxProps.showCheckBox {
    heading
    ->Js.Array2.unshift(
      Table.makeHeaderInfo(~key="select", ~title="", ~showMultiSelectCheckBox=true, ()),
    )
    ->ignore
  }

  let {getShowLink, getObjects} = entity

  let (sortedObj, setSortedObj) = useSortedObj(title, defaultSort)

  let columToConsider = React.useMemo3(() => {
    switch (entity.allColumns, visibleColumns) {
    | (Some(allCol), _) => Some(allCol)
    | (_, Some(visibleColumns)) => Some(visibleColumns)
    | _ => Some(entity.defaultColumns)
    }
  }, (entity.allColumns, visibleColumns, entity.defaultColumns))

  let columnFilterRow = React.useMemo5(() => {
    if tableLocalFilter {
      let columnFilterRow =
        visibleColumns
        ->Belt.Option.getWithDefault(entity.defaultColumns)
        ->Js.Array2.map(item => {
          let headingEntity = entity.getHeading(item)
          let key = headingEntity.key
          let dataType = headingEntity.dataType
          let dictArrObj = Js.Dict.empty()
          let columnFilterCopy = columnFilter->DictionaryUtils.deleteKey(key)
          let newValues =
            actualData
            ->filteredData(columnFilterCopy, visibleColumns, entity, dateFormatConvertor)
            ->Belt.Array.keepMap(
              item => {
                item->Js.Nullable.toOption
              },
            )
          switch columToConsider {
          | Some(allCol) =>
            newValues->Belt.Array.forEach(
              rows => {
                allCol->Belt.Array.forEach(
                  item => {
                    let heading = {item->entity.getHeading}
                    let key = heading.key
                    let dataType = heading.dataType
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
                    switch dictArrObj->Js.Dict.get(key) {
                    | Some(arr) => Js.Dict.set(dictArrObj, key, Belt.Array.concat(arr, [value]))
                    | None => Js.Dict.set(dictArrObj, key, [value])
                    }
                  },
                )
              },
            )

          | None => ()
          }
          let filterValueArray = dictArrObj->Js.Dict.get(key)->Belt.Option.getWithDefault([])
          switch dataType {
          | DropDown => Table.DropDownFilter(key, filterValueArray) // TextDropDownColumn
          | LabelType | TextType => Table.TextFilter(key)
          | MoneyType | NumericType | ProgressType => {
              let newArr =
                filterValueArray
                ->Js.Array2.map(item => item->Js.Json.decodeNumber->Belt.Option.getWithDefault(0.))
                ->Js.Array2.sortInPlaceWith(LogicUtils.numericArraySortComperator)
              let lengthOfArr = newArr->Js.Array2.length

              if lengthOfArr >= 2 {
                Table.Range(
                  key,
                  newArr[0]->Belt.Option.getWithDefault(0.),
                  newArr[lengthOfArr - 1]->Belt.Option.getWithDefault(0.),
                )
              } else if lengthOfArr >= 1 {
                Table.Range(
                  key,
                  newArr[0]->Belt.Option.getWithDefault(0.),
                  newArr[0]->Belt.Option.getWithDefault(0.),
                )
              } else {
                Table.Range(key, 0.0, 0.0)
              }
            }
          }
        })

      Some(
        showSerialNumber && tableLocalFilter
          ? Js.Array2.concat(
              [Table.Range("s_no", 0., actualData->Js.Array2.length->Belt.Int.toFloat)],
              columnFilterRow,
            )
          : columnFilterRow,
      )
    } else {
      None
    }
  }, (actualData, columToConsider, totalResults, visibleColumns, columnFilter))

  let sortArray = useSortArray()

  let actualData = if tableLocalFilter {
    filteredData(actualData, columnFilter, visibleColumns, entity, dateFormatConvertor)
  } else {
    actualData
  }

  let filteredData = React.useMemo4(() => {
    switch sortedObj {
    | Some(obj: Table.sortedObject) => sortArray(actualData, obj.key, obj.order)
    | None => actualData
    }
  }, (sortedObj, customGetObjects, actualData, getObjects))

  let selectAllCheckBox = React.useMemo2(() => {
    let selectedRowDataLength = checkBoxProps.selectedData->Js.Array2.length
    let isCompleteDataSelected = selectedRowDataLength === filteredData->Js.Array2.length
    if isCompleteDataSelected {
      Some(ALL)
    } else if checkBoxProps.selectedData->Js.Array2.length === 0 {
      None
    } else {
      Some(PARTIAL)
    }
  }, (checkBoxProps.selectedData, filteredData))
  let setSelectAllCheckBox = React.useCallback1(
    (v: option<TableUtils.multipleSelectRows> => option<TableUtils.multipleSelectRows>) => {
      switch v(selectAllCheckBox) {
      | Some(ALL) =>
        checkBoxProps.setSelectedData(_ => {
          filteredData->Js.Array2.map(toJson)
        })
      | Some(PARTIAL)
      | None =>
        checkBoxProps.setSelectedData(_ => [])
      }
    },
    [selectAllCheckBox],
  )

  React.useEffect1(() => {
    if selectAllCheckBox === Some(ALL) {
      checkBoxProps.setSelectedData(_ => {
        filteredData->Js.Array2.map(toJson)
      })
    } else if selectAllCheckBox === None {
      checkBoxProps.setSelectedData(_ => [])
    }
    None
  }, [selectAllCheckBox])
  let sNoArr = Js.Dict.get(columnFilter, "s_no")->Belt.Option.getWithDefault([])
  // filtering for SNO
  let rows =
    filteredData
    ->Js.Array2.mapi((nullableItem, index) => {
      let actualRows = switch nullableItem->Js.Nullable.toOption {
      | Some(item) => {
          let visibleCell =
            visibleColumns
            ->Belt.Option.getWithDefault(entity.defaultColumns)
            ->Js.Array2.map(colType => {
              entity.getCell(item, colType)
            })
          let startPoint = sNoArr->Belt.Array.get(0)->Belt.Option.getWithDefault(1.->Js.Json.number)
          let endPoint = sNoArr->Belt.Array.get(1)->Belt.Option.getWithDefault(1.->Js.Json.number)
          let jsonIndex = (index + 1)->Belt.Int.toFloat->Js.Json.number
          sNoArr->Js.Array2.length > 0
            ? {
                startPoint <= jsonIndex && endPoint >= jsonIndex ? visibleCell : []
              }
            : visibleCell
        }

      | None => []
      }
      let getIdFromJson = json => {
        let selectedPlanDict =
          json->Js.Json.decodeObject->Belt.Option.getWithDefault(Js.Dict.empty())
        selectedPlanDict->LogicUtils.getString("id", "")
      }
      let setIsSelected = isSelected => {
        if isSelected {
          checkBoxProps.setSelectedData(prev => prev->Js.Array2.concat([nullableItem->toJson]))
        } else {
          checkBoxProps.setSelectedData(prev =>
            if filterWithIdOnly {
              prev->Js.Array2.filter(
                item => getIdFromJson(item) !== getIdFromJson(nullableItem->toJson),
              )
            } else {
              prev->Js.Array2.filter(item => item !== nullableItem->toJson)
            }
          )
        }
      }

      if showSerialNumber && actualRows->Js.Array2.length > 0 {
        actualRows
        ->Js.Array2.unshift(
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
        let selectedRowIndex = checkBoxProps.selectedData->Js.Array2.findIndex(item =>
          if filterWithIdOnly {
            getIdFromJson(item) == getIdFromJson(nullableItem->toJson)
          } else {
            item == nullableItem->toJson
          }
        )
        actualRows
        ->Js.Array2.unshift(
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
      actualRows
    })
    ->Belt.Array.keepMap(item => {
      item->Js.Array2.length == 0 ? None : Some(item)
    })

  let dataExists = rows->Js.Array2.length > 0
  let heading = heading->Js.Array2.mapi((head, index) => {
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
        totalResults == Js.Array.length(rows)
          ? rows->Js.Array2.some(row => getValue(row) !== default)
          : true
      ),
    }
    head
  })

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
            let finalUrl = url.search->Js.String2.length > 0 ? `${link}?${url.search}` : link
            RescriptReactRouter.push(finalUrl)
          }

        | None => ()
        }
      }
    | None => ()
    }
  }, (filteredData, getShowLink, onEntityClick, url.search))

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

  let handleMouseLeave = React.useCallback4(index => {
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

  <AddDataAttributes attributes=[("data-loaded-table", title)]>
    <div>
      <div
        className={` bg-gray-50 dark:bg-jp-gray-darkgray_background empty:hidden`}
        style={ReactDOMStyle.make(~zIndex="2", ())}>
        <div className="flex flex-row justify-between items-center mt-4 mb-2">
          {if hideTitle {
            React.null
          } else {
            <TableHeading title noVerticalMargin=true ?description />
          }}
          customizeColumn
        </div>
        rightTitleElement
        <div className="flex flex-row my-2">
          <TableFilterSectionContext isFilterSection=true>
            <div className="flex-1">
              {filterSection->React.Children.map(element => {
                if element === React.null {
                  React.null
                } else {
                  <div className="pb-3"> element </div>
                }
              })}
            </div>
          </TableFilterSectionContext>
          <div className="flex flex-row">
            {switch tableActions {
            | Some(actions) =>
              <LoadedTableContext value={actualData->LoadedTableContext.toInfoData}>
                actions
              </LoadedTableContext>
            | None => React.null
            }}
          </div>
        </div>
      </div>
      {if totalResults > 0 {
        <div>
          {
            let children =
              <ReactWindowTableComponent
                actualData
                heading
                rows
                onRowClick=handleRowClick
                onRowClickPresent={onEntityClick->Belt.Option.isSome ||
                  getShowLink->Belt.Option.isSome}
                fullWidth
                removeVerticalLines
                showScrollBar=false
                setSortedObj
                ?sortedObj
                ?columnFilterRow
                tableheadingClass
                tableBorderClass
                tableDataBorderClass
                collapseTableRow
                ?getRowDetails
                ?getIndex
                rowItemHeight
                ?selectAllCheckBox
                setSelectAllCheckBox
                onMouseEnter=handleMouseEnter
                onMouseLeave=handleMouseLeave
                highlightText
                tableHeight
                columnWidth
                showSerialNumber
                customSerialNoColumn
                ?customCellColor
                showCheckBox=checkBoxProps.showCheckBox
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
        </div>
      } else if totalResults === 0 && !tableDataLoading {
        switch dataNotFoundComponent {
        | Some(comp) => comp
        | None => <NoDataFound message="No Data Available" renderType=Painting />
        }
      } else {
        React.null
      }}
      {if tableDataLoading {
        <TableDataLoadingIndicator showWithData={rows->Js.Array2.length !== 0} />
      } else {
        React.null
      }}
      {switch bottomActions {
      | Some(actions) =>
        <LoadedTableContext value={actualData->LoadedTableContext.toInfoData}>
          actions
        </LoadedTableContext>

      | None => React.null
      }}
      {switch downloadCsv {
      | Some(actionData) =>
        <div className="flex justify-end mt-4 mb-2 ">
          <LoadedTableContext value={actualData->LoadedTableContext.toInfoData}>
            actionData
          </LoadedTableContext>
        </div>
      | None => React.null
      }}
    </div>
  </AddDataAttributes>
}
