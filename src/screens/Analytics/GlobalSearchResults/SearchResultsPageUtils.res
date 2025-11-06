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
