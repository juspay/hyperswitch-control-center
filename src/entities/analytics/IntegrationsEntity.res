let domain = "integrations"

open LogicUtils
open EntityType
open Belt.Option
let makeMultiInputFieldInfo = FormRenderer.makeMultiInputFieldInfo
let makeInputFieldInfo = FormRenderer.makeInputFieldInfo
let makeFieldInfo = FormRenderer.makeFieldInfo
let (startTimeFilterKey, endTimeFilterKey, optFilterKey) = ("startTime", "endTime", "opt")
let tabKeys = ["track", "mode"]

let getLabel = key => {
  switch key {
  | "payment_page_session_count" => "Payment Page Sessions Integrations"
  | "payment_page_signature_count" => "Payment Page Signature Integrations"
  | "ec_sdk_count" => `EC + SDK Integrations`
  | "ec_only_count" => "EC Only Integrations"
  | _ => ""
  }
}

let url = `/ic/integration-monitoring/v1/${domain}/metrics`

type apiTableBody = {
  filter?: Js.Json.t,
  metrics?: array<string>,
  startDateTime: string,
  endDateTime: string,
  source?: string,
  groupByNames?: array<string>,
  delta: bool,
}
type merchantData = {merchant_id: string}

type integrationTable = {
  merchant_id: string,
  product_integrated: string,
  status: string,
  date_created: string,
  is_restricted: string,
  track: string,
  go_live_ts: string,
  critical_checklist_score: string,
  critical_total: int,
  critical_success: int,
  score: float,
  mode: string,
}

type colType =
  | Merchant_id
  | Product_integrated
  | Status
  | Date_created
  | Is_restricted
  | Track
  | Go_live_ts
  | Critical_checklist_score
  | Critical_success
  | Critical_total
  | Score
  | Mode

let colMapper = (col: colType) => {
  switch col {
  | Merchant_id => "merchant_id"
  | Product_integrated => "product"
  | Status => "status"
  | Date_created => "last_date_created"
  | Is_restricted => "last_is_restricted"
  | Track => "last_track"
  | Go_live_ts => "last_go_live_timestamp"
  | Critical_checklist_score => "critical_checklist_score"
  | Critical_success => "success_critical"
  | Critical_total => "total_critical"
  | Score => "score"
  | Mode => "mode"
  }
}

let headingKeyMapper = (col: colType) => {
  switch col {
  | Merchant_id => "merchant_id"
  | Product_integrated => "product_integrated"
  | Status => "status"
  | Date_created => "date_created"
  | Is_restricted => "is_restricted"
  | Track => "track"
  | Go_live_ts => "go_live_timestamp"
  | Critical_checklist_score => "critical_checklist_score"
  | Critical_success => "success_critical"
  | Critical_total => "total_critical"
  | Score => "score"
  | Mode => "mode"
  }
}

let itemToObj = dict => {
  {
    merchant_id: LogicUtils.getString(dict, "merchant_id", ""),
  }
}

let tableItemToObjMapper = dict => {
  {
    merchant_id: dict->getString(Merchant_id->colMapper, ""),
    product_integrated: dict->getString(Product_integrated->colMapper, ""),
    status: dict->getString(Status->colMapper, ""),
    date_created: dict->getString(Date_created->colMapper, ""),
    is_restricted: dict->getString(Is_restricted->colMapper, ""),
    track: dict->getString(Track->colMapper, ""),
    go_live_ts: dict->getString(Go_live_ts->colMapper, ""),
    critical_checklist_score: dict->getString(Critical_checklist_score->colMapper, ""),
    critical_success: dict->getInt(Critical_success->colMapper, 0),
    critical_total: dict->getInt(Critical_total->colMapper, 0),
    score: dict->getFloat(Score->colMapper, 0.0),
    mode: dict->getString(Mode->colMapper, ""),
  }
}

