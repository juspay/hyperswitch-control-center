open ReconEngineOverviewUtils

open ReconEngineOverviewTypes
open ReconEngineOverviewSummaryTypes

// Amount type utility functions and variables
let getHeaderText = (amountType: amountType, currency: string) => {
  switch amountType {
  | Reconciled => `Reconciled Amount (${currency})`
  | Pending => `Pending Amount (${currency})`
  | Mismatched => `Mismatched Amount (${currency})`
  }
}

let getAmountPair = (amountType: amountType, data: accountType) => {
  switch amountType {
  | Reconciled => (data.posted_credits, data.posted_debits)
  | Pending => (data.pending_credits, data.pending_debits)
  | Mismatched => (data.mismatched_credits, data.mismatched_debits)
  }
}

let allAmountTypes = [Reconciled, Pending, Mismatched]
let allSubHeaderTypes = [In, Out]

let getSummaryStackedBarGraphData = (
  ~postedCount: int,
  ~mismatchedCount: int,
  ~expectedCount: int,
) => {
  open StackedBarGraphTypes
  {
    categories: ["Transactions"],
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

let calculateTotals = (data: array<accountType>) => {
  data->Array.reduce(Dict.make()->ReconEngineOverviewUtils.accountItemToObjMapper, (acc, item) => {
    {
      ...acc,
      posted_credits: {
        value: acc.posted_credits.value +. item.posted_credits.value,
        currency: item.posted_credits.currency,
      },
      posted_debits: {
        value: acc.posted_debits.value +. item.posted_debits.value,
        currency: item.posted_debits.currency,
      },
      pending_credits: {
        value: acc.pending_credits.value +. item.pending_credits.value,
        currency: item.pending_credits.currency,
      },
      pending_debits: {
        value: acc.pending_debits.value +. item.pending_debits.value,
        currency: item.pending_debits.currency,
      },
      expected_credits: {
        value: acc.expected_credits.value +. item.expected_credits.value,
        currency: item.expected_credits.currency,
      },
      expected_debits: {
        value: acc.expected_debits.value +. item.expected_debits.value,
        currency: item.expected_debits.currency,
      },
      mismatched_credits: {
        value: acc.mismatched_credits.value +. item.mismatched_credits.value,
        currency: item.mismatched_credits.currency,
      },
      mismatched_debits: {
        value: acc.mismatched_debits.value +. item.mismatched_debits.value,
        currency: item.mismatched_debits.currency,
      },
    }
  })
}
