open LogicUtils

let getTimeBucket = (json: JSON.t): array<string> => {
  json
  ->getArrayFromJson([])
  ->Array.map(item => item->getDictFromJsonObject->getString("time_bucket", ""))
}

let createData = (json: JSON.t): LineGraphTypes.data => {
  json
  ->getArrayFromJson([])
  ->Array.mapWithIndex((item, index) => {
    let data =
      item
      ->getDictFromJsonObject
      ->getArrayFromDict("queryData", [])
      ->Array.map(item => {
        item->getDictFromJsonObject->getInt("payments_success_rate", 0)
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

let paymentsSuccessRateMapper = (json: JSON.t): LineGraphTypes.lineGraphPayload => {
  open LineGraphTypes
  let categories = [
    "2024-08-13 18:30:00",
    "2024-08-14 18:30:00",
    "2024-08-15 18:30:00",
    "2024-08-16 18:30:00",
    "2024-08-17 18:30:00",
    "2024-08-18 18:30:00",
    "2024-08-19 18:30:00",
  ]
  // getTimeBucket(json)
  let data = [
    {
      showInLegend: false,
      name: "Series 1",
      data: [40, 35, 60, 70, 75, 65, 50],
      color: "#2f7ed8",
    },
    {
      showInLegend: false,
      name: "Series 2",
      data: [30, 90, 60, 50, 80, 65, 80],
      color: "#2f7ed8",
    },
  ]
  // let data = createData(json)
  let title = {
    text: "Payments Success Rate",
  }
  {categories, data, title}
}