let getHeading = colType => {
  let key = colType->headingKeyMapper
  switch colType {
  | Merchant_id =>
    Table.makeHeaderInfo(~key, ~title="Merchant Id", ~dataType=DropDown, ~showSort=true, ())
  | Product_integrated =>
    Table.makeHeaderInfo(~key, ~title="Product Integrated", ~dataType=DropDown, ~showSort=true, ())
  | Status => Table.makeHeaderInfo(~key, ~title="Status", ~dataType=LabelType, ~showSort=true, ())
  | Date_created =>
    Table.makeHeaderInfo(~key, ~title="Date Created", ~dataType=TextType, ~showSort=true, ())
  | Is_restricted =>
    Table.makeHeaderInfo(~key, ~title="Restricted Mode", ~dataType=DropDown, ~showSort=true, ())
  | Track => Table.makeHeaderInfo(~key, ~title="Track", ~dataType=DropDown, ~showSort=true, ())
  | Go_live_ts =>
    Table.makeHeaderInfo(~key, ~title="Go Live Timestamp", ~dataType=DropDown, ~showSort=true, ())
  | Critical_checklist_score =>
    Table.makeHeaderInfo(
      ~key,
      ~title="Critical Checklist Score",
      ~dataType=TextType,
      ~showSort=true,
      (),
    )
  | Critical_total =>
    Table.makeHeaderInfo(~key, ~title="Critical Total", ~dataType=NumericType, ~showSort=true, ())
  | Critical_success =>
    Table.makeHeaderInfo(~key, ~title="Critical Success", ~dataType=NumericType, ~showSort=true, ())
  | Score => Table.makeHeaderInfo(~key, ~title="Score", ~dataType=NumericType, ~showSort=true, ())
  | Mode => Table.makeHeaderInfo(~key, ~title="Mode", ~dataType=TextType, ~showSort=true, ())
  }
}

let getCell = (integrationTable, colType): Table.cell => {
  switch colType {
  | Merchant_id => Text(integrationTable.merchant_id)
  | Product_integrated => Text(integrationTable.product_integrated)
  | Status =>
    Label({
      title: integrationTable.status,
      color: switch integrationTable.status {
      | "Done" => LabelGreen
      | "Failed" => LabelRed
      | _ => LabelOrange
      },
    })
  | Date_created => Date(integrationTable.date_created)
  | Is_restricted => Text(integrationTable.is_restricted)
  | Track => Text(integrationTable.track)
  | Go_live_ts => Date(integrationTable.go_live_ts)
  | Critical_checklist_score => Text(integrationTable.critical_checklist_score)
  | Critical_total => Numeric(integrationTable.critical_total->Belt.Int.toFloat, indianShortNum)
  | Critical_success => Numeric(integrationTable.critical_success->Belt.Int.toFloat, indianShortNum)
  | Score => Numeric(integrationTable.score, indianShortNum)
  | Mode => Text(integrationTable.mode)
  }
}

let getManagementTable: Js.Json.t => array<integrationTable> = json => {
  let val =
    json
    ->LogicUtils.getArrayFromJson([])
    ->Array.map(item => {
      tableItemToObjMapper(item->getDictFromJsonObject)
    })

  val->Array.map(item => {
    let score =
      item.critical_success->Belt.Int.toFloat /. item.critical_total->Belt.Int.toFloat *. 100.

    {
      ...item,
      status: if score > 75. {
        "Done"
      } else if score > 25. && score <= 75. {
        "Under Progress"
      } else {
        "Failed"
      },
      critical_checklist_score: item.critical_success->Belt.Int.toString ++
      "/" ++
      item.critical_total->Belt.Int.toString,
    }
  })
}

