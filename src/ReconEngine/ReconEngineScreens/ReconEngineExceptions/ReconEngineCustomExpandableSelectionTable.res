open Table
open Typography

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

// TODO:: Refactoring required
module TableHeader = {
  @react.component
  let make = (
    ~heading: array<Table.header>,
    ~headingsLen: int,
    ~isMobileView: bool,
    ~firstColRoundedHeadingClass: string,
    ~lastColRoundedHeadingClass: string,
    ~headingBgColor: string,
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
            let roundedClass = switch (isFirstCol, isLastCol) {
            | (true, _) => firstColRoundedHeadingClass
            | (_, true) => lastColRoundedHeadingClass
            | _ => ""
            }
            let borderClass = isLastCol ? "" : "border-nd_gray-200"
            <AddDataAttributes
              attributes=[("data-table-heading", item.title)] key={i->Int.toString}>
              <th className="p-0">
                <div
                  className={`flex flex-row ${borderClass} justify-between items-center !px-4 !py-3 ${headingBgColor} whitespace-pre ${roundedClass}`}>
                  <div className={`${body.sm.semibold} text-nd_gray-400`}>
                    {React.string(item.title)}
                  </div>
                  <RenderIf condition={item.showFilter || item.showSort}>
                    <div className="flex flex-row items-center select-none">
                      <RenderIf condition={item.showFilter}>
                        {
                          let (options, selected) =
                            filterObj
                            ->Option.flatMap(obj => obj->Array.get(i))
                            ->Option.mapOr(([], []), ele => (ele.options, ele.selected))

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
  ~heading as headingProp,
  ~getSectionRowDetails,
  ~showScrollBar=true,
  ~showOptions=true,
  ~selectedRows=[],
  ~onRowSelect: option<(array<JSON.t> => array<JSON.t>) => unit>=?,
  ~sections: array<ReconEngineExceptionTransactionTypes.tableSection>,
) => {
  let heading = if showOptions {
    [makeHeaderInfo(~key="options", ~title="")]->Array.concat(headingProp)
  } else {
    headingProp
  }

  let isMobileView = MatchMedia.useMobileChecker()

  let (sectionExpandedRowsDict, setSectionExpandedRowsDict) = React.useState(_ => Dict.make())

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

  let headingsLen = heading->Array.length
  let handleUpdateFilterObj = (_ev, _i) => ()

  let renderTableSection = (
    sectionRows: array<array<cell>>,
    sectionRowData: array<JSON.t>,
    sectionIndex: int,
  ) => {
    let sectionRowInfo = RowProcessor.make(sectionRows, false)

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
      getSectionRowDetails(sectionIndex, rowIndex)
    }

    <TableBody
      rowInfo=sectionRowInfo
      rowData=sectionRowData
      expandedRows=sectionExpandedRows
      onExpandClick=onSectionExpandIconClick
      getRowDetailsFn=sectionGetRowDetails
      rowCount={sectionRowInfo->Array.length}
      offset=0
      highlightEnabledFieldsArray
      heading
      title
      rowFontSize="text-sm"
      rowFontStyle="font-medium"
      rowFontColor="text-nd_gray-600"
      isLastRowRounded=false
      rowComponentInCell=true
      customRowStyle="text-sm"
      showOptions
      selectedRows
      ?onRowSelect
    />
  }

  let renderSections = sections => {
    <>
      {sections
      ->Array.mapWithIndex((
        section: ReconEngineExceptionTransactionTypes.tableSection,
        sectionIndex,
      ) => {
        <div key={`section-${sectionIndex->Int.toString}`} className="mb-6">
          {section.titleElement}
          <div className="border rounded-xl overflow-scroll">
            <table className="table-auto w-full h-full" colSpan=0>
              <TableHeader
                heading
                headingsLen
                isMobileView
                firstColRoundedHeadingClass="rounded-tl-xl"
                lastColRoundedHeadingClass="rounded-tr-xl"
                headingBgColor="bg-nd_gray-25"
                filterObj=None
                handleUpdateFilterObj
              />
              {renderTableSection(section.rows, section.rowData, sectionIndex)}
            </table>
          </div>
        </div>
      })
      ->React.array}
    </>
  }

  <>
    <RenderIf condition={showScrollBar}>
      <style> {expandableTableScrollbarCss->React.string} </style>
    </RenderIf>
    <div className={`overflow-scroll ${scrollBarClass}`}>
      <AddDataAttributes attributes=[("data-expandable-table", title)]>
        {renderSections(sections)}
      </AddDataAttributes>
    </div>
  </>
}
