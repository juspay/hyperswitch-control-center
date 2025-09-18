open LogicUtils
open ReconEngineOverviewTypes
open ReconEngineTypes
open ReconEngineAccountsUtils
open ColumnGraphUtils
open NewAnalyticsUtils
open ReconEngineUtils

// Color constants for ReconEngine graphs
let mismatchedColor = "#EA8A8F"
let expectedColor = "#8BC2F3"
let postedColor = "#7AB891"
let exceptionsVolumeColor = "#F39B8B"
let reconciledVolumeColor = "#8BC2F3"

// Flow diagram colors
let highlightStrokeColor = "#3b82f6"
let normalStrokeColor = "#6b7280"

let getOverviewAccountPayloadFromDict: Dict.t<JSON.t> => accountType = dict => {
  dict->accountItemToObjMapper
}

let getAccountNameAndCurrency = (accountData: array<accountType>, accountId: string): (
  string,
  string,
) => {
  let account =
    accountData
    ->Array.find(account => account.account_id === accountId)
    ->Option.getOr(Dict.make()->getAccountPayloadFromDict)
  (account.account_name, account.currency->LogicUtils.isEmptyString ? "N/A" : account.currency)
}

let calculateAccountAmounts = (
  transactionsData: array<ReconEngineTypes.transactionType>,
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

    switch transaction.transaction_status {
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
      cardTitle: `Expectations from ${sourceAccountName}`,
      cardValue: totalSourceAmount->valueFormatter(AmountWithSuffix, ~suffix=sourceAccountCurrency),
    },
    {
      cardTitle: `Received by ${targetAccountName}`,
      cardValue: totalTargetAmount->valueFormatter(AmountWithSuffix, ~suffix=targetAccountCurrency),
    },
    {
      cardTitle: "Net Variance",
      cardValue: variance->valueFormatter(AmountWithSuffix, ~suffix=sourceAccountCurrency),
    },
    {
      cardTitle: `Missing in ${targetAccountName}`,
      cardValue: targetExpected->valueFormatter(AmountWithSuffix, ~suffix=targetAccountCurrency),
    },
  ]
}

let calculateTransactionCounts = (transactionsData: array<ReconEngineTypes.transactionType>) => {
  transactionsData->Array.reduce((0, 0, 0), ((posted, mismatched, expected), transaction) => {
    switch transaction.transaction_status {
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
        color: mismatchedColor,
      },
      {
        name: "Expected",
        data: [expectedCount->Int.toFloat],
        color: expectedColor,
      },
      {
        name: "Posted",
        data: [postedCount->Int.toFloat],
        color: postedColor,
      },
    ],
    labelFormatter: StackedBarGraphUtils.stackedBarGraphLabelFormatter(~statType=Default),
  }
}

let getTransactionDate = (transaction: ReconEngineTypes.transactionType) =>
  transaction.effective_at->String.slice(~start=0, ~end=10)

let findDateRange = transactions => {
  transactions->Array.reduce(None, (acc, transaction) => {
    let date = getTransactionDate(transaction)
    switch acc {
    | Some((min, max)) => {
        let earliestDate = date < min ? date : min
        let latestDate = date > max ? date : max
        Some((earliestDate, latestDate))
      }
    | None => Some((date, date))
    }
  })
}

let calculateSevenDayWindow = (earliestDate, latestDate) => {
  let earliestDayJs = earliestDate->DayJs.getDayJsForString
  let sevenDaysLater = earliestDayJs.add(7, "day")
  let calculatedEndDate = sevenDaysLater.format("YYYY-MM-DD")

  let actualEndDate = calculatedEndDate <= latestDate ? calculatedEndDate : latestDate
  (earliestDate, actualEndDate)
}

let filterTransactionsByDateRange = (transactions, startDate, endDate) => {
  transactions->Array.filter(transaction => {
    let transactionDate = getTransactionDate(transaction)
    transactionDate >= startDate && transactionDate <= endDate
  })
}

let groupTransactionsByDate = transactions => {
  transactions->Array.reduce(Dict.make(), (acc, transaction) => {
    let dateStr = getTransactionDate(transaction)
    let formattedDate = `${dateStr} 00:00:00`
    let currentDateData = acc->getObj(formattedDate, Dict.make())
    let currentCount = currentDateData->getInt("count", 0)

    currentDateData->Dict.set("count", (currentCount + 1)->JSON.Encode.int)
    currentDateData->Dict.set("time_bucket", formattedDate->JSON.Encode.string)
    acc->Dict.set(formattedDate, currentDateData->JSON.Encode.object)
    acc
  })
}

let processCountGraphData = (
  transactionsData: array<ReconEngineTypes.transactionType>,
  ~graphColor: string,
  ~granularity=(#G_ONEDAY: NewAnalyticsTypes.granularity :> string),
) => {
  let (earliestDate, latestDate) = switch findDateRange(transactionsData) {
  | Some((earliest, latest)) => (earliest, latest)
  | None => ("", "")
  }

  let (windowStartDate, windowEndDate) = calculateSevenDayWindow(earliestDate, latestDate)

  let filteredTransactions = filterTransactionsByDateRange(
    transactionsData,
    windowStartDate,
    windowEndDate,
  )

  let groupedByDate = groupTransactionsByDate(filteredTransactions)

  let actualStartDateTime = `${windowStartDate} 00:00:00`
  let actualEndDateTime = `${windowEndDate} 23:59:59`

  let defaultValue = Dict.make()
  defaultValue->Dict.set("count", 0->JSON.Encode.int)
  defaultValue->Dict.set("time_bucket", ""->JSON.Encode.string)
  let defaultValueJson = defaultValue->JSON.Encode.object

  let filledData = fillForMissingTimeRange(
    ~existingTimeDict=groupedByDate,
    ~timeKey="time_bucket",
    ~defaultValue=defaultValueJson,
    ~startDate=actualStartDateTime,
    ~endDate=actualEndDateTime,
    ~granularity,
  )

  filledData
  ->Dict.keysToArray
  ->Array.toSorted(String.compare)
  ->Array.map(dateTime => {
    let dateStr = dateTime->String.slice(~start=0, ~end=10)
    let parts = dateStr->String.split("-")
    let monthStr = parts->getValueFromArray(1, "01")
    let monthNum = monthStr->Int.fromString->Option.getOr(1) - 1 // Convert to 0-11 range
    let month = monthNum->getMonthName
    let day = parts->getValueFromArray(2, "01")
    let count =
      filledData
      ->getObj(dateTime, Dict.make())
      ->getInt("count", 0)
      ->Int.toFloat

    {
      ColumnGraphTypes.name: `${month} ${day}`,
      y: count,
      color: graphColor,
    }
  })
}

let createColumnGraphCountPayload = (
  ~countData: array<ColumnGraphTypes.dataObj>,
  ~title: string,
  ~color: string,
) => {
  let columnGraphData: ColumnGraphTypes.columnGraphPayload = {
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
  let statusOptions = ReconEngineFilterUtils.getTransactionStatusOptions([
    Mismatched,
    Expected,
    Posted,
  ])
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
