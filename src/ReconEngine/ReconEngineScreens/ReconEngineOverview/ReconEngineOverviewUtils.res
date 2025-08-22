open LogicUtils
open ReconEngineOverviewTypes
open ColumnGraphTypes
open ColumnGraphUtils
open ReconEngineTransactionsUtils

let defaultAccount = {
  account_name: "",
  account_id: "",
  currency: "",
  profile_id: "",
  initial_balance: {
    value: 0.0,
    currency: "",
  },
  pending_balance: {
    value: 0.0,
    currency: "",
  },
  posted_balance: {
    value: 0.0,
    currency: "",
  },
}

let defaultAccountDetails = {
  id: "",
  account_id: "",
}

let getAmountPayload = dict => {
  {
    value: dict->getFloat("value", 0.0),
    currency: dict->getString("currency", ""),
  }
}

let accountItemToObjMapper = dict => {
  {
    account_name: dict->getString("account_name", ""),
    account_id: dict->getString("account_id", ""),
    profile_id: dict->getString("profile_id", ""),
    currency: dict->getDictfromDict("initial_balance")->getString("currency", ""),
    initial_balance: dict
    ->getDictfromDict("initial_balance")
    ->getAmountPayload,
    pending_balance: dict
    ->getDictfromDict("pending_balance")
    ->getAmountPayload,
    posted_balance: dict
    ->getDictfromDict("posted_balance")
    ->getAmountPayload,
  }
}

let accountRefItemToObjMapper = dict => {
  {
    id: dict->getString("id", ""),
    account_id: dict->getString("account_id", ""),
  }
}

let reconRuleItemToObjMapper = dict => {
  {
    rule_id: dict->getString("rule_id", ""),
    rule_name: dict->getString("rule_name", ""),
    rule_description: dict->getString("rule_description", ""),
    sources: dict
    ->getArrayFromDict("sources", [])
    ->Array.map(item => item->getDictFromJsonObject->accountRefItemToObjMapper),
    targets: dict
    ->getArrayFromDict("targets", [])
    ->Array.map(item => item->getDictFromJsonObject->accountRefItemToObjMapper),
  }
}

let getMonthAbbreviation = monthStr => {
  switch monthStr {
  | "01" => "Jan"
  | "02" => "Feb"
  | "03" => "Mar"
  | "04" => "Apr"
  | "05" => "May"
  | "06" => "Jun"
  | "07" => "Jul"
  | "08" => "Aug"
  | "09" => "Sep"
  | "10" => "Oct"
  | "11" => "Nov"
  | "12" => "Dec"
  | _ => "Jan"
  }
}

let getAccountNameAndCurrency = (accountData: array<accountType>, accountId: string): (
  string,
  string,
) => {
  let account =
    accountData
    ->Array.find(account => account.account_id === accountId)
    ->Option.getOr(defaultAccount)
  (account.account_name, account.currency->isEmptyString ? "N/A" : account.currency)
}

let calculateAccountAmounts = (
  transactionsData: array<ReconEngineTransactionsTypes.transactionPayload>,
  ~sourceAccountName: string,
  ~sourceAccountCurrency: string,
  ~targetAccountName: string,
  ~targetAccountCurrency: string,
) => {
  let (
    sourcePosted,
    targetPosted,
    sourceMismatched,
    targetMismatched,
    sourceExpected,
    targetExpected,
  ) = transactionsData->Array.reduce((0.0, 0.0, 0.0, 0.0, 0.0, 0.0), (
    (sPosted, tPosted, sMismatched, tMismatched, sExpected, tExpected),
    transaction,
  ) => {
    let creditAmount = transaction.credit_amount.value
    let debitAmount = transaction.debit_amount.value

    switch transaction.transaction_status->getTransactionTypeFromString {
    | Posted => (
        sPosted +. creditAmount,
        tPosted +. debitAmount,
        sMismatched,
        tMismatched,
        sExpected,
        tExpected,
      )
    | Mismatched => (
        sPosted,
        tPosted,
        sMismatched +. creditAmount,
        tMismatched +. debitAmount,
        sExpected,
        tExpected,
      )
    | Expected => (
        sPosted,
        tPosted,
        sMismatched,
        tMismatched,
        sExpected +. creditAmount,
        tExpected +. debitAmount,
      )
    | _ => (sPosted, tPosted, sMismatched, tMismatched, sExpected, tExpected)
    }
  })

  let totalSourceAmount = sourcePosted +. sourceMismatched +. sourceExpected
  let totalTargetAmount = targetPosted +. targetMismatched
  let variance = Math.abs(totalSourceAmount -. totalTargetAmount)

  [
    {
      "title": `Expectations from ${sourceAccountName}`,
      "value": totalSourceAmount->valueFormatter(AmountWithSuffix, ~suffix=sourceAccountCurrency),
    },
    {
      "title": `Received by ${targetAccountName}`,
      "value": totalTargetAmount->valueFormatter(AmountWithSuffix, ~suffix=targetAccountCurrency),
    },
    {
      "title": "Net Variance",
      "value": variance->valueFormatter(AmountWithSuffix, ~suffix=sourceAccountCurrency),
    },
    {
      "title": `Missing in ${targetAccountName}`,
      "value": targetExpected->valueFormatter(AmountWithSuffix, ~suffix=targetAccountCurrency),
    },
  ]
}

