external formEventToInt: ReactEvent.Form.t => int = "%identity"

module NewPagination = {
  @react.component
  let make = (~resultsPerPage, ~totalResults, ~currentPage, ~paginate) => {
    let pageNumbers = []
    let (arrow, setArrow) = React.useState(_ => false)
    let total = Math.ceil(Int.toFloat(totalResults) /. Int.toFloat(resultsPerPage))->Float.toInt

    for x in 1 to total {
      Array.push(pageNumbers, x)->ignore
    }

    open HeadlessUI
    <div className="bg-white border rounded-lg font-medium flex">
      <RenderIf condition={currentPage > 1}>
        <div
          onClick={_evt => paginate(Math.Int.max(1, currentPage - 1))}
          className="flex gap-2 items-center w-full p-2 text-sm  hover:bg-gray-100 cursor-pointer">
          <Icon name="chevron-left" className="fill-ardra-secondary-300" size=12 />
          <div> {"Prev"->React.string} </div>
        </div>
      </RenderIf>
      <Menu \"as"="div" className="relative inline-block text-left">
        {_menuProps =>
          <div>
            <Menu.Button
              className="inline-flex whitespace-pre leading-5 justify-center text-sm  px-2 py-2 font-medium hover:bg-gray-100">
              {_buttonProps => {
                <>
                  {`${currentPage->Int.toString} of ${pageNumbers
                    ->Array.length
                    ->Int.toString}`->React.string}
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
                    <div className="px-1 py-1 max-h-36 overflow-scroll">
                      {pageNumbers
                      ->Array.mapWithIndex((option, i) =>
                        <Menu.Item key={i->Int.toString}>
                          {props =>
                            <div className="relative">
                              <button
                                onClick={_ => paginate(option)}
                                className={
                                  let activeClasses = props["active"]
                                    ? "bg-gray-100 dark:bg-black"
                                    : ""
                                  `group flex rounded-md items-center justify-center w-full px-3 py-2 text-sm ${activeClasses} font-medium text-start`
                                }>
                                <div className=""> {option->Int.toString->React.string} </div>
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
      <RenderIf condition={currentPage < Array.length(pageNumbers)}>
        <div
          onClick={_evt => paginate(currentPage + 1)}
          className="flex gap-2 items-center w-full p-2 text-sm  hover:bg-gray-100 cursor-pointer ">
          <div> {"Next"->React.string} </div>
          <Icon name="chevron-right" size=12 />
        </div>
      </RenderIf>
    </div>
  }
}

@react.component
let make = (
  ~totalResults,
  ~offset,
  ~resultsPerPage,
  ~setOffset,
  ~handleRefetch as _=?,
  ~currrentFetchCount,
  ~downloadCsv as _=?,
  ~isNewPaginator=false,
  ~actualData as _,
  ~tableDataLoading=false,
  ~setResultsPerPage=_ => (),
  ~paginationClass="",
  ~showResultsPerPageSelector=true,
) => {
  let (arrow, setArrow) = React.useState(_ => false)
  let currentPage = offset / resultsPerPage + 1
  let start = offset + 1

  let pageResultsCount =
    resultsPerPage + start > totalResults ? totalResults : resultsPerPage + start - 1

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
  }, (setOffset, resultsPerPage, currrentFetchCount, totalResults))

  open HeadlessUI
  <RenderIf condition={totalResults >= resultsPerPage}>
    <div className="w-full mt-3 flex justify-end gap-2">
      <Menu \"as"="div" className="relative inline-block text-left">
        {_menuProps =>
          <div>
            <Menu.Button
              className="inline-flex whitespace-pre leading-5 justify-center text-sm  px-4 py-2 font-medium rounded-lg hover:bg-opacity-80 bg-white border hover:bg-gray-100">
              {_buttonProps => {
                <>
                  {`${pageResultsCount->Int.toString} per page`->React.string}
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
      <NewPagination totalResults currentPage resultsPerPage paginate />
    </div>
  </RenderIf>
}
