open ExemptionGraphsTypes
open LogicUtils
open InsightsTypes
open InsightsUtils
open NewAnalyticsUtils
open NewAnalyticsTypes

let getStringFromVariant = value => {
  switch value {
  | Authentication_Connector => "authentication_connector"
  | Authentication_Count => "authentication_count"
  | Authentication_Success_Count => "authentication_success_count"
  | Authentication_Success_Rate => "authentication_success_rate"
  | Authentication_Exemption_Approved_Count => "authentication_exemption_approved_count"
  | Authentication_Exemption_Requested_Count => "authentication_exemption_requested_count"
  | Exemption_Approval_Rate => "exemption_approval_rate"
  | Authentication_Attempt_Count => "authentication_attempt_count"
  | Authentication_Failure_Count => "authentication_failure_count"
  | Authentication_Failure_Rate => "authentication_failure_rate"
  | Exemption_Request_Rate => "exemption_request_rate"
  | User_Drop_Off_Rate => "user_drop_off_rate"
  | Time_Bucket => "time_bucket"
  | _ => "unknown"
  }
}

let getVariantValueFromString = value => {
  switch value {
  | "authentication_connector" => Authentication_Connector
  | "authentication_success_count" => Authentication_Success_Count
  | "authentication_failure_count" => Authentication_Failure_Count
  | "authentication_failure_rate" => Authentication_Failure_Rate
  | "authentication_count" => Authentication_Count
  | "authentication_success_rate" => Authentication_Success_Rate
  | "authentication_exemption_approved_count" => Authentication_Exemption_Approved_Count
  | "authentication_exemption_requested_count" => Authentication_Exemption_Requested_Count
  | "exemption_approval_rate" => Exemption_Approval_Rate
  | "authentication_attempt_count" => Authentication_Attempt_Count
  | "exemption_request_rate" => Exemption_Request_Rate
  | "user_drop_off_rate" => User_Drop_Off_Rate
  | "time_bucket" | _ => Time_Bucket
  }
}

let tooltipFormatter = (
  ~title,
  ~metricType,
  ~currency="",
  ~suffix="",
  ~showNameInTooltip=false,
) => {
  open LineGraphTypes

  (
    @this
    (this: pointFormatter) => {
      let tableItems =
        this.points
        ->Array.map(point => {
          let pointData = point->Identity.genericTypeToJson->getDictFromJsonObject
          let iconColor = pointData->getString("color", "#000000")
          let date = pointData->getString("x", "")
          let series = pointData->getDictfromDict("series")
          let name = series->getString("name", "")
          let value = pointData->getFloat("y", 0.0)
          getRowsHtml(
            ~iconColor,
            ~date,
            ~name,
            ~value,
            ~metricType,
            ~currency,
            ~suffix,
            ~showNameInTooltip,
          )
        })
        ->Array.joinWith("")

      getContentsUI(~title=getTitleUI(~title), ~tableItems)
    }
  )->asTooltipPointFormatter
}

let getLineGraphData = (data, ~xKey, ~yKey, ~groupByKey, ~isAmount=false, ~currency) => {
  if groupByKey->isNonEmptyString {
    let separatorDict = Dict.make()
    data
    ->getArrayFromJson([])
    ->Array.forEach(itemArray => {
      let itemList = itemArray->getArrayFromJson([])
      itemList->Array.forEach(item => {
        let itemDict = item->getDictFromJsonObject
        let name = itemDict->getString(groupByKey, "NA")

        switch separatorDict->Dict.get(name) {
        | Some(existingArray) => {
            let updatedArray = existingArray->Array.concat([item])
            separatorDict->Dict.set(name, updatedArray)
          }
        | None => separatorDict->Dict.set(name, [item])
        }
      })
    })

    let dataArray =
      separatorDict
      ->Dict.toArray
      ->Array.mapWithIndex(((name, dictData), index) => {
        let color = index->NewAnalyticsUtils.getColor
        getLineGraphObj(~array=dictData, ~key=xKey, ~name, ~color, ~isAmount)
      })

    dataArray
  } else {
    data->InsightsUtils.getLineGraphData(~xKey, ~yKey, ~isAmount, ~currency)
  }
}

