open HSAnalyticsUtils
open APIUtils
open LogicUtils
open LogicUtilsTypes
open AuthenticationAnalyticsV2Types
open AuthenticationAnalyticsV2Helper

@react.component
let make = () => {
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)
  let (queryData, setQueryData) = React.useState(_ =>
    AuthenticationAnalyticsV2Utils.defaultQueryData
    ->Identity.genericTypeToJson
    ->LogicUtils.getDictFromJsonObject
  )
  let (funnelData, setFunnelData) = React.useState(_ =>
    AuthenticationAnalyticsV2Utils.defaultFunnelData
    ->Identity.genericTypeToJson
    ->LogicUtils.getDictFromJsonObject
  )
  let {updateExistingKeys} = React.useContext(FilterContext.filterContext)
  let {filterValueJson} = React.useContext(FilterContext.filterContext)
  let startTimeVal = filterValueJson->getString("startTime", "")
  let endTimeVal = filterValueJson->getString("endTime", "")
  let title = "Authentication Analytics"

  let loadInfo = async () => {
    try {
      let infoUrl = getURL(~entityName=V1(ANALYTICS_AUTHENTICATION_V2), ~methodType=Post)

      let infoRequestPayload: array<requestPayloadType> = [
        {
          timeRange: {
            startTime: startTimeVal,
            endTime: endTimeVal,
          },
          mode: "ORDER",
          source: "BATCH",
          metrics: [
            "authentication_count",
            "authentication_attempt_count",
            "authentication_success_count",
            "challenge_flow_count",
            "frictionless_flow_count",
            "frictionless_success_count",
            "challenge_attempt_count",
            "challenge_success_count",
          ],
          delta: true,
        },
      ]

      let secondFunnelRequestPayload: array<secondFunnelPayloadType> = [
        {
          timeRange: {
            startTime: startTimeVal,
            endTime: endTimeVal,
          },
          source: "BATCH",
          metrics: ["authentication_funnel"],
          delta: true,
        },
      ]

      let thirdFunnelRequestPayload: array<thirdFunnelPayloadType> = [
        {
          timeRange: {
            startTime: startTimeVal,
            endTime: endTimeVal,
          },
          source: "BATCH",
          filters: {
            authentication_status: ["success", "failed"],
          },
          metrics: ["authentication_funnel"],
          delta: true,
        },
      ]

      let infoQueryResponse = await updateDetails(
        infoUrl,
        infoRequestPayload->Identity.genericTypeToJson,
        Post,
      )
      let queryDataArray =
        infoQueryResponse
        ->getDictFromJsonObject
        ->getArrayFromDict("queryData", [])
      let getFirstValueOfQueryData = switch queryDataArray->Array.get(0) {
      | Some(data) => data->LogicUtils.getDictFromJsonObject
      | None =>
        AuthenticationAnalyticsV2Utils.defaultQueryData
        ->Identity.genericTypeToJson
        ->LogicUtils.getDictFromJsonObject
      }
      setQueryData(_ => getFirstValueOfQueryData)

      let secondFunnelQueryResponse = await updateDetails(
        infoUrl,
        secondFunnelRequestPayload->Identity.genericTypeToJson,
        Post,
      )

      let secondFunnelQueryDataArray = (
        secondFunnelQueryResponse
        ->getDictFromJsonObject
        ->getArrayFromDict("queryData", [])
        ->JSON.Encode.array
        ->getArrayDataFromJson(AuthenticationAnalyticsV2Utils.itemToObjMapperForSecondFunnelData)
        ->getValueFromArray(0, AuthenticationAnalyticsV2Utils.defaultSecondFunnelData)
      ).authentication_funnel

      let thirdFunnelQueryResponse = await updateDetails(
        infoUrl,
        thirdFunnelRequestPayload->Identity.genericTypeToJson,
        Post,
      )

      let thirdFunnelQueryDataArray = (
        thirdFunnelQueryResponse
        ->getDictFromJsonObject
        ->getArrayFromDict("queryData", [])
        ->JSON.Encode.array
        ->getArrayDataFromJson(AuthenticationAnalyticsV2Utils.itemToObjMapperForSecondFunnelData)
        ->getValueFromArray(0, AuthenticationAnalyticsV2Utils.defaultSecondFunnelData)
      ).authentication_funnel

      setFunnelData(prev => {
        let newPrev =
          prev
          ->Identity.genericTypeToJson
          ->JSON.stringify
          ->LogicUtils.safeParse
          ->LogicUtils.getDictFromJsonObject

        newPrev->Dict.set("authentication_initiated", secondFunnelQueryDataArray->JSON.Encode.int)
        newPrev->Dict.set("authentication_attemped", thirdFunnelQueryDataArray->JSON.Encode.int)
        newPrev->Dict.set(
          "payments_requiring_3ds_2_authentication",
          getFirstValueOfQueryData->getInt("authentication_count", 0)->JSON.Encode.int,
        )
        newPrev->Dict.set(
          "authentication_successful",
          getFirstValueOfQueryData->getInt("authentication_success_count", 0)->JSON.Encode.int,
        )

        newPrev
      })

      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | Exn.Error(e) =>
      let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
      setScreenState(_ => PageLoaderWrapper.Error(err))
    }
  }

  let paymentReq3DSAuth = {
    if (
      funnelData->getInt("payments_requiring_3ds_2_authentication", 0) > 0 &&
        funnelData->getInt("authentication_successful", 0) > 0
    ) {
      (funnelData->getInt("payments_requiring_3ds_2_authentication", 0) /
        funnelData->getInt("payments_requiring_3ds_2_authentication", 0))->Int.toFloat
    } else {
      0.0
    }
  }
  let authenticationSuccesful = {
    if (
      funnelData->getInt("payments_requiring_3ds_2_authentication", 0) > 0 &&
        funnelData->getInt("authentication_successful", 0) > 0
    ) {
      funnelData->getInt("authentication_successful", 0)->Int.toFloat /.
        funnelData->getInt("payments_requiring_3ds_2_authentication", 0)->Int.toFloat
    } else {
      0.0
    }
  }

  let authenticationInitated = {
    if (
      funnelData->getInt("authentication_initiated", 0) > 0 &&
        funnelData->getInt("payments_requiring_3ds_2_authentication", 0) > 0
    ) {
      funnelData->getInt("authentication_initiated", 0)->Int.toFloat /.
        funnelData->getInt("payments_requiring_3ds_2_authentication", 0)->Int.toFloat
    } else {
      0.0
    }
  }

  let authenticationAttempted = {
    if (
      funnelData->getInt("authentication_attemped", 0) > 0 &&
        funnelData->getInt("payments_requiring_3ds_2_authentication", 0) > 0
    ) {
      funnelData->getInt("authentication_attemped", 0)->Int.toFloat /.
        funnelData->getInt("payments_requiring_3ds_2_authentication", 0)->Int.toFloat
    } else {
      0.0
    }
  }

  let dict = {
    "payments_requiring_3ds_2_authentication": (paymentReq3DSAuth *. 100.0)->Float.toString,
    "authentication_initiated": (authenticationInitated *. 100.0)->Float.toString,
    "authentication_attemped": (authenticationAttempted *. 100.0)->Float.toString,
    "authentication_successful": (authenticationSuccesful *. 100.0)->Float.toString,
  }->Identity.genericTypeToJson
  let data = [dict]
  let metrics: array<LineChartUtils.metricsConfig> = [
    {
      metric_name_db: "payments_requiring_3ds_2_authentication",
      metric_label: "Payments Requiring 3DS 2.0 Authentication",
      thresholdVal: None,
      step_up_threshold: None,
      metric_type: Rate,
      disabled: false,
    },
    {
      metric_name_db: "authentication_initiated",
      metric_label: "Authentication Initiated",
      thresholdVal: None,
      step_up_threshold: None,
      metric_type: Rate,
      disabled: false,
    },
    {
      metric_name_db: "authentication_attemped",
      metric_label: "Authentication Attempted",
      thresholdVal: None,
      step_up_threshold: None,
      metric_type: Rate,
      disabled: false,
    },
    {
      metric_name_db: "authentication_successful",
      metric_label: "Authentication Successful",
      thresholdVal: None,
      step_up_threshold: None,
      metric_type: Rate,
      disabled: false,
    },
  ]

  React.useEffect(() => {
    if startTimeVal->String.length > 0 && endTimeVal->String.length > 0 {
      loadInfo()->ignore
    }
    None
  }, (startTimeVal, endTimeVal))

  let setInitialFilters = HSwitchRemoteFilter.useSetInitialFilters(
    ~updateExistingKeys,
    ~startTimeFilterKey,
    ~endTimeFilterKey,
    ~origin="analytics",
    ~isInsightsPage=true,
    ~enableCompareTo=None,
    ~range=6,
    (),
  )

  React.useEffect(() => {
    setInitialFilters()
    None
  }, [])

  <PageLoaderWrapper screenState customUI={<NoData title />}>
    <div>
      <PageUtils.PageHeading title />
      <div
        className="-ml-1 sticky top-0 z-30 p-1 bg-hyperswitch_background/70 py-1 rounded-lg my-2">
        <DynamicFilter
          title="NewAnalytics"
          initialFilters=[]
          options=[]
          popupFilterFields=[]
          initialFixedFilters={AuthenticationAnalyticsV2Utils.initialFixedFilterFields()}
          defaultFilterKeys=[startTimeFilterKey, endTimeFilterKey]
          tabNames=[]
          key="0"
          updateUrlWith=updateExistingKeys
          filterFieldsPortalName={HSAnalyticsUtils.filterFieldsPortalName}
          showCustomFilter=false
          refreshFilters=false
        />
      </div>
      <div className="grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-3">
        <Card
          title="Payments Requiring 3DS authentication"
          value={queryData->getInt("authentication_count", 0)->Int.toFloat}
          description="Total number of payments which requires 3DS 2.0 authentication"
          statType={No_Type}
        />
        <Card
          title="Authentication Success Rate"
          value={queryData->getInt("authentication_success_count", 0)->Int.toFloat /.
          queryData->getInt("authentication_count", 1)->Int.toFloat *. 100.0}
          statType={Rate}
          description="Successful authentication requests over total authentication requests"
        />
        <Card
          title="Challenge Flow Rate"
          value={queryData->getInt("challenge_success_count", 0)->Int.toFloat /.
          queryData->getInt("challenge_flow_count", 1)->Int.toFloat *. 100.0}
          statType={Rate}
          description="Successful challenge requests over total challenge requests"
        />
        <Card
          title="Frictionless Flow Rate"
          value={queryData->getInt("frictionless_success_count", 0)->Int.toFloat /.
          queryData->getInt("frictionless_flow_count", 1)->Int.toFloat *. 100.0}
          statType={Rate}
          description="Successful frictionless requests over total frictionless requests"
        />
        <Card
          title="Challenge Attempt Count"
          value={queryData->getInt("challenge_attempt_count", 0)->Int.toFloat}
          statType={No_Type}
          description="Total number of challenge attempts"
        />
        <Card
          title="Challenge Success Count"
          value={queryData->getInt("challenge_success_count", 0)->Int.toFloat}
          statType={No_Type}
          description="Total number of successful challenge count"
        />
        <Card
          title="Frictionless Success Count"
          value={queryData->getInt("frictionless_success_count", 0)->Int.toFloat}
          statType={No_Type}
          description="Total number of successful frictionless count"
        />
      </div>
      <RenderIf condition={funnelData->getInt("authentication_initiated", 0) > 0}>
        <div className="border border-gray-200 mt-5 p-5 rounded-lg">
          <FunnelChart
            data={data}
            metrics={metrics}
            moduleName="Authentication Funnel"
            description=Some("Breakdown of ThreeDS 2.0 Journey")
          />
        </div>
      </RenderIf>
    </div>
  </PageLoaderWrapper>
}
