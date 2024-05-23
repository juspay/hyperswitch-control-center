@react.component
let make = () => {
  open LogicUtils
  let (activeUserCount, setActiveUserCount) = React.useState(_ => 0)
  let fetchApi = AuthHooks.useApiFetcher()
  let (timestamp, setTimestamp) = React.useState(_ => Date.now())
  React.useEffect1(() => {
    let url = switch UserJourneyAnalyticsEntity.paymentChartEntity([]).uri {
    | String(url) => url
    | _ => ""
    }
    let bodyStr =
      [
        [
          (
            "timeRange",
            [
              (
                "startTime",
                (Date.now() -. 300000.0)->Date.fromTime->Date.toISOString->JSON.Encode.string,
              ),
              ("endTime", Date.make()->Date.toISOString->JSON.Encode.string),
            ]
            ->Dict.fromArray
            ->JSON.Encode.object,
          ),
          ("metrics", ["sdk_rendered_count"->JSON.Encode.string]->JSON.Encode.array),
        ]
        ->Dict.fromArray
        ->JSON.Encode.object,
      ]
      ->JSON.Encode.array
      ->JSON.stringify
    open Promise
    fetchApi(url, ~method_=Fetch.Post, ~bodyStr, ())
    ->then(Fetch.Response.json)
    ->then(json => {
      Console.log("Resolved")
      Console.log(json)
      let dict = json->getDictFromJsonObject
      Console.log(("dict", dict))
      let newActiveUserCount =
        dict
        ->getJsonObjectFromDict("queryData")
        ->getArrayFromJson([])
        ->Array.get(0)
        ->Option.getOr(JSON.Encode.null)
        ->getDictFromJsonObject
        ->getInt("sdk_rendered_count", 0)
      setActiveUserCount(_ => newActiveUserCount)
      resolve()
    })
    ->catch(_err => {
      resolve()
    })
    ->ignore
    None
  }, [timestamp])
  React.useEffect0(() => {
    let interval = setInterval(() => {
      setTimeout(
        () => {
          setTimestamp(_ => Date.now())
        },
        10000,
      )->ignore
    }, 10000)
    Some(_ => clearInterval(interval))
  })
  <UIUtils.RenderIf condition={activeUserCount > 0}>
    <div
      className={`flex flex-row px-4 py-2 gap-2 rounded whitespace-nowrap text-fs-13 bg-blue-background_blue border-blue-200 text-blue-500 font-semibold`}>
      <Icon
        name="user"
        className="inline-block text-jp-gray-600 dark:text-jp-gray-text_darktheme dark:text-opacity-25 cursor-pointer"
      />
      {activeUserCount->Int.toString->React.string}
    </div>
  </UIUtils.RenderIf>
}
