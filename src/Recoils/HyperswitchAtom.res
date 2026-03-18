type accessMapping = {
  groups: Map.t<UserManagementTypes.groupAccessType, CommonAuthTypes.authorization>,
  resources: Map.t<UserManagementTypes.resourceAccessType, CommonAuthTypes.authorization>,
}
let ompDefaultValue: OMPSwitchTypes.ompListTypes = {id: "", name: ""}

let merchantDetailsValueAtom: Jotai.jotaiAtom<HSwitchSettingTypes.merchantPayload> = Jotai.atom(
  "merchantDetailsValue",
  JSON.Encode.null->MerchantAccountDetailsMapper.getMerchantDetails,
)

let organizationDetailsValueAtom: Jotai.jotaiAtom<OMPSwitchTypes.ompListTypes> = Jotai.atom(
  "organizationDetailsValue",
  ompDefaultValue,
)

let connectorListAtom: Jotai.jotaiAtom<
  array<ConnectorTypes.connectorPayloadCommonType>,
> = Jotai.atom("connectorListAtom", [])

//Todo: remove this once we start using businessProfileInterface
let businessProfileFromIdAtom = Jotai.atom(
  "businessProfileFromIdAtom",
  JSON.Encode.null->BusinessProfileInterfaceUtilsV1.mapJsonToBusinessProfileV1,
)
//Todo:remove this after businessProfileInterface is stable
let businessProfileFromIdAtomInterface = Jotai.atom(
  "businessProfileFromIdAtomInterface",
  JSON.Encode.null->BusinessProfileInterfaceUtils.mapJsontoCommonType,
)

let themeListAtom: Jotai.jotaiAtom<JSON.t> = Jotai.atom("themeListAtom", JSON.Encode.null)

let enumVariantAtom = Jotai.atom("enumVariantDetails", "")

let featureFlagAtom: Jotai.jotaiAtom<FeatureFlagUtils.featureFlag> = Jotai.atom(
  "featureFlag",
  JSON.Encode.null->FeatureFlagUtils.featureFlagType,
)
let connectorListForLiveAtom: Jotai.jotaiAtom<
  ConnectorListForLiveFromConfigTypes.connectorListForLive,
> = Jotai.atom(
  "connectorListForLive",
  JSON.Encode.null->ConnectorListForLiveFromConfigUtils.getConnectorListForLive,
)
let merchantSpecificConfigAtom: Jotai.jotaiAtom<
  FeatureFlagUtils.merchantSpecificConfig,
> = Jotai.atom("merchantSpecificConfig", JSON.Encode.null->FeatureFlagUtils.merchantSpecificConfig)
let paypalAccountStatusAtom: Jotai.jotaiAtom<PayPalFlowTypes.setupAccountStatus> = Jotai.atom(
  "paypalAccountStatusAtom",
  PayPalFlowTypes.Connect_paypal_landing,
)
// TODO: remove this after userGroupPermissionsAtom is stable
let userPermissionAtom: Jotai.jotaiAtom<UserManagementTypes.groupAccessJsonType> = Jotai.atom(
  "userPermissionAtom",
  GroupACLMapper.defaultValueForGroupAccessJson,
)

let userGroupACLAtom: Jotai.jotaiAtom<option<accessMapping>> = Jotai.atom("userGroupACLAtom", None)

let switchMerchantListAtom: Jotai.jotaiAtom<
  array<SwitchMerchantUtils.switchMerchantListResponse>,
> = Jotai.atom("switchMerchantListAtom", [SwitchMerchantUtils.defaultValue])

let currentTabNameRecoilAtom = Jotai.atom("currentTabName", "ActiveTab")

let globalSeacrchAtom: Jotai.jotaiAtom<GlobalSearchTypes.defaultResult> = Jotai.atom(
  "globalSearch",
  {
    GlobalSearchTypes.local_results: [],
    remote_results: [],
    searchText: "",
  },
)

let orgListAtom: Jotai.jotaiAtom<array<OMPSwitchTypes.ompListTypes>> = Jotai.atom(
  "orgListAtom",
  [ompDefaultValue],
)

let merchantListAtom: Jotai.jotaiAtom<array<OMPSwitchTypes.ompListTypes>> = Jotai.atom(
  "merchantListAtom",
  [ompDefaultValue],
)

let profileListAtom: Jotai.jotaiAtom<array<OMPSwitchTypes.ompListTypes>> = Jotai.atom(
  "profileListAtom",
  [ompDefaultValue],
)

let moduleListRecoil: Jotai.jotaiAtom<array<UserManagementTypes.userModuleType>> = Jotai.atom(
  "moduleListRecoil",
  [],
)

let orchestrationVaultAtom: Jotai.jotaiAtom<bool> = Jotai.atom("orchestrationVaultAtom", false)
