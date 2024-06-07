let getPayoutsList = async (
  filterValueJson,
  ~updateDetails: (
    string,
    JSON.t,
    Fetch.requestMethod,
    ~bodyFormData: Fetch.formData=?,
    ~headers: Dict.t<'a>=?,
    ~contentType: AuthHooks.contentType=?,
    unit,
  ) => promise<JSON.t>,
  ~setPayoutsData,
  ~setScreenState,
  ~offset,
  ~setTotalCount,
  ~setOffset,
  ~getURL: (
    ~entityName: APIUtilsTypes.entityName,
    ~methodType: Fetch.requestMethod,
    ~id: option<string>=?,
    ~connector: option<'a>=?,
    ~userType: APIUtilsTypes.userType=?,
    ~userRoleTypes: APIUtilsTypes.userRoleTypes=?,
    ~reconType: APIUtilsTypes.reconType=?,
    ~queryParamerters: option<string>=?,
    unit,
  ) => string,
) => {
  open LogicUtils

  setScreenState(_ => PageLoaderWrapper.Loading)
  try {
    let payoutsUrl = getURL(~entityName=PAYOUTS, ~methodType=Post, ())
    let res = await updateDetails(payoutsUrl, filterValueJson->JSON.Encode.object, Fetch.Post, ())
    let data = res->getDictFromJsonObject->getArrayFromDict("data", [])
    let total = res->getDictFromJsonObject->getInt("size", 0)

    let arr = Array.make(~length=offset, Dict.make())
    if total <= offset {
      setOffset(_ => 0)
    }

    if total > 0 {
      let payoutDataDictArr = data->Belt.Array.keepMap(JSON.Decode.object)
      let payoutData =
        arr->Array.concat(payoutDataDictArr)->Array.map(PayoutsEntity.itemToObjMapper)
      let list = payoutData->Array.map(Nullable.make)
      setPayoutsData(_ => list)
      setTotalCount(_ => total)
      setScreenState(_ => PageLoaderWrapper.Success)
    } else {
      setScreenState(_ => Custom)
    }
  } catch {
  | _ => setScreenState(_ => Error("Failed to fetch"))
  }
}

let customUI =
  <HelperComponents.BluredTableComponent
    infoText="No payout records as of now. Try initiating a payout."
    moduleName=""
    showRedirectCTA=false
  />

let (startTimeFilterKey, endTimeFilterKey) = ("start_time", "end_time")

let filterByData = (txnArr, value) => {
  open LogicUtils
  let searchText = value->getStringFromJson("")

  txnArr
  ->Belt.Array.keepMap(Nullable.toOption)
  ->Belt.Array.keepMap(data => {
    let valueArr =
      data
      ->Identity.genericTypeToDictOfJson
      ->Dict.toArray
      ->Array.map(item => {
        let (_, value) = item

        value->getStringFromJson("")->String.toLowerCase->String.includes(searchText)
      })
      ->Array.reduce(false, (acc, item) => item || acc)

    valueArr ? data->Nullable.make->Some : None
  })
}

let initialFixedFilter = () => [
  (
    {
      localFilter: None,
      field: FormRenderer.makeMultiInputFieldInfo(
        ~label="",
        ~comboCustomInput=InputFields.filterDateRangeField(
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
          (),
        ),
        ~inputFields=[],
        ~isRequired=false,
        (),
      ),
    }: EntityType.initialFilters<'t>
  ),
]

let getOptionsForPayoutFilters = (dict, filterValues) => {
  open LogicUtils
  let arr = filterValues->getArrayFromDict("connector", [])->getStrArrayFromJsonArray
  let newArr = arr->Array.flatMap(connector => {
    let connectorLabelArr = dict->getDictfromDict("connector")->getArrayFromDict(connector, [])
    connectorLabelArr->Array.map(item => {
      let label = item->getDictFromJsonObject->getString("connector_label", "")
      let value = item->getDictFromJsonObject->getString("merchant_connector_id", "")
      let option: FilterSelectBox.dropdownOption = {
        label,
        value,
      }
      option
    })
  })
  newArr
}

let initialFilters = (json, _) => {
  open LogicUtils

  let dropdownValue =
    json
    ->getDictFromJsonObject
    ->Dict.toArray
    ->Array.map(item => {
      let (key, value) = item

      (
        {
          field: FormRenderer.makeFieldInfo(
            ~label="",
            ~name=key,
            ~customInput=InputFields.filterMultiSelectInput(
              ~options=value
              ->JSON.Decode.array
              ->Option.getOr([])
              ->Array.map(item => item->JSON.Decode.string->Option.getOr(""))
              ->FilterSelectBox.makeOptions,
              ~buttonText=`Select ${key}`,
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
      )
    })

  dropdownValue
}
