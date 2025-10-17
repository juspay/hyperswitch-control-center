open ReconEngineFilterUtils
open ReconEngineTypes
open LogicUtils

let initialDisplayFilters = (~creditAccountOptions=[], ~debitAccountOptions=[], ()) => {
  let statusOptions = getTransactionStatusOptions([Mismatched, Expected])
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
    (
      {
        field: FormRenderer.makeFieldInfo(
          ~label="source_account",
          ~name="source_account",
          ~customInput=InputFields.filterMultiSelectInput(
            ~options=creditAccountOptions,
            ~buttonText="Select Source Account",
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
    (
      {
        field: FormRenderer.makeFieldInfo(
          ~label="target_account",
          ~name="target_account",
          ~customInput=InputFields.filterMultiSelectInput(
            ~options=debitAccountOptions,
            ~buttonText="Select Target Account",
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

let getSumOfAmountWithCurrency = (entries: array<entryType>): (float, string) => {
  let totalAmount = entries->Array.reduce(0.0, (acc, entry) => acc +. entry.amount)
  let currency = switch entries->Array.get(0) {
  | Some(entry) => entry.currency
  | None => ""
  }
  (totalAmount, currency)
}

let getMismatchAmountDisplay = (mismatchData: Js.Json.t): (string, float, string) => {
  let dataDict = mismatchData->getDictFromJsonObject->getJsonObjectFromDict("Mismatched")
  let mismatchType = dataDict->getDictFromJsonObject->Dict.keysToArray->getValueFromArray(0, "")
  let mismatchTypeDict = dataDict->getDictFromJsonObject->getJsonObjectFromDict(mismatchType)

  let expectedAmount =
    mismatchTypeDict
    ->getDictFromJsonObject
    ->getDictfromDict("expected_amount")
    ->getFloat("value", 0.0)

  let actualAmount =
    mismatchTypeDict
    ->getDictFromJsonObject
    ->getDictfromDict("actual_amount")
    ->getFloat("value", 0.0)

  let currency =
    mismatchTypeDict
    ->getDictFromJsonObject
    ->getDictfromDict("expected_amount")
    ->getString("currency", "USD")

  let mismatchAmount = Math.abs(expectedAmount -. actualAmount)
  (mismatchType->camelCaseToTitle, mismatchAmount, currency)
}