let calculateTransactionCounts = (
  transactionsData: array<ReconEngineTransactionsTypes.transactionPayload>,
) => {
  transactionsData->Array.reduce((0, 0, 0), ((posted, mismatched, expected), transaction) => {
    switch transaction.transaction_status->getTransactionTypeFromString {
    | Posted => (posted + 1, mismatched, expected)
    | Mismatched => (posted, mismatched + 1, expected)
    | Expected => (posted, mismatched, expected + 1)
    | _ => (posted, mismatched, expected)
    }
  })
}

// Color constants for ReconEngine graphs
let mismatchedColor = "#EA8A8F"
let pendingColor = "#F3BE8B"
let matchedColor = "#7AB891"
let exceptionsVolumeColor = "#F87171"
let reconciledVolumeColor = "#60A5FA"

let getStackedBarGraphData = (~postedCount: int, ~mismatchedCount: int, ~expectedCount: int) => {
  {
    StackedBarGraphTypes.categories: ["Transactions"],
    data: [
      {
        name: "Mismatched",
        data: [mismatchedCount->Int.toFloat],
        color: mismatchedColor,
      },
      {
        name: "Pending",
        data: [expectedCount->Int.toFloat],
        color: pendingColor,
      },
      {
        name: "Matched",
        data: [postedCount->Int.toFloat],
        color: matchedColor,
      },
    ],
    labelFormatter: StackedBarGraphUtils.stackedBarGraphLabelFormatter(~statType=Default),
  }
}

let processCountGraphData = (
  transactionsData: array<ReconEngineTransactionsTypes.transactionPayload>,
  ~graphColor: string,
  ~startDate: string,
  ~endDate: string,
  ~granularity="G_ONEDAY",
) => {
  let groupedByDate = transactionsData->Array.reduce(Dict.make(), (acc, transaction) => {
    let dateStr = transaction.created_at->String.slice(~start=0, ~end=10)
    let formattedDate = `${dateStr} 00:00:00`
    let currentDateData = acc->getObj(formattedDate, Dict.make())
    let currentCount = currentDateData->getInt("count", 0)
    currentDateData->Dict.set("count", (currentCount + 1)->JSON.Encode.int)
    currentDateData->Dict.set("time_bucket", formattedDate->JSON.Encode.string)
    acc->Dict.set(formattedDate, currentDateData->JSON.Encode.object)
    acc
  })

  let today = Date.make()
  let endDate = if endDate->isEmptyString {
    today->Js.Date.toISOString
  } else {
    today->Js.Date.toISOString->String.slice(~start=0, ~end=10) ++ " 00:00:00"
  }

  let defaultValue = Dict.make()
  defaultValue->Dict.set("count", 0->JSON.Encode.int)
  defaultValue->Dict.set("time_bucket", ""->JSON.Encode.string)
  let defaultValueJson = defaultValue->JSON.Encode.object

  let filledData = NewAnalyticsUtils.fillForMissingTimeRange(
    ~existingTimeDict=groupedByDate,
    ~timeKey="time_bucket",
    ~defaultValue=defaultValueJson,
    ~startDate,
    ~endDate,
    ~granularity,
  )

  let sortedDates =
    filledData
    ->Dict.keysToArray
    ->Array.toSorted(String.compare)

  let countData = sortedDates->Array.map(dateTime => {
    let dateStr = dateTime->String.slice(~start=0, ~end=10)
    let parts = dateStr->String.split("-")
    let month = parts->getValueFromArray(1, "01")->getMonthAbbreviation
    let day = parts->getValueFromArray(2, "01")
    let count =
      filledData
      ->getObj(dateTime, Dict.make())
      ->getInt("count", 0)
      ->Int.toFloat

    {
      name: `${month} ${day}`,
      y: count,
      color: graphColor,
    }
  })

  countData
}

let createColumnGraphCountPayload = (
  ~countData: array<dataObj>,
  ~title: string,
  ~color: string,
) => {
  let columnGraphData: columnGraphPayload = {
    data: [
      {
        showInLegend: false,
        name: title,
        colorByPoint: true,
        data: countData,
        color,
      },
    ],
    title: {text: ""},
    tooltipFormatter: columnGraphTooltipFormatter(~title, ~metricType=Default, ~currency=""),
    yAxisFormatter: columnGraphYAxisFormatter(~statType=Volume, ~suffix=""),
  }
  columnGraphData
}

let initialDisplayFilters = () => {
  let statusOptions = ReconEngineUtils.getTransactionStatusOptions([Mismatched, Expected, Posted])
  [
    (
      {
        field: FormRenderer.makeFieldInfo(
          ~label="transaction_status",
          ~name="transaction_status",
          ~customInput=InputFields.filterMultiSelectInput(
            ~options=statusOptions,
            ~buttonText="Select Transaction Status",
            ~showSelectionAsChips=false,
            ~searchable=true,
            ~showToolTip=true,
            ~showNameAsToolTip=true,
            ~customButtonStyle="bg-none",
            (),
          ),
        ),
        localFilter: Some((_, _) => []->Array.map(Nullable.make)),
      }: EntityType.initialFilters<'t>
    ),
  ]
}
