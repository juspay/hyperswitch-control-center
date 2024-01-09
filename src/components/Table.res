include TableUtils
module TableFilterRow = {
  @react.component
  let make = (
    ~item: array<filterRow>,
    ~removeVerticalLines,
    ~removeHorizontalLines,
    ~evenVertivalLines,
    ~tableDataBorderClass,
    ~customFilterRowStyle,
    ~showCheckbox,
  ) => {
    let colsLen = item->Array.length
    let borderColor = "border-jp-gray-light_table_border_color dark:border-jp-gray-960"
    let paddingClass = "px-4 py-3"
    let hoverClass = "hover:bg-jp-gray-table_hover dark:hover:bg-jp-gray-table_hover_dark"
    <tr
      className={`filterColumns group rounded-md h-10 bg-white dark:bg-jp-gray-lightgray_background ${hoverClass} transition duration-300 ease-in-out text-fs-13 text-jp-gray-900 text-opacity-75 dark:text-jp-gray-text_darktheme dark:text-opacity-75 ${customFilterRowStyle}`}>
      {if showCheckbox {
        <td />
      } else {
        React.null
      }}
      {item
      ->Array.mapWithIndex((obj: filterRow, cellIndex) => {
        let isLast = cellIndex === colsLen - 1
        let showBorderTop = true
        let borderTop = showBorderTop ? "border-t" : "border-t-0"
        let borderClass = if removeHorizontalLines && removeVerticalLines {
          ""
        } else if isLast {
          `${borderTop} ${borderColor}`
        } else if removeVerticalLines || (evenVertivalLines && mod(cellIndex, 2) === 0) {
          `${borderTop} ${borderColor}`
        } else {
          `${borderTop} border-r ${borderColor}`
        }
        <td
          key={string_of_int(cellIndex)}
          className={`align-top ${borderClass} ${tableDataBorderClass}`}>
          <div className={`box-border ${paddingClass}`}>
            <TableFilterCell cell=obj />
          </div>
        </td>
      })
      ->React.array}
    </tr>
  }
}

