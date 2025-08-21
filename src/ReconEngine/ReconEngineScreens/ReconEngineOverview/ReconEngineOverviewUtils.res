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

let getStackedBarGraphData = (~postedCount: int, ~mismatchedCount: int, ~expectedCount: int) => {
  {
    StackedBarGraphTypes.categories: ["Transactions"],
    data: [
      {
        name: "Mismatched",
        data: [mismatchedCount->Int.toFloat],
        color: "#EA8A8F",
      },
      {
        name: "Pending",
        data: [expectedCount->Int.toFloat],
        color: "#F3BE8B",
      },
      {
        name: "Matched",
        data: [postedCount->Int.toFloat],
        color: "#7AB891",
      },
    ],
    labelFormatter: StackedBarGraphUtils.stackedBarGraphLabelFormatter(~statType=Default),
  }
}

let processCountGraphData = (
  transactionsData: array<ReconEngineTransactionsTypes.transactionPayload>,
  ~graphColor: string,
) => {
  let groupedByDate = transactionsData->Array.reduce(Dict.make(), (acc, transaction) => {
    let dateStr = transaction.created_at->String.slice(~start=0, ~end=10) // Extract YYYY-MM-DD
    let currentDateData = acc->getObj(dateStr, Dict.make())
    let currentCount = currentDateData->getInt("count", 0)
    currentDateData->Dict.set("count", (currentCount + 1)->JSON.Encode.int)
    acc->Dict.set(dateStr, currentDateData->JSON.Encode.object)
    acc
  })

  // Generate last 7 days including today
  let today = Date.make()
  let todayTime = today->Date.getTime
  let last7Days = Array.make(~length=7, "")->Array.mapWithIndex((_, index) => {
    let daysBack = Int.toFloat(6 - index)
    let dateTime = todayTime -. daysBack *. 24.0 *. 60.0 *. 60.0 *. 1000.0
    let date = dateTime->Js.Date.fromFloat
    let year = date->Js.Date.getFullYear->Float.toString
    let month = (date->Js.Date.getMonth +. 1.0)->Float.toString->String.padStart(2, "0")
    let day = date->Js.Date.getDate->Float.toString->String.padStart(2, "0")
    `${year}-${month}-${day}`
  })

  let getCountFromDate = (groupedByDate, date) => {
    groupedByDate
    ->getObj(date, Dict.make())
    ->getInt("count", 0)
    ->Int.toFloat
  }

  let countData = last7Days->Array.map(date => {
    let parts = date->String.split("-")
    let month = parts->getValueFromArray(1, "01")->getMonthAbbreviation
    let day = parts->getValueFromArray(2, "01")
    let count = getCountFromDate(groupedByDate, date)

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
