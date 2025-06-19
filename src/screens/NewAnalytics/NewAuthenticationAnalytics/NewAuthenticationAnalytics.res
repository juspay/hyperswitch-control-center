@react.component
let make = () => {
  open APIUtils
  open LogicUtils
  open NewAuthenticationAnalyticsUtils
  open NewAuthenticationAnalyticsHelper
  open NewAuthenticationAnalyticsEntity
  open Typography

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let fetchApi = AuthHooks.useApiFetcher()
  let updateDetails = useUpdateMethod()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (queryData, setQueryData) = React.useState(_ => Dict.make()->itemToObjMapperForQueryData)
  let (funnelData, setFunnelData) = React.useState(_ => Dict.make()->itemToObjMapperForFunnelData)
  let {updateExistingKeys, updateFilterAsync, filterValueJson, filterValue} = React.useContext(
    FilterContext.filterContext,
  )
  let startTimeVal = filterValueJson->getString("startTime", "")
  let endTimeVal = filterValueJson->getString("endTime", "")
  let isSampleDataEnabled = filterValueJson->getStringFromDictAsBool(sampleDataKey, false)

  let title = "Authentication Analytics"
  let (filterDataJson, setFilterDataJson) = React.useState(_ => None)
  let (dimensions, setDimensions) = React.useState(_ => [])
  let mixpanelEvent = MixpanelHook.useSendEvent()
  React.useEffect(() => {
    if startTimeVal->LogicUtils.isNonEmptyString && endTimeVal->LogicUtils.isNonEmptyString {
      mixpanelEvent(~eventName="authentication_analytics_date_filter")
    }
    None
  }, (startTimeVal, endTimeVal))
  let dateDropDownTriggerMixpanelCallback = () => {
    mixpanelEvent(~eventName="authentication_analytics_date_filter_opened")
  }

  let loadInfo = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let infoUrl = getURL(~entityName=V1(ANALYTICS_AUTHENTICATION_V2), ~methodType=Get)
      let infoDetails = await fetchDetails(infoUrl)
      setDimensions(_ => infoDetails->getDictFromJsonObject->getArrayFromDict("dimensions", []))
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | Exn.Error(e) =>
      let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
      setScreenState(_ => PageLoaderWrapper.Error(err))
    }
  }

  let tabNames = HSAnalyticsUtils.getStringListFromArrayDict(dimensions)

  let getFilters = async () => {
    setFilterDataJson(_ => None)
    try {
      let analyticsfilterUrl = getURL(
        ~entityName=V1(ANALYTICS_AUTHENTICATION_V2_FILTERS),
        ~methodType=Post,
      )
      let filterBody =
        InsightsUtils.requestBody(
          ~startTime=startTimeVal,
          ~endTime=endTimeVal,
          ~groupByNames=Some(tabNames),
          ~metrics=[],
          ~filter=None,
          ~delta=Some(true),
        )
        ->getArrayFromJson([])
        ->getValueFromArray(0, JSON.Encode.null)
      let filterData = await updateDetails(analyticsfilterUrl, filterBody, Post)
      setFilterDataJson(_ => Some(filterData))
    } catch {
    | _ => setFilterDataJson(_ => None)
    }
  }

  let getMetricsDetails = async () => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      if isSampleDataEnabled {
        setQueryData(_ => Dict.make()->itemToObjMapperForQueryData)
        setFunnelData(_ => Dict.make()->itemToObjMapperForFunnelData)
        let paymentsUrl = `${GlobalVars.getHostUrl}/test-data/analytics/payments.json`
        let res = await fetchApi(
          paymentsUrl,
          ~method_=Get,
          ~xFeatureRoute=false,
          ~forceCookies=false,
        )
        let paymentsResponse = await res->Fetch.Response.json
        let paymentData =
          paymentsResponse
          ->getDictFromJsonObject
          ->getJsonObjectFromDict("authenticationsOverviewData")
          ->getDictFromJsonObject
          ->getArrayFromDict("queryData", [])
          ->JSON.Encode.array
          ->getArrayDataFromJson(itemToObjMapperForQueryData)
          ->getValueFromArray(0, defaultQueryData)

        setQueryData(_ => paymentData)

        let authenticationInitiated = (
          paymentsResponse
          ->getDictFromJsonObject
          ->getJsonObjectFromDict("funnelData1")
          ->getDictFromJsonObject
          ->getArrayFromDict("queryData", [])
          ->JSON.Encode.array
          ->getArrayDataFromJson(itemToObjMapperForSecondFunnelData)
          ->getValueFromArray(0, defaultSecondFunnelData)
        ).authentication_funnel

        let authenticationAttempted = (
          paymentsResponse
          ->getDictFromJsonObject
          ->getJsonObjectFromDict("funnelData2")
          ->getDictFromJsonObject
          ->getArrayFromDict("queryData", [])
          ->JSON.Encode.array
          ->getArrayDataFromJson(itemToObjMapperForSecondFunnelData)
          ->getValueFromArray(0, defaultSecondFunnelData)
        ).authentication_funnel

        let queryDataMapped = paymentData
        let funnelDict = Dict.make()->itemToObjMapperForFunnelData
        funnelDict.authentication_initiated = authenticationInitiated
        funnelDict.authentication_attemped = authenticationAttempted
        funnelDict.payments_requiring_3ds_2_authentication = queryDataMapped.authentication_count
        funnelDict.authentication_successful = queryDataMapped.authentication_success_count

        setFunnelData(_ => funnelDict)
        setScreenState(_ => PageLoaderWrapper.Success)
      } else {
        setQueryData(_ => Dict.make()->itemToObjMapperForQueryData)
        setFunnelData(_ => Dict.make()->itemToObjMapperForFunnelData)
        let metricsUrl = getURL(~entityName=V1(ANALYTICS_AUTHENTICATION_V2), ~methodType=Post)
        let metricsRequestBody = InsightsUtils.requestBody(
          ~startTime=startTimeVal,
          ~endTime=endTimeVal,
          ~filter=Some(getUpdatedFilterValueJson(filterValueJson)->JSON.Encode.object),
          ~mode=Some("ORDER"),
          ~metrics=[
            #authentication_count,
            #authentication_attempt_count,
            #authentication_success_count,
            #challenge_flow_count,
            #frictionless_flow_count,
            #frictionless_success_count,
            #challenge_attempt_count,
            #authentication_exemption_approved_count,
            #authentication_exemption_requested_count,
          ],
          ~delta=Some(true),
        )

        let metricsQueryResponse = await updateDetails(metricsUrl, metricsRequestBody, Post)

        let queryDataArray =
          metricsQueryResponse
          ->getDictFromJsonObject
          ->getArrayFromDict("queryData", [])
          ->JSON.Encode.array
          ->getArrayDataFromJson(itemToObjMapperForQueryData)

        let valueOfQueryData = queryDataArray->getValueFromArray(0, defaultQueryData)
        setQueryData(_ => valueOfQueryData)

        let secondFunnelRequestBody = InsightsUtils.requestBody(
          ~startTime=startTimeVal,
          ~endTime=endTimeVal,
          ~filter=Some(getUpdatedFilterValueJson(filterValueJson)->JSON.Encode.object),
          ~metrics=[#authentication_funnel],
          ~delta=Some(true),
        )

        let secondFunnelQueryResponse = await updateDetails(
          metricsUrl,
          secondFunnelRequestBody,
          Post,
        )

        let authenticationInitiated = (
          secondFunnelQueryResponse
          ->getDictFromJsonObject
          ->getArrayFromDict("queryData", [])
          ->JSON.Encode.array
          ->getArrayDataFromJson(itemToObjMapperForSecondFunnelData)
          ->getValueFromArray(0, defaultSecondFunnelData)
        ).authentication_funnel

        let updatedFilters = Js.Dict.map(t => t, getUpdatedFilterValueJson(filterValueJson))
        updatedFilters->Dict.set(
          "authentication_status",
          ["success"->JSON.Encode.string, "failed"->JSON.Encode.string]->JSON.Encode.array,
        )

        let thirdFunnelRequestBody = InsightsUtils.requestBody(
          ~startTime=startTimeVal,
          ~endTime=endTimeVal,
          ~filter=Some(updatedFilters->JSON.Encode.object),
          ~metrics=[#authentication_funnel],
          ~delta=Some(true),
        )

        let thirdFunnelQueryResponse = await updateDetails(metricsUrl, thirdFunnelRequestBody, Post)

        let authenticationAttempted = (
          thirdFunnelQueryResponse
          ->getDictFromJsonObject
          ->getArrayFromDict("queryData", [])
          ->JSON.Encode.array
          ->getArrayDataFromJson(itemToObjMapperForSecondFunnelData)
          ->getValueFromArray(0, defaultSecondFunnelData)
        ).authentication_funnel

        let funnelDict = Dict.make()->itemToObjMapperForFunnelData
        funnelDict.authentication_initiated = authenticationInitiated
        funnelDict.authentication_attemped = authenticationAttempted
        funnelDict.payments_requiring_3ds_2_authentication = valueOfQueryData.authentication_count
        funnelDict.authentication_successful = valueOfQueryData.authentication_success_count

        setFunnelData(_ => funnelDict)
        setScreenState(_ => PageLoaderWrapper.Success)
      }
    } catch {
    | Exn.Error(e) =>
      let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
      setScreenState(_ => PageLoaderWrapper.Error(err))
    }
  }
  let setInitialFilters = HSwitchRemoteFilter.useSetInitialFilters(
    ~updateExistingKeys,
    ~startTimeFilterKey,
    ~endTimeFilterKey,
    ~origin="analytics",
    (),
  )

  React.useEffect(() => {
    setInitialFilters()
    loadInfo()->ignore
    None
  }, [])

  React.useEffect(() => {
    if (
      startTimeVal->isNonEmptyString && endTimeVal->isNonEmptyString && dimensions->Array.length > 0
    ) {
      getFilters()->ignore
    }
    None
  }, (startTimeVal, endTimeVal, dimensions))

  React.useEffect(() => {
    if startTimeVal->isNonEmptyString && endTimeVal->isNonEmptyString {
      getMetricsDetails()->ignore
    }
    None
  }, (startTimeVal, endTimeVal, filterValue, isSampleDataEnabled))

  let topFilterUi = switch filterDataJson {
  | Some(filterData) =>
    <div className="flex flex-row">
      <DynamicFilter
        title="AuthenticationAnalyticsV2"
        initialFilters={isSampleDataEnabled ? [] : HSAnalyticsUtils.initialFilterFields(filterData)}
        options=[]
        popupFilterFields={HSAnalyticsUtils.options(filterData)}
        initialFixedFilters={initialFixedFilterFields(
          ~events=dateDropDownTriggerMixpanelCallback,
          ~sampleDataIsEnabled=isSampleDataEnabled,
        )}
        defaultFilterKeys=[startTimeFilterKey, endTimeFilterKey]
        tabNames
        key="0"
        updateUrlWith=updateExistingKeys
        filterFieldsPortalName={HSAnalyticsUtils.filterFieldsPortalName}
        showCustomFilter=false
        refreshFilters=false
      />
    </div>
  | None =>
    <div className="flex flex-row">
      <DynamicFilter
        title="AuthenticationAnalyticsV2"
        initialFilters=[]
        options=[]
        popupFilterFields=[]
        initialFixedFilters={initialFixedFilterFields(
          ~events=dateDropDownTriggerMixpanelCallback,
          ~sampleDataIsEnabled=isSampleDataEnabled,
        )}
        defaultFilterKeys=[startTimeFilterKey, endTimeFilterKey]
        tabNames
        key="1"
        updateUrlWith=updateExistingKeys
        filterFieldsPortalName={HSAnalyticsUtils.filterFieldsPortalName}
        showCustomFilter=false
        refreshFilters=false
      />
    </div>
  }
  let applySampleDateFilters = async isSampleDateEnabled => {
    try {
      setScreenState(_ => Loading)
      let sampleDateRange: HSwitchRemoteFilter.filterBody = {
        start_time: "2025-05-20T00:00:00.000Z",
        end_time: "2025-06-03T00:00:00.000Z",
      }
      let values = InsightsUtils.getSampleDateRange(
        ~useSampleDates=isSampleDateEnabled,
        ~sampleDateRange,
      )
      values->Dict.set(sampleDataKey, isSampleDateEnabled->getStringFromBool)
      let _ = await updateFilterAsync(~delay=1000, values)
      setScreenState(_ => Success)
    } catch {
    | _ => setScreenState(_ => Success)
    }
  }

  let funnelRenderCondition = React.useMemo(
    () =>
      funnelData.authentication_initiated > 0 &&
      funnelData.payments_requiring_3ds_2_authentication > 0 &&
      funnelData.authentication_attemped > 0 &&
      funnelData.authentication_successful > 0,
    [funnelData],
  )
  <PageLoaderWrapper screenState customUI={<HSAnalyticsUtils.NoData title />}>
    <InsightsHelper.SampleDataBanner applySampleDateFilters />
    <PageUtils.PageHeading title />
    <div className="flex justify-end mr-4">
      <GenerateReport entityName={V1(AUTHENTICATION_REPORT)} />
    </div>
    <div className="-ml-1 sticky top-0 z-10 p-1 bg-hyperswitch_background/70 py-1 rounded-lg my-2">
      {topFilterUi}
    </div>
    <div className="grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-3">
      {getMetricsData(queryData)
      ->Array.mapWithIndex((metric, index) =>
        <RenderIf condition={metric.name === "authentication"}>
          <StatCard
            key={index->Int.toString}
            title={metric.title}
            value={metric.value}
            valueType={metric.valueType}
            description={metric.tooltip_description}
          />
        </RenderIf>
      )
      ->React.array}
    </div>
    <RenderIf condition={funnelRenderCondition}>
      <div className="border border-gray-200 mt-5 rounded-lg">
        <FunnelChart
          data={getFunnelChartData(funnelData)}
          metrics={metrics}
          moduleName="Authentication Funnel"
          description=Some("Breakdown of ThreeDS 2.0 Journey")
        />
      </div>
    </RenderIf>
    <Insights />
    <hr className="w-full mt-6" />
    <div className="my-4">
      <h2 className={`${heading.md.semibold} text-jp-gray-900`}>
        {"3DS Exemption Analytics"->React.string}
      </h2>
    </div>
    <div className="grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-3">
      {getMetricsData(queryData)
      ->Array.mapWithIndex((metric, index) =>
        <RenderIf condition={metric.name === "3ds_exemption_authentication"}>
          <StatCard
            key={index->Int.toString}
            title={metric.title}
            value={metric.value}
            valueType={metric.valueType}
            description={metric.tooltip_description}
          />
        </RenderIf>
      )
      ->React.array}
    </div>
    <SCAExemptionAnalytics entity={scaExemptionEntity} chartEntity={scaExemptionChartEntity} />
    <div className="grid grid-cols-2 gap-6 mt-6">
      <ExemptionGraphs
        entity={authenticationSuccessEntity}
        chartEntity={authenticationSuccessChartEntity}
        metricXKey="authentication_success_count"
      />
      <ExemptionGraphs
        entity={userDropOffRateEntity}
        chartEntity={userDropOffRateChartEntity}
        metricXKey="user_drop_off_rate"
      />
      <ExemptionGraphs
        entity={exemptionApprovalRateEntity}
        chartEntity={exemptionApprovalRateChartEntity}
        metricXKey="exemption_approval_rate"
      />
      <ExemptionGraphs
        entity={exemptionRequestRateEntity}
        chartEntity={exemptionRequestRateChartEntity}
        metricXKey="exemption_request_rate"
      />
    </div>
    <AuthenticationSummary entity={authenticationSummaryEntity} />
  </PageLoaderWrapper>
}
