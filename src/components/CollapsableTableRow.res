@react.component
let make = (
  ~item: array<Table.cell>,
  ~rowIndex,
  ~offset as _,
  ~highlightEnabledFieldsArray,
  ~expandedRowIndexArray,
  ~onExpandIconClick,
  ~getRowDetails,
  ~heading,
  ~title,
  ~rowFontSize="text-sm",
  ~rowFontStyle="font-fira-code",
  ~rowFontColor="text-jp-gray-900 dark:text-jp-gray-text_darktheme text-opacity-75 dark:text-opacity-75",
  ~totalRows,
  ~isLastRowRounded=false,
  ~rowComponentInCell=true,
  ~customRowStyle="",
  ~showOptions=false,
  ~selectedRows=[],
  ~onRowSelect: option<(array<JSON.t> => array<JSON.t>) => unit>=?,
  ~rowData: option<JSON.t>=?,
) => {
  let isCurrentRowExpanded = expandedRowIndexArray->Array.includes(rowIndex)
  let headingArray = []
  let isLastRow = rowIndex === totalRows - 1

  heading->Array.forEach((item: TableUtils.header) => {
    headingArray->Array.push(item.title)->ignore
  })
  let borderRadius = "rounded-md"

  let isRowSelected = React.useMemo(() => {
    switch rowData {
    | Some(data) =>
      selectedRows->Array.some(selectedRow => {
        selectedRow === data
      })
    | None => false
    }
  }, (selectedRows, rowData))

  let handleRowSelection = () => {
    switch (onRowSelect, rowData) {
    | (Some(selectFn), Some(data)) =>
      if isRowSelected {
        selectFn(_ => selectedRows->Array.filter(row => row !== data))
      } else {
        selectFn(_ => selectedRows->Array.concat([data]))
      }
    | _ => ()
    }
  }

  <>
    <DesktopView>
      <tr
        className={`group h-full ${borderRadius} bg-white dark:bg-jp-gray-lightgray_background hover:bg-jp-gray-table_hover dark:hover:bg-jp-gray-100 dark:hover:bg-opacity-10 ${rowFontColor} ${rowFontStyle} transition duration-300 ease-in-out ${rowFontSize}}`}>
        <RenderIf condition={showOptions}>
          <td className="h-full p-0 align-top border-t border-jp-gray-500 dark:border-jp-gray-960">
            <div className="h-full box-border pl-4 py-3">
              <div className="flex flex-row gap-3 items-center">
                <div onClick={_ => handleRowSelection()}>
                  <CheckBoxIcon isSelected={isRowSelected} checkboxDimension="h-4 w-4" />
                </div>
              </div>
            </div>
          </td>
        </RenderIf>
        {item
        ->Array.mapWithIndex((obj: Table.cell, cellIndex) => {
          let showBorderTop = switch obj {
          | Text(x) => x !== "-"
          | _ => true
          }

          let paddingClass = switch obj {
          | Link(_) => "pt-2"
          | _ => "py-3"
          }

          let highlightCell = highlightEnabledFieldsArray->Array.includes(cellIndex)
          let borderTop = showBorderTop ? "border-t" : "border-t-0"
          let borderClass = `${borderTop} border-jp-gray-500 dark:border-jp-gray-960`
          let hCell = highlightCell ? "hover:font-bold" : ""
          let cursorI = cellIndex == 0 ? "cursor-pointer" : ""
          let location = `${title}_tr${(rowIndex + 1)->Int.toString}_td${(cellIndex + 1)
              ->Int.toString}`
          let colsLen = item->Array.length
          let isFirstCell = cellIndex === 0
          let isLastCell = cellIndex === colsLen - 1

          let roundedClass = if isLastRow && isLastRowRounded {
            if isFirstCell {
              "rounded-bl-xl"
            } else if isLastCell {
              "rounded-br-xl"
            } else {
              ""
            }
          } else {
            ""
          }
          <AddDataAttributes
            key={cellIndex->Int.toString} attributes=[("data-table-location", location)]>
            <td
              key={Int.toString(cellIndex)}
              className={`h-full p-0 align-top ${borderClass} ${roundedClass} ${hCell} ${cursorI}`}
              onClick={_ => {
                if cellIndex == 0 {
                  onExpandIconClick(isCurrentRowExpanded, rowIndex)
                }
              }}>
              <div className={`h-full box-border px-4 ${paddingClass}`}>
                <div className={`flex flex-row gap-4 items-center ${customRowStyle}`}>
                  <RenderIf condition={cellIndex === 0}>
                    <Icon name={isCurrentRowExpanded ? "caret-down" : "caret-right"} size=14 />
                  </RenderIf>
                  <Table.TableCell cell=obj />
                </div>
              </div>
            </td>
          </AddDataAttributes>
        })
        ->React.array}
      </tr>
      <RenderIf condition={isCurrentRowExpanded && rowComponentInCell}>
        <AddDataAttributes attributes=[("data-table-row-expanded", (rowIndex + 1)->Int.toString)]>
          <tr className="dark:border-jp-gray-dark_disable_border_color">
            <td colSpan=12 className=""> {getRowDetails(rowIndex)} </td>
          </tr>
        </AddDataAttributes>
      </RenderIf>
      <RenderIf condition={isCurrentRowExpanded && !rowComponentInCell}>
        <AddDataAttributes attributes=[("data-table-row-expanded", (rowIndex + 1)->Int.toString)]>
          {getRowDetails(rowIndex)}
        </AddDataAttributes>
      </RenderIf>
    </DesktopView>
    <MobileView>
      <div className="px-3 py-4 bg-white dark:bg-jp-gray-lightgray_background">
        {item
        ->Array.mapWithIndex((obj, index) => {
          let heading = headingArray->Array.get(index)->Option.getOr("")
          <RenderIf condition={index !== 0} key={index->Int.toString}>
            <div className="flex mb-5 justify-between">
              <div className="text-jp-gray-900 opacity-50 font-medium">
                {React.string(heading)}
              </div>
              <div className="font-semibold">
                <Table.TableCell cell=obj />
              </div>
            </div>
          </RenderIf>
        })
        ->React.array}
        {getRowDetails(rowIndex)}
      </div>
    </MobileView>
  </>
}
