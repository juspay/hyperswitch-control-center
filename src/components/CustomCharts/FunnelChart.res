@react.component
let make = (
  ~data,
  ~metrics: array<LineChartUtils.metricsConfig>,
  ~size: float=0.24, // to scale
  ~moduleName,
  ~description,
) => {
  let isMobileView = MatchMedia.useMobileChecker()
  let (size, widthClass, flexDirectionClass) = React.useMemo1(() => {
    isMobileView ? (0.16, "w-full", "flex-col") : (size, "w-1/2", "flex-row")
  }, [isMobileView])
  let funnelData =
    data
    ->Belt.Array.get(0)
    ->Belt.Option.getWithDefault(Js.Json.null)
    ->LogicUtils.getDictFromJsonObject
  let (hoverIndex, setHoverIndex) = React.useState(_ => -1.)
  let length = metrics->Js.Array2.length->Belt.Float.fromInt
  let someData =
    funnelData
    ->Js.Dict.entries
    ->Js.Array2.filter(entry => {
      let (_key, value) = entry
      value->LogicUtils.getIntFromJson(0) !== 0
    })
    ->Js.Array2.length > 0
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
      <div className={`flex ${flexDirectionClass} gap-6 my-10 delay-75 animate-slideUp`}>
        <div className={`flex flex-col items-center my-auto ${widthClass}`}>
          {metrics
          ->Js.Array2.mapi((metric, i) => {
            let i = i->Belt.Float.fromInt
            let opacity = (i +. 1.) /. length
            let borderTop = `${(size *. 14.)
                ->Belt.Float.toString}rem solid rgb(0,109,249,${opacity->Belt.Float.toString})`
            let borderRadius =
              i === 0.
                ? `${(size *. 2.5)->Belt.Float.toString}rem ${(size *. 2.5)
                      ->Belt.Float.toString}rem 0 0`
                : i === length -. 1.
                ? `0 0 ${(size *. 2.5)->Belt.Float.toString}rem ${(size *. 2.5)
                    ->Belt.Float.toString}rem`
                : ``
            let borderX =
              i !== length -. 1.
                ? `${(size *. 14. *. Js.Math.pow_float(~base=0.7, ~exp=i))
                      ->Belt.Float.toString}rem solid transparent`
                : `${size->Belt.Float.toString}rem`
            let width =
              i !== length -. 1.
                ? `${(70. *. size *. Js.Math.pow_float(~base=0.7, ~exp=i))->Belt.Float.toString}rem`
                : `${(70. *. size *. Js.Math.pow_float(~base=0.7, ~exp=i -. 1.))
                      ->Belt.Float.toString}rem`
            let marginBottom = `${(size *. 1.4)->Belt.Float.toString}rem`
            let boxSizing = `content-box`
            let previousMetric = metrics->Belt.Array.get(i->Belt.Float.toInt - 1)
            let _previousMetricLabel = switch previousMetric {
            | Some(prevMetric) => prevMetric.metric_label
            | None => ""
            }
            let previousMetric = switch previousMetric {
            | Some(prevMetric) => prevMetric.metric_name_db
            | None => ""
            }
            let _previousVol = funnelData->LogicUtils.getInt(previousMetric, 0)->Belt.Float.fromInt
            let _currentVol =
              funnelData->LogicUtils.getInt(metric.metric_name_db, 0)->Belt.Float.fromInt
            let funnelElement =
              <div
                key={`${i->Belt.Float.toString}funnelStage`}
                className="flex hover:cursor-pointer transition ease-in-out hover:scale-110 duration-300"
                style={ReactDOMStyle.make(
                  ~borderTop,
                  ~borderRadius,
                  ~borderLeft=borderX,
                  ~borderRight=borderX,
                  ~width,
                  ~marginBottom,
                  ~boxSizing,
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
              ->Js.Array2.mapi((metric, i) => {
                let marginBottom = `${(size *. 1.4)->Belt.Float.toString}rem`
                let paddingTop = `${(size *. 4.2)->Belt.Float.toString}rem`
                <div
                  key={`${i->Belt.Int.toString}funnelStageVol`}
                  className={`flex flex-row gap-4 h-full items-center w-max`}
                  style={ReactDOMStyle.make(~marginBottom, ~paddingTop, ())}>
                  <div
                    className="flex font-semibold text-xl text-black dark:text-white w-max items-start">
                    {
                      let metricVal =
                        funnelData->getInt(metric.metric_name_db, 0)->Belt.Float.fromInt
                      shortNum(
                        ~labelValue=metricVal,
                        ~numberFormat=getDefaultNumberFormat(),
                        (),
                      )->React.string
                    }
                  </div>
                </div>
              })
              ->React.array
            }
          </div>
          <div className="flex flex-col items-start">
            {metrics
            ->Js.Array2.mapi((metric, i) => {
              let marginBottom = `${(size *. 2.1)->Belt.Float.toString}rem`
              let paddingTop = `${(size *. 3.4 *. 1.4)->Belt.Float.toString}rem`
              <div
                key={`${i->Belt.Int.toString}funnelStageDesc`}
                className={`flex flex-row gap-4 h-full items-center w-max items-start`}
                style={ReactDOMStyle.make(~marginBottom, ~paddingTop, ())}>
                <div
                  className={`transition ease-in-out duration-300 font-medium text-base ${hoverIndex ===
                      i->Belt.Float.fromInt
                      ? "text-blue-900 scale-110"
                      : "text-jp-gray-800 dark:text-dark_theme"}`}>
                  {metric.metric_label->React.string}
                </div>
              </div>
            })
            ->React.array}
          </div>
        </div>
      </div>
    </UIUtils.RenderIf>
  </div>
}
