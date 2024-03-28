module RenderSearchResultBody = {
  open GlobalSearchTypes
  open LogicUtils
  open UIUtils
  @react.component
  let make = (~section: resultType) => {
    let redirectOnSelect = element => {
      let redirectLink = element.redirect_link->JSON.Decode.string->Option.getOr("")
      if redirectLink->isNonEmptyString {
        redirectLink->RescriptReactRouter.replace
      }
    }

    switch section.section {
    | Local =>
      section.results
      ->Array.mapWithIndex((item, indx) => {
        let elementsArray = item.texts
        <div
          className={`p-2 text-sm cursor-pointer hover:bg-gray-100 -ml-2`}
          key={indx->Int.toString}
          onClick={_ => redirectOnSelect(item)}>
          {elementsArray
          ->Array.mapWithIndex((item, index) => {
            let elementValue = item->JSON.Decode.string->Option.getOr("")
            <RenderIf condition={elementValue->isNonEmptyString} key={index->Int.toString}>
              <span
                key={index->Int.toString}
                className=" font-medium text-lightgray_background opacity-60 underline underline-offset-4">
                {elementValue->React.string}
              </span>
              <RenderIf condition={index >= 0 && index < elementsArray->Array.length - 1}>
                <span className="mx-2 text-lightgray_background opacity-60">
                  {">"->React.string}
                </span>
              </RenderIf>
            </RenderIf>
          })
          ->React.array}
        </div>
      })
      ->React.array
    | PaymentIntents => <PaymentIntentTable.PreviewTable data={section.results} />
    | PaymentAttempts => <PaymentAttemptTable.PreviewTable data={section.results} />
    | Refunds => <RefundsTable.PreviewTable data={section.results} />
    | Disputes => <DisputeTable.PreviewTable data={section.results} />
    | Others | Default => "Not implemented"->React.string
    }
  }
}

module SearchResultsComponent = {
  open GlobalSearchTypes
  @react.component
  let make = (~searchResults, ~searchText) => {
    searchResults
    ->Array.mapWithIndex((section: resultType, i) => {
      let borderClass = searchResults->Array.length > 0 ? "" : "border-b dark:border-jp-gray-960"
      <div className={`py-5 ${borderClass}`} key={i->Int.toString}>
        <div className="flex justify-between">
          <div className="text-lightgray_background font-bold  text-lg pb-2">
            {section.section->getSectionHeader->React.string}
          </div>
          <GlobalSearchBarUtils.ShowMoreLink
            section textStyleClass="text-sm pt-2 font-medium text-blue-900" searchText
          />
        </div>
        <RenderSearchResultBody section />
      </div>
    })
    ->React.array
  }
}

@react.component
let make = () => {
  open LogicUtils
  open SearchResultsPageUtils
  open GlobalSearchTypes
  open GlobalSearchBarUtils
  let fetchDetails = APIUtils.useUpdateMethod()
  let url = RescriptReactRouter.useUrl()
  let prefix = useUrlPrefix()
  let (state, setState) = React.useState(_ => Idle)
  let (searchText, setSearchText) = React.useState(_ => "")
  let (searchResults, setSearchResults) = React.useState(_ => [])
  let globalSearchResult = HyperswitchAtom.globalSeacrchAtom->Recoil.useRecoilValueFromAtom
  let merchentDetails = HSwitchUtils.useMerchantDetailsValue()
  let isReconEnabled = merchentDetails.recon_status === Active
  let hswitchTabs = SidebarValues.useGetSidebarValues(~isReconEnabled)
  let query = UrlUtils.useGetFilterDictFromUrl("")->getString("query", "")
  // TODO: need to add feature flag here
  let isShowRemoteResults = !(
    HSLocalStorage.getFromUserDetails("user_role")->String.includes("internal_")
  )
  let getSearchResults = async results => {
    try {
      let url = APIUtils.getURL(~entityName=GLOBAL_SEARCH, ~methodType=Post, ())
      let body = [("query", query->JSON.Encode.string)]->LogicUtils.getJsonFromArrayOfJson
      let response = await fetchDetails(url, body, Post, ())

      let local_results = []
      results->Array.forEach((item: resultType) => {
        switch item.section {
        | Local => local_results->Array.pushMany(item.results)
        | _ => ()
        }
      })

      let remote_results = response->parseResponse

      let data = {
        local_results,
        remote_results,
        searchText: query,
      }

      let (results, text) = data->getSearchresults

      setSearchResults(_ => results)
      setSearchText(_ => text)

      setState(_ => Loaded)
    } catch {
    | _ => setState(_ => Failed)
    }
  }

  React.useEffect2(() => {
    let (results, text) = globalSearchResult->getSearchresults

    if text->isNonEmptyString {
      setSearchResults(_ => results)
      setSearchText(_ => text)
      setState(_ => Loaded)
    } else if query->isNonEmptyString {
      let results = []
      setState(_ => Loading)
      let localResults: resultType = query->GlobalSearchBarUtils.getLocalMatchedResults(hswitchTabs)

      if localResults.results->Array.length > 0 {
        results->Array.push(localResults)
      }

      if isShowRemoteResults {
        getSearchResults(results)->ignore
      } else {
        if results->Array.length > 0 {
          setSearchResults(_ => results)
        } else {
          setSearchResults(_ => [])
        }
        setState(_ => Loaded)
      }
    } else {
      setState(_ => Idle)
      setSearchResults(_ => [])
    }

    None
  }, (query, url.search))

  <div>
    <PageUtils.PageHeading title="Search results" />
    {switch state {
    | Loading =>
      <div className="my-14 py-4">
        <Loader />
      </div>
    | _ =>
      if searchResults->Array.length === 0 {
        <GlobalSearchBar.EmptyResult prefix searchText />
      } else {
        <SearchResultsComponent searchResults searchText={query} />
      }
    }}
  </div>
}
