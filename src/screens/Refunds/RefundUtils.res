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
  | "status" => #status
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
) => {
  open APIUtils
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
      let new_arr = []
      let _ = arr->Array.map(item => {
        let connectorLabelArr = dict->getDictfromDict("connector")->getArrayFromDict(item, [])
        let _ = connectorLabelArr->Array.map(item => {
          let a = item->getDictFromJsonObject->getString("connector_label", "")
          new_arr->Array.push(a)
          new_arr
        })
      })
      new_arr
    }
  | _ => []
  }

  filtersArr
}

let getMerchantIdforConnector: (Js.Dict.t<'a>, Js.Dict.t<'a>) => array<SelectBox.dropdownOption> = (
  dict,
  filterValues,
) => {
  open LogicUtils
  let arr = filterValues->getArrayFromDict("connector", [])->getStrArrayFromJsonArray
  let new_arr: array<SelectBox.dropdownOption> = []
  let _ = arr->Array.map(item => {
    let connectorLabelArr = dict->getDictfromDict("connector")->getArrayFromDict(item, [])
    let _ = connectorLabelArr->Array.map(item => {
      let a = item->getDictFromJsonObject->getString("connector_label", "")
      let b = item->getDictFromJsonObject->getString("merchant_connector_id", "")
      let ops: SelectBox.dropdownOption = {
        label: a,
        value: b,
      }
      new_arr->Array.push(ops)
    })
  })

  new_arr
}

let itemToObjMapper = dict => {
  open LogicUtils
  {
    connector: dict->getDictfromDict("connector")->Dict.keysToArray,
    currency: dict->getArrayFromDict("currency", [])->getStrArrayFromJsonArray,
    status: dict->getArrayFromDict("status", [])->getStrArrayFromJsonArray,
    connector_label: [],
  }
}

let initialFilters = (json, filtervalues) => {
  open LogicUtils

  let connectorFilter = React.useMemo1(() => {
    filtervalues->getArrayFromDict("connector", [])->getStrArrayFromJsonArray
  }, [filtervalues])

  let filterDict = json->getDictFromJsonObject
  let filterArr = filterDict->itemToObjMapper

  let a = filterDict->Dict.keysToArray
  let b = a->Array.filterWithIndex((_item, index) => index <= 2)

  if connectorFilter->Array.length !== 0 {
    b->Array.push("connector_label")
  }

  b->Array.map((key): EntityType.initialFilters<'t> => {
    let title = `Select ${key->snakeToTitle}`

    let values = switch key->getFilterTypeFromString {
    | #connector => filterArr.connector
    | #currency => filterArr.currency
    | #status => filterArr.status
    | #connector_label => getConditionalFilter(key, filterDict, filtervalues)
    | _ => []
    }

    let options = switch key->getFilterTypeFromString {
    | #connector_label => getMerchantIdforConnector(filterDict, filtervalues)
    | _ => values->SelectBox.makeOptions
    }

    let name = switch key->getFilterTypeFromString {
    | #connector_label => "merchant_connector_id"
    | _ => key
    }

    {
      field: FormRenderer.makeFieldInfo(
        ~label="",
        ~name,
        ~customInput=InputFields.multiSelectInput(
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