module TableRow = {
  @react.component
  let make = (
    ~title,
    ~item: array<cell>,
    ~rowIndex,
    ~onRowClick,
    ~onRowDoubleClick,
    ~onRowClickPresent,
    ~offset,
    ~removeVerticalLines,
    ~removeHorizontalLines,
    ~evenVertivalLines,
    ~highlightEnabledFieldsArray,
    ~tableDataBorderClass="",
    ~collapseTableRow=false,
    ~expandedRow: _ => React.element,
    ~onMouseEnter,
    ~onMouseLeave,
    ~highlightText,
    ~clearFormatting=false,
    ~rowHeightClass="",
    ~rowCustomClass="",
    ~fixedWidthClass,
    ~isHighchartLegend=false,
    ~labelMargin="",
    ~isEllipsisTextRelative=true,
    ~customMoneyStyle="",
    ~ellipseClass="",
    ~selectedRowColor="bg-white dark:bg-jp-gray-lightgray_background",
    ~lastColClass="",
    ~fixLastCol=false,
    ~alignCellContent="",
    ~customCellColor="",
  ) => {
    open Window
    let (isCurrentRowExpanded, setIsCurrentRowExpanded) = React.useState(_ => false)
    let (expandedData, setExpandedData) = React.useState(_ => React.null)
    let actualIndex = offset + rowIndex
    let onClick = React.useCallback2(_ev => {
      let isRangeSelected = getSelection().\"type" == "Range"
      switch (onRowClick, isRangeSelected) {
      | (Some(fn), false) => fn(actualIndex)
      | _ => ()
      }
    }, (onRowClick, actualIndex))

    let onDoubleClick = React.useCallback2(_ev => {
      switch onRowDoubleClick {
      | Some(fn) => fn(actualIndex)
      | _ => ()
      }
    }, (onRowDoubleClick, actualIndex))

    let onMouseEnter = React.useCallback2(_ev => {
      switch onMouseEnter {
      | Some(fn) => fn(actualIndex)
      | _ => ()
      }
    }, (onMouseEnter, actualIndex))

    let onMouseLeave = React.useCallback2(_ev => {
      switch onMouseLeave {
      | Some(fn) => fn(actualIndex)
      | _ => ()
      }
    }, (onMouseLeave, actualIndex))
    let colsLen = item->Array.length
    let cursorClass = onRowClickPresent ? "cursor-pointer" : ""
    let rowRef = React.useRef(Js.Nullable.null)
    let coloredRow =
      // colour based on custom cell's value
      item
      ->Array.find(obj => {
        switch obj {
        | CustomCell(_, x) => x === "true"
        | _ => false
        }
      })
      ->Belt.Option.isSome
    let bgColor = coloredRow ? selectedRowColor : "bg-white dark:bg-jp-gray-lightgray_background"
    let fontSize = "text-fs-13"
    let fontWeight = ""
    let textColor = "text-jp-gray-900  dark:text-jp-gray-text_darktheme dark:text-opacity-75"
    let hoverClass = "hover:bg-jp-gray-table_hover dark:hover:bg-jp-gray-table_hover_dark"
    let tableBodyText = if isHighchartLegend {
      `group rounded-md ${cursorClass} text-fs-10 font-medium dark:text-jp-gray-dark_chart_legend_text jp-gray-light_chart_legend_text pb-4 whitespace-nowrap text-ellipsis overflow-x-hidden`
    } else {
      `group rounded-md ${cursorClass} ${bgColor} ${fontSize} ${fontWeight} ${rowCustomClass} ${textColor} ${hoverClass} transition duration-300 ease-in-out`
    }
    <>
      <tr
        ref={rowRef->ReactDOM.Ref.domRef}
        className=tableBodyText
        onClick
        onMouseEnter
        onMouseLeave
        onDoubleClick>
        {item
        ->Array.mapWithIndex((obj: cell, cellIndex) => {
          let isLast = cellIndex === colsLen - 1
          let showBorderTop = switch obj {
          | Text(x) => x !== "-"
          | _ => true
          }

          let paddingClass = switch obj {
          | Link(_) => "pt-2"
          | _ => "py-3"
          }
          let coloredRow = switch obj {
          | CustomCell(_, x) => x === "true"
          | _ => false
          }

          let customColorCell = coloredRow ? customCellColor : ""

          let highlightCell = highlightEnabledFieldsArray->Array.includes(cellIndex)
          let highlightClass = highlightCell ? "hover:font-bold" : ""
          let borderColor = "border-jp-gray-light_table_border_color dark:border-jp-gray-960"
          let borderTop = showBorderTop ? "border-t" : "border-t-0"
          let borderClass = if removeHorizontalLines && removeVerticalLines {
            ""
          } else if isLast {
            `${borderTop} ${borderColor}`
          } else if removeVerticalLines || (evenVertivalLines && mod(cellIndex, 2) === 0) {
            `${borderTop} ${borderColor}`
          } else {
            `${borderTop} border-r ${borderColor}`
          }
          let cursorI = cellIndex == 0 && collapseTableRow ? "cursor-pointer" : ""
          let isLast = cellIndex === colsLen - 1
          let lastColProp =
            isLast && fixLastCol ? "border-l h-full !py-0 flex flex-col justify-center" : ""
          let tableRowBorderClass = if isHighchartLegend {
            `align-top ${highlightClass} ${tableDataBorderClass} ${cursorI} ${rowHeightClass}`
          } else if isLast {
            `align-top ${lastColClass} ${borderClass} ${highlightClass} ${tableDataBorderClass} ${cursorI} ${rowHeightClass}`
          } else {
            `align-top ${borderClass} ${highlightClass} ${tableDataBorderClass} ${cursorI} ${rowHeightClass}`
          }
          let paddingClass = `px-4 ${paddingClass}`
          let tableRowPaddingClass = if isHighchartLegend {
            `box-border py-1 ${lastColProp} ${alignCellContent}`
          } else {
            `box-border ${paddingClass} ${lastColProp} ${alignCellContent}`
          }
          let location = `${title}_tr${(rowIndex + 1)->Belt.Int.toString}_td${(cellIndex + 1)
              ->Belt.Int.toString}`
          <AddDataAttributes
            key={cellIndex->string_of_int} attributes=[("data-table-location", location)]>
            <td
              key={string_of_int(cellIndex)}
              className={`${tableRowBorderClass} ${customColorCell}`}
              style={ReactDOMStyle.make(~width=fixedWidthClass, ())}
              onClick={_ => {
                if collapseTableRow && cellIndex == 0 {
                  setIsCurrentRowExpanded(prev => !prev)
                  setExpandedData(_ => expandedRow())
                }
              }}>
              <div className=tableRowPaddingClass>
                {if collapseTableRow {
                  <div className="flex flex-row gap-4 items-center">
                    {if cellIndex === 0 {
                      <Icon name={isCurrentRowExpanded ? "caret-down" : "caret-right"} size=14 />
                    } else {
                      React.null
                    }}
                    <TableCell
                      cell=obj
                      highlightText
                      clearFormatting
                      labelMargin
                      isEllipsisTextRelative
                      customMoneyStyle
                      ellipseClass
                    />
                  </div>
                } else {
                  <TableCell
                    cell=obj
                    highlightText
                    clearFormatting
                    labelMargin
                    isEllipsisTextRelative
                    customMoneyStyle
                    ellipseClass
                  />
                }}
              </div>
            </td>
          </AddDataAttributes>
        })
        ->React.array}
      </tr>
      {if isCurrentRowExpanded {
        <tr className="dark:border-jp-gray-dark_disable_border_color">
          <td colSpan=12 className=""> {expandedData} </td>
        </tr>
      } else {
        React.null
      }}
    </>
  }
}

