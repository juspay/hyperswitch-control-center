open GlobalSearchTypes
open LogicUtils

let defaultRoute = "/search"
let global_search_activate_key = "k"
let filterSeparator = ":"
let sectionsViewResultsCount = 4

let getEndChar = string => {
  string->String.charAt(string->String.length - 1)
}

let matchInSearchOption = (searchOptions, searchText, name, link, ~sectionName) => {
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
  let getAmount = (value, amountKey, currencyKey) => {
    let currency = value->getString(currencyKey, "")
    let conversionFactor = CurrencyUtils.getCurrencyConversionFactor(currency)
    let amount = (value->getFloat(amountKey, 0.0) /. conversionFactor)->Float.toString
    `${amount} ${currency}`
  }

  let getValues = item => {
    let value = item->JSON.Decode.object->Option.getOr(Dict.make())
    let payId = value->getString("payment_id", "")
    let amount = value->getAmount("amount", "currency")
    let status = value->getString("status", "")
    let profileId = value->getString("profile_id", "")
    let merchantId = value->getString("merchant_id", "")
    let orgId = value->getString("organization_id", "")

    let metadata = {
      orgId,
      merchantId,
      profileId,
    }

    (payId, amount, status, metadata)
  }

  switch section {
  | PaymentAttempts | SessionizerPaymentAttempts =>
    hits->Array.map(item => {
      let (payId, amount, status, metadata) = item->getValues

      {
        texts: [payId, amount, status]->Array.map(JSON.Encode.string),
        redirect_link: `/payments/${payId}/${metadata.profileId}/${metadata.merchantId}/${metadata.orgId}`->JSON.Encode.string,
      }
    })
  | PaymentIntents | SessionizerPaymentIntents =>
    hits->Array.map(item => {
      let (payId, amount, status, metadata) = item->getValues

      {
        texts: [payId, amount, status]->Array.map(JSON.Encode.string),
        redirect_link: `/payments/${payId}/${metadata.profileId}/${metadata.merchantId}/${metadata.orgId}`->JSON.Encode.string,
      }
    })

  | Refunds | SessionizerPaymentRefunds =>
    hits->Array.map(item => {
      let value = item->JSON.Decode.object->Option.getOr(Dict.make())
      let refId = value->getString("refund_id", "")
      let amount = value->getAmount("refund_amount", "currency")
      let status = value->getString("refund_status", "")
      let profileId = value->getString("profile_id", "")
      let orgId = value->getString("organization_id", "")
      let merchantId = value->getString("merchant_id", "")

      {
        texts: [refId, amount, status]->Array.map(JSON.Encode.string),
        redirect_link: `/refunds/${refId}/${profileId}/${merchantId}/${orgId}`->JSON.Encode.string,
      }
    })
  | Disputes | SessionizerPaymentDisputes =>
    hits->Array.map(item => {
      let value = item->JSON.Decode.object->Option.getOr(Dict.make())
      let disId = value->getString("dispute_id", "")
      let amount = value->getAmount("dispute_amount", "currency")
      let status = value->getString("dispute_status", "")
      let profileId = value->getString("profile_id", "")
      let orgId = value->getString("organization_id", "")
      let merchantId = value->getString("merchant_id", "")

      {
        texts: [disId, amount, status]->Array.map(JSON.Encode.string),
        redirect_link: `/${disId}/${profileId}/${merchantId}/${orgId}`->JSON.Encode.string,
      }
    })
  | Payouts =>
    hits->Array.map(item => {
      let value = item->JSON.Decode.object->Option.getOr(Dict.make())
      let payoutId = value->getString("payout_id", "")
      let currency = value->getString("destination_currency", "")
      let conversionFactor = CurrencyUtils.getCurrencyConversionFactor(currency)
      let amount = (value->getFloat("amount", 0.0) /. conversionFactor)->Float.toString
      let formattedAmount = `${amount} ${currency}`
      let status = value->getString("status", "")
      let profileId = value->getString("profile_id", "")
      let orgId = value->getString("organization_id", "")
      let merchantId = value->getString("merchant_id", "")

      {
        texts: [payoutId, formattedAmount, status]->Array.map(JSON.Encode.string),
        redirect_link: `/payouts/${payoutId}/${profileId}/${merchantId}/${orgId}`->JSON.Encode.string,
      }
    })
  | PayoutAttempts =>
    hits->Array.map(item => {
      let value = item->JSON.Decode.object->Option.getOr(Dict.make())
      let payoutId = value->getString("payout_id", "")
      let payoutAttemptId = value->getString("payout_attempt_id", "")
      let currency = value->getString("destination_currency", "")
      let conversionFactor = CurrencyUtils.getCurrencyConversionFactor(currency)
      let amount = (value->getFloat("amount", 0.0) /. conversionFactor)->Float.toString
      let formattedAmount = `${amount} ${currency}`
      let status = value->getString("status", "")
      let profileId = value->getString("profile_id", "")
      let orgId = value->getString("organization_id", "")
      let merchantId = value->getString("merchant_id", "")

      {
        texts: [payoutAttemptId, formattedAmount, status]->Array.map(JSON.Encode.string),
        redirect_link: `/payouts/${payoutId}/${profileId}/${merchantId}/${orgId}`->JSON.Encode.string,
      }
    })
  | Local
  | Others
  | Default => []
  }
}

