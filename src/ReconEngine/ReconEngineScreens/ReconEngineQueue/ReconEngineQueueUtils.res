let generateAccountDropdownOptions = (
  accountData: array<ReconEngineOverviewTypes.accountType>,
): array<SelectBox.dropdownOption> => {
  accountData->Array.map(item => {
    {
      SelectBox.label: item.account_name,
      value: item.account_id,
    }
  })
}
