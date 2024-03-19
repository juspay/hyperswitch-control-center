let getSearchresults = json => {
  open LogicUtils
  open GlobalSearchTypes
  let results = []
  let valueDict = json->JSON.parseExn->JSON.Decode.object->Option.getOr(Dict.make())
  let searchText = valueDict->getString("searchText", "")

  let localResults =
    valueDict
    ->getArrayFromDict("local-results", [])
    ->Array.map(value => {
      let valueDict = value->JSON.Decode.object->Option.getOr(Dict.make())

      {
        texts: valueDict->getArrayFromDict("texts", []),
        redirect_link: valueDict->getString("redirect_link", "")->JSON.Encode.string,
      }
    })

  if localResults->Array.length > 0 {
    results->Array.push({
      section: Local,
      results: localResults,
      total_results: results->Array.length,
    })
  }

  valueDict
  ->getArrayFromDict("remote-results", [])
  ->Array.forEach(value => {
    let valueDict = value->JSON.Decode.object->Option.getOr(Dict.make())

    let remoteResults =
      valueDict
      ->getArrayFromDict("hits", [])
      ->Array.map(item => {
        {
          texts: [item],
          redirect_link: ""->JSON.Encode.string,
        }
      })

    let total_results = valueDict->getInt("count", remoteResults->Array.length)

    if remoteResults->Array.length > 0 {
      results->Array.push({
        section: valueDict->getString("index", "")->GlobalSearchTypes.getSectionVariant,
        results: remoteResults,
        total_results,
      })
    }
  })

  (results, searchText)
}