let getDefaultFilters = () => {
  let filterCreatedDict = Dict.make()

  let currentDate = Js.Date.now()
  let currentTimestamp = currentDate->Js.Date.fromFloat->Js.Date.toISOString
  filterCreatedDict->Dict.set(
    "endTime",
    Js.Json.string(currentTimestamp->TimeZoneHook.formattedISOString("YYYY-MM-DDTHH:mm:ss[Z]")),
  )

  let prevMins = {
    let presentDayInString = Js.Date.fromFloat(currentDate)
    let prevDateInFloat = Js.Date.getDate(presentDayInString) -. 7.0
    Js.Date.setDate(presentDayInString, prevDateInFloat)
  }

  Dict.set(
    filterCreatedDict,
    "startTime",
    Js.Json.string(
      prevMins
      ->Js.Date.fromFloat
      ->Js.Date.toISOString
      ->TimeZoneHook.formattedISOString("YYYY-MM-DDTHH:mm:ss[Z]"),
    ),
  )

  filterCreatedDict
}

let tableIntegrationEntity = EntityType.makeEntity(
  ~uri="",
  ~getObjects=getManagementTable,
  ~defaultColumns=[
    Merchant_id,
    Product_integrated,
    Status,
    Critical_checklist_score,
    Date_created,
    Is_restricted,
    Track,
    Go_live_ts,
  ],
  ~getHeading,
  ~getCell,
  ~dataKey="",
  (),
)
let bodyDict = (bodyEntity: apiTableBody) => {
  [
    AnalyticsUtils.getFilterRequestBody(
      ~filter=bodyEntity.filter,
      ~metrics=bodyEntity.metrics,
      ~startDateTime=bodyEntity.startDateTime,
      ~endDateTime=bodyEntity.endDateTime,
      ~source="REALTIME",
      ~groupByNames=bodyEntity.groupByNames,
      ~delta=bodyEntity.delta,
      (),
    )->Js.Json.object_,
  ]
  ->Js.Json.array
  ->Js.Json.stringify
}

let initialFixedFilterFields = _json => {
  let newArr = [
    (
      {
        localFilter: None,
        field: makeMultiInputFieldInfo(
          ~label="",
          ~comboCustomInput=InputFields.dateRangeField(
            ~startKey=startTimeFilterKey,
            ~endKey=endTimeFilterKey,
            ~format="YYYY-MM-DDTHH:mm:ss[Z]",
            ~showTime=true,
            ~disablePastDates={false},
            ~disableFutureDates={true},
            ~predefinedDays=[
              Hour(0.5),
              Hour(1.0),
              Hour(6.0),
              Today,
              Yesterday,
              Day(2.0),
              Day(7.0),
              Day(30.0),
              ThisMonth,
              LastMonth,
            ],
            ~numMonths=2,
            ~disableApply=false,
            ~dateRangeLimit=60,
            ~optFieldKey=optFilterKey,
            (),
          ),
          ~inputFields=[],
          ~isRequired=false,
          (),
        ),
      }: EntityType.initialFilters<'t>
    ),
    (
      {
        localFilter: None,
        field: makeFieldInfo(
          ~label="",
          ~name="mode",
          ~customInput=InputFields.multiSelectInput(
            ~options=["Live", "Restricted"]->SelectBox.makeOptions,
            ~buttonText="Select Mode",
            ~showSelectionAsChips=false,
            ~searchable=true,
            (),
          ),
          (),
        ),
      }: EntityType.initialFilters<'t>
    ),
    (
      {
        localFilter: None,
        field: makeFieldInfo(
          ~label="",
          ~name="track",
          ~customInput=InputFields.multiSelectInput(
            ~options=["F1", "F2"]->SelectBox.makeOptions,
            ~buttonText="Select Action",
            ~showSelectionAsChips=false,
            ~searchable=true,
            (),
          ),
          (),
        ),
      }: EntityType.initialFilters<'t>
    ),
  ]

  newArr
}
let filterEntity: AnalyticsUtils.filterEntity<integrationTable> = {
  uri: "",
  moduleName: "IntegrationMonitoring",
  filterDropDownOptions: _ => {
    []
  },
  filterKeys: tabKeys,
  initialFixedFilters: initialFixedFilterFields,
  initialFilters: _ => {
    []
  },
  timeKeys: {
    startTimeKey: startTimeFilterKey,
    endTimeKey: endTimeFilterKey,
  },
  defaultFilterKeys: [startTimeFilterKey, endTimeFilterKey, "mode", "track"],
}