module SortAction = {
  @react.component
  let make = (
    ~item: TableUtils.header,
    ~sortedObj: option<TableUtils.sortedObject>,
    ~setSortedObj,
    ~sortIconSize,
    ~isLastCol=false,
    ~filterRow: option<filterRow>,
  ) => {
    if item.showSort || filterRow->Belt.Option.isSome {
      let order: sortOrder = switch sortedObj {
      | Some(obj: sortedObject) => obj.key === item.key ? obj.order : NONE
      | None => NONE
      }
      let handleSortClick = _ev => {
        switch setSortedObj {
        | Some(fn) =>
          fn(_ => Some({
            key: item.key,
            order: order === DEC ? INC : DEC,
          }))
        | None => ()
        }
      }

      <AddDataAttributes attributes=[("data-table", "tableSort")]>
        <div className="cursor-pointer text-gray-300 pl-4" onClick=handleSortClick>
          <SortIcons order size=sortIconSize />
        </div>
      </AddDataAttributes>
    } else {
      React.null
    }
  }
}

module TableHeadingCell = {
  @react.component
  let make = (
    ~item,
    ~index,
    ~headingArray,
    ~isHighchartLegend,
    ~frozenUpto,
    ~heightHeadingClass,
    ~tableheadingClass,
    ~sortedObj,
    ~setSortedObj,
    ~filterObj,
    ~fixedWidthClass,
    ~setFilterObj,
    ~headingCenter,
    ~filterIcon=?,
    ~filterDropdownClass=?,
    ~filterDropdownMaxHeight=?,
    ~selectAllCheckBox: option<multipleSelectRows>,
    ~setSelectAllCheckBox,
    ~isFrozen=false,
    ~lastHeadingClass="",
    ~fixLastCol=false,
    ~headerCustomBgColor=?,
    ~filterRow,
    ~customizeColumnNewTheme=?,
    ~tableHeadingTextClass="",
  ) => {
    let i = index
    let isFirstCol = i === 0
    let isLastCol = i === headingArray->Array.length - 1

    let handleUpdateFilterObj = (ev, i) => {
      switch setFilterObj {
      | Some(fn) =>
        fn((prevFilterObj: array<filterObject>) => {
          prevFilterObj->Array.map(obj => {
            obj.key === string_of_int(i)
              ? {
                  key: string_of_int(i),
                  options: obj.options,
                  selected: ev->Identity.formReactEventToArrayOfString,
                }
              : obj
          })
        })
      | None => ()
      }
    }

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

    let headerBgColor =
      headerCustomBgColor->Belt.Option.isSome
        ? headerCustomBgColor->Belt.Option.getWithDefault("")
        : "bg-gray-50 dark:bg-jp-gray-darkgray_background"
    let paddingClass = "px-4 py-3"
    let roundedClass = if isFirstCol {
      "rounded-tl"
    } else if isLastCol {
      "rounded-tr"
    } else {
      ""
    }

    let headerTextClass = "text-jp-gray-900 text-opacity-75 dark:text-jp-gray-text_darktheme dark:text-opacity-75"
    let fontWeight = "font-bold"
    let fontSize = "text-fs-13"
    let lastColProp = isLastCol && fixLastCol ? "sticky right-0 !px-0 !py-0 z-20" : ""
    let borderlastCol =
      isLastCol && fixLastCol ? "border-l px-4 py-3 h-full justify-center !flex-col" : ""
    let tableHeaderClass = if isHighchartLegend {
      `tableHeader ${lastColProp} p-0 pb-2 justify-between items-center dark:text-jp-gray-dark_chart_legend_text jp-gray-light_chart_legend_text text-opacity-75 dark:text-opacity-75 whitespace-pre select-none ${isLastCol
          ? lastHeadingClass
          : ""}`
    } else {
      let heightHeadingClass2 = frozenUpto == 0 ? "" : heightHeadingClass
      `tableHeader ${lastColProp} ${item.customWidth->Belt.Option.getWithDefault(
          "",
        )} justify-between items-center ${headerTextClass} whitespace-pre select-none ${headerBgColor} ${paddingClass} ${roundedClass} ${heightHeadingClass2} ${tableheadingClass} ${isLastCol
          ? lastHeadingClass
          : ""}`
    }
    let tableHeadingTextClass = if isHighchartLegend {
      "text-fs-11 dark:text-blue-650 text-jp-gray-900 text-opacity-80 dark:text-opacity-100 font-medium not-italic whitespace-nowrap text-ellipsis overflow-x-hidden "
    } else {
      `${fontWeight} ${fontSize} ${tableHeadingTextClass}`
    }
    let (isAllSelected, isSelectedStateMinus, checkboxDimension) = (
      selectAllCheckBox->Belt.Option.isSome,
      selectAllCheckBox === Some(PARTIAL),
      "h-4 w-4",
    )

    let sortIconSize = isHighchartLegend ? 11 : 13
    let justifyClass = ""
    <AddDataAttributes attributes=[("data-table-heading", item.title)]>
      <th
        key={string_of_int(i)}
        className=tableHeaderClass
        style={ReactDOMStyle.make(~width=fixedWidthClass, ())}>
        {switch customizeColumnNewTheme {
        | Some(value) =>
          <div className="flex flex-row justify-center items-center"> value.customizeColumnUi </div>
        | None =>
          <div
            className={`flex flex-row ${borderlastCol}  ${headingCenter
                ? "justify-center"
                : justifyClass}`}>
            <div className="">
              <div className={"flex flex-row"}>
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
                <div className="flex justify-between items-center">
                  {switch item.headerElement {
                  | Some(headerElement) => headerElement
                  | _ => <div className=tableHeadingTextClass> {React.string(item.title)} </div>
                  }}
                  <UIUtils.RenderIf condition={item.data->Belt.Option.isSome}>
                    <AddDataAttributes
                      attributes=[
                        ("data-heading-value", item.data->Belt.Option.getWithDefault("")),
                      ]>
                      <div
                        className="flex justify-start text-fs-10 font-medium text-gray-400 whitespace-pre text-ellipsis overflow-x-hidden">
                        {React.string(` (${item.data->Belt.Option.getWithDefault("")})`)}
                      </div>
                    </AddDataAttributes>
                  </UIUtils.RenderIf>
                  {if item.showFilter || item.showSort || filterRow->Belt.Option.isSome {
                    let selfClass = "self-end"
                    <div className={`flex flex-row ${selfClass} items-center`}>
                      <SortAction
                        item
                        sortedObj
                        setSortedObj
                        sortIconSize
                        filterRow
                        isLastCol={isLastCol && !isFrozen && !isFirstCol}
                      />
                      {if item.showFilter {
                        let (options, selected) = switch filterObj {
                        | Some(obj) =>
                          switch obj[i] {
                          | Some(ele) => (ele.options, ele.selected)
                          | None => ([], [])
                          }
                        | None => ([], [])
                        }
                        if options->Array.length > 1 {
                          let filterInput: ReactFinalForm.fieldRenderPropsInput = {
                            name: "filterInput",
                            onBlur: _ev => (),
                            onChange: ev => handleUpdateFilterObj(ev, i),
                            onFocus: _ev => (),
                            value: selected->Array.map(Js.Json.string)->Js.Json.array,
                            checked: true,
                          }
                          let icon = switch filterIcon {
                          | Some(icon) => icon
                          | None =>
                            <Icon className="align-middle text-gray-400" name="filter" size=12 />
                          }

                          let dropdownClass = switch filterDropdownClass {
                          | Some(className) => className
                          | None => ""
                          }

                          let maxHeight = filterDropdownMaxHeight
                          <div className={`${dropdownClass}`}>
                            <SelectBox.BaseDropdown
                              allowMultiSelect=true
                              hideMultiSelectButtons=true
                              buttonText=""
                              input={filterInput}
                              options={options->SelectBox.makeOptions}
                              deselectDisable=false
                              baseComponent=icon
                              autoApply=false
                              ?maxHeight
                            />
                          </div>
                        } else {
                          React.null
                        }
                      } else {
                        React.null
                      }}
                    </div>
                  } else {
                    React.null
                  }}
                </div>
                <UIUtils.RenderIf condition={item.isMandatory->Belt.Option.getWithDefault(false)}>
                  <div className="text-red-400 text-sm ml-1"> {React.string("*")} </div>
                </UIUtils.RenderIf>
                <UIUtils.RenderIf
                  condition={item.description->Belt.Option.getWithDefault("") !== ""}>
                  <div className="text-sm text-gray-500 mx-2">
                    <ToolTip
                      description={item.description->Belt.Option.getWithDefault("")}
                      toolTipPosition={ToolTip.Bottom}
                    />
                  </div>
                </UIUtils.RenderIf>
              </div>
            </div>
          </div>
        }}
      </th>
    </AddDataAttributes>
  }
}

