type statChartColor = [#blue | #grey]
open ApexCharts
@react.component
let make = (
  ~title,
  ~tooltipText,
  ~deltaTooltipComponent=React.null,
  ~value: float,
  ~data,
  ~statType="",
  ~borderRounded="rounded-lg",
  ~singleStatLoading=false,
  ~showPercentage=true,
  ~loaderType: AnalyticsUtils.loaderType=Shimmer,
  ~statChartColor: statChartColor=#blue,
  ~filterNullVals: bool=false,
  ~statSentiment: Dict.t<AnalyticsUtils.statSentiment>=Dict.make(),
  ~statThreshold: Dict.t<float>=Dict.make(),
  ~fullWidth=false,
) => {
  let percentFormat = value => {
    `${Float.toFixedWithPrecision(value, ~digits=2)}%`
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
      latencyShortNum(~labelValue=value)
    } else if statType === "LatencyMs" {
      latencyShortNum(~labelValue=value, ~includeMilliseconds=true)
    } else {
      value->Float.toString
    }
  }

  let isMobileWidth = MatchMedia.useMatchMedia("(max-width: 700px)")

  let sortedData1 = React.useMemo(() => {
    data
    ->Array.toSorted((item1, item2) => {
      let (x1, _y1) = item1
      let (x2, _y2) = item2
      if x1 > x2 {
        -1.
      } else if x1 == x2 {
        0.
      } else {
        1.
      }
    })
    ->Array.map(item => {
      let (x, y) = item
      {
        x,
        y,
      }
    })
  }, [data])

  let _options1 = {
    chart: {
      height: 10,
      toolbar: {
        show: false,
      },
    },
    legend: {show: false},
    stroke: {curve: "smooth"},
    dataLabels: {enabled: false},
    grid: {show: false},
    xaxis: {
      labels: {
        show: false, // Hide x-axis labels
      },
      axisBorder: {
        show: false, // Hide x-axis border
      },
      axisTicks: {
        show: false, // Hide x-axis ticks
      },
    },
    yaxis: {
      labels: {
        show: false, // Hide x-axis labels
      },
      axisBorder: {
        show: false, // Hide x-axis border
      },
      axisTicks: {
        show: false, // Hide x-axis ticks
      },
    },
    tooltip: {
      enabled: false,
    },
    colors: ["#006DF9"],
  }

  let _series = [
    {
      \"type": "area",
      data: sortedData1,
    },
  ]

  if singleStatLoading && loaderType === Shimmer {
    <div className={`p-4`} style={width: fullWidth ? "100%" : isMobileWidth ? "100%" : "33.33%"}>
      <Shimmer styleClass="w-full h-28" />
    </div>
  } else {
    <div
      className="h-full mt-4" style={width: fullWidth ? "100%" : isMobileWidth ? "100%" : "33.33%"}>
      <div
        className={`h-full flex flex-col border ${borderRounded} dark:border-jp-gray-850 bg-white dark:bg-jp-gray-lightgray_background overflow-hidden singlestatBox p-2 md:mr-4`}>
        <div className="p-4 flex flex-col justify-between h-full gap-auto">
          <RenderIf condition={singleStatLoading && loaderType === SideLoader}>
            <div className="animate-spin self-end absolute">
              <Icon name="spinner" size=16 />
            </div>
          </RenderIf>
          <div className="flex justify-between w-full h-1/2 items-end">
            <div className="font-bold text-3xl w-1/3">
              {statValue(statType)->String.toLowerCase->React.string}
            </div>
            // <div className="h-16 w-2/3 scale-[0.4]">
            // <ApexCharts.ReactApexChart
            //   \"type"="area"
            //   options={options1}
            //   series={series->objToJson}
            //   height={"170"}
            //   width="380"
            // />
            // </div>
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
              newDesign=true
            />
          </div>
        </div>
      </div>
    </div>
  }
}
