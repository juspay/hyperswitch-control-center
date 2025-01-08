type accessMapping = {
  groups: Map.t<UserManagementTypes.groupAccessType, CommonAuthTypes.authorization>,
  resources: Map.t<UserManagementTypes.resourceAccessType, CommonAuthTypes.authorization>,
}

let orgDefaultValue: OMPSwitchTypes.orgList = {id: "", name: "", orgType: Default}
let merchantDefaultValue: OMPSwitchTypes.merchantList = {id: "", name: "", merchantType: Default}
let profileDefaultValue: OMPSwitchTypes.profileList = {id: "", name: ""}

let merchantDetailsValueAtom: Recoil.recoilAtom<HSwitchSettingTypes.merchantPayload> = Recoil.atom(
  "merchantDetailsValue",
  JSON.Encode.null->MerchantAccountDetailsMapper.getMerchantDetails,
)

let businessProfilesAtom = Recoil.atom(
  "businessProfileDetails",
  JSON.Encode.null->BusinessProfileMapper.getArrayOfBusinessProfile,
)

let connectorListAtom: Recoil.recoilAtom<array<ConnectorTypes.connectorPayload>> = Recoil.atom(
  "connectorListAtom",
  JSON.Encode.null->ConnectorListMapper.getArrayOfConnectorListPayloadType,
)

let enumVariantAtom = Recoil.atom("enumVariantDetails", "")

let featureFlagAtom: Recoil.recoilAtom<FeatureFlagUtils.featureFlag> = Recoil.atom(
  "featureFlag",
  JSON.Encode.null->FeatureFlagUtils.featureFlagType,
)
let merchantSpecificConfigAtom: Recoil.recoilAtom<
  FeatureFlagUtils.merchantSpecificConfig,
> = Recoil.atom("merchantSpecificConfig", JSON.Encode.null->FeatureFlagUtils.merchantSpecificConfig)
let paypalAccountStatusAtom: Recoil.recoilAtom<PayPalFlowTypes.setupAccountStatus> = Recoil.atom(
  "paypalAccountStatusAtom",
  PayPalFlowTypes.Connect_paypal_landing,
)
// TODO: remove this after userGroupPermissionsAtom is stable
let userPermissionAtom: Recoil.recoilAtom<UserManagementTypes.groupAccessJsonType> = Recoil.atom(
  "userPermissionAtom",
  GroupACLMapper.defaultValueForGroupAccessJson,
)

let userGroupACLAtom: Recoil.recoilAtom<option<accessMapping>> = Recoil.atom(
  "userGroupACLAtom",
  None,
)

let switchMerchantListAtom: Recoil.recoilAtom<
  array<SwitchMerchantUtils.switchMerchantListResponse>,
> = Recoil.atom("switchMerchantListAtom", [SwitchMerchantUtils.defaultValue])

let currentTabNameRecoilAtom = Recoil.atom("currentTabName", "ActiveTab")

let globalSeacrchAtom: Recoil.recoilAtom<GlobalSearchTypes.defaultResult> = Recoil.atom(
  "globalSearch",
  {
    GlobalSearchTypes.local_results: [],
    remote_results: [],
    searchText: "",
  },
)

let orgListAtom: Recoil.recoilAtom<array<OMPSwitchTypes.orgList>> = Recoil.atom(
  "orgListAtom",
  [orgDefaultValue],
)

let merchantListAtom: Recoil.recoilAtom<array<OMPSwitchTypes.merchantList>> = Recoil.atom(
  "merchantListAtom",
  [merchantDefaultValue],
)

let profileListAtom: Recoil.recoilAtom<array<OMPSwitchTypes.profileList>> = Recoil.atom(
  "profileListAtom",
  [profileDefaultValue],
)

let moduleListRecoil: Recoil.recoilAtom<array<UserManagementTypes.userModuleType>> = Recoil.atom(
  "moduleListRecoil",
  [],
)

let isPlatform: Recoil.recoilAtom<bool> = Recoil.atom("isPlatform", false)
