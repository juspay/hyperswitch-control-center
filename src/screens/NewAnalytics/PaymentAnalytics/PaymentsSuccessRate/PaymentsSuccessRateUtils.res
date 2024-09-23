open LogicUtils
open NewPaymentAnalyticsUtils

let getData = (json: JSON.t): LineGraphTypes.data => {
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
  let categories = getCategories(json)
  let data = getData(json)
  let title = {
    text: "Payments Success Rate",
  }
  {categories, data, title}
}
