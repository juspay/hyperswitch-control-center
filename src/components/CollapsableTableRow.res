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
) => {
  let isCurrentRowExpanded = expandedRowIndexArray->Array.includes(rowIndex)

  let headingArray = []

  heading->Array.forEach((item: TableUtils.header) => {
    headingArray->Array.push(item.title)->ignore
  })
  let textColor = "text-jp-gray-900 dark:text-jp-gray-text_darktheme text-opacity-75 dark:text-opacity-75"
  let fontStyle = "font-fira-code"
  let fontSize = "text-sm"
  let borderRadius = "rounded-md"

  <>
    <DesktopView>
      <tr
        className={`group h-full ${borderRadius} bg-white dark:bg-jp-gray-lightgray_background hover:bg-jp-gray-table_hover dark:hover:bg-jp-gray-100 dark:hover:bg-opacity-10 ${textColor} ${fontStyle} transition duration-300 ease-in-out ${fontSize}`}>
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
          let location = `${title}_tr${(rowIndex + 1)->Belt.Int.toString}_td${(cellIndex + 1)
              ->Belt.Int.toString}`
          <AddDataAttributes
            key={cellIndex->string_of_int} attributes=[("data-table-location", location)]>
            <td
              key={string_of_int(cellIndex)}
              className={`h-full p-0 align-top ${borderClass} ${hCell} ${cursorI}`}
              onClick={_ => {
                if cellIndex == 0 {
                  onExpandIconClick(isCurrentRowExpanded, rowIndex)
                }
              }}>
              <div className={`h-full box-border px-4 ${paddingClass}`}>
                <div className="flex flex-row gap-4 items-center">
                  <UIUtils.RenderIf condition={cellIndex === 0}>
                    <Icon name={isCurrentRowExpanded ? "caret-down" : "caret-right"} size=14 />
                  </UIUtils.RenderIf>
                  <Table.TableCell cell=obj />
                </div>
              </div>
            </td>
          </AddDataAttributes>
        })
        ->React.array}
      </tr>
      <UIUtils.RenderIf condition=isCurrentRowExpanded>
        <AddDataAttributes
          attributes=[("data-table-row-expanded", (rowIndex + 1)->Belt.Int.toString)]>
          <tr className="dark:border-jp-gray-dark_disable_border_color">
            <td colSpan=12 className=""> {getRowDetails(rowIndex)} </td>
          </tr>
        </AddDataAttributes>
      </UIUtils.RenderIf>
    </DesktopView>
    <MobileView>
      <div className="px-3 py-4 bg-white dark:bg-jp-gray-lightgray_background">
        {item
        ->Array.mapWithIndex((obj, index) => {
          let heading = headingArray->Belt.Array.get(index)->Belt.Option.getWithDefault("")
          <UIUtils.RenderIf condition={index !== 0} key={index->string_of_int}>
            <div className="flex mb-5 justify-between">
              <div className="text-jp-gray-900 opacity-50 font-medium">
                {React.string(heading)}
              </div>
              <div className="font-semibold">
                <Table.TableCell cell=obj />
              </div>
            </div>
          </UIUtils.RenderIf>
        })
        ->React.array}
        {getRowDetails(rowIndex)}
      </div>
    </MobileView>
  </>
}
