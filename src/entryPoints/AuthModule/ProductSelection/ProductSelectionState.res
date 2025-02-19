open ProductTypes

type productSelectionState =
  | CreateNewMerchant
  | SwitchToMerchant(OMPSwitchTypes.ompListTypes)
  | SelectMerchantToSwitch(array<OMPSwitchTypes.ompListTypes>)

type productSelectProviderTypes = {
  activeProduct: productTypes,
  setActiveProductValue: productTypes => unit,
  setCreateNewMerchant: productTypes => unit,
  setSwitchToMerchant: (OMPSwitchTypes.ompListTypes, productTypes) => unit,
  setSelectMerchantToSwitch: array<OMPSwitchTypes.ompListTypes> => unit,
  onProductSelectClick: string => unit,
  setDefaultProductToSessionStorage: productTypes => unit,
}

let defaultValueOfProductProvider = (~currentProductValue) => {
  activeProduct: currentProductValue->ProductUtils.getVariantFromString,
  setActiveProductValue: _ => (),
  setCreateNewMerchant: _ => (),
  setSwitchToMerchant: (_, _) => (),
  setSelectMerchantToSwitch: _ => (),
  onProductSelectClick: _ => (),
  setDefaultProductToSessionStorage: _ => (),
}
