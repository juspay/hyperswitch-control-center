external objToJson: {..} => Js.Json.t = "%identity"

module RawBarChart = {
  @react.component
  let make = (~options: Js.Json.t) => {
    <Highcharts.BarChart highcharts={Highcharts.highchartsModule} options />
  }
}

module HighBarChart1D = {
  @react.component
  let make = (
    ~rawData: array<Js.Json.t>,
    ~groupKey,
    ~isHrizonatalBar: bool=true,
    ~selectedMetrics: LineChartUtils.metricsConfig,
  ) => {
    let (theme, _setTheme) = React.useContext(ThemeProvider.themeContext)
    let gridLineColor = switch theme {
    | Light => "#2e2f39"
    | Dark => "#e6e6e6"
    }

    let (categories, barSeries) = React.useMemo3(() => {
      LineChartUtils.barChartDataMaker(
        ~rawData,
        ~activeTab=groupKey,
        ~yAxis=selectedMetrics.metric_name_db,
      )
    }, (rawData, groupKey, selectedMetrics.metric_name_db))

    let barOption: Js.Json.t = React.useMemo2(() => {
      let barOption: Js.Json.t = {
        "chart": Highcharts.makebarChart(
          ~chartType={isHrizonatalBar ? "bar" : "column"},
          ~backgroundColor=Js.Nullable.null,
          (),
        ),
        "title": {
          "text": "",
          "style": Js.Json.object_(Js.Dict.empty()),
        },
        "xAxis": {
          "categories": categories,
        },
        "yAxis": {
          "gridLineColor": gridLineColor,
          "title": {"text": selectedMetrics.metric_label},
          "labels": {
            "formatter": Some(
              @this
              (param: Highcharts.yAxisRecord) =>
                LineChartUtils.formatLabels(selectedMetrics, param.value),
            ),
          }->Some,
        },
        "credits": {
          "enabled": false,
        },
        "series": barSeries,
        "legend": {"enabled": false},
      }->objToJson
      barOption
    }, (barSeries, gridLineColor))
    if barSeries->Js.Array2.length > 0 {
      <RawBarChart options=barOption />
    } else {
      React.null
    }
  }
}
open LineChartUtils
module HighBarChart2D = {
  @react.component
  let make = (
    ~rawData: array<Js.Json.t>,
    ~groupKey,
    ~isHrizonatalBar: bool=true,
    ~selectedMetrics: LineChartUtils.metricsConfig,
  ) => {
    let (groupBy1, groupBy2) = switch groupKey {
    | Some(value) => (
        value->Belt.Array.get(0)->Belt.Option.getWithDefault(""),
        value->Belt.Array.get(1)->Belt.Option.getWithDefault(""),
      )
    | None => ("", "")
    }
    let (groupBy1, groupBy2) = (groupBy2, groupBy1)
    let chartDictData = Js.Dict.empty()
    rawData->Js.Array2.forEach(item => {
      let dict = item->LogicUtils.getDictFromJsonObject
      let groupBy =
        dict->LogicUtils.getString(
          groupBy1,
          Js.Dict.get(dict, groupBy1)
          ->Belt.Option.getWithDefault(""->Js.Json.string)
          ->Js.Json.stringify,
        )
      let groupBy = groupBy === "" ? "NA" : groupBy

      chartDictData->appendToDictValue(groupBy, item)
    })
    let isMobileView = MatchMedia.useMobileChecker()

    <div className="flex flex-wrap">
      {
        let chartArr = {
          chartDictData
          ->Js.Dict.entries
          ->Js.Array2.mapi((item, index) => {
            let (_, value) = item
            <div key={Belt.Int.toString(index)} className={isMobileView ? "w-fit" : "w-1/3"}>
              <HighBarChart1D rawData=value groupKey=groupBy2 isHrizonatalBar selectedMetrics />
            </div>
          })
        }
        if isMobileView {
          <Carousel imgArr=chartArr />
        } else {
          chartArr->React.array
        }
      }
    </div>
  }
}

module HighBarChart3D = {
  @react.component
  let make = (
    ~rawData: array<Js.Json.t>,
    ~groupKey,
    ~isHrizonatalBar: bool=true,
    ~selectedMetrics: LineChartUtils.metricsConfig,
  ) => {
    let (groupBy1, groupBy2, groupby3) = switch groupKey {
    | Some(value) => (
        value->Belt.Array.get(0)->Belt.Option.getWithDefault(""),
        value->Belt.Array.get(1)->Belt.Option.getWithDefault(""),
        value->Belt.Array.get(2)->Belt.Option.getWithDefault(""),
      )
    | None => ("", "", "")
    }
    let (groupBy1, groupBy2, groupby3) = (groupBy2, groupby3, groupBy1)

    let chartDictData = Js.Dict.empty()
    rawData->Js.Array2.forEach(item => {
      let dict = item->LogicUtils.getDictFromJsonObject
      let groupBy1 =
        dict->LogicUtils.getString(
          groupBy1,
          Js.Dict.get(dict, groupBy1)
          ->Belt.Option.getWithDefault(""->Js.Json.string)
          ->Js.Json.stringify,
        )
      let groupBy1 = groupBy1 === "" ? "NA" : groupBy1
      let groupBy2 =
        dict->LogicUtils.getString(
          groupBy2,
          Js.Dict.get(dict, groupBy2)
          ->Belt.Option.getWithDefault(""->Js.Json.string)
          ->Js.Json.stringify,
        )
      let groupBy2 = groupBy2 === "" ? "NA" : groupBy2

      chartDictData->appendToDictValue(groupBy1 ++ " / " ++ groupBy2, item)
    })
    let isMobileView = MatchMedia.useMobileChecker()

    <div className="flex  flex-wrap">
      {
        let chartArr = {
          chartDictData
          ->Js.Dict.entries
          ->Js.Array2.mapi((item, index) => {
            let (_, value) = item

            <div key={Belt.Int.toString(index)} className={isMobileView ? "w-fit" : "w-1/3"}>
              <HighBarChart1D rawData=value groupKey=groupby3 isHrizonatalBar selectedMetrics />
            </div>
          })
        }
        if isMobileView {
          <Carousel imgArr=chartArr />
        } else {
          chartArr->React.array
        }
      }
    </div>
  }
}
