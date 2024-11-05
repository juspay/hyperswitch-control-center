module ShowMoreLink = {
  open GlobalSearchTypes
  @react.component
  let make = (
    ~section: resultType,
    ~cleanUpFunction=() => {()},
    ~textStyleClass="",
    ~searchText,
  ) => {
    <RenderIf condition={section.total_results > 10}>
      {
        let linkText = `View ${section.total_results->Int.toString} result${section.total_results > 1
            ? "s"
            : ""}`

        switch section.section {
        | Local
        | Default
        | Others
        | SessionizerPaymentAttempts
        | SessionizerPaymentIntents
        | SessionizerPaymentRefunds
        | SessionizerPaymentDisputes => React.null
        | PaymentAttempts | PaymentIntents | Refunds | Disputes =>
          <div
            onClick={_ => {
              let link = switch section.section {
              | PaymentAttempts => `payment-attempts?query=${searchText}`
              | PaymentIntents => `payment-intents?query=${searchText}`
              | Refunds => `refunds-global?query=${searchText}`
              | Disputes => `dispute-global?query=${searchText}`
              | Local
              | Others
              | Default
              | SessionizerPaymentAttempts
              | SessionizerPaymentIntents
              | SessionizerPaymentRefunds
              | SessionizerPaymentDisputes => ""
              }
              GlobalVars.appendDashboardPath(~url=link)->RescriptReactRouter.push
              cleanUpFunction()
            }}
            className={`font-medium cursor-pointer underline underline-offset-2 ${textStyleClass}`}>
            {linkText->React.string}
          </div>
        }
      }
    </RenderIf>
  }
}

let matchInSearchOption = (searchOptions, searchText, name, link, ~sectionName) => {
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
        )
        acc->Array.concat(matchedSearchValues)
      }

    | Heading(_) | CustomComponent(_) => acc->Array.concat([])
    }
  })

  {
    section: Local,
    results,
    total_results: results->Array.length,
  }
}