//////// management singlestats

type managementSinglestat = {
  payment_page_session_count: int,
  payment_page_signature_count: int,
  ec_only_count: int,
  ec_sdk_count: int,
  delta_payment_page_signature_count: float,
  delta_payment_page_session_count: float,
  delta_ec_only_count: float,
  delta_ec_sdk_count: float,
}

let singlestatInitialValue = {
  payment_page_session_count: 0,
  payment_page_signature_count: 0,
  ec_only_count: 0,
  ec_sdk_count: 0,
  delta_payment_page_signature_count: 0.0,
  delta_payment_page_session_count: 0.0,
  delta_ec_only_count: 0.0,
  delta_ec_sdk_count: 0.0,
}

type mangaementSinglestatTimeseries = {
  payment_page_session_count: int,
  payment_page_signature_count: int,
  ec_only_count: int,
  ec_sdk_count: int,
  timeSeries: string,
}

let singlestatTimeseriesInitialValue = {
  payment_page_session_count: 0,
  payment_page_signature_count: 0,
  ec_only_count: 0,
  ec_sdk_count: 0,
  timeSeries: "",
}

let singlestatTimeseriesItemToObjMapper = json => {
  json
  ->Js.Json.decodeObject
  ->map(dict => {
    let product = dict->getString("product_integrated", "")
    {
      payment_page_session_count: product->String.includes("Payment Page Session")
        ? dict->getInt("merchant_count", 0)
        : 0,
      payment_page_signature_count: product->String.includes("Payment Page Signature")
        ? dict->getInt("merchant_count", 0)
        : 0,
      ec_only_count: product->String.includes("EC Only") ? dict->getInt("merchant_count", 0) : 0,
      ec_sdk_count: product->String.includes("EC + SDK") ? dict->getInt("merchant_count", 0) : 0,
      timeSeries: dict->getString("time_bucket", "2023-01-01 18:00:00"),
    }
  })
  ->getWithDefault({
    singlestatTimeseriesInitialValue
  })
}

let itemToObjMapper = json => {
  let queryData =
    Js.Json.decodeObject(json)
    ->Belt.Option.flatMap(dict => Dict.get(dict, "queryData"))
    ->Belt.Option.flatMap(Js.Json.decodeArray)
    ->Belt.Option.getWithDefault([])

  let data = queryData->Array.reduce(singlestatInitialValue, (finalDict, json) => {
    let dict = json->Js.Json.decodeObject->getWithDefault(Dict.make())
    let product = dict->getString("product_integrated", "")
    if product === "Payment Page Signature" {
      {
        ...finalDict,
        payment_page_signature_count: dict->getInt("merchant_count", 0),
        delta_payment_page_signature_count: dict->getFloat("delta_merchant_count", 0.0),
      }
    } else if product === "Payment Page Session" {
      {
        ...finalDict,
        payment_page_session_count: dict->getInt("merchant_count", 0),
        delta_payment_page_session_count: dict->getFloat("delta_merchant_count", 0.0),
      }
    } else if product === "EC Only" {
      {
        ...finalDict,
        ec_only_count: dict->getInt("merchant_count", 0),
        delta_ec_only_count: dict->getFloat("delta_merchant_count", 0.0),
      }
    } else if product === "EC + SDK" {
      {
        ...finalDict,
        ec_sdk_count: dict->getInt("merchant_count", 0),
        delta_ec_sdk_count: dict->getFloat("delta_merchant_count", 0.0),
      }
    } else {
      finalDict
    }
  })
  data
}