let getItemFromArray = (results, key1, key2, resultsData) => {
  switch (resultsData->Dict.get(key1), resultsData->Dict.get(key2)) {
  | (Some(data), Some(sessionizerData)) => {
      let intentsCount = data.total_results
      let sessionizerCount = sessionizerData.total_results
      if intentsCount > 0 && sessionizerCount > 0 {
        if intentsCount >= sessionizerCount {
          results->Array.push(data)
        } else {
          results->Array.push(sessionizerData)
        }
      } else if intentsCount > 0 {
        results->Array.push(data)
      } else {
        results->Array.push(sessionizerData)
      }
    }
  | (None, Some(sessionizerData)) => results->Array.push(sessionizerData)
  | (Some(data), None) => results->Array.push(data)
  | _ => ()
  }
}

let getRemoteResults = json => {
  let data = Dict.make()

  json
  ->JSON.Decode.array
  ->Option.getOr([])
  ->Array.forEach(item => {
    let value = item->JSON.Decode.object->Option.getOr(Dict.make())
    let section = value->getString("index", "")->getSectionVariant
    let hints =
      value
      ->getArrayFromDict("hits", [])
      ->Array.filterWithIndex((_, index) => index < sectionsViewResultsCount)
    let total_results = value->getInt("count", hints->Array.length)
    let key = value->getString("index", "")

    if hints->Array.length > 0 {
      data->Dict.set(
        key,
        {
          section,
          results: hints->getElements(section),
          total_results,
        },
      )
    }
  })

  let results = []

  // intents
  let key1 = PaymentIntents->getSectionIndex
  let key2 = SessionizerPaymentIntents->getSectionIndex
  getItemFromArray(results, key1, key2, data)

  // Attempts
  let key1 = PaymentAttempts->getSectionIndex
  let key2 = SessionizerPaymentAttempts->getSectionIndex
  getItemFromArray(results, key1, key2, data)

  // Refunds
  let key1 = Refunds->getSectionIndex
  let key2 = SessionizerPaymentRefunds->getSectionIndex
  getItemFromArray(results, key1, key2, data)

  // Disputes
  let key1 = Disputes->getSectionIndex
  let key2 = SessionizerPaymentDisputes->getSectionIndex
  getItemFromArray(results, key1, key2, data)

  // Payouts
  let key1 = Payouts->getSectionIndex
  let key2 = ""  // No sessionizer variant for payouts
  getItemFromArray(results, key1, key2, data)

  // Payout Attempts
  let key1 = PayoutAttempts->getSectionIndex
  let key2 = ""  // No sessionizer variant for payout attempts
  getItemFromArray(results, key1, key2, data)

  results
}

