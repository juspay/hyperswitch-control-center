open ReconEngineExceptionTypes
open LogicUtils
open ReconEngineFilterUtils

let getStagingAccountOptions = (stagingData: array<processingEntryType>) => {
  let allAccounts = stagingData->Array.map(entry => entry.account)

  let uniqueAccounts = allAccounts->Array.reduce([], (acc, account) => {
    let exists =
      acc->Array.some(existingAccount => existingAccount.account_id === account.account_id)
    exists ? acc : [...acc, account]
  })

  uniqueAccounts->Array.map(account => {
    {
      FilterSelectBox.label: account.account_name,
      value: account.account_id,
    }
  })
}

let initialDisplayFilters = () => {
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
  ]
}

let getAccountTypeMapper = dict => {
  {
    account_id: dict->getString("account_id", ""),
    account_name: dict->getString("account_name", ""),
  }
}

let processingItemToObjMapper = (dict): processingEntryType => {
  {
    staging_entry_id: dict->getString("staging_entry_id", ""),
    account: dict
    ->getDictfromDict("account")
    ->getAccountTypeMapper,
    entry_type: dict->getString("entry_type", ""),
    amount: dict->getDictfromDict("amount")->getFloat("value", 0.0),
    currency: dict->getDictfromDict("amount")->getString("currency", ""),
    status: dict->getString("status", ""),
    effective_at: dict->getString("effective_at", ""),
    processing_mode: dict->getString("processing_mode", ""),
    metadata: dict->getJsonObjectFromDict("metadata"),
    transformation_id: dict->getString("transformation_id", ""),
    transformation_history_id: dict->getString("transformation_history_id", ""),
  }
}
