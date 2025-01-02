let getPayoutsList = async (
  filterValueJson,
  ~updateDetails: (
    string,
    JSON.t,
    Fetch.requestMethod,
    ~bodyFormData: Fetch.formData=?,
    ~headers: Dict.t<'a>=?,
    ~contentType: AuthHooks.contentType=?,
  ) => promise<JSON.t>,
  ~setPayoutsData,
  ~setScreenState,
  ~offset,
  ~setTotalCount,
  ~setOffset,
  ~getURL: APIUtilsTypes.getUrlTypes,
) => {
  open LogicUtils

  setScreenState(_ => PageLoaderWrapper.Loading)
  try {
    let payoutsUrl = getURL(~entityName=PAYOUTS, ~methodType=Post)
    let res = await updateDetails(payoutsUrl, filterValueJson->JSON.Encode.object, Post)
    let data = res->getDictFromJsonObject->getArrayFromDict("data", [])
    let total = res->getDictFromJsonObject->getInt("total_count", 0)

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

let customUI = () => {
  open LogicUtils
  let {filterValueJson, updateExistingKeys} = React.useContext(FilterContext.filterContext)
  let startTime = filterValueJson->getString("start_time", "")

  let handleClick = _ => {
    let startDateObj = startTime->DayJs.getDayJsForString
    let extendedStartDate = startDateObj.subtract(90, "day").toDate()->Date.toISOString
    updateExistingKeys(Dict.fromArray([("start_time", {extendedStartDate})]))
    let extendedEndDate = startDateObj.subtract(1, "day").toDate()->Date.toISOString
    updateExistingKeys(Dict.fromArray([("end_time", {extendedEndDate})]))
  }
  <NoDataFound
    customCssClass={"my-6 "}
    message="No results found"
    renderType={ExtendDateWithNoResult}
    customMessageCss="">
    <ACLButton
      buttonType={Primary}
      onClick={handleClick}
      text="Expand the search range to include the past 90 days."
    />
    <div className="flex justify-center">
      <p className="mt-6">
        {React.string("Or try the following:")}
        <ul className="list-disc">
          <li> {React.string("Try a different search parameter")} </li>
          <li> {React.string("Adjust or remove filters and search once more")} </li>
        </ul>
      </p>
    </div>
  </NoDataFound>
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

let initialFilters = (json, _, _, _, _) => {
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
          ),
          localFilter: Some(filterByData),
        }: EntityType.initialFilters<'t>
      )
    })

  dropdownValue
}
