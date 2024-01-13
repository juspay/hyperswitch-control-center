let getRefundsList = async (
  filterValueJson,
  ~updateDetails,
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
    let res = await updateDetails(refundsUrl, filterValueJson->Js.Json.object_, Fetch.Post)
    let data = res->getDictFromJsonObject->getArrayFromDict("data", [])
    let total = res->getDictFromJsonObject->getInt("total_count", 0)

    let arr = Belt.Array.make(offset, Dict.make())
    if total <= offset {
      setOffset(_ => 0)
    }

    if total > 0 {
      let refundDataDictArr = data->Belt.Array.keepMap(Js.Json.decodeObject)
      let refundData = arr->Array.concat(refundDataDictArr)->Array.map(RefundEntity.itemToObjMapper)
      let list = refundData->Array.map(Js.Nullable.return)
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
  ->Belt.Array.keepMap(Js.Nullable.toOption)
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

    valueArr ? data->Js.Nullable.return->Some : None
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

let initialFilters = json => {
  open LogicUtils
  let filterDict = json->getDictFromJsonObject

  filterDict
  ->Dict.keysToArray
  ->Array.filterWithIndex((_item, index) => index <= 2)
  ->Array.map((key): EntityType.initialFilters<'t> => {
    let title = `Select ${key->snakeToTitle}`
    let values = filterDict->getArrayFromDict(key, [])->getStrArrayFromJsonArray

    {
      field: FormRenderer.makeFieldInfo(
        ~label="",
        ~name=key,
        ~customInput=InputFields.multiSelectInput(
          ~options=values->SelectBox.makeOptions,
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
