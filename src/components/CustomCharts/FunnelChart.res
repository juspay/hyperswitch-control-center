type funnelMetric = Volume | Percentage

@react.component
let make = (
  ~data,
  ~metrics: array<LineChartUtils.metricsConfig>,
  ~size: float=0.24, // to scale
  ~moduleName,
  ~description,
) => {
  let {globalUIConfig: {font: {textColor}}} = React.useContext(ConfigContext.configContext)
  let isMobileView = MatchMedia.useMobileChecker()
  let (size, widthClass, flexDirectionClass) = React.useMemo1(() => {
    isMobileView ? (0.16, "w-full", "flex-col") : (size, "w-1/2", "flex-row")
  }, [isMobileView])
  let funnelData =
    data->Array.get(0)->Option.getOr(JSON.Encode.null)->LogicUtils.getDictFromJsonObject
  let (hoverIndex, setHoverIndex) = React.useState(_ => -1.)
  let (selectedMetric, setSelectedMetric) = React.useState(_ => Volume)
  let length = metrics->Array.length->Float.fromInt
  let widths = metrics->Array.mapWithIndex((metric, i) => {
    let previousMetric = metrics->Array.get(i - 1)
    let previousMetric = switch previousMetric {
    | Some(prevMetric) => prevMetric.metric_name_db
    | None => ""
    }
    let currentVol = funnelData->LogicUtils.getInt(metric.metric_name_db, 0)->Float.fromInt
    let previousVol =
      funnelData->LogicUtils.getInt(previousMetric, currentVol->Float.toInt)->Float.fromInt
    Math.log10(currentVol *. 100. /. previousVol) /. 2.0
  })

  let fixedWidth = ref(size *. 70.)
  let prevMetricVol = ref(None)

  let someData =
    funnelData
    ->Dict.toArray
    ->Array.filter(entry => {
      let (_key, value) = entry
      value->LogicUtils.getIntFromJson(0) !== 0
    })
    ->Array.length > 0
  <div className="block m-6 mb-2">
    <div className="font-semibold text-lg text-black dark:text-white">
      {moduleName->LogicUtils.camelToSnake->LogicUtils.snakeToTitle->React.string}
    </div>
    {switch description {
    | Some(description) =>
      <div className="font-medium text-sm text-jp-gray-800 dark:text-dark_theme my-2">
        {description->React.string}
      </div>
    | None => React.null
    }}
    <UIUtils.RenderIf condition={someData}>
      <div className="flex flex-col">
        <div className="flex gap-6 justify-end">
          <div className={`flex flex-col ${widthClass}`} />
          <div
            className={`flex flex-row items-start ml-6 ${widthClass} font-medium text-sm text-jp-gray-800 dark:text-dark_theme cursor-pointer`}>
            <div
              className={selectedMetric === Volume ? "font-bold" : ""}
              onClick={_ => setSelectedMetric(_ => Volume)}>
              {React.string("Volume")}
            </div>
            {React.string("/")}
            <div
              className={selectedMetric === Percentage ? "font-bold" : ""}
              onClick={_ => setSelectedMetric(_ => Percentage)}>
              {React.string("Percentage")}
            </div>
          </div>
        </div>
        <div className={`flex ${flexDirectionClass} gap-6 mt-5 mb-10 delay-75 animate-slideUp`}>
          <div className={`flex flex-col items-center my-auto ${widthClass}`}>
            {metrics
            ->Array.mapWithIndex((_metric, i) => {
              let i = i->Float.fromInt
              let opacity = (i +. 1.) /. length
              let borderTop = `${(size *. 14.)
                  ->Float.toString}rem solid rgb(0,109,249,${opacity->Float.toString})`

              let currentWidthRatio = switch widths->Array.get(i->Float.toInt) {
              | Some(width) => width
              | None => size *. 70.
              }

              let nextWidthRatio = switch widths->Array.get(i->Float.toInt + 1) {
              | Some(width) => width
              | None => widths->Array.get(i->Float.toInt)->Option.getOr(size *. 70.)
              }

              fixedWidth := currentWidthRatio *. fixedWidth.contents
              let borderXFloat = (1. -. nextWidthRatio) *. fixedWidth.contents /. 2.
              let borderX = `${borderXFloat->Float.toString}rem solid transparent`

              let width = `${fixedWidth.contents->Float.toString}rem`

              let marginBottom = `${(size *. 1.4)->Float.toString}rem`
              let funnelElement =
                <div
                  key={`${i->Float.toString}funnelStage`}
                  className="flex hover:cursor-pointer transition ease-in-out hover:scale-110 duration-300"
                  style={ReactDOMStyle.make(
                    ~borderTop,
                    ~borderLeft=borderX,
                    ~borderRight=borderX,
                    ~width,
                    ~marginBottom,
                    (),
                  )}
                  onMouseOver={_ => setHoverIndex(_ => i)}
                  onMouseOut={_ => setHoverIndex(_ => -1.)}
                />
              funnelElement
            })
            ->React.array}
          </div>
          <div className="flex flex-row justify-center gap-6">
            <div className="flex flex-col items-start">
              {
                open LogicUtils
                metrics
                ->Array.mapWithIndex((metric, i) => {
                  let marginBottom = `${(size *. 1.4)->Float.toString}rem`
                  let paddingTop = `${(size *. 4.2)->Float.toString}rem`
                  let metricVal = funnelData->getInt(metric.metric_name_db, 0)->Float.fromInt
                  let prevMetricVolume = switch prevMetricVol.contents {
                  | Some(vol) => vol
                  | None => metricVal
                  }
                  prevMetricVol :=
                    switch prevMetricVol.contents {
                    | Some(val) => Some(val)
                    | None => Some(metricVal)
                    }

                  <div
                    key={`${i->Int.toString}funnelStageVol`}
                    className={`flex flex-row gap-4 h-full items-center w-max`}
                    style={ReactDOMStyle.make(~marginBottom, ~paddingTop, ())}>
                    <div
                      className="flex font-semibold text-xl text-black dark:text-white w-max items-start">
                      {switch selectedMetric {
                      | Volume =>
                        shortNum(~labelValue=metricVal, ~numberFormat=getDefaultNumberFormat(), ())
                      | Percentage =>
                        (metricVal *. 100. /. prevMetricVolume)
                          ->Float.toFixedWithPrecision(~digits=2) ++ "%"
                      }->React.string}
                    </div>
                  </div>
                })
                ->React.array
              }
            </div>
            <div className="flex flex-col items-start">
              {metrics
              ->Array.mapWithIndex((metric, i) => {
                let marginBottom = `${(size *. 2.1)->Float.toString}rem`
                let paddingTop = `${(size *. 3.4 *. 1.4)->Float.toString}rem`
                <div
                  key={`${i->Int.toString}funnelStageDesc`}
                  className={`flex flex-row gap-4 h-full items-center w-max `}
                  style={ReactDOMStyle.make(~marginBottom, ~paddingTop, ())}>
                  <div
                    className={`transition ease-in-out duration-300 font-medium text-base ${hoverIndex ===
                        i->Float.fromInt
                        ? `${textColor.primaryNormal} scale-110`
                        : "text-jp-gray-800 dark:text-dark_theme"}`}>
                    {metric.metric_label->React.string}
                  </div>
                </div>
              })
              ->React.array}
            </div>
          </div>
        </div>
      </div>
    </UIUtils.RenderIf>
  </div>
}
