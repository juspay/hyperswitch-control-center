@val @scope(("window", "location")) external hostname: string = "hostname"

let filterFieldsPortalName = "analytics"

let setPrecision = (num, ~digit=2, ()) => {
  num->Js.Float.toFixedWithPrecision(~digits=digit)->Js.Float.fromString
}

let getQueryData = json => {
  open LogicUtils
  json->getDictFromJsonObject->getArrayFromDict("queryData", [])
}

let options: Js.Json.t => array<EntityType.optionType<'t>> = json => {
  open LogicUtils
  json
  ->getDictFromJsonObject
  ->getOptionalArrayFromDict("queryData")
  ->Belt.Option.flatMap(arr => {
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
              (),
            ),
            (),
          )
        },
        parser: val => val,
        localFilter: None,
      }
      dropdownOptions
    })
    ->Some
  })
  ->Belt.Option.getWithDefault([])
}

let filterByData = (txnArr, value) => {
  let searchText = LogicUtils.getStringFromJson(value, "")

  txnArr
  ->Belt.Array.keepMap(Js.Nullable.toOption)
  ->Belt.Array.keepMap((data: 't) => {
    let valueArr =
      data
      ->Identity.genericTypeToDictOfJson
      ->Dict.toArray
      ->Array.map(item => {
        let (_, value) = item

        value
        ->Js.Json.decodeString
        ->Belt.Option.getWithDefault("")
        ->String.toLowerCase
        ->String.includes(searchText)
      })
      ->Array.reduce(false, (acc, item) => item || acc)
    if valueArr {
      data->Js.Nullable.return->Some
    } else {
      None
    }
  })
}

let initialFilterFields = json => {
  open LogicUtils

  let dropdownValue =
    json
    ->getDictFromJsonObject
    ->getOptionalArrayFromDict("queryData")
    ->Belt.Option.flatMap(arr => {
      arr
      ->Belt.Array.keepMap(item => {
        let dimensionObject = item->getDictFromJsonObject

        let dimension = getString(dimensionObject, "dimension", "")
        let dimensionTitleCase = `Select ${snakeToTitle(dimension)}`
        let value = getArrayFromDict(dimensionObject, "values", [])->getStrArrayFromJsonArray

        Some(
          (
            {
              field: FormRenderer.makeFieldInfo(
                ~label="",
                ~name=dimension,
                ~customInput=InputFields.multiSelectInput(
                  ~options=value->SelectBox.makeOptions,
                  ~buttonText=dimensionTitleCase,
                  ~showSelectionAsChips=false,
                  ~searchable=true,
                  ~showToolTip=true,
                  ~showNameAsToolTip=true,
                  ~customButtonStyle="bg-none",
                  (),
                ),
                (),
              ),
              localFilter: Some(filterByData),
            }: EntityType.initialFilters<'t>
          ),
        )
      })
      ->Some
    })
    ->Belt.Option.getWithDefault([])

  dropdownValue
}
let (startTimeFilterKey, endTimeFilterKey, optFilterKey) = ("startTime", "endTime", "opt")

let initialFixedFilterFields = _json => {
  let newArr = [
    (
      {
        localFilter: None,
        field: FormRenderer.makeMultiInputFieldInfo(
          ~label="",
          ~comboCustomInput=InputFields.dateRangeField(
            ~startKey=startTimeFilterKey,
            ~endKey=endTimeFilterKey,
            ~format="YYYY-MM-DDTHH:mm:ss[Z]",
            ~showTime=false,
            ~disablePastDates={false},
            ~disableFutureDates={true},
            ~predefinedDays=[Today, Yesterday, Day(2.0), Day(7.0), Day(30.0), ThisMonth, LastMonth],
            ~numMonths=2,
            ~disableApply=false,
            ~dateRangeLimit=180,
            ~optFieldKey=optFilterKey,
            (),
          ),
          ~inputFields=[],
          ~isRequired=false,
          (),
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
  let make = (~title, ~subTitle) => {
    <div className="p-5">
      <PageUtils.PageHeading title subTitle />
      <NoDataFound message="No Data Available" renderType=Painting>
        <Button
          text={"Make a Payment"}
          buttonSize={Small}
          onClick={_ => RescriptReactRouter.push("/home")}
          buttonType=Secondary
          customButtonStyle={`!bg-blue-800 mt-3`}
          textStyle={`!text-white`}
        />
      </NoDataFound>
    </div>
  }
}

let generateTablePayload = (
  ~startTimeFromUrl: string,
  ~endTimeFromUrl: string,
  ~filterValueFromUrl: option<Js.Json.t>,
  ~currenltySelectedTab: option<array<string>>,
  ~tableMetrics: array<string>,
  ~distributionArray: option<array<Js.Json.t>>,
  ~deltaMetrics: array<string>,
  ~deltaPrefixArr: array<string>,
  ~isIndustry: bool,
  ~mode: option<string>,
  ~customFilter,
  ~showDeltaMetrics,
  ~moduleName as _: string,
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
        (),
      ),
    ]
  } else {
    []
  }

  let tableBodyWithDeltaMetrix = if deltaMetrics->Array.length > 0 {
    switch distributionArray {
    | Some(distributionArray) =>
      distributionArray->Belt.Array.map(arr =>
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
          (),
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
          (),
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
        (),
      ),
    ]
  } else {
    []
  }
  let tableBodyValues = Belt.Array.concatMany([
    tableBodyWithNonDeltaMetrix,
    tableBodyWithDeltaMetrix,
    tableIndustryPayload,
  ])

  let tableBody =
    Belt.Array.concatMany([tableBodyValues, deltaPayload])
    ->Belt.Array.map(Js.Json.object_)
    ->Js.Json.array
  tableBody
}
