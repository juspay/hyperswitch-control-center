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
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (queryData, setQueryData) = React.useState(_ => Dict.make())
  let (funnelData, setFunnelData) = React.useState(_ => Dict.make())
  let {updateExistingKeys} = React.useContext(FilterContext.filterContext)
  let {filterValueJson} = React.useContext(FilterContext.filterContext)
  let startTimeVal = filterValueJson->getString("startTime", "")
  let endTimeVal = filterValueJson->getString("endTime", "")
  let title = "Authentication Analytics"

  let loadInfo = async () => {
    setScreenState(_ => PageLoaderWrapper.Loading)
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

      let funnelDict = Dict.make()

      funnelDict->Dict.set("authentication_initiated", secondFunnelQueryDataArray->JSON.Encode.int)
      funnelDict->Dict.set("authentication_attemped", thirdFunnelQueryDataArray->JSON.Encode.int)
      funnelDict->Dict.set(
        "payments_requiring_3ds_2_authentication",
        getFirstValueOfQueryData->getInt("authentication_count", 0)->JSON.Encode.int,
      )
      funnelDict->Dict.set(
        "authentication_successful",
        getFirstValueOfQueryData->getInt("authentication_success_count", 0)->JSON.Encode.int,
      )

      setFunnelData(_ => {
        funnelDict
      })

      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | Exn.Error(e) =>
      let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
      setScreenState(_ => PageLoaderWrapper.Error(err))
    }
  }

  // Need to be refactored

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
      <RenderIf
        condition={funnelData->getInt("authentication_initiated", 0) > 0 &&
        funnelData->getInt("payments_requiring_3ds_2_authentication", 0) > 0 &&
        funnelData->getInt("authentication_attemped", 0) > 0 &&
        funnelData->getInt("authentication_successful", 0) > 0}>
        <div className="border border-gray-200 mt-5 p-5 rounded-lg">
          <FunnelChart
            data={data}
            metrics={AuthenticationAnalyticsV2Utils.metrics}
            moduleName="Authentication Funnel"
            description=Some("Breakdown of ThreeDS 2.0 Journey")
          />
        </div>
      </RenderIf>
      <Insights startTimeVal endTimeVal />
    </div>
  </PageLoaderWrapper>
}
