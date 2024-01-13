type statChartColor = [#blue | #grey]
@react.component
let make = (
  ~title,
  ~tooltipText,
  ~deltaTooltipComponent=React.null,
  ~value: float,
  ~data,
  ~statType="",
  ~borderRounded="rounded",
  ~singleStatLoading=false,
  ~showPercentage=true,
  ~loaderType: AnalyticsUtils.loaderType=Shimmer,
  ~statChartColor: statChartColor=#blue,
  ~filterNullVals: bool=false,
  ~statSentiment: Dict.t<AnalyticsUtils.statSentiment>=Dict.make(),
  ~statThreshold: Dict.t<float>=Dict.make(),
  ~isHomePage=false,
) => {
  open Identity
  let (updateKey, setUpdateKey) = React.useState(_ => false)

  let sortedData = React.useMemo1(() => {
    data
    ->Js.Array2.sortInPlaceWith((item1, item2) => {
      let (x1, _y1) = item1
      let (x2, _y2) = item2
      if x1 > x2 {
        -1
      } else if x1 == x2 {
        0
      } else {
        1
      }
    })
    ->Array.map(item => {
      let (x, y) = item
      if y === 0. && filterNullVals {
        (x, Js.Nullable.null)
      } else {
        (x, y->Js.Nullable.return)
      }
    })
  }, [data])

  React.useEffect1(() => {
    if !singleStatLoading {
      setUpdateKey(prev => !prev)
    }
    None
  }, [singleStatLoading])

  let percentFormat = value => {
    `${Js.Float.toFixedWithPrecision(value, ~digits=2)}%`
  }
  // if day > then only date else time
  let statValue = statType => {
    open LogicUtils
    if statType === "Amount" {
      value->indianShortNum
    } else if statType === "Rate" || statType === "NegativeRate" {
      value->Js.Float.isNaN ? "-" : value->percentFormat
    } else if statType === "Volume" {
      value->indianShortNum
    } else if statType === "Latency" {
      latencyShortNum(~labelValue=value, ())
    } else if statType === "LatencyMs" {
      latencyShortNum(~labelValue=value, ~includeMilliseconds=true, ())
    } else {
      value->Belt.Float.toString
    }
  }

  let strokeColor = "#006DF9"

  let options = React.useMemo2((): Highcharts.options<float> => {
    {
      chart: Some(
        {
          "type": "area",
          "zoomType": "x",
          "margin": Some([0, 0, 0, 0]),
          "marginLeft": isHomePage ? Some(-5) : None,
          "marginRight": isHomePage ? Some(-5) : None,
          "backgroundColor": Js.Nullable.null,
          "height": (isHomePage ? "80" : "50")->Some,
          "width": isHomePage ? None : Some("105"),
          "events": None,
        }->genericObjectOrRecordToJson,
      ),
      title: {
        "text": "",
        "style": Js.Json.object_(Dict.make()),
      }->genericObjectOrRecordToJson,
      credits: {
        "enabled": false,
      },
      legend: {
        "enabled": false,
      }->genericObjectOrRecordToJson,
      tooltip: {
        "enabled": false,
      }->genericObjectOrRecordToJson,
      plotOptions: Some(
        {
          "area": {
            "inverted": true,
            "backgroundColor": "transparent",
            "spacing": (0, 0, 0, 0),
            "styledMode": true,
            "pointStart": None,
            "states": {
              "hover": {
                "lineWidth": 3,
              },
            },
            "lineWidth": 3,
          }->genericObjectOrRecordToJson,
          "boxplot": {
            "visible": false,
          },
          "series": {
            "marker": {
              "enabled": false->Some,
              "radius": None,
              "symbol": None,
            },
            "states": None,
            "events": Some({
              "legendItemClick": None,
              "mouseOver": Some(""),
            }),
          }->genericObjectOrRecordToJson,
        }->genericObjectOrRecordToJson,
      ),
      xAxis: {
        "type": "datetime",
        "zoomEnabled": false,
      }->genericObjectOrRecordToJson,
      yAxis: {
        "tickPositioner": None,
        "plotLines": None,
        "visible": false,
        "title": {
          "text": "",
          "style": Js.Json.object_(Dict.make()),
        }->genericObjectOrRecordToJson,
        "labels": {"formatter": None, "enabled": false, "useHTML": false}->Some,
        "zoomEnabled": false,
      }->genericObjectOrRecordToJson,
      series: [
        {
          color: Some(strokeColor),
          fillOpacity: isHomePage ? 0.3 : 0.0,
          name: "Sample",
          data: sortedData,
          legendIndex: 0,
          connectNulls: false,
        },
      ],
    }
  }, (sortedData, statType))
  let isMobileWidth = MatchMedia.useMatchMedia("(max-width: 700px)")

  if singleStatLoading && loaderType === Shimmer {
    if isHomePage {
      <Shimmer styleClass="w-full h-full" />
    } else {
      <div
        className={`p-4`} style={ReactDOMStyle.make(~width=isMobileWidth ? "100%" : "33.33%", ())}>
        <Shimmer styleClass="w-full h-28" />
      </div>
    }
  } else if isHomePage {
    <div className="relative w-full h-full">
      <div
        className={`h-full w-full flex flex-col border ${borderRounded} dark:border-jp-gray-850 bg-white dark:bg-jp-gray-lightgray_background overflow-hidden p-10 mb-7`}>
        <div className="h-full flex flex-col gap-1">
          <div className="font-bold text-[2.3rem]">
            {statValue(statType)->String.toLowerCase->React.string}
          </div>
          <div className={"flex gap-2 items-centertext-jp-gray-700 font-bold"}>
            <div
              className={`${HSwitchUtils.getTextClass(
                  ~textVariant=H3,
                  ~h3TextVariant=Leading_2,
                  (),
                )} text-grey-700`}>
              {title->React.string}
            </div>
            <ToolTip
              description=tooltipText
              toolTipFor={<div className="cursor-pointer">
                <Icon name="info-vacent" size=13 />
              </div>}
              toolTipPosition=ToolTip.Top
            />
          </div>
        </div>
      </div>
      <div className="absolute bottom-0 w-full h-1/3 overflow-hidden rounded">
        <Highcharts.HighchartsReact
          highcharts={Highcharts.highchartsModule} options key={updateKey ? "0" : "1"}
        />
      </div>
    </div>
  } else {
    <div
      className={`mt-4`} style={ReactDOMStyle.make(~width=isMobileWidth ? "100%" : "33.33%", ())}>
      <div
        className={`h-full flex flex-col border ${borderRounded} dark:border-jp-gray-850 bg-white dark:bg-jp-gray-lightgray_background overflow-hidden singlestatBox p-4 md:mr-4`}>
        <div className="p-4 flex flex-col justify-between h-full gap-auto">
          <UIUtils.RenderIf condition={singleStatLoading && loaderType === SideLoader}>
            <div className="animate-spin self-end absolute">
              <Icon name="spinner" size=16 />
            </div>
          </UIUtils.RenderIf>
          <div className="flex flex-row h-1/2 items-end">
            <div className="font-bold text-3xl">
              {statValue(statType)->String.toLowerCase->React.string}
            </div>
            <div className="flex px-4 h-full items-center">
              <Highcharts.HighchartsReact
                highcharts={Highcharts.highchartsModule} options key={updateKey ? "0" : "1"}
              />
            </div>
          </div>
          <div
            className={"flex gap-2 items-center pt-4 text-jp-gray-700 font-bold self-start h-1/2"}>
            <div className="font-semibold text-base text-black dark:text-white">
              {title->React.string}
            </div>
            <ToolTip
              description=tooltipText
              toolTipFor={<div className="cursor-pointer">
                <Icon name="info-vacent" size=13 />
              </div>}
              toolTipPosition=ToolTip.Top
            />
          </div>
        </div>
      </div>
    </div>
  }
}
