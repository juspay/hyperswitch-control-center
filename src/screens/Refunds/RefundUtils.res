type filterTypes = {
  connector: array<string>,
  currency: array<string>,
  status: array<string>,
  connector_label: array<string>,
}

type filter = [
  | #connector
  | #currency
  | #status
  | #connector_label
  | #unknown
]

let getFilterTypeFromString = filterType => {
  switch filterType {
  | "connector" => #connector
  | "currency" => #currency
  | "connector_label" => #connector_label
  | "refund_status" => #status
  | _ => #unknown
  }
}

let getRefundsList = async (
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
  ~setRefundsData,
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
    let refundsUrl = getURL(~entityName=REFUNDS, ~methodType=Post, ~id=Some("refund-post"), ())
    let res = await updateDetails(refundsUrl, filterValueJson->JSON.Encode.object, Fetch.Post, ())
    let data = res->getDictFromJsonObject->getArrayFromDict("data", [])
    let total = res->getDictFromJsonObject->getInt("total_count", 0)

    let arr = Array.make(~length=offset, Dict.make())
    if total <= offset {
      setOffset(_ => 0)
    }

    if total > 0 {
      let refundDataDictArr = data->Belt.Array.keepMap(JSON.Decode.object)
      let refundData = arr->Array.concat(refundDataDictArr)->Array.map(RefundEntity.itemToObjMapper)
      let list = refundData->Array.map(Nullable.make)
      setRefundsData(_ => list)
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
    infoText="No refund records as of now. Try initiating a refund for a successful payment."
    buttonText="Take me to payments"
    onClickUrl="payments"
    moduleName=""
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

let getConditionalFilter = (key, dict, filterValues) => {
  open LogicUtils

  let filtersArr = switch key->getFilterTypeFromString {
  | #connector_label => {
      let arr = filterValues->getArrayFromDict("connector", [])->getStrArrayFromJsonArray
      let newArr = arr->Array.flatMap(connector => {
        let connectorLabelArr = dict->getDictfromDict("connector")->getArrayFromDict(connector, [])
        connectorLabelArr->Array.map(item => {
          item->getDictFromJsonObject->getString("connector_label", "")
        })
      })
      newArr
    }
  | _ => []
  }

  filtersArr
}

let getOptionsForRefundFilters = (dict, filterValues) => {
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

let itemToObjMapper = dict => {
  open LogicUtils
  {
    connector: dict->getDictfromDict("connector")->Dict.keysToArray,
    currency: dict->getArrayFromDict("currency", [])->getStrArrayFromJsonArray,
    status: dict->getArrayFromDict("refund_status", [])->getStrArrayFromJsonArray,
    connector_label: [],
  }
}

let initialFilters = (json, filtervalues) => {
  open LogicUtils

  let connectorFilter = filtervalues->getArrayFromDict("connector", [])->getStrArrayFromJsonArray

  let filterDict = json->getDictFromJsonObject
  let arr = filterDict->Dict.keysToArray->Array.filterWithIndex((_item, index) => index <= 2)

  if connectorFilter->Array.length !== 0 {
    arr->Array.push("connector_label")
  }

  let filterArr = filterDict->itemToObjMapper

  arr->Array.map((key): EntityType.initialFilters<'t> => {
    let title = `Select ${key->snakeToTitle}`

    let values = switch key->getFilterTypeFromString {
    | #connector => filterArr.connector
    | #currency => filterArr.currency
    | #status => filterArr.status
    | #connector_label => getConditionalFilter(key, filterDict, filtervalues)
    | _ => []
    }

    let options = switch key->getFilterTypeFromString {
    | #connector_label => getOptionsForRefundFilters(filterDict, filtervalues)
    | _ => values->FilterSelectBox.makeOptions
    }

    let name = switch key->getFilterTypeFromString {
    | #connector_label => "merchant_connector_id"
    | _ => key
    }

    {
      field: FormRenderer.makeFieldInfo(
        ~label=key,
        ~name,
        ~customInput=InputFields.filterMultiSelectInput(
          ~options,
          ~buttonText=title,
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
    }
  })
}
