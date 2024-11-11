open LogicUtils

let getCategories = (data: JSON.t, index: int, key: string) => {
  data
  ->getArrayFromJson([])
  ->getValueFromArray(index, []->JSON.Encode.array)
  ->getArrayFromJson([])
  ->Array.map(item => {
    let value = item->getDictFromJsonObject->getString(key, "NA")

    if value->isNonEmptyString && key == "time_bucket" {
      let dateObj = value->DayJs.getDayJsForString
      `${dateObj.month()->NewAnalyticsUtils.getMonthName} ${dateObj.format("DD")}`
    } else {
      value
    }
  })
}

let getColor = index => {
  ["#1059C1B2", "#0EB025B2"]->Array.get(index)->Option.getOr("#1059C1B2")
}

let getAmountValue = (data, ~id) => {
  switch data->getOptionFloat(id) {
  | Some(value) => value /. 100.0
  | _ => 0.0
  }
}

let getLineGraphObj = (
  ~array: array<JSON.t>,
  ~key: string,
  ~name: string,
  ~color,
  ~isAmount=false,
): LineGraphTypes.dataObj => {
  let data = array->Array.map(item => {
    let dict = item->getDictFromJsonObject
    if isAmount {
      dict->getAmountValue(~id=key)
    } else {
      dict->getFloat(key, 0.0)
    }
  })
  let dataObj: LineGraphTypes.dataObj = {
    showInLegend: true,
    name,
    data,
    color,
  }
  dataObj
}

let getBarGraphObj = (
  ~array: array<JSON.t>,
  ~key: string,
  ~name: string,
  ~color,
): BarGraphTypes.dataObj => {
  let data = array->Array.map(item => {
    item->getDictFromJsonObject->getInt(key, 0)
  })
  let dataObj: BarGraphTypes.dataObj = {
    showInLegend: false,
    name,
    data,
    color,
  }
  dataObj
}

let getBarGraphData = (json: JSON.t, key: string, barColor: string): BarGraphTypes.data => {
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
      color: barColor,
    }
    dataObj
  })
}

let modifyDataWithMissingPoints = (
  ~data,
  ~key,
  ~startDate,
  ~endDate,
  ~defaultValue: JSON.t,
  ~timeKey="time_bucket",
  ~granularity,
) => {
  data->Array.map(response => {
    let dict = response->getDictFromJsonObject->Dict.copy
    let queryData = dict->getArrayFromDict(key, [])
    let modifiedData = NewAnalyticsUtils.fillMissingDataPoints(
      ~data=queryData,
      ~startDate,
      ~endDate,
      ~timeKey,
      ~defaultValue,
      ~granularity,
    )
    dict->Dict.set(key, modifiedData->JSON.Encode.array)
    dict
  })
}

let getMetaDataValue = (~data, ~index, ~key) => {
  data
  ->getArrayFromJson([])
  ->getValueFromArray(index, Dict.make()->JSON.Encode.object)
  ->getDictFromJsonObject
  ->getFloat(key, 0.0)
}

open LineGraphTypes
let tooltipFormatter = (
  ~secondaryCategories,
  ~title,
  ~metricType,
  ~comparison: option<DateRangeUtils.comparison>=None,
) => {
  open NewAnalyticsUtils

  (
    @this
    (this: pointFormatter) => {
      let title = `<div style="font-size: 16px; font-weight: bold;">${title}</div>`

      let defaultValue = {color: "", x: "", y: 0.0, point: {index: 0}}
      let primartPoint = this.points->getValueFromArray(0, defaultValue)
      let secondaryPoint = this.points->getValueFromArray(1, defaultValue)

      // TODO:Currency need to be picked from filter
      let suffix = metricType == NewAnalyticsTypes.Amount ? "USD" : ""

      let getRowsHtml = (~iconColor, ~date, ~value, ~comparisionComponent="") => {
        let valueString = valueFormatter(value, metricType)
        `<div style="display: flex; align-items: center;">
            <div style="width: 10px; height: 10px; background-color:${iconColor}; border-radius:3px;"></div>
            <div style="margin-left: 8px;">${date}${comparisionComponent}</div>
            <div style="flex: 1; text-align: right; font-weight: bold;margin-left: 25px;">${valueString} ${suffix}</div>
        </div>`
      }

      let tableItems = [
        getRowsHtml(~iconColor=primartPoint.color, ~date=primartPoint.x, ~value=primartPoint.y),
        {
          switch comparison {
          | Some(value) =>
            value == DateRangeUtils.EnableComparison
              ? getRowsHtml(
                  ~iconColor=secondaryPoint.color,
                  ~date=secondaryCategories->getValueFromArray(secondaryPoint.point.index, ""),
                  ~value=secondaryPoint.y,
                  ~comparisionComponent=getToolTipConparision(
                    ~primaryValue=primartPoint.y,
                    ~secondaryValue=secondaryPoint.y,
                  ),
                )
              : ""
          | None => ""
          }
        },
      ]->Array.joinWith("")

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
}

let getSmartRetryMetricType = isSmartRetryEnabled => {
  open NewAnalyticsTypes
  switch isSmartRetryEnabled {
  | true => Smart_Retry
  | false => Default
  }
}

let getEntityForSmartRetry = isEnabled => {
  open NewAnalyticsTypes
  open APIUtilsTypes
  switch isEnabled {
  | Smart_Retry => ANALYTICS_PAYMENTS
  | Default => ANALYTICS_PAYMENTS_V2
  }
}
