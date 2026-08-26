open LogicUtils
open ReconEngineTypes
open ReconEngineDataUtils
open ReconEngineUtils

// Flow diagram colors
let highlightStrokeColor = "#3b82f6"
let normalStrokeColor = "#6b7280"

let getPercentage = (~count: int, ~total: int) =>
  total > 0 ? count->Int.toFloat /. total->Int.toFloat *. 100.0 : 0.0

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
  (account.account_name, account.currency->isEmptyString ? "N/A" : account.currency)
}

let initialDisplayFilters = () => {
  let statusOptions = ReconEngineFilterUtils.getGroupedTransactionStatusOptions([
    Posted(Manual),
    Matched(Auto),
    Matched(Manual),
    Matched(WithTolerance),
    OverAmount(Mismatch),
    OverAmount(Expected),
    UnderAmount(Mismatch),
    UnderAmount(Expected),
    DataMismatch,
    CurrencyMismatch,
    SplitMismatch,
    PartiallyReconciled,
    Expected,
    Missing,
    Void,
  ])
  [
    (
      {
        field: FormRenderer.makeFieldInfo(
          ~label="transaction_status",
          ~name="status",
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
