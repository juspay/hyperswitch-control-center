type sessionStorage = {
  getItem: (. string) => Nullable.t<string>,
  setItem: (. string, string) => unit,
  removeItem: (. string) => unit,
}

@val external sessionStorage: sessionStorage = "sessionStorage"

let matchInSearchOption = (searchOptions, searchText, name, link, ~sectionName, ()) => {
  open GlobalSearchTypes
  open LogicUtils
  searchOptions
  ->Option.getOr([])
  ->Array.filter(item => {
    let (searchKey, _) = item
    checkStringStartsWithSubstring(~itemToCheck=searchKey, ~searchText)
  })
  ->Array.map(item => {
    let (searchKey, redirection) = item

    {
      texts: [
        sectionName->JSON.Encode.string,
        name->JSON.Encode.string,
        searchKey->JSON.Encode.string,
      ],
      redirect_link: `${link}${redirection}`->JSON.Encode.string,
    }
  })
}

let getLocalMatchedResults = (searchText, tabs) => {
  open LogicUtils
  open GlobalSearchTypes
  open SidebarTypes
  let results = tabs->Array.reduce([], (acc, item) => {
    switch item {
    | Link(tab)
    | RemoteLink(tab) => {
        if checkStringStartsWithSubstring(~itemToCheck=tab.name, ~searchText) {
          let matchedEle = {
            texts: [""->JSON.Encode.string, tab.name->JSON.Encode.string],
            redirect_link: tab.link->JSON.Encode.string,
          }

          acc->Array.push(matchedEle)
        }
        let matchedSearchValues = matchInSearchOption(
          tab.searchOptions,
          searchText,
          tab.name,
          tab.link,
          ~sectionName="",
          (),
        )

        acc->Array.concat(matchedSearchValues)
      }

    | Section(sectionObj) => {
        let sectionSearchedValues = sectionObj.links->Array.reduce([], (insideAcc, item) => {
          switch item {
          | SubLevelLink(tab) => {
              if (
                checkStringStartsWithSubstring(~itemToCheck=sectionObj.name, ~searchText) ||
                checkStringStartsWithSubstring(~itemToCheck=tab.name, ~searchText)
              ) {
                let matchedEle = {
                  texts: [sectionObj.name->JSON.Encode.string, tab.name->JSON.Encode.string],
                  redirect_link: tab.link->JSON.Encode.string,
                }

                insideAcc->Array.push(matchedEle)
              }
              let matchedSearchValues = matchInSearchOption(
                tab.searchOptions,
                searchText,
                tab.name,
                tab.link,
                ~sectionName=sectionObj.name,
                (),
              )
              insideAcc->Array.concat(matchedSearchValues)
            }
          }
        })
        acc->Array.concat(sectionSearchedValues)
      }

    | LinkWithTag(tab) => {
        if checkStringStartsWithSubstring(~itemToCheck=tab.name, ~searchText) {
          let matchedEle = {
            texts: [tab.name->JSON.Encode.string],
            redirect_link: tab.link->JSON.Encode.string,
          }

          acc->Array.push(matchedEle)
        }

        let matchedSearchValues = matchInSearchOption(
          tab.searchOptions,
          searchText,
          tab.name,
          tab.link,
          ~sectionName="",
          (),
        )
        acc->Array.concat(matchedSearchValues)
      }

    | Heading(_) | CustomComponent(_) => acc->Array.concat([])
    }
  })

  {
    section: Local,
    results,
  }
}

let getElements = (hits, section) => {
  open GlobalSearchTypes
  open LogicUtils
  switch section {
  | PaymentAttempts =>
    hits->Array.map(item => {
      let value = item->JSON.Decode.object->Option.getOr(Dict.make())
      let payId = value->getString("payment_id", "")
      let amount = value->getFloat("amount", 0.0)->Belt.Float.toString
      let status = value->getString("status", "")
      let currency = value->getString("currency", "")

      {
        texts: [payId, amount, status, currency]->Array.map(JSON.Encode.string),
        redirect_link: ""->JSON.Encode.string,
      }
    })
  | PaymentIntents =>
    hits->Array.map(item => {
      let value = item->JSON.Decode.object->Option.getOr(Dict.make())
      let payId = value->getString("payment_id", "")
      let amount = value->getFloat("amount", 0.0)->Belt.Float.toString
      let status = value->getString("status", "")
      let currency = value->getString("currency", "")

      {
        texts: [payId, amount, status, currency]->Array.map(JSON.Encode.string),
        redirect_link: ""->JSON.Encode.string,
      }
    })

  | _ => []
  }
}

let getRemoteResults = json => {
  open GlobalSearchTypes
  open LogicUtils
  let results = []

  json
  ->JSON.Decode.array
  ->Option.getOr([])
  ->Array.forEach(item => {
    let value = item->JSON.Decode.object->Option.getOr(Dict.make())
    let section = value->getString("index", "")->getSectionVariant
    let hints = value->getArrayFromDict("hits", [])

    if hints->Array.length > 0 {
      results->Array.push({
        section,
        results: hints->getElements(section),
      })
    }
  })

  results
}

let getDefaultResult = searchText => {
  open GlobalSearchTypes
  {
    section: Default,
    results: [
      {
        texts: ["Show all results for"->JSON.Encode.string, searchText->JSON.Encode.string],
        redirect_link: "search"->JSON.Encode.string,
      },
    ],
  }
}
