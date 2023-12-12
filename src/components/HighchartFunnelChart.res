open Highcharts
open LogicUtils
type options = {x: int}
type tooltipPoints = {
  name: string,
  x: int,
  y: float,
  color: string,
}
type xAxisCategory = {value: string}
type yAxisLabel = {value: float}
type userOptions = {name: string}
type data = {options: options}
type legendObj = {data: array<data>, color: string, userOptions: userOptions}
type thisType = {value: int}

@react.component
let make = (
  ~dataSet: Js.Dict.t<array<float>>,
  ~categories: array<string>,
  ~formatter,
  ~chartColors: array<string>=[],
  ~tooltipFormatter,
  ~yAxisLabelFormatter,
) => {
  let (theme, _setTheme) = React.useContext(ThemeProvider.themeContext)
  let categories = if categories->Js.Array2.length >= 1 {
    Js.Array2.concat(categories, [""])
  } else {
    categories
  }
  let (zonesFor1D, chartType) = if dataSet->Js.Dict.keys->Js.Array2.length === 1 {
    let datasetValues = dataSet->Js.Dict.values->Belt.Array.get(0)->Belt.Option.getWithDefault([])
    let len = if mod(datasetValues->Js.Array2.length, 1) === 0 {
      datasetValues->Js.Array2.length + 1
    } else {
      datasetValues->Js.Array2.length
    }

    (
      datasetValues->Js.Array2.mapi((_, i) => {
        let strOpacity =
          `0${(100 / len * (i + 1))->Belt.Int.toString}`->Js.String2.sliceToEnd(~from=-2)
        let opacity = `${strOpacity}`

        {
          "value": i,
          "fillColor": `${chartColors
            ->Belt.Array.get(0)
            ->Belt.Option.getWithDefault("")}${opacity}`,
          "color": `${chartColors->Belt.Array.get(0)->Belt.Option.getWithDefault("")}`,
        }->Identity.genericObjectOrRecordToJson
      }),
      "area",
    )
  } else {
    ([], "line")
  }
  let maxValueForTheDataSet =
    []->Js.Array2.concatMany(dataSet->Js.Dict.values)->Js.Math.maxMany_float

  let chartData: array<Js.Json.t> =
    dataSet
    ->Js.Dict.entries
    ->Js.Array2.mapi((dataSetValue, chartItemIndex) => {
      let (key, value) = dataSetValue

      let updatedValue = value->Js.Array2.map(item => {
        {
          "name": key,
          "y": item->Js.Nullable.return,
        }->Identity.genericObjectOrRecordToJson
      })
      let values = {
        "name": key,
        "data": updatedValue,
        "color": chartColors->Belt.Array.get(chartItemIndex),
        "pointPlacement": "on",
        "legendIndex": chartItemIndex,
      }->Identity.genericObjectOrRecordToJson
      if zonesFor1D->Js.Array2.length !== 0 {
        Js.Array2.concat(
          values->getDictFromJsonObject->Js.Dict.entries,
          Js.Dict.fromArray([
            ("zones", zonesFor1D->Js.Json.array),
            ("zoneAxis", "x"->Js.Json.string),
          ])->Js.Dict.entries,
        )
        ->Js.Dict.fromArray
        ->Js.Json.object_
      } else {
        values
      }
    })
  let options = React.useMemo3((): Highcharts.optionsJson<Js.Json.t> => {
    {
      chart: Some(
        {
          "type": chartType,
          "zoomType": "x",
          "backgroundColor": Js.Nullable.null,
          "events": None,
          "marginBottom": 50,
        }->Identity.genericObjectOrRecordToJson,
      ),
      title: {
        "text": "",
        "style": Js.Json.object_(Js.Dict.empty()),
      }->Identity.genericObjectOrRecordToJson,
      credits: {
        "enabled": false,
      },
      tooltip: {
        "shared": true,
        "enabled": true,
        "useHTML": true,
        "stickOnContact": true,
        "pointFormat": None,
        "pointFormatter": Some(
          @this
          (points: tooltipPoints) => {
            tooltipFormatter(points)
          },
        ),
        "headerFormat": "",
        "backgroundColor": theme === Light ? "rgba(25, 26, 26, 1)" : "rgba(247, 247, 250, 1)",
        "borderColor": theme === Light ? "rgba(25, 26, 26, 1)" : "rgba(247, 247, 250, 1)",
        "style": {
          "color": theme === Light ? "rgba(246, 248, 249, 1)" : "rgba(25, 26, 26, 1)",
        },
      }->Identity.genericObjectOrRecordToJson,
      plotOptions: Some(
        {
          "area": {
            "inverted": true,
            "lineWidth": 2,
          }->Identity.genericObjectOrRecordToJson,
          "boxplot": {
            "visible": false,
          },
          "series": {
            "stickyTracking": false,
            "marker": {
              "fillColor": "#FFFFFF",
              "lineWidth": 2,
              "lineColor": Js.Json.null,
              "symbol": "circle"->Some,
            },
            "reversed": true,
            "animation": true,
            "events": Some({
              "legendItemClick": None,
              "mouseOver": Some(""),
            }),
          }->Identity.genericObjectOrRecordToJson,
        }->Identity.genericObjectOrRecordToJson,
      ),
      legend: {
        "enabled": false,
      }->Identity.genericObjectOrRecordToJson,
      xAxis: {
        "visible": true,
        "lineWidth": 0,
        "labels": {
          "style": {
            "color": "#2B2B2B",
            "fontFamily": "Inter",
            "fontSize": "14px",
            "fontStyle": "normal",
            "fontWeight": "600",
            "lineHeight": "20px",
            "wordBreak": "break-all",
            "textOverflow": "allow",
          },
        },
        "categories": categories,
      }->Identity.genericObjectOrRecordToJson,
      yAxis: {
        "title": "",
        "max": maxValueForTheDataSet,
        "min": 0.,
        "visible": true,
        "gridLineWidth": 0,
        "labels": {
          "align": "right",
          "formatter": Some((@this param: yAxisLabel) => {yAxisLabelFormatter(param.value)}),
          "enabled": true,
          "style": {
            "fontFamily": "Lato, sans-serif",
            "fontSize": "14px",
            "fontStyle": "normal",
            "fontWeight": 500,
            "lineHeight": "20px",
            "letterSpacing": "1px",
            "color": theme === Light ? "#4B5468" : "rgba(246, 248, 249, 0.25)",
          },
        }->Identity.genericObjectOrRecordToJson,
      }->Identity.genericObjectOrRecordToJson,
      series: chartData,
    }
  }, (dataSet, categories, formatter))

  <div className="w-full">
    <Highcharts.HighchartsReactDataJson highcharts={Highcharts.highchartsModule} options />
  </div>
}