let sortBasedOnTime = (a, b) => {
  let {timeSeries} = a
  let time = timeSeries
  let {timeSeries} = b
  let timeb = timeSeries
  if time < timeb {
    -1
  } else if time > timeb {
    1
  } else {
    0
  }
}

let timeSeriesObjMapper = json => {
  let finalArr = []
  let queryData =
    Js.Json.decodeObject(json)
    ->Belt.Option.flatMap(dict => Dict.get(dict, "queryData"))
    ->Belt.Option.flatMap(Js.Json.decodeArray)
    ->Belt.Option.getWithDefault([])

  let timeSeriesArr =
    queryData
    ->Array.map(item => {
      let dic = item->Js.Json.decodeObject->getWithDefault(Dict.make())
      dic->getString("time_bucket", "")
    })
    ->getUniqueArray
    ->Array.map(item => {
      queryData->Array.filter(ele => {
        let dic = ele->Js.Json.decodeObject->getWithDefault(Dict.make())
        let timeBucket = dic->getString("time_bucket", "")
        item === timeBucket
      })
    })

  timeSeriesArr->Array.forEach(item => {
    let data = item->Array.reduce(singlestatTimeseriesInitialValue, (finalData, item) => {
      let dict = singlestatTimeseriesItemToObjMapper(item)
      {
        payment_page_session_count: finalData.payment_page_session_count +
        dict.payment_page_session_count,
        payment_page_signature_count: finalData.payment_page_signature_count +
        dict.payment_page_signature_count,
        ec_only_count: finalData.ec_only_count + dict.ec_only_count,
        ec_sdk_count: finalData.ec_sdk_count + dict.ec_sdk_count,
        timeSeries: dict.timeSeries,
      }
    })
    finalArr->Array.push(data)->ignore
  })

  finalArr
}

type colT =
  | PaymentPageSessionCount
  | PaymentPageSignatureCount
  | EcOnlyCount
  | EcSdkCount

let defaultColumn: array<DynamicSingleStat.columns<colT>> = [
  {
    sectionName: "",
    columns: [PaymentPageSessionCount, PaymentPageSignatureCount, EcOnlyCount, EcSdkCount],
  },
]

let constructData = (key, singlestatTimeseriesData) => {
  switch key {
  | "ec_only_count" =>
    singlestatTimeseriesData->Array.map(ob => (
      ob.timeSeries->DateTimeUtils.parseAsFloat,
      ob.ec_only_count->Belt.Int.toFloat,
    ))
  | "ec_sdk_count" =>
    singlestatTimeseriesData->Array.map(ob => (
      ob.timeSeries->DateTimeUtils.parseAsFloat,
      ob.ec_sdk_count->Belt.Int.toFloat,
    ))
  | "payment_page_session_count" =>
    singlestatTimeseriesData->Array.map(ob => (
      ob.timeSeries->DateTimeUtils.parseAsFloat,
      ob.payment_page_session_count->Belt.Int.toFloat,
    ))
  | "payment_page_signature_count" =>
    singlestatTimeseriesData->Array.map(ob => (
      ob.timeSeries->DateTimeUtils.parseAsFloat,
      ob.payment_page_signature_count->Belt.Int.toFloat,
    ))
  | _ => []
  }
}

