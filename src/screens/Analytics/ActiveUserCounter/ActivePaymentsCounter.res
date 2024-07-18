@react.component
let make = () => {
  open LogicUtils
  open APIUtils
  open APIUtilsTypes
  let (activePaymentsCount, setActivePaymentsCount) = React.useState(_ => 0)
  let (healthCheck, setHealthCheck) = React.useState(_ => true)
  let updateDetails = useUpdateMethod()
  let (timestamp, setTimestamp) = React.useState(_ => Date.now())
  let getURL = useGetURL()

  let fetchMetrics = async setData => {
    let (domainUrl, metric) = ("active_payments", "active_payments")
    let url = getURL(
      ~entityName=ANALYTICS_ACTIVE_PAYMENTS,
      ~methodType=Post,
      ~id=Some(domainUrl),
      (),
    )
    let startTime = (Date.now() -. 60000.0)->Date.fromTime
    let body =
      [
        [
          (
            "timeRange",
            [
              ("startTime", startTime->Date.toISOString->JSON.Encode.string),
              ("endTime", Date.make()->Date.toISOString->JSON.Encode.string),
            ]->getJsonFromArrayOfJson,
          ),
          ("metrics", [metric->JSON.Encode.string]->JSON.Encode.array),
        ]->getJsonFromArrayOfJson,
      ]->JSON.Encode.array
    try {
      let json = await updateDetails(url, body, Fetch.Post, ())
      let dict = json->getDictFromJsonObject
      let newCount =
        dict
        ->getJsonObjectFromDict("queryData")
        ->getArrayFromJson([])
        ->getValueFromArray(0, JSON.Encode.null)
        ->getDictFromJsonObject
        ->getInt(metric, 0)
      setData(_ => newCount)
    } catch {
    | Exn.Error(_) => setHealthCheck(_ => false)
    }
  }

  React.useEffect(() => {
    fetchMetrics(setActivePaymentsCount)->ignore
    None
  }, [timestamp])

  React.useEffect(() => {
    let activePaymentsCountInterval = setInterval(() => {
      if healthCheck {
        setTimestamp(_ => Date.now())
      }
    }, 10000)
    if !healthCheck {
      clearInterval(activePaymentsCountInterval)
    }
    Some(
      _ => {
        clearInterval(activePaymentsCountInterval)
      },
    )
  }, [healthCheck])
  open HeadlessUI
  <Transition
    \"as"="span"
    enter={"transition ease-out duration-300"}
    enterFrom="opacity-0 translate-y-1"
    enterTo="opacity-100 translate-y-0"
    leave={"transition ease-in duration-300"}
    leaveFrom="opacity-100 translate-y-0"
    leaveTo="opacity-0 translate-y-1"
    show={healthCheck && activePaymentsCount > 0}>
    <div
      className={`flex flex-row px-4 py-2 md:gap-8 gap-4 rounded whitespace-nowrap text-fs-13 bg-blue-200 border-blue-200 font-semibold justify-center`}>
      <Icon
        name="liveTag"
        size=40
        className="flex text-jp-gray-600 dark:text-jp-gray-text_darktheme dark:text-opacity-25"
      />
      <div className="flex gap-2">
        <div className="flex text-gray-500 items-center"> {`Active Payments`->React.string} </div>
        <div className="flex text-blue-400 items-center">
          {activePaymentsCount->Int.toString->React.string}
        </div>
      </div>
    </div>
  </Transition>
}
