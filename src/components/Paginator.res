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
  let url = RescriptReactRouter.useUrl()
  let currentPage = offset / resultsPerPage + 1
  let start = offset + 1
  let isMobileView = MatchMedia.useMobileChecker()
  let isTabView = MatchMedia.useMatchMedia("(max-width: 800px)") && !isMobileView
  let mobileFlexDirection = isMobileView ? "flex-row" : "flex-col md:flex-row"
  let (flexDirection, btnCount, justify) = switch downloadCsv {
  | Some(_) => (mobileFlexDirection, isTabView ? 2 : 4, "items-center justify-between")
  | None => ("flex-row", isMobileView ? 2 : 4, "justify-start")
  }

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
    [5, 10, 15, 20, 50]
    ->Array.filter(val => val <= totalResults)
    ->Array.map(Int.toString)
    ->SelectBox.makeOptions
  }
  let selectInput: ReactFinalForm.fieldRenderPropsInput = {
    name: "dummy-name",
    onBlur: _ => (),
    onChange: ev => {
      setResultsPerPage(_ => {
        ev->Identity.formReactEventToString->Int.fromString->Option.getOr(15)
      })
    },
    onFocus: _ => (),
    value: resultsPerPage->Int.toString->JSON.Encode.string,
    checked: true,
  }
  let paginate = React.useCallback(pageNumber => {
    let total = Math.ceil(Int.toFloat(totalResults) /. Int.toFloat(resultsPerPage))->Float.toInt
    // for handling page count
    let defaultPageNumber = Math.Int.min(total, pageNumber)
    let page = defaultPageNumber

    let newOffset = (page - 1) * resultsPerPage
    setOffset(_ => newOffset)
  }, (setOffset, resultsPerPage, currrentFetchCount, url.search, totalResults))

  let marginClass = "mt-4 md:mr-0"

  if totalResults >= resultsPerPage {
    <div className={`flex ${flexDirection} justify-between ${marginClass} ${paginationClass} `}>
      <div className={`flex flex-row w-full ${justify}`}>
        <RenderIf condition={!isMobileView && showResultsPerPageSelector}>
          <div
            className="flex self-center text-center text-gray-400 dark:text-gray-500 font-medium">
            {React.string(
              `Showing ${start->Int.toString} to ${toNum->Int.toString} of ${totalResults->Int.toString} entries`,
            )}
            <SelectBox.BaseDropdown
              options=selectInputOption
              fixedDropDownDirection={TopRight}
              buttonText=""
              searchable=false
              allowMultiSelect=false
              input=selectInput
              hideMultiSelectButtons=true
              deselectDisable=true
              buttonType=Button.Primary
              baseComponent={<Icon className="pl-2" size=20 name="chevron-down" />}
            />
          </div>
        </RenderIf>
        {switch downloadCsv {
        | Some(actionData) =>
          <div className="md:mr-2 lg:mr-5 mb-2">
            <LoadedTableContext value={actualData->LoadedTableContext.toInfoData}>
              actionData
            </LoadedTableContext>
          </div>
        | None => React.null
        }}
      </div>
      <div className="flex justify-end sm:justify-center tablePagination p-1 select-none">
        {if isNewPaginator {
          <NewPagination totalResults currentPage resultsPerPage paginate btnCount />
        } else {
          <Pagination totalResults currentPage resultsPerPage paginate btnCount />
        }}
      </div>
    </div>
  } else {
    switch downloadCsv {
    | Some(actionData) =>
      <div className="flex justify-end mt-4">
        <LoadedTableContext value={actualData->LoadedTableContext.toInfoData}>
          actionData
        </LoadedTableContext>
      </div>

    | None => React.null
    }
  }
}
