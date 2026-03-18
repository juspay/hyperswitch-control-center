let useClearRecoilValue = () => {
  open HyperswitchAtom

  let setMerchantDetailsValue = merchantDetailsValueAtom->Jotai.useSetAtom
  let setConnectorListAtom = connectorListAtom->Jotai.useSetAtom
  let setEnumVariantAtom = enumVariantAtom->Jotai.useSetAtom
  let setPaypalAccountStatusAtom = paypalAccountStatusAtom->Jotai.useSetAtom
  let setUserPermissionAtom = userPermissionAtom->Jotai.useSetAtom
  let setUserGroupACLAtom = userGroupACLAtom->Jotai.useSetAtom
  let setSwitchMerchantListAtom = switchMerchantListAtom->Jotai.useSetAtom
  let setCurrentTabNameRecoilAtom = currentTabNameRecoilAtom->Jotai.useSetAtom
  let setOrgListRecoilAtom = orgListAtom->Jotai.useSetAtom
  let setMerchantListRecoilAtom = merchantListAtom->Jotai.useSetAtom
  let setProfileListRecoilAtom = profileListAtom->Jotai.useSetAtom
  let setModuleListListRecoilAtom = moduleListRecoil->Jotai.useSetAtom
  //Todo: remove id atom once we start using businessProfileInterface
  let setBusinessProfileRecoil = businessProfileFromIdAtom->Jotai.useSetAtom
  let setBusinessProfileInterfaceRecoil = businessProfileFromIdAtomInterface->Jotai.useSetAtom

  let clearRecoilValue = () => {
    setMerchantDetailsValue(_ => JSON.Encode.null->MerchantAccountDetailsMapper.getMerchantDetails)
    //Todo: remove id atom once we start using businessProfileInterface
    setBusinessProfileRecoil(_ =>
      JSON.Encode.null->BusinessProfileInterfaceUtilsV1.mapJsonToBusinessProfileV1
    )
    setBusinessProfileInterfaceRecoil(_ =>
      JSON.Encode.null->BusinessProfileInterfaceUtils.mapJsontoCommonType
    )
    setConnectorListAtom(_ => [])
    setEnumVariantAtom(_ => "")
    setPaypalAccountStatusAtom(_ => PayPalFlowTypes.Connect_paypal_landing)
    setUserPermissionAtom(_ => GroupACLMapper.defaultValueForGroupAccessJson)
    setUserGroupACLAtom(_ => None)
    setSwitchMerchantListAtom(_ => [SwitchMerchantUtils.defaultValue])
    setCurrentTabNameRecoilAtom(_ => "ActiveTab")
    setOrgListRecoilAtom(_ => [ompDefaultValue])
    setMerchantListRecoilAtom(_ => [ompDefaultValue])
    setProfileListRecoilAtom(_ => [ompDefaultValue])
    setModuleListListRecoilAtom(_ => [])
  }
  clearRecoilValue
}
