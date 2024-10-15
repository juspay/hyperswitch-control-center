let useClearRecoilValue = () => {
  open HyperswitchAtom

  let setMerchantDetailsValue = merchantDetailsValueAtom->Recoil.useSetRecoilState
  let setBusinessProfilesAtom = businessProfilesAtom->Recoil.useSetRecoilState
  let setConnectorListAtom = connectorListAtom->Recoil.useSetRecoilState
  let setEnumVariantAtom = enumVariantAtom->Recoil.useSetRecoilState
  let setPaypalAccountStatusAtom = paypalAccountStatusAtom->Recoil.useSetRecoilState
  let setUserPermissionAtom = userPermissionAtom->Recoil.useSetRecoilState
  let setSwitchMerchantListAtom = switchMerchantListAtom->Recoil.useSetRecoilState
  let setCurrentTabNameRecoilAtom = currentTabNameRecoilAtom->Recoil.useSetRecoilState
  let setOrgListRecoilAtom = orgListAtom->Recoil.useSetRecoilState
  let setMerchantListRecoilAtom = merchantListAtom->Recoil.useSetRecoilState
  let setProfileListRecoilAtom = profileListAtom->Recoil.useSetRecoilState
  let setModuleListListRecoilAtom = moduleListRecoil->Recoil.useSetRecoilState

  let clearRecoilValue = () => {
    setMerchantDetailsValue(_ => JSON.Encode.null->MerchantAccountDetailsMapper.getMerchantDetails)
    setBusinessProfilesAtom(_ => JSON.Encode.null->BusinessProfileMapper.getArrayOfBusinessProfile)
    setConnectorListAtom(_ =>
      JSON.Encode.null->ConnectorListMapper.getArrayOfConnectorListPayloadType
    )
    setEnumVariantAtom(_ => "")
    setPaypalAccountStatusAtom(_ => PayPalFlowTypes.Connect_paypal_landing)
    setUserPermissionAtom(_ => PermissionUtils.defaultValueForPermission)
    setSwitchMerchantListAtom(_ => [SwitchMerchantUtils.defaultValue])
    setCurrentTabNameRecoilAtom(_ => "ActiveTab")
    setOrgListRecoilAtom(_ => [defaultValue])
    setMerchantListRecoilAtom(_ => [defaultValue])
    setProfileListRecoilAtom(_ => [defaultValue])
    setModuleListListRecoilAtom(_ => [])
  }
  clearRecoilValue
}
