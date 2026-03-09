let getSearchresults = (result: GlobalSearchTypes.defaultResult) => {
  open GlobalSearchTypes
  let results = []

  if result.local_results->Array.length > 0 {
    results->Array.push({
      section: Local,
      results: result.local_results,
      total_results: results->Array.length,
    })
  }

  let data = Dict.make()

  result.remote_results->Array.forEach(value => {
    let remoteResults = value.hits->Array.map(item => {
      {
        texts: [item],
        redirect_link: ""->JSON.Encode.string,
      }
    })

    if remoteResults->Array.length > 0 {
      data->Dict.set(
        value.index,
        {
          section: value.index->getSectionVariant,
          results: remoteResults,
          total_results: value.count,
        },
      )
    }
  })

  open GlobalSearchBarUtils
  // intents
  let key1 = PaymentIntents->getSectionIndex
  let key2 = SessionizerPaymentIntents->getSectionIndex
  getItemFromArray(results, key1, key2, data)

  // Attempts
  let key1 = PaymentAttempts->getSectionIndex
  let key2 = SessionizerPaymentAttempts->getSectionIndex
  getItemFromArray(results, key1, key2, data)

  // Payouts
  let key1 = Payouts->getSectionIndex
  let key2 = "" // No sessionizer variant for payouts
  getItemFromArray(results, key1, key2, data)

  // Payout Attempts
  let key1 = PayoutAttempts->getSectionIndex
  let key2 = "" // No sessionizer variant for payout attempts
  getItemFromArray(results, key1, key2, data)

  // Refunds
  let key1 = Refunds->getSectionIndex
  let key2 = SessionizerPaymentRefunds->getSectionIndex
  getItemFromArray(results, key1, key2, data)

  // Disputes
  let key1 = Disputes->getSectionIndex
  let key2 = SessionizerPaymentDisputes->getSectionIndex
  getItemFromArray(results, key1, key2, data)

  (results, result.searchText)
}

let getMapToCsvRow = (itemToObjMapper, itemToCSVMapping) => {
  raw => raw->itemToObjMapper->itemToCSVMapping
}

let getDownloadConfig = section => {
  open GlobalSearchTypes
  switch section {
  | PaymentIntents
  | SessionizerPaymentIntents =>
    Some({
      csvHeaders: PaymentIntentEntity.csvHeaders,
      mapToCsvRow: getMapToCsvRow(
        PaymentIntentEntity.tableItemToObjMapper,
        PaymentIntentEntity.itemToCSVMapping,
      ),
      fileNamePrefix: "payment_intents",
    })

  | PaymentAttempts
  | SessionizerPaymentAttempts =>
    Some({
      csvHeaders: PaymentAttemptEntity.csvHeaders,
      mapToCsvRow: getMapToCsvRow(
        PaymentAttemptEntity.tableItemToObjMapper,
        PaymentAttemptEntity.itemToCSVMapping,
      ),
      fileNamePrefix: "payment_attempts",
    })
  | Payouts =>
    Some({
      csvHeaders: PayoutTableEntity.csvHeaders,
      mapToCsvRow: getMapToCsvRow(
        PayoutTableEntity.tableItemToObjMapper,
        PayoutTableEntity.itemToCSVMapping,
      ),
      fileNamePrefix: "payouts",
    })
  | Refunds | SessionizerPaymentRefunds =>
    Some({
      csvHeaders: RefundsTableEntity.csvHeaders,
      mapToCsvRow: getMapToCsvRow(
        RefundsTableEntity.tableItemToObjMapper,
        RefundsTableEntity.itemToCSVMapping,
      ),
      fileNamePrefix: "refunds",
    })
  | Disputes | SessionizerPaymentDisputes =>
    Some({
      csvHeaders: DisputeTableEntity.csvHeaders,
      mapToCsvRow: getMapToCsvRow(
        DisputeTableEntity.tableItemToObjMapper,
        DisputeTableEntity.itemToCSVMapping,
      ),
      fileNamePrefix: "disputes",
    })
  | PayoutAttempts | Others | Default | Local => None
  }
}
