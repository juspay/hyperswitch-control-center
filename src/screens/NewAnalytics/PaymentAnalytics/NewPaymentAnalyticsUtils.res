open LogicUtils

let getCategories = (json: JSON.t, key: string): array<string> => {
  json
  ->getArrayFromJson([])
  ->Array.flatMap(item => {
    item
    ->getDictFromJsonObject
    ->getArrayFromDict("queryData", [])
    ->Array.map(item => item->getDictFromJsonObject->getString(key, ""))
  })
}

let getColor = index => {
  ["#1059C1B2", "#0EB025B2"]->Array.get(index)->Option.getOr("#1059C1B2")
}

let getLineGraphData = (json: JSON.t, key: string): LineGraphTypes.data => {
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
      name: `Series ${(index + 1)->Int.toString}`,
      data,
      color: index->getColor,
    }
    dataObj
  })
}

let getBarGraphData = (json: JSON.t, key: string): BarGraphTypes.data => {
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
    let dataObj: BarGraphTypes.dataObj = {
      showInLegend: false,
      name: `Series ${(index + 1)->Int.toString}`,
      data,
      color: "#7CC88F",
    }
    dataObj
  })
}
