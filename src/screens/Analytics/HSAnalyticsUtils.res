let filterFieldsPortalName = "analytics"

let setPrecision = (num, ~digit=2) => {
  num->Float.toFixedWithPrecision(~digits=digit)->Js.Float.fromString
}

let getQueryData = json => {
  open LogicUtils
  json->getDictFromJsonObject->getArrayFromDict("queryData", [])
}

let options: JSON.t => array<EntityType.optionType<'t>> = json => {
  open LogicUtils
  json
  ->getDictFromJsonObject
  ->getOptionalArrayFromDict("queryData")
  ->Option.flatMap(arr => {
    arr
    ->Array.map(dimensionObject => {
      let dimensionObject = dimensionObject->getDictFromJsonObject
      let dimension = getString(dimensionObject, "dimension", "")
      let dimensionTitleCase = `Select ${snakeToTitle(dimension)}`
      let value = getArrayFromDict(dimensionObject, "values", [])->getStrArrayFromJsonArray
      let dropdownOptions: EntityType.optionType<'t> = {
        urlKey: dimension,
        field: {
          FormRenderer.makeFieldInfo(
            ~label="",
            ~name=dimension,
            ~customInput=InputFields.multiSelectInput(
              ~options={
                value
                ->SelectBox.makeOptions
                ->Array.map(
                  item => {
                    let value = {...item, label: item.value}
                    value
                  },
                )
              },
              ~buttonText=dimensionTitleCase,
              ~showSelectionAsChips=false,
              ~searchable=true,
              ~showToolTip=true,
              ~showNameAsToolTip=true,
              ~customButtonStyle="bg-none",
            ),
          )
        },
        parser: val => val,
        localFilter: None,
      }
      dropdownOptions
    })
    ->Some
  })
  ->Option.getOr([])
}

let filterByData = (txnArr, value) => {
  let searchText = LogicUtils.getStringFromJson(value, "")

  txnArr
  ->Belt.Array.keepMap(Nullable.toOption)
  ->Belt.Array.keepMap((data: 't) => {
    let valueArr =
      data
      ->Identity.genericTypeToDictOfJson
      ->Dict.toArray
      ->Array.map(item => {
        let (_, value) = item

        value->JSON.Decode.string->Option.getOr("")->String.toLowerCase->String.includes(searchText)
      })
      ->Array.reduce(false, (acc, item) => item || acc)
    if valueArr {
      data->Nullable.make->Some
    } else {
      None
    }
  })
}

let initialFilterFields = (json, ~isTitle=false) => {
  open LogicUtils

  let dropdownValue =
    json
    ->getDictFromJsonObject
    ->getOptionalArrayFromDict("queryData")
    ->Option.flatMap(arr => {
      arr
      ->Belt.Array.keepMap(item => {
        let dimensionObject = item->getDictFromJsonObject

        let dimensionValue = getString(dimensionObject, "dimension", "")
        // TODO: Add support for custom labels. This can be achieved either through backend support (by making dimension an array of objects) or frontend support (via a custom label field).
        let dimensionLabel = switch dimensionValue {
        | "acs_reference_number" => "issuer"
        | _ => dimensionValue
        }
        let dimensionTitleCase = `Select ${snakeToTitle(dimensionLabel)}`
        let value = getArrayFromDict(dimensionObject, "values", [])->getStrArrayFromJsonArray

        Some(
          (
            {
              field: FormRenderer.makeFieldInfo(
                ~label=dimensionLabel,
                ~name=dimensionValue,
                ~customInput=InputFields.filterMultiSelectInput(
                  ~options=value->FilterSelectBox.makeOptions(~isTitle),
                  ~buttonText=dimensionTitleCase,
                  ~showSelectionAsChips=false,
                  ~searchable=true,
                  ~showToolTip=true,
                  ~showNameAsToolTip=true,
                  ~customButtonStyle="bg-none",
                  (),
                ),
              ),
              localFilter: Some(filterByData),
            }: EntityType.initialFilters<'t>
          ),
        )
      })
      ->Some
    })
    ->Option.getOr([])

  dropdownValue
}

let (startTimeFilterKey, endTimeFilterKey, optFilterKey) = ("startTime", "endTime", "opt")