let exemptionGraphsMapper = (~params: getObjects<JSON.t>): LineGraphTypes.lineGraphPayload => {
  let {data, xKey, yKey} = params
  let title = params.title->Option.getOr("")
  let currency = params.currency->Option.getOr("")
  let primaryCategories = data->getCategories(0, yKey)
  let groupByKey = params.groupByKey->Option.getOr("")

  let lineGraphData = data->getLineGraphData(~xKey, ~yKey, ~groupByKey, ~currency)
  let tooltipFormatter = tooltipFormatter(
    ~title,
    ~metricType=Amount,
    ~currency,
    ~showNameInTooltip=true,
  )

  {
    chartHeight: DefaultHeight,
    chartLeftSpacing: DefaultLeftSpacing,
    categories: primaryCategories,
    data: lineGraphData,
    title: {
      text: "",
    },
    yAxisMaxValue: Some(100),
    yAxisMinValue: Some(0),
    tooltipFormatter,
    yAxisFormatter: LineGraphUtils.lineGraphYAxisFormatter(
      ~statType=Default,
      ~currency="",
      ~suffix="",
    ),
    legend: {
      useHTML: true,
      labelFormatter: LineGraphUtils.valueFormatter,
    },
  }
}

let visibleColumns = [Time_Bucket]

let tableItemToObjMapper: Dict.t<JSON.t> => exemptionGraphsObject = dict => {
  {
    authentication_count: dict->getInt(Authentication_Count->getStringFromVariant, 0),
    authentication_success_count: dict->getInt(
      Authentication_Success_Count->getStringFromVariant,
      0,
    ),
    authentication_failure_count: dict->getInt(
      Authentication_Failure_Count->getStringFromVariant,
      0,
    ),
    authentication_success_rate: dict->getFloat(
      Authentication_Success_Rate->getStringFromVariant,
      0.0,
    ),
    authentication_failure_rate: dict->getFloat(
      Authentication_Failure_Rate->getStringFromVariant,
      0.0,
    ),
    time_bucket: dict->getString(Time_Bucket->getStringFromVariant, "NA"),
    authentication_exemption_approved_count: dict->getInt(
      Authentication_Exemption_Approved_Count->getStringFromVariant,
      0,
    ),
    authentication_exemption_requested_count: dict->getInt(
      Authentication_Exemption_Requested_Count->getStringFromVariant,
      0,
    ),
    exemption_approval_rate: dict->getFloat(Exemption_Approval_Rate->getStringFromVariant, 0.0),
    authentication_attempt_count: dict->getInt(
      Authentication_Attempt_Count->getStringFromVariant,
      0,
    ),
    exemption_request_rate: dict->getFloat(Exemption_Request_Rate->getStringFromVariant, 0.0),
    user_drop_off_rate: dict->getFloat(User_Drop_Off_Rate->getStringFromVariant, 0.0),
    authentication_connector: dict->getString(Authentication_Connector->getStringFromVariant, "NA"),
  }
}

let getObjects: JSON.t => array<exemptionGraphsObject> = json => {
  json
  ->LogicUtils.getArrayFromJson([])
  ->Array.map(item => {
    tableItemToObjMapper(item->getDictFromJsonObject)
  })
}

