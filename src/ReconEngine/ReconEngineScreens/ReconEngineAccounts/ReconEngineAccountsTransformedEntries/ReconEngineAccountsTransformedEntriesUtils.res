open ReconEngineUtils
open ReconEngineAccountsTransformedEntriesTypes
open LogicUtils

let getTotalNeedsManualReviewEntries = (
  stagingEntries: array<ReconEngineExceptionTypes.processingEntryType>,
): float => {
  stagingEntries
  ->Array.filter(entry => entry.status == "needs_manual_review")
  ->Array.length
  ->Int.toFloat
}

let getTotalProcessedEntries = (
  stagingEntries: array<ReconEngineExceptionTypes.processingEntryType>,
): float => {
  stagingEntries
  ->Array.filter(entry => entry.status == "processed")
  ->Array.length
  ->Int.toFloat
}

let getTotalEntries = (
  stagingEntries: array<ReconEngineExceptionTypes.processingEntryType>,
): float => {
  stagingEntries->Array.length->Int.toFloat
}

let cardDetails = (~stagingData: array<ReconEngineExceptionTypes.processingEntryType>) => {
  [
    {
      title: "Total Records",
      value: valueFormatter(getTotalEntries(stagingData), Volume),
    },
    {
      title: "Processed",
      value: valueFormatter(getTotalProcessedEntries(stagingData), Volume),
    },
    {
      title: "Needs Manual Review",
      value: valueFormatter(getTotalNeedsManualReviewEntries(stagingData), Volume),
    },
    {
      title: "% Valid",
      value: valueFormatter(
        getTotalProcessedEntries(stagingData) /. getTotalEntries(stagingData) *. 100.0,
        Rate,
      ),
    },
  ]
}

let getAccountOptionsFromStagingData = (
  stagingEntries: array<ReconEngineExceptionTypes.processingEntryType>,
): array<FilterSelectBox.dropdownOption> => {
  stagingEntries
  ->Array.reduce(Dict.make(), (acc, entry) => {
    acc->Dict.set(entry.account.account_id, entry.account)
    acc
  })
  ->Dict.valuesToArray
  ->Array.map(account => {
    FilterSelectBox.label: account.account_name,
    value: account.account_id,
  })
}

let initialDisplayFilters = (~accountOptions) => {
  let entryTypeOptions: array<FilterSelectBox.dropdownOption> = [
    {label: "Credit", value: "credit"},
    {label: "Debit", value: "debit"},
  ]

  let statusOptions = getStagingEntryStatusOptions()

  [
    (
      {
        field: FormRenderer.makeFieldInfo(
          ~label="entry_type",
          ~name="entry_type",
          ~customInput=InputFields.filterMultiSelectInput(
            ~options=entryTypeOptions,
            ~buttonText="Select Entry Type",
            ~showSelectionAsChips=false,
            ~searchable=true,
            ~showToolTip=true,
            ~showNameAsToolTip=true,
            ~customButtonStyle="bg-none",
            ~fixedDropDownDirection=BottomRight,
            (),
          ),
        ),
        localFilter: Some((_, _) => []->Array.map(Nullable.make)),
      }: EntityType.initialFilters<'t>
    ),
    (
      {
        field: FormRenderer.makeFieldInfo(
          ~label="status",
          ~name="status",
          ~customInput=InputFields.filterMultiSelectInput(
            ~options=statusOptions,
            ~buttonText="Select Status",
            ~showSelectionAsChips=false,
            ~searchable=true,
            ~showToolTip=true,
            ~showNameAsToolTip=true,
            ~customButtonStyle="bg-none",
            ~fixedDropDownDirection=BottomRight,
            (),
          ),
        ),
        localFilter: Some((_, _) => []->Array.map(Nullable.make)),
      }: EntityType.initialFilters<'t>
    ),
    (
      {
        field: FormRenderer.makeFieldInfo(
          ~label="Account",
          ~name="account_id",
          ~customInput=InputFields.filterMultiSelectInput(
            ~options=accountOptions,
            ~buttonText="Select Account",
            ~showSelectionAsChips=false,
            ~searchable=true,
            ~showToolTip=true,
            ~showNameAsToolTip=true,
            ~customButtonStyle="bg-none",
            ~fixedDropDownDirection=BottomRight,
            (),
          ),
        ),
        localFilter: Some((_, _) => []->Array.map(Nullable.make)),
      }: EntityType.initialFilters<'t>
    ),
  ]
}
