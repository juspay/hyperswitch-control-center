module RawBarChart = {
  @react.component
  let make = (~options: JSON.t) => {
    <Highcharts.BarChart highcharts={Highcharts.highchartsModule} options />
  }
}

module HighBarChart1D = {
  @react.component
  let make = (
    ~rawData: array<JSON.t>,
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

    let barOption: JSON.t = React.useMemo2(() => {
      let barOption: JSON.t = {
        "chart": Highcharts.makebarChart(
          ~chartType={isHrizonatalBar ? "bar" : "column"},
          ~backgroundColor=Nullable.null,
          (),
        ),
        "title": {
          "text": "",
          "style": JSON.Encode.object(Dict.make()),
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
      }->Identity.genericObjectOrRecordToJson
      barOption
    }, (barSeries, gridLineColor))
    if barSeries->Array.length > 0 {
      <RawBarChart options=barOption />
    } else {
      React.null
    }
  }
}