let defaulGranularity = {
  label: "Daily",
  value: (#G_ONEDAY: NewAnalyticsTypes.granularity :> string),
}

let getKey = id => {
  let key = switch id {
  | Time_Bucket => #time_bucket
  | Authentication_Connector => #authentication_connector
  | Authentication_Success_Count => #authentication_success_count
  | Authentication_Count => #authentication_count
  | Authentication_Success_Rate => #authentication_success_rate
  | Authentication_Exemption_Approved_Count => #authentication_exemption_approved_count
  | Authentication_Exemption_Requested_Count => #authentication_exemption_requested_count
  | Exemption_Approval_Rate => #exemption_approval_rate
  | Authentication_Attempt_Count => #authentication_attempt_count
  | Exemption_Request_Rate => #exemption_request_rate
  | User_Drop_Off_Rate => #user_drop_off_rate
  | _ => #time_bucket
  }
  (key: responseKeys :> string)
}

let modifyQueryData = data => {
  // Group by time_bucket and authentication_connector
  let groupedDataDict = Dict.make()

  data->Array.forEach(item => {
    let valueDict = item->getDictFromJsonObject
    let time = valueDict->getString(Time_Bucket->getStringFromVariant, "")
    let connector = valueDict->getString(Authentication_Connector->getStringFromVariant, "NA")
    let groupKey = `${time}_${connector}`

    switch groupedDataDict->Dict.get(groupKey) {
    | Some(existingArray) =>
      groupedDataDict->Dict.set(groupKey, existingArray->Array.concat([item]))
    | None => groupedDataDict->Dict.set(groupKey, [item])
    }
  })

  let resultDict = Dict.make()

  groupedDataDict
  ->Dict.toArray
  ->Array.forEach(((groupKey, items)) => {
    let totalAuthenticationCount = ref(0)
    let totalAuthenticationSuccessCount = ref(0)
    let totalAuthenticationAttemptCount = ref(0)
    let totalAuthenticationFailedCount = ref(0)
    let totalAuthenticationExemptionApprovedCount = ref(0)
    let totalAuthenticationExemptionRequestedCount = ref(0)

    let time = ref("")
    let connector = ref("NA")

    // Aggregate all counts for this time_bucket + connector group
    items->Array.forEach(item => {
      let itemDict = item->getDictFromJsonObject

      time := itemDict->getString(Time_Bucket->getStringFromVariant, "")
      connector := itemDict->getString(Authentication_Connector->getStringFromVariant, "NA")

      let authStatus = itemDict->getString("authentication_status", "")
      let count = itemDict->getInt(Authentication_Count->getKey, 0)
      let attemptCount = itemDict->getInt(Authentication_Attempt_Count->getKey, 0)
      let successCount = itemDict->getInt(Authentication_Success_Count->getKey, 0)
      let exemptionApprovedCount =
        itemDict->getInt(Authentication_Exemption_Approved_Count->getKey, 0)
      let exemptionRequestedCount =
        itemDict->getInt(Authentication_Exemption_Requested_Count->getKey, 0)

      totalAuthenticationCount := totalAuthenticationCount.contents + count
      totalAuthenticationAttemptCount := totalAuthenticationAttemptCount.contents + attemptCount
      totalAuthenticationSuccessCount := totalAuthenticationSuccessCount.contents + successCount
      totalAuthenticationExemptionApprovedCount :=
        totalAuthenticationExemptionApprovedCount.contents + exemptionApprovedCount
      totalAuthenticationExemptionRequestedCount :=
        totalAuthenticationExemptionRequestedCount.contents + exemptionRequestedCount

      if authStatus == "failed" {
        totalAuthenticationFailedCount := totalAuthenticationFailedCount.contents + count
      }
    })

    let authenticationSuccessRate = if totalAuthenticationAttemptCount.contents == 0 {
      0.0
    } else {
      let rate =
        float_of_int(totalAuthenticationSuccessCount.contents) /.
        float_of_int(totalAuthenticationAttemptCount.contents) *. 100.0
      Float.toFixedWithPrecision(rate, ~digits=2)->Float.fromString->Option.getOr(0.0)
    }

    let authenticationFailureRate = if totalAuthenticationAttemptCount.contents == 0 {
      0.0
    } else {
      let rate =
        float_of_int(totalAuthenticationFailedCount.contents) /.
        float_of_int(totalAuthenticationAttemptCount.contents) *. 100.0
      Float.toFixedWithPrecision(rate, ~digits=2)->Float.fromString->Option.getOr(0.0)
    }

    let exemptionApprovalRate = if totalAuthenticationExemptionRequestedCount.contents == 0 {
      0.0
    } else {
      let rate =
        float_of_int(totalAuthenticationExemptionApprovedCount.contents) /.
        float_of_int(totalAuthenticationExemptionRequestedCount.contents) *. 100.0
      Float.toFixedWithPrecision(rate, ~digits=2)->Float.fromString->Option.getOr(0.0)
    }

    let exemptionRequestRate = if totalAuthenticationCount.contents == 0 {
      0.0
    } else {
      let rate =
        float_of_int(totalAuthenticationExemptionRequestedCount.contents) /.
        float_of_int(totalAuthenticationCount.contents) *. 100.0
      Float.toFixedWithPrecision(rate, ~digits=2)->Float.fromString->Option.getOr(0.0)
    }

    let userDropOffRate = if totalAuthenticationAttemptCount.contents == 0 {
      0.0
    } else {
      let dropOffCount =
        totalAuthenticationAttemptCount.contents -
        (totalAuthenticationSuccessCount.contents +
        totalAuthenticationFailedCount.contents)
      let rate =
        float_of_int(dropOffCount) /.
        float_of_int(totalAuthenticationAttemptCount.contents) *. 100.0
      Float.toFixedWithPrecision(rate, ~digits=2)->Float.fromString->Option.getOr(0.0)
    }

    let resultDict_inner = Dict.make()
    resultDict_inner->Dict.set(Time_Bucket->getStringFromVariant, time.contents->JSON.Encode.string)
    resultDict_inner->Dict.set(
      Authentication_Connector->getStringFromVariant,
      connector.contents->JSON.Encode.string,
    )
    resultDict_inner->Dict.set(
      Authentication_Count->getStringFromVariant,
      totalAuthenticationCount.contents->JSON.Encode.int,
    )
    resultDict_inner->Dict.set(
      Authentication_Success_Count->getStringFromVariant,
      totalAuthenticationSuccessCount.contents->JSON.Encode.int,
    )
    resultDict_inner->Dict.set(
      Authentication_Failure_Count->getStringFromVariant,
      totalAuthenticationFailedCount.contents->JSON.Encode.int,
    )
    resultDict_inner->Dict.set(
      Authentication_Attempt_Count->getStringFromVariant,
      totalAuthenticationAttemptCount.contents->JSON.Encode.int,
    )
    resultDict_inner->Dict.set(
      Authentication_Exemption_Approved_Count->getStringFromVariant,
      totalAuthenticationExemptionApprovedCount.contents->JSON.Encode.int,
    )
    resultDict_inner->Dict.set(
      Authentication_Exemption_Requested_Count->getStringFromVariant,
      totalAuthenticationExemptionRequestedCount.contents->JSON.Encode.int,
    )
    resultDict_inner->Dict.set(
      Authentication_Success_Rate->getStringFromVariant,
      authenticationSuccessRate->JSON.Encode.float,
    )
    resultDict_inner->Dict.set(
      Authentication_Failure_Rate->getStringFromVariant,
      authenticationFailureRate->JSON.Encode.float,
    )
    resultDict_inner->Dict.set(
      Exemption_Approval_Rate->getStringFromVariant,
      exemptionApprovalRate->JSON.Encode.float,
    )
    resultDict_inner->Dict.set(
      Exemption_Request_Rate->getStringFromVariant,
      exemptionRequestRate->JSON.Encode.float,
    )
    resultDict_inner->Dict.set(
      User_Drop_Off_Rate->getStringFromVariant,
      userDropOffRate->JSON.Encode.float,
    )

    resultDict->Dict.set(groupKey, resultDict_inner->JSON.Encode.object)
  })

  resultDict->Dict.valuesToArray
}

let getCell = (obj: exemptionGraphsObject, colType): Table.cell => {
  switch colType {
  | Authentication_Connector => Text(obj.authentication_connector)
  | Authentication_Success_Rate => Text(obj.authentication_success_rate->Float.toString ++ "%")
  | Exemption_Approval_Rate => Text(obj.exemption_approval_rate->Float.toString ++ "%")
  | Exemption_Request_Rate => Text(obj.exemption_request_rate->Float.toString ++ "%")
  | User_Drop_Off_Rate => Text(obj.user_drop_off_rate->Float.toString ++ "%")
  | Authentication_Failure_Rate => Text(obj.authentication_failure_rate->Float.toString ++ "%")
  | Time_Bucket => Text(obj.time_bucket->formatDateValue(~includeYear=true))
  | _ => Text("")
  }
}

let getHeading = colType => {
  switch colType {
  | Authentication_Connector =>
    Table.makeHeaderInfo(
      ~key=Authentication_Connector->getStringFromVariant,
      ~title="Authentication Connector",
      ~dataType=TextType,
    )
  | Authentication_Success_Rate =>
    Table.makeHeaderInfo(
      ~key=Authentication_Success_Rate->getStringFromVariant,
      ~title="Authentication Success Rate",
      ~dataType=TextType,
    )
  | Exemption_Approval_Rate =>
    Table.makeHeaderInfo(
      ~key=Exemption_Approval_Rate->getStringFromVariant,
      ~title="Exemption Approval Rate",
      ~dataType=TextType,
    )
  | Exemption_Request_Rate =>
    Table.makeHeaderInfo(
      ~key=Exemption_Request_Rate->getStringFromVariant,
      ~title="Exemption Request Rate",
      ~dataType=TextType,
    )
  | User_Drop_Off_Rate =>
    Table.makeHeaderInfo(
      ~key=User_Drop_Off_Rate->getStringFromVariant,
      ~title="User Drop Off Rate",
      ~dataType=TextType,
    )
  | Authentication_Failure_Rate =>
    Table.makeHeaderInfo(
      ~key=Authentication_Failure_Rate->getStringFromVariant,
      ~title="Authentication Failure Rate",
      ~dataType=TextType,
    )
  | Time_Bucket =>
    Table.makeHeaderInfo(~key=Time_Bucket->getStringFromVariant, ~title="Date", ~dataType=TextType)
  | _ => Table.makeHeaderInfo(~key="", ~title="", ~dataType=TextType)
  }
}

let fillMissingDataPointsForConnectors = (
  ~data,
  ~startDate,
  ~endDate,
  ~timeKey,
  ~granularity,
  ~isoStringToCustomTimeZone,
  ~granularityEnabled,
  ~connectorKey="authentication_connector",
) => {
  // Extract unique connector names from the data using a dictionary
  let connectorDict = Dict.make()

  data->Array.forEach(item => {
    let itemDict = item->getDictFromJsonObject
    let connectorName = itemDict->getString(connectorKey, "NA")
    connectorDict->Dict.set(connectorName, true)
  })

  let uniqueConnectors = connectorDict->Dict.keysToArray

  // For each connector, filter data and fill missing data points
  let filledDataByConnector = uniqueConnectors->Array.map(connectorName => {
    let connectorData = data->Array.filter(item => {
      let itemDict = item->getDictFromJsonObject
      itemDict->getString(connectorKey, "NA") === connectorName
    })

    // Fill missing data points with this connector's name
    let defaultValue = {
      "authentication_count": 0,
      "authentication_success_count": 0,
      "authentication_attempt_count": 0,
      "authentication_exemption_requested": 0,
      "authentication_exemption_accepted": 0,
      "authentication_connector": connectorName,
      "time_bucket": startDate,
    }->Identity.genericTypeToJson

    fillMissingDataPoints(
      ~data=connectorData,
      ~startDate,
      ~endDate,
      ~timeKey,
      ~defaultValue,
      ~granularity,
      ~isoStringToCustomTimeZone,
      ~granularityEnabled,
    )
  })

  filledDataByConnector->Array.flat
}

let getDataKeyForMetric = metric => {
  switch metric->getVariantValueFromString {
  | Authentication_Success_Rate => "authenticationLifeCycleData1"
  | User_Drop_Off_Rate => "authenticationLifeCycleData2"
  | _ => "authenticationLifeCycleData3"
  }
}
