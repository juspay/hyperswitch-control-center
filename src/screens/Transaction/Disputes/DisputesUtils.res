open DisputeTypes
open LogicUtils
let disputeStatusVariantMapper = status => {
  switch status {
  | "dispute_opened" => DisputeOpened
  | "dispute_expired" => DisputeExpired
  | "dispute_accepted" => DisputeAccepted
  | "dispute_cancelled" => DisputeCancelled
  | "dispute_challenged" => DisputeChallenged
  | "dispute_won" => DisputeWon
  | "dispute_lost" => DisputeLost
  | _ => NotFound(status)
  }
}

let showDisputeInfoStatus = [DisputeOpened, DisputeAccepted, DisputeChallenged]
let evidenceList = [
  "Receipt",
  "Refund Policy",
  "Uncategorized File",
  "Customer Signature",
  "Service Documentation",
  "Customer Communication",
  "Shipping Documentation",
  "Recurring Transaction Agreement",
  "Invoice Showing Distinct Transactions",
]

let getDictFromFilesAvailable = arrayValue => {
  let manipulatedDict = Dict.make()
  arrayValue->Array.forEach(val => {
    let dictFromJson = val->getDictFromJsonObject
    let evidenceTypekey = dictFromJson->getString("evidence_type", "")
    let filemetadata = dictFromJson->getDictfromDict("file_metadata_response")
    let file_id = filemetadata->getString("file_id", "")
    let file_name = filemetadata->getString("file_name", "")

    let fileVal =
      [
        ("fileId", file_id->JSON.Encode.string),
        ("fileName", file_name->JSON.Encode.string),
      ]->getJsonFromArrayOfJson

    manipulatedDict->Dict.set(evidenceTypekey, fileVal)
  })
  manipulatedDict
}

let constructDisputesBody = (dict, disputesId) => {
  let body = Dict.make()
  dict
  ->Dict.keysToArray
  ->Array.forEach(value => {
    let fileID = dict->LogicUtils.getDictfromDict(value)->LogicUtils.getString("fileId", "")
    if fileID->String.length > 0 {
      body->Dict.set(value, fileID->JSON.Encode.string)
    }
  })
  body->Dict.set("dispute_id", disputesId->JSON.Encode.string)
  body
}

let getFileTypeFromFileName = fileName => {
  let lastIndex = fileName->String.lastIndexOf(".")
  let afterDotFileType = fileName->String.substringToEnd(~start=lastIndex + 1)
  afterDotFileType
}

let (startTimeFilterKey, endTimeFilterKey) = ("start_time", "end_time")

let getFilterTypeFromString = filterType => {
  switch filterType {
  | "connector" => #connector
  | "currency" => #currency
  | "connector_label" => #connector_label
  | "dispute_status" => #dispute_status
  | "dispute_stage" => #dispute_stage
  | _ => #unknown
  }
}

let filterByData = (txnArr, value) => {
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
  | _ => (filter :> string)
  }
}

let getConditionalFilter = (key, dict, filterValues) => {
  switch key->getFilterTypeFromString {
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
}

let getOptionsForDisputeFilters = (dict, filterValues) => {
  filterValues
  ->getArrayFromDict("connector", [])
  ->getStrArrayFromJsonArray
  ->Array.flatMap(connector => {
    dict
    ->getDictfromDict("connector")
    ->getArrayFromDict(connector, [])
    ->Array.map(item => {
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
  {
    connector: dict->getDictfromDict("connector")->Dict.keysToArray,
    currency: dict->getArrayFromDict("currency", [])->getStrArrayFromJsonArray,
    dispute_status: dict->getArrayFromDict("dispute_status", [])->getStrArrayFromJsonArray,
    dispute_stage: dict->getArrayFromDict("dispute_stage", [])->getStrArrayFromJsonArray,
    connector_label: [],
  }
}

let initialFilters = (json, filtervalues, _, _, _) => {
  let filterDict = json->getDictFromJsonObject
  let filtersArray = filterDict->Dict.keysToArray->Array.filter(item => item != "currency")

  let connectorFilter = filtervalues->getArrayFromDict("connector", [])->getStrArrayFromJsonArray
  if connectorFilter->Array.length !== 0 {
    filtersArray->Array.push(#connector_label->getLabelFromFilterType)
  }
  let filterData = filterDict->itemToObjMapper

  filtersArray->Array.map((key): EntityType.initialFilters<'t> => {
    let title = `Select ${key->snakeToTitle}`

    let values = switch key->getFilterTypeFromString {
    | #connector => filterData.connector
    | #currency => filterData.currency
    | #dispute_status => filterData.dispute_status
    | #dispute_stage => filterData.dispute_stage
    | #connector_label => getConditionalFilter(key, filterDict, filtervalues)
    | _ => []
    }

    let options = switch key->getFilterTypeFromString {
    | #connector_label => getOptionsForDisputeFilters(filterDict, filtervalues)
    | #connector => values->FilterSelectBox.makeOptions(~isTitle=true)
    | _ => values->FilterSelectBox.makeOptions
    }

    {
      field: FormRenderer.makeFieldInfo(
        ~label=key,
        ~name=getValueFromFilterType(key->getFilterTypeFromString),
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
      ),
      localFilter: Some(filterByData),
    }
  })
}

let isNonEmptyValue = value => {
  value->Option.getOr(Dict.make())->Dict.toArray->Array.length > 0
}

open ConnectorTypes
let connectorsSupportEvidenceUpload = [Processors(CHECKOUT), Processors(STRIPE)]
let connectorsSupportAcceptDispute = [Processors(CHECKOUT)]
let connectorSupportCounterDispute = [Processors(CHECKOUT), Processors(STRIPE)]
