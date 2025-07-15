open LogicUtils
let generateAccountDropdownOptions = (accountData): array<SelectBox.dropdownOption> => {
  accountData
  ->getArrayFromJson([])
  ->Array.map(item => {
    let accountDict = item->getDictFromJsonObject
    let accountName = accountDict->getString("account_name", "")
    let accountId = accountDict->getString("account_id", "")
    {
      SelectBox.label: accountName,
      value: accountId,
    }
  })
}
