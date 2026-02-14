type accessMapping = {
  groups: Map.t<UserManagementTypes.groupAccessType, CommonAuthTypes.authorization>,
  resources: Map.t<UserManagementTypes.resourceAccessType, CommonAuthTypes.authorization>,
}
let ompDefaultValue: OMPSwitchTypes.ompListTypes = {id: "", name: ""}

let merchantDetailsValueAtom: Recoil.recoilAtom<HSwitchSettingTypes.merchantPayload> = Recoil.atom(
  "merchantDetailsValue",
  JSON.Encode.null->MerchantAccountDetailsMapper.getMerchantDetails,
)

let organizationDetailsValueAtom: Recoil.recoilAtom<OMPSwitchTypes.ompListTypes> = Recoil.atom(
  "organizationDetailsValue",
  ompDefaultValue,
)

let connectorListAtom: Recoil.recoilAtom<
  array<ConnectorTypes.connectorPayloadCommonType>,
> = Recoil.atom("connectorListAtom", [])

//Todo: remove this once we start using businessProfileInterface
let businessProfileFromIdAtom = Recoil.atom(
  "businessProfileFromIdAtom",
  JSON.Encode.null->BusinessProfileInterfaceUtilsV1.mapJsonToBusinessProfileV1,
)
//Todo:remove this after businessProfileInterface is stable
let businessProfileFromIdAtomInterface = Recoil.atom(
  "businessProfileFromIdAtomInterface",
  JSON.Encode.null->BusinessProfileInterfaceUtils.mapJsontoCommonType,
)

let themeListAtom: Recoil.recoilAtom<JSON.t> = Recoil.atom("themeListAtom", JSON.Encode.null)

let enumVariantAtom = Recoil.atom("enumVariantDetails", "")

let featureFlagAtom: Recoil.recoilAtom<FeatureFlagUtils.featureFlag> = Recoil.atom(
  "featureFlag",
  JSON.Encode.null->FeatureFlagUtils.featureFlagType,
)
let connectorListForLiveAtom: Recoil.recoilAtom<
  ConnectorListForLiveFromConfigUtils.connectorListForLive,
> = Recoil.atom(
  "connectorListForLive",
  JSON.Encode.null->ConnectorListForLiveFromConfigUtils.connectorListForLive,
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

let orgListAtom: Recoil.recoilAtom<array<OMPSwitchTypes.ompListTypes>> = Recoil.atom(
  "orgListAtom",
  [ompDefaultValue],
)

let merchantListAtom: Recoil.recoilAtom<array<OMPSwitchTypes.ompListTypes>> = Recoil.atom(
  "merchantListAtom",
  [ompDefaultValue],
)

let profileListAtom: Recoil.recoilAtom<array<OMPSwitchTypes.ompListTypes>> = Recoil.atom(
  "profileListAtom",
  [ompDefaultValue],
)

let moduleListRecoil: Recoil.recoilAtom<array<UserManagementTypes.userModuleType>> = Recoil.atom(
  "moduleListRecoil",
  [],
)
