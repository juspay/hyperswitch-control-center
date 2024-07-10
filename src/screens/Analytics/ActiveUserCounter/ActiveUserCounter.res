type domain = ActivePayments | SdkEvents

@react.component
let make = () => {
  open LogicUtils
  open APIUtils
  open APIUtilsTypes
  let (activeUserCount, setActiveUserCount) = React.useState(_ => 0)
  let (todayVisits, setTodayVisits) = React.useState(_ => 0)
  let (healthCheck, setHealthCheck) = React.useState(_ => true)
  let updateDetails = useUpdateMethod()
  let (todayVisitsTimestamp, setTodayVisitsTimestamp) = React.useState(_ => Date.now())
  let (activeUserCountTimestamp, setActiveUserCountTimestamp) = React.useState(_ => Date.now())
  let getURL = useGetURL()

  let fetchMetrics = async (domain, setData) => {
    let entityName = switch domain {
    | ActivePayments => ANALYTICS_ACTIVE_PAYMENTS
    | SdkEvents => ANALYTICS_USER_JOURNEY
    }
    let (domainUrl, metric) = switch domain {
    | ActivePayments => ("active_payments", "active_payments")
    | SdkEvents => ("sdk_events", "sdk_rendered_count")
    }
    let url = getURL(~entityName, ~methodType=Post, ~id=Some(domainUrl), ())
    let startTime = switch domain {
    | ActivePayments => (Date.now() -. 60000.0)->Date.fromTime
    | SdkEvents => {
        let today = Date.make()
        Date.makeWithYMD(
          ~year=today->Date.getFullYear,
          ~month=today->Date.getMonth,
          ~date=today->Date.getDate,
        )
      }
    }
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

  React.useEffect1(() => {
    fetchMetrics(ActivePayments, setActiveUserCount)->ignore
    None
  }, [activeUserCountTimestamp])

  React.useEffect1(() => {
    fetchMetrics(SdkEvents, setTodayVisits)->ignore
    None
  }, [todayVisitsTimestamp])

  React.useEffect1(() => {
    let todayVisitsInterval = setInterval(() => {
      setTimeout(
        () => {
          if healthCheck {
            setTodayVisitsTimestamp(_ => Date.now())
          }
        },
        60000,
      )->ignore
    }, 60000)
    let activeUserCountInterval = setInterval(() => {
      setTimeout(
        () => {
          if healthCheck {
            setActiveUserCountTimestamp(_ => Date.now())
          }
        },
        5000,
      )->ignore
    }, 5000)
    if !healthCheck {
      clearInterval(todayVisitsInterval)
      clearInterval(activeUserCountInterval)
    }
    Some(
      _ => {
        clearInterval(todayVisitsInterval)
        clearInterval(activeUserCountInterval)
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
    show={healthCheck && (activeUserCount > 0 || todayVisits > 0)}>
    <div
      className={`flex flex-row px-4 py-2 md:gap-8 gap-4 rounded whitespace-nowrap text-fs-13 bg-sky-100 border-blue-200 font-semibold justify-center`}>
      <UIUtils.RenderIf condition={activeUserCount > 0}>
        <Icon
          name="liveTag"
          size=40
          className="flex text-jp-gray-600 dark:text-jp-gray-text_darktheme dark:text-opacity-25"
        />
        <div className="flex gap-2">
          <div className="flex text-gray-500 items-center">
            {`Users on Checkout`->React.string}
          </div>
          <div className="flex text-blue-400 items-center">
            {activeUserCount->Int.toString->React.string}
          </div>
        </div>
      </UIUtils.RenderIf>
      <UIUtils.RenderIf condition={todayVisits > 0 && activeUserCount > 0}>
        <div className="flex text-gray-400 items-center"> {`|`->React.string} </div>
      </UIUtils.RenderIf>
      <UIUtils.RenderIf condition={todayVisits > 0}>
        <div className="flex gap-2">
          <div className="flex text-gray-500 items-center">
            {`Total visits today`->React.string}
          </div>
          <div className="flex text-blue-400 items-center">
            {todayVisits->Int.toString->React.string}
          </div>
        </div>
      </UIUtils.RenderIf>
    </div>
  </Transition>
}