module TableHeadingRow = {
  @react.component
  let make = (
    ~headingArray,
    ~isHighchartLegend,
    ~frozenUpto,
    ~heightHeadingClass,
    ~tableheadingClass,
    ~sortedObj,
    ~setSortedObj,
    ~filterObj,
    ~fixedWidthClass,
    ~setFilterObj,
    ~headingCenter,
    ~filterIcon=?,
    ~filterDropdownClass=?,
    ~selectAllCheckBox,
    ~setSelectAllCheckBox,
    ~isFrozen=false,
    ~lastHeadingClass="",
    ~fixLastCol=false,
    ~headerCustomBgColor=?,
    ~filterDropdownMaxHeight=?,
    ~columnFilterRow,
    ~customizeColumnNewTheme=?,
    ~tableHeadingTextClass="",
  ) => {
    if headingArray->Array.length !== 0 {
      <thead>
        <tr>
          {headingArray
          ->Array.mapWithIndex((item, i) => {
            let columnFilterRow: array<filterRow> = columnFilterRow->Belt.Option.getWithDefault([])
            let filterRow = columnFilterRow->Belt.Array.get(i)
            <TableHeadingCell
              key={Belt.Int.toString(i)}
              item
              index=i
              headingArray
              isHighchartLegend
              frozenUpto
              heightHeadingClass
              tableheadingClass
              sortedObj
              setSortedObj
              filterObj
              fixedWidthClass
              setFilterObj
              headingCenter
              ?filterIcon
              ?filterDropdownClass
              selectAllCheckBox
              setSelectAllCheckBox
              isFrozen
              lastHeadingClass
              fixLastCol
              ?headerCustomBgColor
              ?filterDropdownMaxHeight
              filterRow
              ?customizeColumnNewTheme
              tableHeadingTextClass
            />
          })
          ->React.array}
        </tr>
      </thead>
    } else {
      React.null
    }
  }
}

