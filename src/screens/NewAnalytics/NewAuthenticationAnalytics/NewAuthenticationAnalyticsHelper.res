open LogicUtils
open LogicUtilsTypes

module Card = {
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
        let insightsRequestBody = NewAnalyticsUtils.requestBody(
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
                  {item.error_message->React.string}
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
