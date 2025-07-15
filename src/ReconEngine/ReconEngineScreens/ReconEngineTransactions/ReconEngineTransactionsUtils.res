open ReconEngineTransactionsTypes
open LogicUtils

let getArrayDictFromRes = res => {
  res->getDictFromJsonObject->getArrayFromDict("data", [])
}

let getHeadersForCSV = () => {
  "Order ID,Transaction ID,Payment Gateway,Payment Method,Txn Amount,Settlement Amount,Recon Status,Transaction Date"
}

let getAllTransactionPayload = dict => {
  {
    id: dict->getString("id", ""),
    transaction_id: dict->getString("transaction_id", ""),
    entry_id: dict->getStrArray("entry_id"),
    credit_account: dict->getString("credit_account", ""),
    debit_account: dict->getString("debit_account", ""),
    amount: dict->getFloat("amount", 0.0),
    currency: dict->getString("currency", ""),
    transaction_status: dict->getString("transaction_status", ""),
    variance: dict->getInt("variance", 0),
    discarded_status: dict->getString("discarded_status", ""),
    version: dict->getInt("version", 0),
    created_at: dict->getString("created_at", ""),
  }
}

let getArrayOfTransactionsListPayloadType = json => {
  json->Array.map(transactionJson => {
    transactionJson->getDictFromJsonObject->getAllTransactionPayload
  })
}

let getAllEntryPayload = dict => {
  {
    entry_id: dict->getString("entry_id", ""),
    entry_type: dict->getString("entry_type", ""),
    transaction_id: dict->getString("transaction_id", ""),
    amount: dict->getFloat("amount", 0.0),
    currency: dict->getString("currency", ""),
    status: dict->getString("status", ""),
    discarded_status: dict->getString("discarded_status", ""),
    metadata: dict->getJsonObjectFromDict("metadata"),
    created_at: dict->getString("created_at", ""),
    effective_at: dict->getString("effective_at", ""),
  }
}

let getArrayOfEntriesListPayloadType = json => {
  json->Array.map(entriesJson => {
    entriesJson->getDictFromJsonObject->getAllEntryPayload
  })
}

let getTransactionsList: JSON.t => array<transactionPayload> = json => {
  LogicUtils.getArrayDataFromJson(json, getAllTransactionPayload)
}

let getEntriesList: JSON.t => array<entryPayload> = json => {
  LogicUtils.getArrayDataFromJson(json, getAllEntryPayload)
}

let sortByVersion = (
  c1: ReconEngineTransactionsTypes.transactionPayload,
  c2: ReconEngineTransactionsTypes.transactionPayload,
) => {
  compareLogic(c1.version, c2.version)
}

let (startTimeFilterKey, endTimeFilterKey) = ("startTime", "endTime")

let initialFixedFilterFields = (~events=?) => {
  let events = switch events {
  | Some(fn) => fn
  | _ => () => ()
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
            ~disable=false,
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

let getSampleStackedBarGraphData = () => {
  open StackedBarGraphTypes
  {
    categories: ["Total Orders"],
    data: [
      {
        name: "Expected",
        data: [400.0],
        color: "#8BC2F3",
      },
      {
        name: "Mismatch",
        data: [400.0],
        color: "#EA8A8F",
      },
      {
        name: "Posted",
        data: [1200.0],
        color: "#7AB891",
      },
    ],
    labelFormatter: StackedBarGraphUtils.stackedBarGraphLabelFormatter(~statType=Default),
  }
}