let getStatData = (
  singleStatData: managementSinglestat,
  timeSeriesData,
  deltaTimestampData: DynamicSingleStat.deltaRange,
  colType,
  _mode,
) => {
  let a: DynamicSingleStat.singleStatData = switch colType {
  | PaymentPageSessionCount => {
      title: getLabel("payment_page_session_count"),
      tooltipText: "Number of Payment Page Session integrations",
      deltaTooltipComponent: AnalyticsUtils.singlestatDeltaTooltipFormat(
        singleStatData.delta_payment_page_session_count,
        deltaTimestampData.currentSr,
      ),
      value: singleStatData.payment_page_session_count->Belt.Int.toFloat,
      delta: {
        Js.Float.fromString(
          Js.Float.toFixedWithPrecision(singleStatData.delta_payment_page_session_count, ~digits=2),
        )
      },
      data: constructData("payment_page_session_count", timeSeriesData),
      statType: "Volume",
      showDelta: true,
    }
  | PaymentPageSignatureCount => {
      title: getLabel("payment_page_signature_count"),
      tooltipText: "Number of Payment Page Signature integrations",
      deltaTooltipComponent: AnalyticsUtils.singlestatDeltaTooltipFormat(
        singleStatData.delta_payment_page_signature_count,
        deltaTimestampData.currentSr,
      ),
      value: singleStatData.payment_page_signature_count->Belt.Int.toFloat,
      delta: {
        Js.Float.fromString(
          Js.Float.toFixedWithPrecision(
            singleStatData.delta_payment_page_signature_count,
            ~digits=2,
          ),
        )
      },
      data: constructData("payment_page_signature_count", timeSeriesData),
      statType: "Volume",
      showDelta: true,
    }
  | EcOnlyCount => {
      title: getLabel("ec_only_count"),
      tooltipText: "Number of EC product integrations",
      deltaTooltipComponent: AnalyticsUtils.singlestatDeltaTooltipFormat(
        singleStatData.delta_ec_only_count,
        deltaTimestampData.currentSr,
      ),
      value: singleStatData.ec_only_count->Belt.Int.toFloat,
      delta: {
        Js.Float.fromString(
          Js.Float.toFixedWithPrecision(singleStatData.delta_ec_only_count, ~digits=2),
        )
      },
      data: constructData("ec_only_count", timeSeriesData),
      statType: "Volume",
      showDelta: true,
    }
  | EcSdkCount => {
      title: getLabel("ec_sdk_count"),
      tooltipText: "Number of EC + SDK product integrations",
      deltaTooltipComponent: AnalyticsUtils.singlestatDeltaTooltipFormat(
        singleStatData.delta_ec_sdk_count,
        deltaTimestampData.currentSr,
      ),
      value: singleStatData.ec_sdk_count->Belt.Int.toFloat,
      delta: {
        Js.Float.fromString(
          Js.Float.toFixedWithPrecision(singleStatData.delta_ec_sdk_count, ~digits=2),
        )
      },
      data: constructData("ec_sdk_count", timeSeriesData),
      statType: "Volume",
      showDelta: true,
    }
  }
  a
}

let singleStatBodyMake = (singleStatBodyEntity: DynamicSingleStat.singleStatBodyEntity) => {
  [
    AnalyticsUtils.getFilterRequestBody(
      ~filter=singleStatBodyEntity.filter,
      ~metrics=singleStatBodyEntity.metrics,
      ~delta=?singleStatBodyEntity.delta,
      ~startDateTime=singleStatBodyEntity.startDateTime,
      ~endDateTime=singleStatBodyEntity.endDateTime,
      ~customFilter=?singleStatBodyEntity.customFilter,
      ~granularity=singleStatBodyEntity.granularity,
      ~source="REALTIME",
      ~groupByNames=Some(["product_integrated"]),
      (),
    )->Js.Json.object_,
  ]
  ->Js.Json.array
  ->Js.Json.stringify
}

let singleStatEntity: DynamicSingleStat.entityType<'colType, 't, 't2> = {
  urlConfig: [
    {
      uri: url,
      metrics: ["merchant_count"],
      singleStatBody: singleStatBodyMake,
      singleStatTimeSeriesBody: singleStatBodyMake,
    },
  ],
  getObjects: itemToObjMapper,
  getTimeSeriesObject: timeSeriesObjMapper,
  defaultColumns: defaultColumn,
  getData: getStatData,
  totalVolumeCol: None,
  matrixUriMapper: _ => {
    url
  },
  source: "REALTIME",
}
