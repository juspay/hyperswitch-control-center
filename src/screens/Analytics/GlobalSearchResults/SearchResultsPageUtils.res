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

let downloadSectionData = (~section: GlobalSearchTypes.resultType, ~searchText, ~toast) => {
  open GlobalSearchTypes
  let rawData = section.results->Array.map(item => {
    item.texts->Array.get(0)->Option.getOr(JSON.Encode.null)
  })

  let download = (~csvHeaders, ~tableItemToObjMapper, ~itemToCSVMapping, ~fileNamePrefix) => {
    DownloadUtils.downloadTableAsCsv(
      ~csvHeaders,
      ~rawData,
      ~tableItemToObjMapper,
      ~itemToCSVMapping,
      ~fileName=`${fileNamePrefix}_${searchText}.csv`,
      ~toast,
    )
  }

  switch section.section {
  | PaymentIntents | SessionizerPaymentIntents =>
    download(
      ~csvHeaders=PaymentIntentEntity.csvHeaders,
      ~tableItemToObjMapper=PaymentIntentEntity.tableItemToObjMapper,
      ~itemToCSVMapping=PaymentIntentEntity.itemToCSVMapping,
      ~fileNamePrefix="payment_intents",
    )
  | PaymentAttempts | SessionizerPaymentAttempts =>
    download(
      ~csvHeaders=PaymentAttemptEntity.csvHeaders,
      ~tableItemToObjMapper=PaymentAttemptEntity.tableItemToObjMapper,
      ~itemToCSVMapping=PaymentAttemptEntity.itemToCSVMapping,
      ~fileNamePrefix="payment_attempts",
    )
  | Payouts =>
    download(
      ~csvHeaders=PayoutTableEntity.csvHeaders,
      ~tableItemToObjMapper=PayoutTableEntity.tableItemToObjMapper,
      ~itemToCSVMapping=PayoutTableEntity.itemToCSVMapping,
      ~fileNamePrefix="payouts",
    )
  | Refunds | SessionizerPaymentRefunds =>
    download(
      ~csvHeaders=RefundsTableEntity.csvHeaders,
      ~tableItemToObjMapper=RefundsTableEntity.tableItemToObjMapper,
      ~itemToCSVMapping=RefundsTableEntity.itemToCSVMapping,
      ~fileNamePrefix="refunds",
    )
  | Disputes | SessionizerPaymentDisputes =>
    download(
      ~csvHeaders=DisputeTableEntity.csvHeaders,
      ~tableItemToObjMapper=DisputeTableEntity.tableItemToObjMapper,
      ~itemToCSVMapping=DisputeTableEntity.itemToCSVMapping,
      ~fileNamePrefix="disputes",
    )
  | PayoutAttempts | Others | Default | Local => ()
  }
}