let getDefaultResult = searchText => {
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

let getDefaultOption = searchText => {
  {
    texts: ["Show all results for"->JSON.Encode.string, searchText->JSON.Encode.string],
    redirect_link: `/search?query=${searchText}`->JSON.Encode.string,
  }
}

let getAllOptions = (results: array<GlobalSearchTypes.resultType>) => {
  results->Array.flatMap(item => item.results)
}

let parseResponse = response => {
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

let categoryList = [
  Payment_Method,
  Payment_Method_Type,
  Currency,
  Connector,
  Customer_Email,
  Card_Network,
  Card_Last_4,
  Status,
  Payment_id,
  Amount,
]

let getcategoryFromVariant = category => {
  switch category {
  | Payment_Method => "payment_method"
  | Payment_Method_Type => "payment_method_type"
  | Currency => "currency"
  | Connector => "connector"
  | Customer_Email => "customer_email"
  | Card_Network => "card_network"
  | Card_Last_4 => "card_last_4"
  | Date => "date"
  | Status => "status"
  | Payment_id => "payment_id"
  | Amount => "amount"
  }
}

let getDefaultPlaceholderValue = category => {
  switch category {
  | Payment_Method => "payment_method:card"
  | Payment_Method_Type => "payment_method_type:credit"
  | Currency => "currency:USD"
  | Connector => "connector:stripe"
  | Customer_Email => "customer_email:abc@abc.com"
  | Card_Network => "card_network:visa"
  | Card_Last_4 => "card_last_4:2326"
  | Date => "date:today"
  | Status => "status:charged"
  | Payment_id => "payment_id:pay_xxxxxxxxx"
  | Amount => "amount:100"
  }
}

let getCategoryVariantFromString = category => {
  switch category {
  | "payment_method" => Payment_Method
  | "payment_method_type" => Payment_Method_Type
  | "connector" => Connector
  | "currency" => Currency
  | "customer_email" => Customer_Email
  | "card_network" => Card_Network
  | "card_last_4" => Card_Last_4
  | "payment_id" => Payment_id
  | "status" => Status
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
      ->Array.filter(item => item->String.length > 0)
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
  "status",
  "profile_id",
  "card_network",
  "merchant_id",
]

let refundsGroupByNames = ["currency", "refund_status", "connector", "refund_type", "profile_id"]
let disputesGroupByNames = ["connector", "dispute_stage"]

let getFilterBody = groupByNames =>
  {
    let defaultDate = HSwitchRemoteFilter.getDateFilteredObject(~range=7)
    let filterBodyEntity: AnalyticsUtils.filterBodyEntity = {
      startTime: defaultDate.start_time,
      endTime: defaultDate.end_time,
      groupByNames,
      source: "BATCH",
    }
    AnalyticsUtils.filterBody(filterBodyEntity)
  }->Identity.genericTypeToJson

let generateFilter = (queryArray: array<string>) => {
  let filter = Dict.make()
  queryArray->Array.forEach(query => {
    let keyValuePair =
      query
      ->String.split(filterSeparator)
      ->Array.filter(query => {
        query->String.trim->isNonEmptyString
      })

    let key = keyValuePair->getValueFromArray(0, "")
    let value = keyValuePair->getValueFromArray(1, "")

    switch filter->Dict.get(key) {
    | Some(prevArr) =>
      if !(prevArr->Array.includes(value)) && value->isNonEmptyString {
        filter->Dict.set(key, prevArr->Array.concat([value]))
      }
    | _ =>
      if value->isNonEmptyString {
        filter->Dict.set(key, [value])
      }
    }
  })

  filter
  ->Dict.toArray
  ->Array.map(item => {
    let (key, value) = item
    let newValue = if key == Amount->getcategoryFromVariant {
      value->Array.map(item => {
        item->Float.fromString->Option.getOr(0.0)->JSON.Encode.float
      })
    } else {
      value->Array.map(JSON.Encode.string)
    }
    (key, newValue->JSON.Encode.array)
  })
  ->Dict.fromArray
}

let generateQuery = searchQuery => {
  let filters = []
  let queryText = ref("")

  searchQuery
  ->String.split(" ")
  ->Array.filter(query => {
    query->String.trim->isNonEmptyString
  })
  ->Array.forEach(query => {
    if RegExp.test(%re("/^[^:\s]+:[^:\s]*$/"), query) {
      let key = query->String.split(filterSeparator)->Array.get(0)->Option.getOr("")

      if key == Amount->getcategoryFromVariant {
        let valueString =
          query
          ->String.split(filterSeparator)
          ->Array.get(1)
          ->Option.getOr("")

        if valueString->isNonEmptyString && RegExp.test(%re("/^\d+(\.\d+)?$/"), valueString) {
          let value = (valueString
          ->Float.fromString
          ->Option.getOr(0.0) *. 100.00)->Float.toString

          let filter = `${Amount->getcategoryFromVariant}${filterSeparator}${value}`
          filters->Array.push(filter)
        }
      } else {
        filters->Array.push(query)
      }
    } else if !(query->CommonAuthUtils.isValidEmail) {
      let filter = `${Customer_Email->getcategoryFromVariant}${filterSeparator}${query}`
      filters->Array.push(filter)
    } else if queryText.contents->isEmptyString {
      queryText := query
    }
  })

  let body = {
    let filterObj = filters->generateFilter
    let query = if filters->Array.length > 0 && filterObj->Dict.keysToArray->Array.length > 0 {
      [("filters", filterObj->JSON.Encode.object)]
    } else {
      []
    }

    let query =
      query->Array.concat([("query", queryText.contents->String.trim->JSON.Encode.string)])

    query->Dict.fromArray
  }

  body
}

let validateQuery = searchQuery => {
  let freeTextCount = ref(0)

  searchQuery
  ->String.split(" ")
  ->Array.filter(query => {
    query->String.trim->isNonEmptyString
  })
  ->Array.forEach(query => {
    if !RegExp.test(%re("/^[^:\s]+:[^:\s]+$/"), query) {
      freeTextCount := freeTextCount.contents + 1
    }
  })

  freeTextCount.contents > 1
}

let getViewType = (~state, ~searchResults) => {
  switch state {
  | Loading => Load
  | Loaded =>
    if searchResults->Array.length > 0 {
      Results
    } else {
      EmptyResult
    }
  | Idle => FiltersSugsestions
  }
}

let getSearchValidation = query => {
  let paylod = query->generateQuery
  let query = paylod->getString("query", "")->String.trim

  !(paylod->getObj("filters", Dict.make())->isEmptyDict && query->isEmptyString)
}

let sidebarScrollbarCss = `
  @supports (-webkit-appearance: none){
    .sidebar-scrollbar {
        scrollbar-width: auto;
        scrollbar-color: #8a8c8f;
      }
      
      .sidebar-scrollbar::-webkit-scrollbar {
        display: block;
        overflow: scroll;
        height: 4px;
        width: 5px;
      }
      
      .sidebar-scrollbar::-webkit-scrollbar-thumb {
        background-color: #8a8c8f;
        border-radius: 3px;
      }
      
      .sidebar-scrollbar::-webkit-scrollbar-track {
        display: none;
      }
}
  `

let revertFocus = (~inputRef: React.ref<'a>) => {
  switch inputRef.current->Js.Nullable.toOption {
  | Some(elem) => elem->MultipleFileUpload.focus
  | None => ()
  }
}
