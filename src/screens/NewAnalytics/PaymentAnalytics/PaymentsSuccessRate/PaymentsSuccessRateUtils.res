open NewPaymentAnalyticsUtils
open LogicUtils

open LineGraphTypes
let tooltipFormatter = (
  @this
  (this: pointFormatter) => {
    let title = `<div style="font-size: 16px; font-weight: bold;">Payments Success Rate</div>`

    let tableItems =
      this.points
      ->Array.map(point =>
        `<div style="display: flex; align-items: center;">
                  <div style="width: 10px; height: 10px; background-color:${point.color}; border-radius:3px;"></div>
                  <div style="margin-left: 8px;">${point.x}</div>
                  <div style="flex: 1; text-align: right; font-weight: bold;">${point.y->Float.toString} %</div>
                </div>`
      )
      ->Array.joinWith("")

    let content = `
          <div style=" 
          padding:5px 12px;
          border-left: 3px solid #0069FD;
          display:flex;
          flex-direction:column;
          justify-content: space-between;
          gap: 7px;">
              ${title}
              <div style="
                margin-top: 5px;
                display:flex;
                flex-direction:column;
                gap: 7px;">
                ${tableItems}
              </div>
        </div>`

    `<div style="
    padding: 10px;
    width:fit-content;
    border-radius: 7px;
    background-color:#FFFFFF;
    padding:10px;
    box-shadow: 0px 4px 8px rgba(0, 0, 0, 0.2);
    border: 1px solid #E5E5E5;
    position:relative;">
        ${content}
    </div>`
  }
)->asTooltipPointFormatter

let getMetaData = json => {
  json
  ->getArrayFromJson([])
  ->getValueFromArray(0, JSON.Encode.array([]))
  ->getDictFromJsonObject
  ->getArrayFromDict("metaData", [])
  ->getValueFromArray(0, JSON.Encode.null)
  ->getDictFromJsonObject
}

let graphTitle = json => getMetaData(json)->getInt("payments_success_rate", 0)->Int.toString

let paymentsSuccessRateMapper = (
  ~data: JSON.t,
  ~xKey: string,
  ~yKey: string,
): LineGraphTypes.lineGraphPayload => {
  open LineGraphTypes
  let categories = data->getCategories(0, yKey)

  let lineGraphData =
    data
    ->getArrayFromJson([])
    ->Array.mapWithIndex((item, index) => {
      let name = `Series ${(index + 1)->Int.toString}`
      let color = index->getColor
      getLineGraphObj(~array=item->getArrayFromJson([]), ~key=xKey, ~name, ~color)
    })
  let title = {
    text: "Payments Success Rate",
  }
  {categories, data: lineGraphData, title, tooltipFormatter}
}

open NewAnalyticsTypes
let tabs = [{label: "Daily", value: (#G_ONEDAY: granularity :> string)}]

let defaulGranularity = {
  label: "Hourly",
  value: (#G_ONEDAY: granularity :> string),
}
