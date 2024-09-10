open LineGraphType
open NewAnalyticsTypes

let getChartData = (array, ~color, ~name) => {
  open LogicUtils
  let key = "payment_processed_amount"

  let data = array->Array.map(value => {
    let valueDict = value->getDictFromJsonObject

    valueDict->getInt(key, 0)
  })

  {
    name,
    color,
    data,
    showInLegend: false,
  }
}

let options = {
  "chart": {
    "type": "line",
    "spacingLeft": 20,
    "spacingRight": 20,
  },
  "title": {
    "text": "",
  },
  "xAxis": {
    "categories": [
      "01 Aug",
      "02 Aug",
      "03 Aug",
      "04 Aug",
      "05 Aug",
      "06 Aug",
      "07 Aug",
      "08 Aug",
      "09 Aug",
      "10 Aug",
      "11 Aug",
    ],
    "crosshair": true,
    "lineWidth": 1, // Keep a minimal axis line width
    "tickWidth": 1, // Keep the ticks on the line
    "labels": {
      "align": "center", // Align labels with the grid lines
      "style": {
        "color": "#666", // Label color as per the example
      },
      "y": 35,
    },
    "gridLineWidth": 1, // Solid grid line for x-axis
    "gridLineColor": "#e6e6e6", // Lighter grid lines
    "tickmarkPlacement": "on", // Ensure tick marks and labels are aligned
    "endOnTick": false, // Allow the axis to end in an open format
    "startOnTick": false, // Avoid a boxed-in look
  },
  "yAxis": {
    "title": {
      "text": "USD",
    },
    // "labels": {
    //     formatter: function () {
    //         return this.value.toLocaleString(); // Format the value in thousands with commas
    //     },
    //     style: {
    //         color: '#999' // Label color similar to image
    //     }
    // },
    "gridLineWidth": 1,
    "gridLineColor": "#e6e6e6",
    "gridLineDashStyle": "Dash", // Dashed grid lines for y-axis
    "min": 0,
  },
  // tooltip: {
  //     useHTML: true,
  //     shared: true,
  //     borderWidth: 0,
  //     shadow: false,
  //     backgroundColor: 'white',
  //     style: {
  //         color: '#333',
  //         fontSize: '12px'
  //     },
  //     formatter: function () {
  //         let amount = this.points[0].y.toLocaleString(); // Formatted value with commas
  //         let change = '+20%'; // Customize as needed or calculate dynamically
  //         return `
  //             <div style="padding: 10px;">
  //                 <b>Amount Processed: <span style="font-size: 16px;">${amount} USD</span></b><br>
  //                 <span style="color: green;">${change} from previous day</span><br>
  //                 ${Highcharts.dateFormat('%d %b %Y', this.x)}
  //             </div>
  //         `;
  //     }
  // },
  "plotOptions": {
    "line": {
      "marker": {
        "enabled": false, // Disable point markers on lines
      },
    },
  },
  "series": [
    {
      "showInLegend": false, // Hide the legend
      "name": "Series 1",
      "data": [2, 4, 3, 6, 5, 7, 3, 4, 6, 8, 5],
      "color": "#2f7ed8",
    },
    {
      "showInLegend": false, // Hide the legend
      "name": "Series 2",
      "data": [3, 2, 5, 4, 7, 5, 6, 7, 4, 6, 7],
      "color": "#8bbc21",
    },
  ],
  "credits": {
    "enabled": false, // Hide Highcharts credits
  },
}->Identity.genericObjectOrRecordToJson

open LogicUtils

let defaultDimesions = {
  dimension: #no_value,
  values: [],
}

let getSpecificDimension = (dimensions: dimensions, dimension: dimension) => {
  dimensions
  ->Array.filter(ele => ele.dimension == dimension)
  ->Array.at(0)
  ->Option.getOr(defaultDimesions)
}

let getGroupByForPerformance = (~dimensions: array<dimension>) => {
  dimensions->Array.map(v => (v: dimension :> string))
}

