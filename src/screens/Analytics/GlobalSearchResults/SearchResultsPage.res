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
        let borderClass = indx == 0 ? "border-t-1" : ""
        <div
          className={`p-2 text-sm cursor-pointer hover:bg-gray-100 ${borderClass} border-b-1`}
          key={indx->Int.toString}
          onClick={_ => redirectOnSelect(item)}>
          {elementsArray
          ->Array.mapWithIndex((item, index) => {
            let elementValue = item->JSON.Decode.string->Option.getOr("")
            <RenderIf condition={elementValue->isNonEmptyString} key={index->Int.toString}>
              <span
                key={index->Int.toString}
                className=" font-medium text-lightgray_background opacity-60">
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
    | PaymentIntents => {
        let data =
          section.results
          ->Array.map(item => {
            let data = item.texts->Array.get(0)->Option.getOr(Dict.make()->JSON.Encode.object)
            data->JSON.Decode.object->Option.getOr(Dict.make())
          })
          ->Array.filter(dict => dict->Dict.keysToArray->Array.length > 0)
          ->Array.map(item => item->PaymentIntentEntity.tableItemToObjMapper->Nullable.make)

        <PaymentIntentTable tableData={data} />
      }
    | PaymentAttempts => {
        let data =
          section.results
          ->Array.map(item => {
            let data = item.texts->Array.get(0)->Option.getOr(Dict.make()->JSON.Encode.object)
            data->JSON.Decode.object->Option.getOr(Dict.make())
          })
          ->Array.filter(dict => dict->Dict.keysToArray->Array.length > 0)
          ->Array.map(item => item->PaymentIntentEntity.tableItemToObjMapper->Nullable.make)

        <PaymentAttemptTable tableData={data} />
      }

    | _ => "Not implemented"->React.string
    }
  }
}

module SearchResultsComponent = {
  open GlobalSearchTypes
  @react.component
  let make = (~searchResults) => {
    searchResults
    ->Array.mapWithIndex((section: resultType, i) => {
      let borderClass = searchResults->Array.length > 0 ? "" : "border-b dark:border-jp-gray-960"
      <div className={`py-5 ${borderClass}`} key={i->Int.toString}>
        <div className="text-lightgray_background font-bold pb-1 text-lg pb-2">
          {section.section->getSectionHeader->React.string}
        </div>
        <RenderSearchResultBody section />
      </div>
    })
    ->React.array
  }
}

@react.component
let make = () => {
  open GlobalSearchBarUtils
  open LogicUtils
  open SearchResultsPageUtils

  let prefix = useUrlPrefix()
  let (searchText, setSearchText) = React.useState(_ => "")
  let (searchResults, setSearchResults) = React.useState(_ => [])

  React.useEffect0(() => {
    switch sessionStorage.getItem(. "results")->Nullable.toOption {
    | Some(value) => {
        let (results, text) = value->getSearchresults
        setSearchText(_ => text)
        setSearchResults(_ => results)
      }
    | None => ()
    }

    None
  })

  <div>
    <PageUtils.PageHeading title="Search results" />
    {if searchResults->Array.length === 0 {
      <GlobalSearchBar.EmptyResult prefix searchText />
    } else {
      <SearchResultsComponent searchResults />
    }}
  </div>
}
