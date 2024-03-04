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
