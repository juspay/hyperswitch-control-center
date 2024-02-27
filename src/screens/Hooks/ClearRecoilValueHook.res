let useClearRecoilValue = () => {
  open HyperswitchAtom

  let setMerchantDetailsValue = merchantDetailsValueAtom->Recoil.useSetRecoilState
  let setBusinessProfilesAtom = businessProfilesAtom->Recoil.useSetRecoilState
  let setConnectorListAtom = connectorListAtom->Recoil.useSetRecoilState
  let setEnumVariantAtom = enumVariantAtom->Recoil.useSetRecoilState
  let setFeatureFlagAtom = featureFlagAtom->Recoil.useSetRecoilState
  let setPaypalAccountStatusAtom = paypalAccountStatusAtom->Recoil.useSetRecoilState
  let setUserPermissionAtom = userPermissionAtom->Recoil.useSetRecoilState
  let setSwitchMerchantListAtom = switchMerchantListAtom->Recoil.useSetRecoilState
  let setCurrentTabNameRecoilAtom = currentTabNameRecoilAtom->Recoil.useSetRecoilState

  let clearRecoilValue = () => {
    setMerchantDetailsValue(._ => JSON.Encode.null->MerchantAccountDetailsMapper.getMerchantDetails)
    setBusinessProfilesAtom(._ => "")
    setConnectorListAtom(._ => "")
    setEnumVariantAtom(._ => "")
    setFeatureFlagAtom(._ => JSON.Encode.null->FeatureFlagUtils.featureFlagType)
    setPaypalAccountStatusAtom(._ => PayPalFlowTypes.Connect_paypal_landing)
    setUserPermissionAtom(._ => PermissionUtils.defaultValueForPermission)
    setSwitchMerchantListAtom(._ => [SwitchMerchantUtils.defaultValue])
    setCurrentTabNameRecoilAtom(._ => "ActiveTab")
  }
  clearRecoilValue
}