let initialFixedFilterFields = (_json, ~events=?) => {
  let events = switch events {
  | Some(fn) => fn
  | None => _ => ()
  }

  let newArr = [
    (
      {
        localFilter: None,
        field: FormRenderer.makeMultiInputFieldInfo(
          ~label="",
          ~comboCustomInput=InputFields.filterDateRangeField(
            ~startKey=startTimeFilterKey,
            ~endKey=endTimeFilterKey,
            ~format="YYYY-MM-DDTHH:mm:ss[Z]",
            ~showTime=true,
            ~disablePastDates={false},
            ~disableFutureDates={true},
            ~predefinedDays=[
              Hour(0.5),
              Hour(1.0),
              Hour(2.0),
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
            ~dateRangeLimit=180,
            ~optFieldKey=optFilterKey,
            ~events,
          ),
          ~inputFields=[],
          ~isRequired=false,
        ),
      }: EntityType.initialFilters<'t>
    ),
  ]

  newArr
}

let getStringListFromArrayDict = metrics => {
  open LogicUtils
  metrics->Array.map(item => item->getDictFromJsonObject->getString("name", ""))
}

module NoData = {
  @react.component
  let make = (~title) => {
    <div className="p-5">
      <PageUtils.PageHeading title />
      <NoDataFound message="No Data Available" renderType=Painting>
        <Button
          text={"Make a Payment"}
          buttonSize={Small}
          onClick={_ => RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url="/home"))}
          buttonType={Primary}
        />
      </NoDataFound>
    </div>
  }
}

let generateTablePayload = (
  ~startTimeFromUrl: string,
  ~endTimeFromUrl: string,
  ~filterValueFromUrl: option<JSON.t>,
  ~currenltySelectedTab: option<array<string>>,
  ~tableMetrics: array<string>,
  ~distributionArray: option<array<JSON.t>>,
  ~deltaMetrics: array<string>,
  ~deltaPrefixArr: array<string>,
  ~isIndustry: bool,
  ~mode: option<string>,
  ~customFilter,
  ~showDeltaMetrics,
  ~moduleName as _,
  ~source: string="BATCH",
  (),
) => {
  open AnalyticsUtils
  let metrics = tableMetrics
  let startTime = startTimeFromUrl
  let endTime = endTimeFromUrl

  let deltaDateArr =
    {deltaMetrics->Array.length === 0}
      ? []
      : generateDateArray(~startTime, ~endTime, ~deltaPrefixArr)

  let deltaPayload = generatedeltaTablePayload(
    ~deltaDateArr,
    ~metrics=deltaMetrics,
    ~groupByNames=currenltySelectedTab,
    ~source,
    ~mode,
    ~deltaPrefixArr,
    ~filters=filterValueFromUrl,
    ~customFilter,
    ~showDeltaMetrics,
  )

  let tableBodyWithNonDeltaMetrix = if metrics->Array.length > 0 {
    [
      getFilterRequestBody(
        ~groupByNames=currenltySelectedTab,
        ~filter=filterValueFromUrl,
        ~metrics=Some(metrics),
        ~delta=showDeltaMetrics,
        ~mode,
        ~startDateTime=startTime,
        ~endDateTime=endTime,
        ~customFilter,
        ~source,
      ),
    ]
  } else {
    []
  }

  let tableBodyWithDeltaMetrix = if deltaMetrics->Array.length > 0 {
    switch distributionArray {
    | Some(distributionArray) =>
      distributionArray->Array.map(arr =>
        getFilterRequestBody(
          ~groupByNames=currenltySelectedTab,
          ~filter=filterValueFromUrl,
          ~metrics=Some(deltaMetrics),
          ~delta=showDeltaMetrics,
          ~mode,
          ~startDateTime=startTime,
          ~distributionValues=Some(arr),
          ~endDateTime=endTime,
          ~customFilter,
          ~source,
        )
      )
    | None => [
        getFilterRequestBody(
          ~groupByNames=currenltySelectedTab,
          ~filter=filterValueFromUrl,
          ~metrics=Some(deltaMetrics),
          ~delta=showDeltaMetrics,
          ~mode,
          ~startDateTime=startTime,
          ~endDateTime=endTime,
          ~customFilter,
          ~source,
        ),
      ]
    }
  } else {
    []
  }

  let tableIndustryPayload = if isIndustry {
    [
      getFilterRequestBody(
        ~groupByNames=currenltySelectedTab,
        ~filter=filterValueFromUrl,
        ~metrics=Some(deltaMetrics),
        ~delta=showDeltaMetrics,
        ~mode,
        ~prefix=Some("industry"),
        ~startDateTime=startTime,
        ~endDateTime=endTime,
        ~customFilter,
        ~source,
      ),
    ]
  } else {
    []
  }
  let tableBodyValues =
    tableBodyWithNonDeltaMetrix->Array.concatMany([tableBodyWithDeltaMetrix, tableIndustryPayload])

  let tableBody =
    tableBodyValues->Array.concat(deltaPayload)->Array.map(JSON.Encode.object)->JSON.Encode.array
  tableBody
}
