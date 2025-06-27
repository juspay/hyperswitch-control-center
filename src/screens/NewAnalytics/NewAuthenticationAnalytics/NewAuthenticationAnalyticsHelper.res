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
    let fetchApi = AuthHooks.useApiFetcher()
    let updateDetails = useUpdateMethod()
    let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
    let (data, setData) = React.useState(_ => Dict.make()->itemToObjMapperForInsightsData)
    let {filterValueJson} = React.useContext(FilterContext.filterContext)
    let startTimeVal = filterValueJson->getString("startTime", "")
    let endTimeVal = filterValueJson->getString("endTime", "")
    let isSampleDataEnabled = filterValueJson->getStringFromDictAsBool(sampleDataKey, false)

    let loadTable = async () => {
      setScreenState(_ => PageLoaderWrapper.Loading)
      try {
        let insightsUrl = getURL(~entityName=V1(ANALYTICS_AUTHENTICATION_V2), ~methodType=Post)

        let infoQueryResponse = if isSampleDataEnabled {
          let paymentsUrl = `${GlobalVars.getHostUrl}/test-data/analytics/payments.json`
          let res = await fetchApi(
            paymentsUrl,
            ~method_=Get,
            ~xFeatureRoute=false,
            ~forceCookies=false,
          )
          let paymentsResponse = await res->(res => res->Fetch.Response.json)
          paymentsResponse
          ->getDictFromJsonObject
          ->getJsonObjectFromDict("Insights")
        } else {
          let insightsRequestBody = InsightsUtils.requestBody(
            ~startTime=startTimeVal,
            ~endTime=endTimeVal,
            ~groupByNames=Some(["error_message"]),
            ~metrics=[#authentication_error_message],
            ~filter=Some(
              getUpdatedFilterValueJson(filterValueJson, ~tabIndex=0)->JSON.Encode.object,
            ),
            ~delta=Some(true),
          )
          await updateDetails(insightsUrl, insightsRequestBody, Post)
        }

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

module ModuleHeader = {
  @react.component
  let make = (~title, ~description="") => {
    open Typography
    <div className="p-4 bg-nd_gray-25 border-b dark:border-jp-gray-850">
      <h2 className={`${heading.md.semibold} text-jp-gray-900`}> {title->React.string} </h2>
      <div className={`${body.md.medium} text-jp-gray-800 dark:text-dark_theme my-2`}>
        {description->React.string}
      </div>
    </div>
  }
}
