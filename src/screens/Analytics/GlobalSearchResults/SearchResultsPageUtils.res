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

  result.remote_results->Array.forEach(value => {
    let remoteResults = value.hits->Array.map(item => {
      {
        texts: [item],
        redirect_link: ""->JSON.Encode.string,
      }
    })

    if remoteResults->Array.length > 0 {
      results->Array.push({
        section: value.index->getSectionVariant,
        results: remoteResults,
        total_results: value.count,
      })
    }
  })

  (results, result.searchText)
}
