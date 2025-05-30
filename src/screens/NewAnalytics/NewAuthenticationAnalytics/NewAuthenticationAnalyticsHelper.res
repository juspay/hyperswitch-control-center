open LogicUtils
open LogicUtilsTypes

module StatCard = {
  @react.component
  let make = (~title: string, ~description: string, ~value: float, ~valueType: valueType) => {
    let valueString = valueFormatter(value, valueType)
    <div className="bg-white border rounded-lg p-4">
      <div className="flex flex-col justify-between items-start gap-3">
        <div className="text-2xl font-bold text-gray-800"> {valueString->React.string} </div>
        <div className="flex flex-row items-center gap-4">
          <div className="text-sm font-medium text-gray-500"> {title->React.string} </div>
          <div className="cursor-pointer">
            <ToolTip description={description} toolTipPosition={ToolTip.Top} />
          </div>
        </div>
      </div>
    </div>
  }
}

module Insights = {
  @react.component
  let make = () => {
    open APIUtils
    open NewAuthenticationAnalyticsUtils

    let getURL = useGetURL()
    let updateDetails = useUpdateMethod()
    let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
    let (data, setData) = React.useState(_ => Dict.make()->itemToObjMapperForInsightsData)
    let {filterValueJson} = React.useContext(FilterContext.filterContext)
    let startTimeVal = filterValueJson->getString("startTime", "")
    let endTimeVal = filterValueJson->getString("endTime", "")

    let loadTable = async () => {
      setScreenState(_ => PageLoaderWrapper.Loading)
      try {
        let insightsUrl = getURL(~entityName=V1(ANALYTICS_AUTHENTICATION_V2), ~methodType=Post)
        let insightsRequestBody = InsightsUtils.requestBody(
          ~startTime=startTimeVal,
          ~endTime=endTimeVal,
          ~groupByNames=Some(["error_message"]),
          ~metrics=[#authentication_error_message],
          ~filter=Some(getUpdatedFilterValueJson(filterValueJson)->JSON.Encode.object),
          ~delta=Some(true),
        )
        let infoQueryResponse = await updateDetails(insightsUrl, insightsRequestBody, Post)

        setData(_ => infoQueryResponse->getDictFromJsonObject->itemToObjMapperForInsightsData)
        setScreenState(_ => PageLoaderWrapper.Success)
      } catch {
      | Exn.Error(e) =>
        let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
        setScreenState(_ => PageLoaderWrapper.Error(err))
      }
    }

    React.useEffect(() => {
      if startTimeVal->String.length > 0 && endTimeVal->String.length > 0 {
        loadTable()->ignore
      }
      None
    }, (startTimeVal, endTimeVal, filterValueJson))

    <PageLoaderWrapper
      screenState
      customLoader={<p className="mt-6 text-center text-sm text-jp-gray-900">
        {"Crunching the latest data…"->React.string}
      </p>}>
      <RenderIf condition={data.queryData->Array.length > 0}>
        <div className="mt-6 border rounded-lg p-4">
          <p className="text-base uppercase font-medium text-nd_gray-800">
            {"Insights"->React.string}
          </p>
          {
            data.queryData->Array.sort((a, b) => {
              a.error_message_count <= b.error_message_count ? 1. : -1.
            })
            let queryDataArray = data.queryData
            let metaDataObj = data.metaData->getValueFromArray(0, defaultMetaData)
            queryDataArray
            ->Array.mapWithIndex((item, index) => {
              let errorPercentage =
                item.error_message_count->Int.toFloat /.
                metaDataObj.total_error_message_count->Int.toFloat *. 100.0
              let formattedPercentage = `${errorPercentage->Js.Float.toFixedWithPrecision(
                  ~digits=2,
                )} %`
              let isLastItem = index == queryDataArray->Array.length - 1
              let borderClass = isLastItem ? "border-none" : "border-b"

              <div
                key={index->Int.toString}
                className={`flex bg-white ${borderClass} items-center justify-between`}>
                <div
                  className="py-4 font-medium text-gray-900 whitespace-pre-wrap flex items-center">
                  <span
                    className="inline-flex justify-center items-center bg-blue-200 text-blue-500 text-xs font-medium mr-3 w-6 h-6 rounded">
                    {(index + 1)->Int.toString->React.string}
                  </span>
                  <span className="max-w-2xl"> {item.error_message->React.string} </span>
                </div>
                <div className="px-6 py-4 font-medium"> {formattedPercentage->React.string} </div>
              </div>
            })
            ->React.array
          }
        </div>
      </RenderIf>
    </PageLoaderWrapper>
  }
}

let tableBorderClass = "border-2 border-solid  border-jp-gray-940 border-collapse border-opacity-30 dark:border-jp-gray-dark_table_border_color dark:border-opacity-30"
module Card = {
  @react.component
  let make = (~children) => {
    <div
      className={`h-full flex flex-col justify-between border rounded-lg dark:border-jp-gray-850 bg-white dark:bg-jp-gray-lightgray_background overflow-hidden singlestatBox`}>
      {children}
    </div>
  }
}

module NoData = {
  @react.component
  let make = (~height="h-96") => {
    <div
      className={`${height} border-2 flex justify-center items-center border-dashed opacity-70 rounded-lg p-5 m-7`}>
      {"No entires in selected time period."->React.string}
    </div>
  }
}

module Shimmer = {
  @react.component
  let make = (~className="w-full h-96", ~layoutId) => {
    <FramerMotion.Motion.Div
      className={`${className} bg-gradient-to-r from-gray-100 via-gray-200 to-gray-100`}
      initial={{backgroundPosition: "-200% 0"}}
      animate={{backgroundPosition: "200% 0"}}
      transition={{duration: 1.5, ease: "easeInOut", repeat: 10000}}
      style={{backgroundSize: "200% 100%"}}
      layoutId
    />
  }
}

module ModuleHeader = {
  @react.component
  let make = (~title, ~description="") => {
    <div className="p-4 bg-[#fcfcfd] border-b dark:border-jp-gray-850">
      <h2 className="font-semibold text-xl text-jp-gray-900"> {title->React.string} </h2>
      <div className="font-medium text-sm text-jp-gray-800 dark:text-dark_theme my-2">
        {description->React.string}
      </div>
    </div>
  }
}

module SimpleHeader = {
  @react.component
  let make = (~title) => {
    <h2 className="font-semibold text-xl text-jp-gray-900"> {title->React.string} </h2>
  }
}

module SampleDataBanner = {
  @react.component
  let make = (~applySampleDateFilters) => {
    open Typography
    open InsightsContainerUtils
    let mixpanelEvent = MixpanelHook.useSendEvent()
    let {sampleDataAnalytics} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
    let {filterValueJson} = React.useContext(FilterContext.filterContext)
    let isSampleDataEnabled = filterValueJson->getStringFromDictAsBool(sampleDataKey, false)
    let stickyToggleClass = isSampleDataEnabled ? "sticky z-[30] top-0 " : "relative "
    let (isSampleModeEnabled, setIsSampleModeEnabled) = React.useState(_ =>
      filterValueJson->getStringFromDictAsBool(sampleDataKey, false)
    )
    let (bannerText, toggleText) = isSampleDataEnabled
      ? (
          "Currently viewing sample data. Toggle it off to return to your real insights.",
          "Hide sample data",
        )
      : ("No data yet? View sample data to explore the analytics.", "View sample data")
    let handleToggleChange = _ => {
      let newToggleState = !isSampleModeEnabled
      mixpanelEvent(~eventName="sample_data_analytics", ~metadata=newToggleState->JSON.Encode.bool)
      setIsSampleModeEnabled(_ => newToggleState)
      applySampleDateFilters(newToggleState)->ignore
    }
    <RenderIf condition=sampleDataAnalytics>
      <div
        className={`${stickyToggleClass} text-nd_gray-600 py-3 px-4 bg-orange-50 flex justify-between items-center`}>
        <div className="flex gap-2 items-center">
          <Icon name="info-vacent" size=13 />
          <p className={` ${body.md.medium}`}> {bannerText->React.string} </p>
        </div>
        <div className="flex flex-row gap-4 items-center">
          <p className={`${body.md.semibold}`}> {toggleText->React.string} </p>
          <BoolInput.BaseComponent
            isSelected={isSampleModeEnabled}
            setIsSelected=handleToggleChange
            isDisabled=false
            boolCustomClass="rounded-lg !bg-primary"
            toggleBorder="border-primary"
          />
        </div>
      </div>
    </RenderIf>
  }
}
