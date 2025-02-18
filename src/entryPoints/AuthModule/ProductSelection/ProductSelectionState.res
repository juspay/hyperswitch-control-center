type productSelectionState =
  | CreateNewMerchant
  | SwitchToMerchant(OMPSwitchTypes.ompListTypes)
  | SelectMerchantToSwitch(array<OMPSwitchTypes.ompListTypes>)

type productSelectProviderTypes = {
  setCreateNewMerchant: ProductTypes.productTypes => unit,
  setSwitchToMerchant: (OMPSwitchTypes.ompListTypes, ProductTypes.productTypes) => unit,
  setSelectMerchantToSwitch: array<OMPSwitchTypes.ompListTypes> => unit,
  onProductSelectClick: string => unit,
}

let defaultValueOfProductProvider = {
  setCreateNewMerchant: _ => (),
  setSwitchToMerchant: (_, _) => (),
  setSelectMerchantToSwitch: _ => (),
  onProductSelectClick: _ => (),
}
