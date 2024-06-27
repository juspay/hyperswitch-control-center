@react.component
let make = () => {
  open LogicUtils
  open APIUtils
  let (activeUserCount, setActiveUserCount) = React.useState(_ => 0)
  let (todayVisits, setTodayVisits) = React.useState(_ => 0)
  let (healthCheck, setHealthCheck) = React.useState(_ => true)
  let updateDetails = useUpdateMethod()
  let (timestamp, setTimestamp) = React.useState(_ => Date.now())

  React.useEffect1(() => {
    let domain = "active_payments"
    let url = `${Window.env.apiBaseUrl}/analytics/v1/metrics/${domain}`
    let body =
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
            ]->getJsonFromArrayOfJson,
          ),
          ("metrics", ["active_payments"->JSON.Encode.string]->JSON.Encode.array),
        ]->getJsonFromArrayOfJson,
      ]->JSON.Encode.array
    let _ = async () => {
      try {
        let json = await updateDetails(url, body, Fetch.Post, ())
        let dict = json->getDictFromJsonObject
        let newActiveUserCount =
          dict
          ->getJsonObjectFromDict("queryData")
          ->getArrayFromJson([])
          ->getValueFromArray(0, JSON.Encode.null)
          ->getDictFromJsonObject
          ->getInt("active_payments", 0)
        setActiveUserCount(_ => newActiveUserCount)
      } catch {
      | Exn.Error(_) => setHealthCheck(_ => false)
      }
    }
    None
  }, [timestamp])

  React.useEffect1(() => {
    let domain = "sdk_events"
    let url = `${Window.env.apiBaseUrl}/analytics/v1/metrics/${domain}`
    let today = Date.make()
    let body =
      [
        [
          (
            "timeRange",
            [
              (
                "startTime",
                Date.makeWithYMD(
                  ~year=today->Date.getFullYear,
                  ~month=today->Date.getMonth,
                  ~date=today->Date.getDate,
                )
                ->Date.toISOString
                ->JSON.Encode.string,
              ),
              ("endTime", Date.make()->Date.toISOString->JSON.Encode.string),
            ]->getJsonFromArrayOfJson,
          ),
          ("metrics", ["sdk_rendered_count"->JSON.Encode.string]->JSON.Encode.array),
        ]->getJsonFromArrayOfJson,
      ]->JSON.Encode.array
    let _ = async () => {
      try {
        let json = await updateDetails(url, body, Fetch.Post, ())
        let dict = json->getDictFromJsonObject
        let todayVisitsCount =
          dict
          ->getJsonObjectFromDict("queryData")
          ->getArrayFromJson([])
          ->getValueFromArray(0, JSON.Encode.null)
          ->getDictFromJsonObject
          ->getInt("sdk_rendered_count", 0)
        setTodayVisits(_ => todayVisitsCount)
      } catch {
      | Exn.Error(_) => setHealthCheck(_ => false)
      }
    }
    None
  }, [timestamp])

  React.useEffect1(() => {
    let interval = setInterval(() => {
      setTimeout(
        () => {
          if healthCheck {
            setTimestamp(_ => Date.now())
          }
        },
        5000,
      )->ignore
    }, 5000)
    if !healthCheck {
      clearInterval(interval)
    }
    Some(_ => clearInterval(interval))
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
