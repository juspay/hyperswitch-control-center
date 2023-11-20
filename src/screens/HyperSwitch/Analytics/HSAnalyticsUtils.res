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
    ->Js.Array2.map(dimensionObject => {
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
                ->Js.Array2.map(
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

external toDict: 't => Js.Dict.t<Js.Json.t> = "%identity"
let filterByData = (txnArr, value) => {
  let searchText = LogicUtils.getStringFromJson(value, "")

  txnArr
  ->Belt.Array.keepMap(Js.Nullable.toOption)
  ->Belt.Array.keepMap((data: 't) => {
    let valueArr =
      data
      ->toDict
      ->Js.Dict.entries
      ->Js.Array2.map(item => {
        let (_, value) = item

        value
        ->Js.Json.decodeString
        ->Belt.Option.getWithDefault("")
        ->Js.String2.toLowerCase
        ->Js.String2.includes(searchText)
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
  ]

  newArr
}

let getStringListFromArrayDict = metrics => {
  open LogicUtils
  metrics->Js.Array2.map(item => item->getDictFromJsonObject->getString("name", ""))
}

let getCustomFormattedFloatDate = (floatDate, format) => {
  floatDate->Js.Date.fromFloat->Js.Date.toISOString->Table.dateFormat(format)
}

module NoData = {
  @react.component
  let make = () => {
    <div className="p-5">
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
