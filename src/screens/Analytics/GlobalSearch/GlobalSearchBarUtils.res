let matchInSearchOption = (searchOptions, searchText, name, link, ~sectionName, ()) => {
  open LogicUtils
  searchOptions
  ->Option.getOr([])
  ->Array.filter(item => {
    let (searchKey, _redirection) = item
    checkStringStartsWithSubstring(~itemToCheck=searchKey, ~searchText)
  })
  ->Array.map(item => {
    let (searchKey, redirection) = item
    [
      (
        "elements",
        [
          sectionName->JSON.Encode.string,
          name->JSON.Encode.string,
          searchKey->JSON.Encode.string,
        ]->JSON.Encode.array,
      ),
      ("redirect_link", `${link}${redirection}`->JSON.Encode.string),
    ]->Dict.fromArray
  })
}

let getMatchedList = (searchText, tabs) => {
  open LogicUtils
  open SidebarTypes
  tabs->Array.reduce([], (acc, item) => {
    switch item {
    | Link(obj)
    | RemoteLink(obj) => {
        if checkStringStartsWithSubstring(~itemToCheck=obj.name, ~searchText) {
          let matchedEle =
            [
              (
                "elements",
                [""->JSON.Encode.string, obj.name->JSON.Encode.string]->JSON.Encode.array,
              ),
              ("redirect_link", obj.link->JSON.Encode.string),
            ]->Dict.fromArray
          acc->Array.push(matchedEle)
        }
        let matchedSearchValues = matchInSearchOption(
          obj.searchOptions,
          searchText,
          obj.name,
          obj.link,
          ~sectionName="",
          (),
        )

        acc->Array.concat(matchedSearchValues)
      }

    | Section(sectionObj) => {
        let sectionSearchedValues = sectionObj.links->Array.reduce([], (insideAcc, item) => {
          switch item {
          | SubLevelLink(obj) => {
              if (
                checkStringStartsWithSubstring(~itemToCheck=sectionObj.name, ~searchText) ||
                checkStringStartsWithSubstring(~itemToCheck=obj.name, ~searchText)
              ) {
                let matchedEle =
                  [
                    (
                      "elements",
                      [
                        sectionObj.name->JSON.Encode.string,
                        obj.name->JSON.Encode.string,
                      ]->JSON.Encode.array,
                    ),
                    ("redirect_link", obj.link->JSON.Encode.string),
                  ]->Dict.fromArray
                insideAcc->Array.push(matchedEle)
              }
              let matchedSearchValues = matchInSearchOption(
                obj.searchOptions,
                searchText,
                obj.name,
                obj.link,
                ~sectionName=sectionObj.name,
                (),
              )
              insideAcc->Array.concat(matchedSearchValues)
            }
          }
        })
        acc->Array.concat(sectionSearchedValues)
      }

    | LinkWithTag(obj) => {
        if checkStringStartsWithSubstring(~itemToCheck=obj.name, ~searchText) {
          let matchedEle =
            [
              ("elements", [obj.name->JSON.Encode.string]->JSON.Encode.array),
              ("redirect_link", obj.link->JSON.Encode.string),
            ]->Dict.fromArray
          acc->Array.push(matchedEle)
        }

        let matchedSearchValues = matchInSearchOption(
          obj.searchOptions,
          searchText,
          obj.name,
          obj.link,
          ~sectionName="",
          (),
        )
        acc->Array.concat(matchedSearchValues)
      }

    | Heading(_) | CustomComponent(_) => acc->Array.concat([])
    }
  })
}