let getElements = (hits, section) => {
  open GlobalSearchTypes
  open LogicUtils

  let getAmount = (value, amountKey, currencyKey) =>
    `${value->getFloat(amountKey, 0.0)->Belt.Float.toString} ${value->getString(currencyKey, "")}`

  let getValues = item => {
    let value = item->JSON.Decode.object->Option.getOr(Dict.make())
    let payId = value->getString("payment_id", "")
    let amount = value->getAmount("amount", "currency")
    let status = value->getString("status", "")
    let profileId = value->getString("profile_id", "")

    (payId, amount, status, profileId)
  }

  switch section {
  | PaymentAttempts =>
    hits->Array.map(item => {
      let (payId, amount, status, profileId) = item->getValues

      {
        texts: [payId, amount, status]->Array.map(JSON.Encode.string),
        redirect_link: `/payments/${payId}/${profileId}`->JSON.Encode.string,
      }
    })
  | PaymentIntents =>
    hits->Array.map(item => {
      let (payId, amount, status, profileId) = item->getValues

      {
        texts: [payId, amount, status]->Array.map(JSON.Encode.string),
        redirect_link: `/payments/${payId}/${profileId}`->JSON.Encode.string,
      }
    })

  | Refunds =>
    hits->Array.map(item => {
      let value = item->JSON.Decode.object->Option.getOr(Dict.make())
      let refId = value->getString("refund_id", "")
      let amount = value->getAmount("total_amount", "currency")
      let status = value->getString("refund_status", "")
      let profileId = value->getString("profile_id", "")

      {
        texts: [refId, amount, status]->Array.map(JSON.Encode.string),
        redirect_link: `/refunds/${refId}/${profileId}`->JSON.Encode.string,
      }
    })
  | Disputes =>
    hits->Array.map(item => {
      let value = item->JSON.Decode.object->Option.getOr(Dict.make())
      let disId = value->getString("dispute_id", "")
      let amount = value->getAmount("dispute_amount", "currency")
      let status = value->getString("dispute_status", "")
      let profileId = value->getString("profile_id", "")

      {
        texts: [disId, amount, status]->Array.map(JSON.Encode.string),
        redirect_link: `/disputes/${disId}/${profileId}`->JSON.Encode.string,
      }
    })
  | Local
  | Others
  | Default
  | SessionizerPaymentAttempts
  | SessionizerPaymentIntents
  | SessionizerPaymentRefunds
  | SessionizerPaymentDisputes => []
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
    let total_results = value->getInt("count", hints->Array.length)

    if hints->Array.length > 0 {
      results->Array.push({
        section,
        results: hints->getElements(section),
        total_results,
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
        redirect_link: `/search?query=${searchText}`->JSON.Encode.string,
      },
    ],
    total_results: 1,
  }
}

let parseResponse = response => {
  open GlobalSearchTypes
  open LogicUtils
  response
  ->getArrayFromJson([])
  ->Array.map(json => {
    let item = json->getDictFromJsonObject

    {
      count: item->getInt("count", 0),
      hits: item->getArrayFromDict("hits", []),
      index: item->getString("index", ""),
    }
  })
}

let generateSearchBody = (~searchText, ~merchant_id) => {
  open LogicUtils
  if !(searchText->CommonAuthUtils.isValidEmail) {
    let filters =
      [
        ("customer_email", [searchText->JSON.Encode.string]->JSON.Encode.array),
      ]->getJsonFromArrayOfJson
    [("query", merchant_id->JSON.Encode.string), ("filters", filters)]->getJsonFromArrayOfJson
  } else {
    [("query", searchText->JSON.Encode.string)]->getJsonFromArrayOfJson
  }
}

open GlobalSearchTypes
let categoryList = [
  Payment_Method,
  Payment_Method_Type,
  Connector,
  Customer_Email,
  Card_Network,
  Last_4,
  Date,
]

let getcategoryFromVariant = category => {
  switch category {
  | Payment_Method => "payment_method"
  | Payment_Method_Type => "payment_method_type"
  | Connector => "connector"
  | Customer_Email => "customer_email"
  | Card_Network => "card_network"
  | Last_4 => "last_4"
  | Date => "date"
  }
}

let getDefaultPlaceholderValue = category => {
  switch category {
  | Payment_Method => "payment_method:card"
  | Payment_Method_Type => "payment_method_type:credit"
  | Connector => "connector:stripe"
  | Customer_Email => "customer_email:abc@abc.com"
  | Card_Network => "card_network:visa"
  | Last_4 => "last_4:2326"
  | Date => "date:today"
  }
}

let getCategoryVariantFromString = category => {
  switch category {
  | "payment_method" => Payment_Method
  | "payment_method_type" => Payment_Method_Type
  | "connector" => Connector
  | "customer_email" => Customer_Email
  | "card_network" => Card_Network
  | "last_4" => Last_4
  | "date" | _ => Date
  }
}

let generatePlaceHolderValue = (category, options) => {
  switch options->Array.get(0) {
  | Some(value) => `${category->getcategoryFromVariant}:${value}`
  | _ => category->getDefaultPlaceholderValue
  }
}

let getCategorySuggestions = json => {
  open LogicUtils
  let suggestions = Dict.make()

  json
  ->getDictFromJsonObject
  ->getArrayFromDict("queryData", [])
  ->Array.forEach(item => {
    let itemDict = item->getDictFromJsonObject
    let key = itemDict->getString("dimension", "")
    let value =
      itemDict
      ->getArrayFromDict("values", [])
      ->Array.map(value => {
        value->JSON.Decode.string->Option.getOr("")
      })
    if key->isNonEmptyString && value->Array.length > 0 {
      suggestions->Dict.set(key, value)
    }
  })

  categoryList->Array.map(category => {
    let options = suggestions->Dict.get(category->getcategoryFromVariant)->Option.getOr([])

    {
      categoryType: category,
      options,
      placeholder: generatePlaceHolderValue(category, options),
    }
  })
}

let paymentsGroupByNames = [
  "connector",
  "payment_method",
  "payment_method_type",
  "currency",
  "authentication_type",
  "status",
  "client_source",
  "client_version",
  "profile_id",
  "card_network",
  "merchant_id",
]

let refundsGroupByNames = ["currency", "refund_status", "connector", "refund_type", "profile_id"]
let disputesGroupByNames = ["connector", "dispute_stage"]

let getFilterBody = groupByNames =>
  {
    let defaultDate = HSwitchRemoteFilter.getDateFilteredObject(~range=360)
    let filterBodyEntity: AnalyticsUtils.filterBodyEntity = {
      startTime: defaultDate.start_time,
      endTime: defaultDate.end_time,
      groupByNames,
      source: "BATCH",
    }
    AnalyticsUtils.filterBody(filterBodyEntity)
  }->Identity.genericTypeToJson
