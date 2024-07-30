@react.component
let make = (
  ~totalResults,
  ~offset,
  ~resultsPerPage,
  ~setOffset,
  ~handleRefetch=?,
  ~currrentFetchCount,
  ~downloadCsv=?,
  ~isNewPaginator=false,
  ~actualData,
  ~tableDataLoading=false,
  ~setResultsPerPage=_ => (),
  ~paginationClass="",
  ~showResultsPerPageSelector=true,
) => {
  let (arrow, setArrow) = React.useState(_ => false)
  let url = RescriptReactRouter.useUrl()
  let currentPage = offset / resultsPerPage + 1
  let start = offset + 1

  let toNum = resultsPerPage + start > totalResults ? totalResults : resultsPerPage + start - 1
  let shouldRefetch = toNum > currrentFetchCount && toNum <= totalResults && !tableDataLoading
  React.useEffect(() => {
    if shouldRefetch {
      switch handleRefetch {
      | Some(fun) => fun()
      | None => ()
      }
    }
    None
  }, (shouldRefetch, handleRefetch))

  let selectInputOption = {
    [5, 10, 15, 25, 50]
    ->Array.filter(val => val <= totalResults)
    ->Array.map(Int.toString)
  }

  let paginate = React.useCallback(pageNumber => {
    let total = Math.ceil(Int.toFloat(totalResults) /. Int.toFloat(resultsPerPage))->Float.toInt
    // for handling page count
    let defaultPageNumber = Math.Int.min(total, pageNumber)
    let page = defaultPageNumber

    let newOffset = (page - 1) * resultsPerPage
    setOffset(_ => newOffset)
  }, (setOffset, resultsPerPage, currrentFetchCount, url.search, totalResults))

  // if totalResults >= resultsPerPage {
  //   <div className={`flex ${flexDirection} justify-between ${marginClass} ${paginationClass} `}>
  //     <div className={`flex flex-row w-full ${justify}`}>
  //       <RenderIf condition={!isMobileView && showResultsPerPageSelector}>
  //         <div
  //           className="flex self-center text-center text-gray-400 dark:text-gray-500 font-medium">
  //           {React.string(
  //             `Showing ${start->Int.toString} to ${toNum->Int.toString} of ${totalResults->Int.toString} entries`,
  //           )}
  //           <SelectBox.BaseDropdown
  //             options=selectInputOption
  //             buttonText=""
  //             searchable=false
  //             allowMultiSelect=false
  //             input=selectInput
  //             hideMultiSelectButtons=true
  //             deselectDisable=true
  //             buttonType=Button.Primary
  //             baseComponent={<Icon className="pl-2" size=20 name="chevron-down" />}
  //           />
  //         </div>
  //       </RenderIf>
  //       {switch downloadCsv {
  //       | Some(actionData) =>
  //         <div className="md:mr-2 lg:mr-5 mb-2">
  //           <LoadedTableContext value={actualData->LoadedTableContext.toInfoData}>
  //             actionData
  //           </LoadedTableContext>
  //         </div>
  //       | None => React.null
  //       }}
  //     </div>
  //     <div className="flex justify-end sm:justify-center tablePagination select-none">
  //       {if isNewPaginator {
  //         <NewPagination totalResults currentPage resultsPerPage paginate btnCount />
  //       } else {
  //         <Pagination totalResults currentPage resultsPerPage paginate btnCount />
  //       }}
  //     </div>
  //   </div>
  // } else {
  //   switch downloadCsv {
  //   | Some(actionData) =>
  //     <div className="flex justify-end mt-4">
  //       <LoadedTableContext value={actualData->LoadedTableContext.toInfoData}>
  //         actionData
  //       </LoadedTableContext>
  //     </div>

  //   | None => React.null
  //   }
  // }

  open HeadlessUI

  <div className="w-full mt-3 flex justify-end">
    <Menu \"as"="div" className="relative inline-block text-left">
      {_menuProps =>
        <div>
          <Menu.Button
            className="inline-flex whitespace-pre leading-5 justify-center text-sm  px-4 py-2 font-medium rounded-md hover:bg-opacity-80 bg-white border">
            {_buttonProps => {
              <>
                {`${toNum->Int.toString} per page`->React.string}
                <Icon
                  className={arrow
                    ? `rotate-0 transition duration-[250ms] ml-1 mt-1 opacity-60`
                    : `rotate-180 transition duration-[250ms] ml-1 mt-1 opacity-60`}
                  name="arrow-without-tail"
                  size=15
                />
              </>
            }}
          </Menu.Button>
          <Transition
            \"as"="span"
            enter="transition ease-out duration-100"
            enterFrom="transform opacity-0 scale-95"
            enterTo="transform opacity-100 scale-100"
            leave="transition ease-in duration-75"
            leaveFrom="transform opacity-100 scale-100"
            leaveTo="transform opacity-0 scale-95">
            {<Menu.Items
              className="absolute bottom-0 z-50 w-fit mb-11 bg-white dark:bg-jp-gray-950 divide-y divide-gray-100 rounded-md shadow-md ring-1 ring-black ring-opacity-5 focus:outline-none">
              {props => {
                if props["open"] {
                  setArrow(_ => true)
                } else {
                  setArrow(_ => false)
                }
                <>
                  <div className="px-1 py-1 ">
                    {selectInputOption
                    ->Array.mapWithIndex((option, i) =>
                      <Menu.Item key={i->Int.toString}>
                        {props =>
                          <div className="relative">
                            <button
                              onClick={_ =>
                                setResultsPerPage(_ => option->Int.fromString->Option.getOr(20))}
                              className={
                                let activeClasses = props["active"]
                                  ? "bg-gray-100 dark:bg-black"
                                  : ""
                                `group flex rounded-md items-center w-full px-3 py-2 text-sm ${activeClasses} font-medium text-start`
                              }>
                              <div className=""> {option->React.string} </div>
                            </button>
                          </div>}
                      </Menu.Item>
                    )
                    ->React.array}
                  </div>
                </>
              }}
            </Menu.Items>}
          </Transition>
        </div>}
    </Menu>
  </div>
}
