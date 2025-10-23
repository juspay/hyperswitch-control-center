open Table

module RowProcessor = {
  let make = (rows: array<array<cell>>, showSerial: bool) => {
    rows->Array.mapWithIndex((data, i) => {
      if showSerial {
        data->Array.unshift(Text((i + 1)->Int.toString))->ignore
      }
      data
    })
  }
}

// Module to handle table header rendering
module TableHeader = {
  @react.component
  let make = (
    ~heading: array<Table.header>,
    ~headingsLen: int,
    ~isMobileView: bool,
    ~firstColRoundedHeadingClass: string,
    ~lastColRoundedHeadingClass: string,
    ~headingBgColor: string,
    ~headingFontColor: string,
    ~headingFontWeight: string,
    ~filterObj: option<array<Table.filterObject>>,
    ~handleUpdateFilterObj: (ReactEvent.Form.t, int) => unit,
  ) => {
    <RenderIf condition={heading->Array.length !== 0 && !isMobileView}>
      <thead>
        <tr>
          {heading
          ->Array.mapWithIndex((item, i) => {
            let isFirstCol = i === 0
            let isLastCol = i === headingsLen - 1
            let oldThemeRoundedClass = if isFirstCol {
              firstColRoundedHeadingClass
            } else if isLastCol {
              lastColRoundedHeadingClass
            } else {
              ""
            }
            let roundedClass = oldThemeRoundedClass
            let borderClass = isLastCol ? "" : "border-jp-gray-500 dark:border-jp-gray-960"
            let fontSize = "text-sm"
            let paddingClass = "px-4 py-3"
            <AddDataAttributes
              attributes=[("data-table-heading", item.title)] key={i->Int.toString}>
              <th className="p-0">
                <div
                  className={`flex flex-row ${borderClass} justify-between items-center ${paddingClass} ${headingBgColor} ${headingFontColor} whitespace-pre ${roundedClass}`}>
                  <div className={`${headingFontWeight} ${fontSize}`}>
                    {React.string(item.title)}
                  </div>
                  <RenderIf condition={item.showFilter || item.showSort}>
                    <div className="flex flex-row items-center select-none">
                      <RenderIf condition={item.showFilter}>
                        {
                          let (options, selected) =
                            filterObj
                            ->Option.flatMap(obj =>
                              switch obj[i] {
                              | Some(ele) => (ele.options, ele.selected)
                              | None => ([], [])
                              }->Some
                            )
                            ->Option.getOr(([], []))

                          <RenderIf condition={options->Array.length > 1}>
                            {
                              let filterInput: ReactFinalForm.fieldRenderPropsInput = {
                                name: "filterInput",
                                onBlur: _ => (),
                                onChange: ev => handleUpdateFilterObj(ev, i),
                                onFocus: _ => (),
                                value: selected->Array.map(JSON.Encode.string)->JSON.Encode.array,
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
                            }
                          </RenderIf>
                        }
                      </RenderIf>
                    </div>
                  </RenderIf>
                </div>
              </th>
            </AddDataAttributes>
          })
          ->React.array}
        </tr>
      </thead>
    </RenderIf>
  }
}

// Module to handle table body rendering
module TableBody = {
  @react.component
  let make = (
    ~rowInfo: array<array<cell>>,
    ~rowData: array<JSON.t>,
    ~expandedRows: array<int>,
    ~onExpandClick: (bool, int) => unit,
    ~getRowDetailsFn: int => React.element,
    ~rowCount: int,
    ~offset: int,
    ~highlightEnabledFieldsArray: array<int>,
    ~heading: array<Table.header>,
    ~title: string,
    ~rowFontSize: string,
    ~rowFontStyle: string,
    ~rowFontColor: string,
    ~isLastRowRounded: bool,
    ~rowComponentInCell: bool,
    ~customRowStyle: string,
    ~showOptions: bool,
    ~selectedRows: array<JSON.t>,
    ~onRowSelect: option<(array<JSON.t> => array<JSON.t>) => unit>=?,
  ) => {
    <tbody>
      {rowInfo
      ->Array.mapWithIndex((item: array<cell>, rowIndex) => {
        <CollapsableTableRow
          key={Int.toString(rowIndex)}
          item
          rowIndex
          offset
          highlightEnabledFieldsArray
          expandedRowIndexArray={expandedRows}
          onExpandIconClick={onExpandClick}
          getRowDetails={getRowDetailsFn}
          heading
          title
          rowFontSize
          rowFontStyle
          rowFontColor
          totalRows={rowCount}
          isLastRowRounded
          rowComponentInCell
          customRowStyle
          showOptions
          selectedRows
          ?onRowSelect
          rowData={rowData->Array.get(rowIndex)->Option.getOr(JSON.Encode.null)}
        />
      })
      ->React.array}
    </tbody>
  }
}

@react.component
let make = (
  ~title,
  ~heading=[],
  ~rows=[],
  ~offset=0,
  ~fullWidth=true,
  ~showScrollBar=false,
  ~setFilterObj=?,
  ~filterObj=?,
  ~onExpandIconClick,
  ~expandedRowIndexArray,
  ~getRowDetails,
  ~getSectionRowDetails=?,
  ~showSerial=false,
  ~tableClass="",
  ~borderClass="border border-jp-gray-500 dark:border-jp-gray-960 rounded",
  ~firstColRoundedHeadingClass="rounded-tl",
  ~lastColRoundedHeadingClass="rounded-tr",
  ~headingBgColor="bg-gradient-to-b from-jp-gray-250 to-jp-gray-200 dark:from-jp-gray-950 dark:to-jp-gray-950",
  ~headingFontWeight="font-bold",
  ~headingFontColor="text-jp-gray-800 dark:text-jp-gray-text_darktheme dark:text-opacity-75",
  ~rowFontSize="text-sm",
  ~rowFontStyle="font-fira-code",
  ~rowFontColor="text-jp-gray-900 dark:text-jp-gray-text_darktheme text-opacity-75 dark:text-opacity-75",
  ~isLastRowRounded=false,
  ~rowComponentInCell=true,
  ~customRowStyle="",
  ~showOptions=false,
  ~selectedRows=[],
  ~onRowSelect: option<(array<JSON.t> => array<JSON.t>) => unit>=?,
  ~rowData=[],
  ~sections: array<Table.tableSection>=[],
) => {
  if showSerial {
    heading->Array.unshift(makeHeaderInfo(~key="serial_number", ~title="S.No"))->ignore
  }

  if showOptions {
    heading->Array.unshift(makeHeaderInfo(~key="options", ~title=""))->ignore
  }

  let isMobileView = MatchMedia.useMobileChecker()

  // State to track expanded rows for each section (using Dict to avoid hook ordering issues)
  let (sectionExpandedRowsDict, setSectionExpandedRowsDict) = React.useState(_ => Dict.make())

  let filterPresent = heading->Array.find(head => head.showFilter)->Option.isSome
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

  let expandableTableScrollbarCss = `
  @supports (-webkit-appearance: none) {
    .show-scrollbar {
      scrollbar-width: auto;
      scrollbar-color: #CACFD8; 
    }

    .show-scrollbar::-webkit-scrollbar {
      display: block;
      height: 6px;
      width: 5px;
    }

    .show-scrollbar::-webkit-scrollbar-thumb {
      background-color: #CACFD8; 
      border-radius: 3px;
    }

    .show-scrollbar::-webkit-scrollbar-track {
      display:none;
    }
  }
    `

  let rowInfo: array<array<cell>> = RowProcessor.make(rows, showSerial)
  let headingsLen = heading->Array.length
  let widthClass = if fullWidth {
    "min-w-full"
  } else {
    ""
  }
  let totalRows = rowInfo->Array.length
  let handleUpdateFilterObj = (ev, i) => {
    switch setFilterObj {
    | Some(fn) =>
      fn((prevFilterObj: option<array<filterObject>>) => {
        prevFilterObj->Option.map(prevObj => {
          prevObj->Array.map(
            obj =>
              obj.key === Int.toString(i)
                ? {
                    key: Int.toString(i),
                    options: obj.options,
                    selected: ev->Identity.formReactEventToArrayOfString,
                  }
                : obj,
          )
        })
      })
    | None => ()
    }
  }

  let renderTableSection = (
    sectionRows: array<array<cell>>,
    sectionRowData: array<JSON.t>,
    sectionIndex: int,
  ) => {
    let sectionRowInfo = RowProcessor.make(sectionRows, showSerial)

    // Get expanded rows for this section from the shared state
    let sectionKey = sectionIndex->Int.toString
    let sectionExpandedRows = sectionExpandedRowsDict->Dict.get(sectionKey)->Option.getOr([])

    let onSectionExpandIconClick = (isExpanded, rowIndex) => {
      setSectionExpandedRowsDict(prev => {
        let newDict = prev->Dict.toArray->Dict.fromArray
        let currentExpanded = newDict->Dict.get(sectionKey)->Option.getOr([])
        let updatedExpanded = isExpanded
          ? currentExpanded->Array.filter(idx => idx !== rowIndex)
          : currentExpanded->Array.concat([rowIndex])
        newDict->Dict.set(sectionKey, updatedExpanded)
        newDict
      })
    }

    let sectionGetRowDetails = (rowIndex: int) => {
      switch getSectionRowDetails {
      | Some(fn) => fn(sectionIndex, rowIndex)
      | None => getRowDetails(rowIndex)
      }
    }

    <TableBody
      rowInfo=sectionRowInfo
      rowData=sectionRowData
      expandedRows=sectionExpandedRows
      onExpandClick=onSectionExpandIconClick
      getRowDetailsFn=sectionGetRowDetails
      rowCount={sectionRowInfo->Array.length}
      offset
      highlightEnabledFieldsArray
      heading
      title
      rowFontSize
      rowFontStyle
      rowFontColor
      isLastRowRounded
      rowComponentInCell
      customRowStyle
      showOptions
      selectedRows
      ?onRowSelect
    />
  }

  let renderSections = sections_ => {
    <>
      <RenderIf condition={sections_->Array.length === 0}>
        <div className={`${borderClass} overflow-scroll`}>
          <table className={`table-auto ${widthClass} h-full`} colSpan=0>
            <TableHeader
              heading
              headingsLen
              isMobileView
              firstColRoundedHeadingClass
              lastColRoundedHeadingClass
              headingBgColor
              headingFontColor
              headingFontWeight
              filterObj
              handleUpdateFilterObj
            />
            <TableBody
              rowInfo
              rowData
              expandedRows=expandedRowIndexArray
              onExpandClick=onExpandIconClick
              getRowDetailsFn=getRowDetails
              rowCount=totalRows
              offset
              highlightEnabledFieldsArray
              heading
              title
              rowFontSize
              rowFontStyle
              rowFontColor
              isLastRowRounded
              rowComponentInCell
              customRowStyle
              showOptions
              selectedRows
              ?onRowSelect
            />
          </table>
        </div>
      </RenderIf>
      <RenderIf condition={sections_->Array.length > 0}>
        {sections_
        ->Array.mapWithIndex((section, sectionIndex) => {
          <div key={"section-" ++ Int.toString(sectionIndex)} className="mb-6">
            {section.titleElement}
            <div className={`${borderClass} overflow-scroll`}>
              <table className={`table-auto w-full h-full`} colSpan=0>
                <TableHeader
                  heading
                  headingsLen
                  isMobileView
                  firstColRoundedHeadingClass
                  lastColRoundedHeadingClass
                  headingBgColor
                  headingFontColor
                  headingFontWeight
                  filterObj
                  handleUpdateFilterObj
                />
                {renderTableSection(section.rows, section.rowData, sectionIndex)}
              </table>
            </div>
          </div>
        })
        ->React.array}
      </RenderIf>
    </>
  }

  <>
    <RenderIf condition={showScrollBar}>
      <style> {React.string(expandableTableScrollbarCss)} </style>
    </RenderIf>
    <div
      className={`overflow-scroll ${scrollBarClass} ${tableClass}`}
      style={minHeight: {filterPresent ? "30rem" : ""}}>
      <AddDataAttributes attributes=[("data-expandable-table", title)]>
        {renderSections(sections)}
      </AddDataAttributes>
    </div>
  </>
}
