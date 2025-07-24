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

let generateIngestionConfigDropdownOptions = (
  ingestionConfigData: array<ReconEngineFileManagementTypes.ingestionConfigType>,
): array<SelectBox.dropdownOption> => {
  ingestionConfigData->Array.map(item => {
    {
      SelectBox.label: item.name,
      value: item.ingestion_id,
    }
  })
}