let getMetricForPerformance = (~metrics: array<metrics>) =>
  metrics->Array.map(v => (v: metrics :> string))

let getFilterForPerformance = (
  ~dimensions: dimensions,
  ~filters: option<array<dimension>>,
  ~custom: option<dimension>=None,
  ~customValue: option<array<status>>=None,
  ~excludeFilterValue: option<array<status>>=None,
) => {
  let filtersDict = Dict.make()
  let customFilter = custom->Option.getOr(#no_value)
  switch filters {
  | Some(val) => {
      val->Array.forEach(filter => {
        let data = if filter == customFilter {
          customValue->Option.getOr([])->Array.map(v => (v: status :> string))
        } else {
          getSpecificDimension(dimensions, filter).values
        }

        let updatedFilters = switch excludeFilterValue {
        | Some(excludeValues) =>
          data->Array.filter(item => {
            !(excludeValues->Array.map(v => (v: status :> string))->Array.includes(item))
          })
        | None => data
        }->Array.map(str => str->JSON.Encode.string)

        filtersDict->Dict.set((filter: dimension :> string), updatedFilters->JSON.Encode.array)
      })
      filtersDict->JSON.Encode.object->Some
    }
  | None => None
  }
}

let getTimeRange = (startTime, endTime) => {
  [
    ("startTime", startTime->JSON.Encode.string),
    ("endTimeVal", endTime->JSON.Encode.string),
  ]->getJsonFromArrayOfJson
}

let requestBody = (
  ~dimensions: dimensions,
  ~startTime: string,
  ~endTime: string,
  ~metrics: array<metrics>,
  ~groupBy: option<array<dimension>>=None,
  ~filters: option<array<dimension>>=[]->Some,
  ~customFilter: option<dimension>=None,
  ~excludeFilterValue: option<array<status>>=None,
  ~applyFilterFor: option<array<status>>=None,
  ~delta: option<bool>=None,
) => {
  let metrics = getMetricForPerformance(~metrics)
  let filter = getFilterForPerformance(
    ~dimensions,
    ~filters,
    ~custom=customFilter,
    ~customValue=applyFilterFor,
    ~excludeFilterValue,
  )
  let groupByNames = switch groupBy {
  | Some(vals) => getGroupByForPerformance(~dimensions=vals)->Some
  | None => None
  }

  [
    AnalyticsUtils.getFilterRequestBody(
      ~metrics=Some(metrics),
      ~delta=delta->Option.getOr(false),
      ~groupByNames,
      ~filter,
      ~startDateTime=startTime,
      ~endDateTime=endTime,
    )->JSON.Encode.object,
  ]->JSON.Encode.array
}

let getGroupByKey = (dict, keys: array<dimension>) => {
  let key =
    keys
    ->Array.map(key => {
      dict->getDictFromJsonObject->getString((key: dimension :> string), "")
    })
    ->Array.joinWith(":")
  key
}

let getGroupByDataForStatusAndPaymentCount = (array, keys: array<dimension>) => {
  let result = Dict.make()
  array->Array.forEach(entry => {
    let key = getGroupByKey(entry, keys)
    let connectorResult = Dict.get(result, key)
    switch connectorResult {
    | None => {
        let newConnectorResult = Dict.make()
        let st = entry->getDictFromJsonObject->getString("status", "")
        let pc = entry->getDictFromJsonObject->getInt("payment_count", 0)
        Dict.set(result, key, newConnectorResult)
        Dict.set(newConnectorResult, st, pc)
      }
    | Some(connectorResult) => {
        let st = entry->getDictFromJsonObject->getString("status", "")
        let pc = entry->getDictFromJsonObject->getInt("payment_count", 0)
        let currentCount = Dict.get(connectorResult, st)->Belt.Option.getWithDefault(0)
        Dict.set(connectorResult, st, currentCount + pc)
      }
    }
  })

  result
}
