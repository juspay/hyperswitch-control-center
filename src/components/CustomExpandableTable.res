open Table

@react.component
let make = (
  ~title,
  ~heading=[],
  ~rows,
  ~offset=0,
  ~fullWidth=true,
  ~showScrollBar=false,
  ~setSortedObj=?,
  ~sortedObj=?,
  ~setFilterObj=?,
  ~filterObj=?,
  ~onExpandIconClick,
  ~expandedRowIndexArray,
  ~getRowDetails,
  ~showSerial=false,
) => {
  if showSerial {
    heading->Array.unshift(makeHeaderInfo(~key="serial_number", ~title="S.No", ()))->ignore
  }

  let isMobileView = MatchMedia.useMobileChecker()

  let filterPresent = heading->Array.find(head => head.showFilter)->Js.Option.isSome
  let highlightEnabledFieldsArray = heading->Array.reduceWithIndex([], (acc, item, index) => {
    if item.highlightCellOnHover {
      let _ = Array.push(acc, index)
    }
    acc
  })

  let scrollBarClass = if showScrollBar {
    "show-scrollbar"
  } else {
    ""
  }

  let rowInfo: array<array<cell>> = {
    let a = rows->Array.mapWithIndex((data, i) => {
      if showSerial {
        data->Array.unshift(Text((i + 1)->Belt.Int.toString))->ignore
      }
      data
    })
    a
  }
  let headingsLen = heading->Array.length
  let widthClass = if fullWidth {
    "min-w-full"
  } else {
    ""
  }

  let handleUpdateFilterObj = (ev, i) => {
    switch setFilterObj {
    | Some(fn) =>
      fn((prevFilterObj: option<array<filterObject>>) => {
        prevFilterObj->Belt.Option.map(prevObj => {
          prevObj->Array.map(
            obj => {
              if obj.key === string_of_int(i) {
                {
                  key: string_of_int(i),
                  options: obj.options,
                  selected: ev->Identity.formReactEventToArrayOfString,
                }
              } else {
                obj
              }
            },
          )
        })
      })
    | None => ()
    }
  }

  let tableClass = ""
  let borderClass = "border border-jp-gray-500 dark:border-jp-gray-960 rounded"

  <div
    className={`overflow ${scrollBarClass} ${tableClass}`} //replaced "overflow-auto" -> to be tested with master
    style={ReactDOMStyle.make(~minHeight={filterPresent ? "30rem" : ""}, ())}>
    <AddDataAttributes attributes=[("data-expandable-table", title)]>
      <table className={`table-auto ${widthClass} h-full ${borderClass}`} colSpan=0>
        <UIUtils.RenderIf condition={heading->Array.length !== 0 && !isMobileView}>
          <thead>
            <tr>
              {heading
              ->Array.mapWithIndex((item, i) => {
                let isFirstCol = i === 0
                let isLastCol = i === headingsLen - 1
                let oldThemeRoundedClass = if isFirstCol {
                  "rounded-tl"
                } else if isLastCol {
                  "rounded-tr"
                } else {
                  ""
                }
                let roundedClass = oldThemeRoundedClass
                let borderClass = isLastCol ? "" : "border-jp-gray-500 dark:border-jp-gray-960"
                let borderClass = borderClass
                let bgColor = "bg-gradient-to-b from-jp-gray-450 to-jp-gray-350 dark:from-jp-gray-950  dark:to-jp-gray-950"
                let headerTextClass = "text-jp-gray-800 dark:text-jp-gray-text_darktheme dark:text-opacity-75"
                let fontWeight = "font-bold"
                let fontSize = "text-sm"
                let paddingClass = "px-4 py-3"
                <AddDataAttributes
                  attributes=[("data-table-heading", item.title)] key={i->string_of_int}>
                  <th className="p-0">
                    <div
                      className={`flex flex-row ${borderClass} justify-between items-center ${paddingClass} ${bgColor} ${headerTextClass} whitespace-pre ${roundedClass}`}>
                      <div className={`${fontWeight} ${fontSize}`}>
                        {React.string(item.title)}
                      </div>
                      <UIUtils.RenderIf condition={item.showFilter || item.showSort}>
                        <div className="flex flex-row items-center select-none">
                          <UIUtils.RenderIf condition={item.showSort}>
                            {
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
                                <div
                                  className="cursor-pointer text-gray-300 pl-4"
                                  onClick=handleSortClick>
                                  <SortIcons order size=13 />
                                </div>
                              </AddDataAttributes>
                            }
                          </UIUtils.RenderIf>
                          {if item.showFilter {
                            let (options, selected) =
                              filterObj
                              ->Belt.Option.flatMap(obj =>
                                switch obj[i] {
                                | Some(ele) => (ele.options, ele.selected)
                                | None => ([], [])
                                }->Some
                              )
                              ->Belt.Option.getWithDefault(([], []))

                            if options->Array.length > 1 {
                              let filterInput: ReactFinalForm.fieldRenderPropsInput = {
                                name: "filterInput",
                                onBlur: _ev => (),
                                onChange: ev => handleUpdateFilterObj(ev, i),
                                onFocus: _ev => (),
                                value: selected->Array.map(Js.Json.string)->Js.Json.array,
                                checked: true,
                              }

                              <SelectBox.BaseDropdown
                                allowMultiSelect=true
                                hideMultiSelectButtons=true
                                buttonText=""
                                input={filterInput}
                                options={options->SelectBox.makeOptions}
                                deselectDisable=false
                                baseComponent={<Icon
                                  className="align-middle text-gray-400" name="filter" size=12
                                />}
                                autoApply=false
                              />
                            } else {
                              React.null
                            }
                          } else {
                            React.null
                          }}
                        </div>
                      </UIUtils.RenderIf>
                    </div>
                  </th>
                </AddDataAttributes>
              })
              ->React.array}
            </tr>
          </thead>
        </UIUtils.RenderIf>
        <tbody>
          {rowInfo
          ->Array.mapWithIndex((item: array<cell>, rowIndex) => {
            <CollapsableTableRow
              key={string_of_int(rowIndex)}
              item
              rowIndex
              offset
              highlightEnabledFieldsArray
              expandedRowIndexArray
              onExpandIconClick
              getRowDetails
              heading
              title
            />
          })
          ->React.array}
        </tbody>
      </table>
    </AddDataAttributes>
  </div>
}
