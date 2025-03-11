type filterTypes = {
  connector: array<string>,
  currency: array<string>,
  status: array<string>,
  connector_label: array<string>,
  amount: array<string>,
}

type filter = [
  | #connector
  | #currency
  | #status
  | #connector_label
  | #amount
  | #unknown
]

let getFilterTypeFromString = filterType => {
  switch filterType {
  | "connector" => #connector
  | "currency" => #currency
  | "connector_label" => #connector_label
  | "refund_status" => #status
  | "amount" => #amount
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
    ~version: UserInfoTypes.version=?,
  ) => promise<JSON.t>,
  ~setRefundsData,
  ~setScreenState,
  ~offset,
  ~setTotalCount,
  ~setOffset,
  ~getURL: APIUtilsTypes.getUrlTypes,
) => {
  open LogicUtils

  setScreenState(_ => PageLoaderWrapper.Loading)
  try {
    let refundsUrl = getURL(~entityName=V1(REFUNDS), ~methodType=Post, ~id=Some("refund-post"))
    let res = await updateDetails(refundsUrl, filterValueJson->JSON.Encode.object, Post)
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

    valueArr ? Some(data->Nullable.make) : None
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
        ),
        ~inputFields=[],
        ~isRequired=false,
      ),
    }: EntityType.initialFilters<'t>
  ),
]

let getLabelFromFilterType = (filter: filter) => (filter :> string)

let getValueFromFilterType = (filter: filter) => {
  switch filter {
  | #connector_label => "merchant_connector_id"
  | #status => "refund_status"
  | _ => (filter :> string)
  }
}

let getConditionalFilter = (key, dict, filterValues) => {
  open LogicUtils

  let filtersArr = switch key->getFilterTypeFromString {
  | #connector_label =>
    filterValues
    ->getArrayFromDict("connector", [])
    ->getStrArrayFromJsonArray
    ->Array.flatMap(connector => {
      dict
      ->getDictfromDict("connector")
      ->getArrayFromDict(connector, [])
      ->Array.map(item => {
        item->getDictFromJsonObject->getString("connector_label", "")
      })
    })
  | _ => []
  }

  filtersArr
}

let getOptionsForRefundFilters = (dict, filterValues) => {
  open LogicUtils
  filterValues
  ->getArrayFromDict("connector", [])
  ->getStrArrayFromJsonArray
  ->Array.flatMap(connector => {
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
}

let itemToObjMapper = dict => {
  open LogicUtils
  {
    connector: dict->getDictfromDict("connector")->Dict.keysToArray,
    currency: dict->getArrayFromDict("currency", [])->getStrArrayFromJsonArray,
    status: dict->getArrayFromDict("refund_status", [])->getStrArrayFromJsonArray,
    connector_label: [],
    amount: [],
  }
}

let initialFilters = (json, filtervalues, _, _, _) => {
  open LogicUtils

  let filterDict = json->getDictFromJsonObject
  let filtersArray =
    filterDict->Dict.keysToArray->Array.filterWithIndex((_item, index) => index <= 2)
  let filterData = filterDict->itemToObjMapper

  let connectorFilter = filtervalues->getArrayFromDict("connector", [])->getStrArrayFromJsonArray
  if connectorFilter->Array.length !== 0 {
    filtersArray->Array.push(#connector_label->getLabelFromFilterType)
  }
  let additionalFilters = [#amount]->Array.map(getLabelFromFilterType)
  let allFiltersArray = filtersArray->Array.concat(additionalFilters)
  allFiltersArray->Array.map((key): EntityType.initialFilters<'t> => {
    let title = `Select ${key->snakeToTitle}`

    let values = switch key->getFilterTypeFromString {
    | #connector => filterData.connector
    | #currency => filterData.currency
    | #status => filterData.status
    | #connector_label => getConditionalFilter(key, filterDict, filtervalues)
    | _ => []
    }

    let options = switch key->getFilterTypeFromString {
    | #connector_label => getOptionsForRefundFilters(filterDict, filtervalues)
    | _ => values->FilterSelectBox.makeOptions
    }
    let customInput = switch key->getFilterTypeFromString {
    | #amount =>
      (~input as _, ~placeholder as _) => {
        <AmountFilter options=AmountFilterUtils.amountFilterOptions />
      }
    | _ =>
      InputFields.filterMultiSelectInput(
        ~options,
        ~buttonText=title,
        ~showSelectionAsChips=false,
        ~searchable=true,
        ~showToolTip=true,
        ~showNameAsToolTip=true,
        ~customButtonStyle="bg-none",
        (),
      )
    }
    {
      field: FormRenderer.makeFieldInfo(
        ~label=key,
        ~name=getValueFromFilterType(key->getFilterTypeFromString),
        ~customInput,
      ),
      localFilter: Some(filterByData),
    }
  })
}
