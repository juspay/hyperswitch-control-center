let useClearRecoilValue = () => {
  open HyperswitchAtom

  let setMerchantDetailsValue = merchantDetailsValueAtom->Recoil.useSetRecoilState
  let setConnectorListAtom = connectorListAtom->Recoil.useSetRecoilState
  let setEnumVariantAtom = enumVariantAtom->Recoil.useSetRecoilState
  let setPaypalAccountStatusAtom = paypalAccountStatusAtom->Recoil.useSetRecoilState
  let setUserPermissionAtom = userPermissionAtom->Recoil.useSetRecoilState
  let setUserGroupACLAtom = userGroupACLAtom->Recoil.useSetRecoilState
  let setSwitchMerchantListAtom = switchMerchantListAtom->Recoil.useSetRecoilState
  let setCurrentTabNameRecoilAtom = currentTabNameRecoilAtom->Recoil.useSetRecoilState
  let setOrgListRecoilAtom = orgListAtom->Recoil.useSetRecoilState
  let setMerchantListRecoilAtom = merchantListAtom->Recoil.useSetRecoilState
  let setProfileListRecoilAtom = profileListAtom->Recoil.useSetRecoilState
  let setModuleListListRecoilAtom = moduleListRecoil->Recoil.useSetRecoilState
  //Todo: remove id atom once we start using businessProfileInterface
  let setBusinessProfileRecoil = businessProfileFromIdAtom->Recoil.useSetRecoilState
  let setBusinessProfileInterfaceRecoil =
    businessProfileFromIdAtomInterface->Recoil.useSetRecoilState

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