@react.component
let make = (
  ~title="Title",
  ~heading=[],
  ~rows,
  ~offset=0,
  ~onRowClick=?,
  ~onRowDoubleClick=?,
  ~onRowClickPresent=false,
  ~fullWidth=true,
  ~removeVerticalLines=true,
  ~removeHorizontalLines=false,
  ~evenVertivalLines=false,
  ~showScrollBar=false,
  ~setSortedObj=?,
  ~sortedObj=?,
  ~setFilterObj=?,
  ~filterObj=?,
  ~columnFilterRow=?,
  ~tableheadingClass="",
  ~tableBorderClass="",
  ~tableDataBorderClass="",
  ~collapseTableRow=false,
  ~getRowDetails=?,
  ~actualData=?,
  ~onExpandClickData as _=?,
  ~onMouseEnter=?,
  ~onMouseLeave=?,
  ~highlightText="",
  ~heightHeadingClass="h-16",
  ~frozenUpto=0,
  ~clearFormatting=false,
  ~rowHeightClass="",
  ~isMinHeightRequired=false,
  ~rowCustomClass="",
  ~enableEqualWidthCol=false,
  ~isHighchartLegend=false,
  ~headingCenter=false,
  ~filterIcon=?,
  ~filterDropdownClass=?,
  ~showHeading=true,
  ~maxTableHeight="",
  ~labelMargin="",
  ~customFilterRowStyle="",
  ~selectAllCheckBox=?,
  ~setSelectAllCheckBox=?,
  ~isEllipsisTextRelative=true,
  ~customMoneyStyle="",
  ~ellipseClass="",
  ~selectedRowColor=?,
  ~lastHeadingClass="",
  ~showCheckbox=false,
  ~lastColClass="",
  ~fixLastCol=false,
  ~headerCustomBgColor=?,
  ~alignCellContent=?,
  ~minTableHeightClass="",
  ~filterDropdownMaxHeight=?,
  ~customizeColumnNewTheme=?,
  ~customCellColor=?,
  ~customBorderClass=?,
  ~showborderColor=true,
  ~tableHeadingTextClass="",
) => {
  let isMobileView = MatchMedia.useMobileChecker()
  let rowInfo: array<array<cell>> = rows
  let actualData: option<Js.Array2.t<Js.Nullable.t<'t>>> = actualData
  let numberOfCols = heading->Array.length
  open Webapi
  let totalTableWidth =
    Dom.document
    ->Dom.Document.getElementById(`table`)
    ->Belt.Option.mapWithDefault(0, ele => ele->Document.offsetWidth)

  let equalColWidth = (totalTableWidth / numberOfCols)->Belt.Int.toString
  let fixedWidthClass = enableEqualWidthCol ? `${equalColWidth}px` : ""
  let widthClass = if fullWidth {
    "min-w-full"
  } else {
    ""
  }
  let stickCol = {"sticky left-0 z-10"}
  let scrollBarClass = if showScrollBar {
    "show-scrollbar"
  } else {
    ""
  }
  let filterPresent = heading->Array.find(head => head.showFilter)->Js.Option.isSome

  let highlightEnabledFieldsArray = heading->Array.reduceWithIndex([], (acc, item, index) => {
    if item.highlightCellOnHover {
      let _ = Array.push(acc, index)
    }
    acc
  })

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

  let tableRows = (rowArr, isCustomiseColumn) => {
    rowArr
    ->Array.mapWithIndex((item: array<cell>, rowIndex) => {
      <TableRow
        title
        key={string_of_int(offset + rowIndex)}
        item
        rowIndex
        offset
        onRowClick
        onRowDoubleClick
        onRowClickPresent
        removeVerticalLines
        removeHorizontalLines
        evenVertivalLines
        highlightEnabledFieldsArray
        tableDataBorderClass
        collapseTableRow
        expandedRow={_ => getRowDetails(offset + rowIndex)}
        onMouseEnter
        onMouseLeave
        highlightText
        clearFormatting
        rowHeightClass
        rowCustomClass={`${rowCustomClass} ${isCustomiseColumn ? "opacity-0" : ""}`}
        fixedWidthClass
        isHighchartLegend
        labelMargin
        isEllipsisTextRelative
        customMoneyStyle
        ellipseClass
        ?selectedRowColor
        lastColClass
        fixLastCol
        ?alignCellContent
        ?customCellColor
      />
    })
    ->React.array
  }

  let renderTableHeadingRow = (headingArray, isFrozen, isCustomiseColumn, lastHeadingClass) => {
    let columnFilterRow = switch columnFilterRow {
    | Some(fitlerRows) =>
      switch isFrozen {
      | true => Some(fitlerRows->Array.slice(~start=0, ~end=frozenUpto))
      | false => Some(fitlerRows->Js.Array2.sliceFrom(frozenUpto))
      }
    | None => None
    }
    let tableheadingClass =
      customizeColumnNewTheme->Belt.Option.isSome
        ? `${tableheadingClass} ${heightHeadingClass}`
        : tableheadingClass

    let customizeColumnNewTheme = isCustomiseColumn ? customizeColumnNewTheme : None
    <TableHeadingRow
      headingArray
      isHighchartLegend
      frozenUpto
      heightHeadingClass
      tableheadingClass
      sortedObj
      setSortedObj
      filterObj
      fixedWidthClass
      setFilterObj
      headingCenter
      ?filterIcon
      ?filterDropdownClass
      selectAllCheckBox
      setSelectAllCheckBox
      isFrozen
      lastHeadingClass
      fixLastCol
      ?headerCustomBgColor
      ?filterDropdownMaxHeight
      columnFilterRow
      ?customizeColumnNewTheme
      tableHeadingTextClass
    />
  }

  let tableFilterRow = (~isFrozen) => {
    switch columnFilterRow {
    | Some(fitlerRows) => {
        let filterRows = switch isFrozen {
        | true => fitlerRows->Array.slice(~start=0, ~end=frozenUpto)
        | false => fitlerRows->Js.Array2.sliceFrom(frozenUpto)
        }

        <TableFilterRow
          item=filterRows
          removeVerticalLines
          removeHorizontalLines
          tableDataBorderClass
          evenVertivalLines
          customFilterRowStyle
          showCheckbox
        />
      }

    | None => React.null
    }
  }

  let frozenHeading = heading->Array.slice(~start=0, ~end=frozenUpto)
  let frozenCustomiseColumnHeading = [
    makeHeaderInfo(~key="", ~title="Customize Column", ~showMultiSelectCheckBox=true, ()),
  ]
  let frozenRow = rowInfo->Array.map(row => {
    row->Array.slice(~start=0, ~end=frozenUpto)
  })

  let remainingHeading = heading->Js.Array2.sliceFrom(frozenUpto)
  let remaingRow = rowInfo->Array.map(row => {
    row->Js.Array2.sliceFrom(frozenUpto)
  })

  let frozenTableWidthClass = isMobileView ? "w-48" : "w-auto"

  let parentBoderColor = "border border-jp-gray-940 border-opacity-100 dark:border-jp-gray-960"

  let boderColor = !showborderColor
    ? ""
    : "border border-jp-gray-940 border-opacity-50 dark:border-jp-gray-960"

  let frozenTable = {
    <table
      className={`table-auto ${frozenTableWidthClass} ${parentBoderColor} rounded-lg ${tableBorderClass} ${stickCol}`}>
      <UIUtils.RenderIf condition=showHeading>
        {renderTableHeadingRow(frozenHeading, true, false, lastHeadingClass)}
      </UIUtils.RenderIf>
      <tbody>
        {tableFilterRow(~isFrozen=true)}
        {tableRows(frozenRow, false)}
      </tbody>
    </table>
  }

  let totalLength = rowInfo->Array.length

  let customizeColumn = {
    <table className={`table-auto rounded-lg sticky right-0 !px-0 !py-0 z-10`}>
      <UIUtils.RenderIf condition=showHeading>
        {renderTableHeadingRow(
          frozenCustomiseColumnHeading,
          true,
          true,
          `${lastHeadingClass} rounded-tl-none rounded-tr-lg`,
        )}
      </UIUtils.RenderIf>
      <tbody>
        {tableRows(Belt.Array.range(1, totalLength)->Array.map(_ => [Text("")]), true)}
      </tbody>
    </table>
  }

  let tableBorderClass = if isHighchartLegend {
    `table-auto ${widthClass}`
  } else {
    `table-auto ${widthClass} ${tableBorderClass} ${boderColor} rounded-lg`
  }
  let (lclFilterOpen, _) = React.useContext(DataTableFilterOpenContext.filterOpenContext)

  let nonFrozenTable = {
    <table id="table" className=tableBorderClass>
      <UIUtils.RenderIf condition=showHeading>
        {renderTableHeadingRow(remainingHeading, false, false, `${lastHeadingClass}`)}
      </UIUtils.RenderIf>
      <tbody>
        {tableFilterRow(~isFrozen=false)}
        {tableRows(remaingRow, false)}
      </tbody>
    </table>
  }
  let parentMinWidthClass = frozenUpto > 0 ? "min-w-max" : ""
  let childMinWidthClass = frozenUpto > 0 ? "" : "min-w-full"
  let overflowClass =
    lclFilterOpen->Dict.valuesToArray->Array.reduce(false, (acc, item) => item || acc)
      ? ""
      : isMinHeightRequired
      ? ""
      : "overflow-scroll"
  let parentBorderRadius = !isHighchartLegend ? "rounded-t-lg" : ""
  let parentBorderClass = !isHighchartLegend ? "border border-jp-2-light-gray-300" : ""
  <div
    className={`flex flex-row items-stretch ${scrollBarClass} loadedTable ${parentMinWidthClass} ${customBorderClass->Belt.Option.getWithDefault(
        parentBorderClass ++ " " ++ parentBorderRadius,
      )}`}
    style={ReactDOMStyle.make(
      ~minHeight={
        minTableHeightClass != ""
          ? minTableHeightClass
          : filterPresent || isMinHeightRequired
          ? "25rem"
          : ""
      },
      ~maxHeight={maxTableHeight},
      (),
    )} //replaced "overflow-auto" -> to be tested with master
  >
    <UIUtils.RenderIf condition={frozenUpto > 0}> {frozenTable} </UIUtils.RenderIf>
    <div className={`flex-1 ${overflowClass} no-scrollbar ${childMinWidthClass}`}>
      nonFrozenTable
    </div>
    {switch customizeColumnNewTheme {
    | Some(customizeColumnObj) =>
      <UIUtils.RenderIf condition={customizeColumnObj.customizeColumnUi !== React.null}>
        {customizeColumn}
      </UIUtils.RenderIf>
    | None => React.null
    }}
  </div>
}
