open LogicUtils

let getCategories = (json: JSON.t): array<string> => {
  json
  ->getArrayFromJson([])
  ->Array.flatMap(item => {
    item
    ->getDictFromJsonObject
    ->getArrayFromDict("queryData", [])
    ->Array.map(item => item->getDictFromJsonObject->getString("time_bucket", ""))
  })
}

let getData = (json: JSON.t, key: string): LineGraphTypes.data => {
  json
  ->getArrayFromJson([])
  ->Array.mapWithIndex((item, index) => {
    let data =
      item
      ->getDictFromJsonObject
      ->getArrayFromDict("queryData", [])
      ->Array.map(item => {
        item->getDictFromJsonObject->getInt(key, 0)
      })
    let dataObj: LineGraphTypes.dataObj = {
      showInLegend: false,
      name: `Series ${index->Int.toString}`,
      data,
      color: "#2f7ed8",
    }
    dataObj
  })
}
