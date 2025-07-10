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
    transaction_id: dict->getString("transaction_id", ""),
    credit_account: dict->getString("credit_account", ""),
    debit_account: dict->getString("debit_account", ""),
    amount: dict->getInt("amount", 0),
    currency: dict->getString("currency", ""),
    variance: dict->getInt("variance", 0),
    status: dict->getString("status", ""),
    created_at: dict->getString("created_at", ""),
  }
}

let getArrayOfTransactionsListPayloadType = json => {
  json->Array.map(reportJson => {
    reportJson->getDictFromJsonObject->getAllTransactionPayload
  })
}

let getTransactionsList: JSON.t => array<transactionPayload> = json => {
  LogicUtils.getArrayDataFromJson(json, getAllTransactionPayload)
}

let (startTimeFilterKey, endTimeFilterKey) = ("startTime", "endTime")

let initialFixedFilterFields = (~events=?, ~sampleDataIsEnabled=false) => {
  let events = switch events {
  | Some(fn) => fn
  | _ => () => ()
  }
  let customButtonStyle = sampleDataIsEnabled
    ? "!bg-nd_gray-50 !text-nd_gray-400 !rounded-lg !bg-none"
    : "border !rounded-lg !bg-none"
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
            ~disable=sampleDataIsEnabled,
            ~events,
            ~customButtonStyle,
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
