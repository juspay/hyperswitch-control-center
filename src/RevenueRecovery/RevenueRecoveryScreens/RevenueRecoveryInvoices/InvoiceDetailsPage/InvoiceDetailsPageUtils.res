let getAmountPercentage = (~orderAmount, ~amountCaptured) => {
  if orderAmount <= 0.0 {
    0.0
  } else {
    let calculated = amountCaptured /. orderAmount *. 100.0

    if calculated < 0.0 {
      0.0
    } else if calculated > 100.0 {
      100.0
    } else {
      calculated
    }
  }
}

open RevenueRecoveryOrderTypes
open RevenueRecoveryOrderUtils
let formatCurrency = (amount: float) => {
  amount->CurrencyFormatUtils.valueFormatter(AmountWithSuffix, ~currency="$")
}

let parseAttemptStatus = (attempt: attempts) =>
  attempt.attempt_triggered_by->String.toUpperCase->attemptTriggeredByVariantMapper

let isInternalAttempt = (attempt: attempts) => {
  attempt->parseAttemptStatus == INTERNAL
}

let isExternalAttempt = (attempt: attempts) => {
  attempt->parseAttemptStatus != INTERNAL
}

let getStatusBadgeColor = (status: string) => {
  switch status->HSwitchOrderUtils.paymentAttemptStatusVariantMapper {
  | #CHARGED => (
      "bg-nd_green-100 text-nd_green-600  border border-nd_green-200",
      "Recovered successfully",
    )
  | #FAILURE => ("bg-nd_red-50 text-nd_red-500 border border-nd_red-200 ", "Failed")
  | _ => ("bg-nd_orange-150 text-nd_orange-300 border border-nd_orange-300", "Pending")
  }
}

let getTimelineDotColor = (status: string) => {
  switch status->HSwitchOrderUtils.paymentAttemptStatusVariantMapper {
  | #CHARGED => "bg-nd_green-500"
  | #FAILURE => "bg-nd_red-500"
  | _ => "bg-nd_orange-300"
  }
}
