let merchantDetailsValueAtom: Recoil.recoilAtom<HSwitchSettingTypes.merchantPayload> = Recoil.atom(.
  "merchantDetailsValue",
  JSON.Encode.null->MerchantAccountDetailsMapper.getMerchantDetails,
)

let businessProfilesAtom = Recoil.atom(.
  "businessProfileDetails",
  JSON.Encode.null->BusinessProfileMapper.getArrayOfBusinessProfile,
)

let connectorListAtom: Recoil.recoilAtom<string> = Recoil.atom(. "connectorListAtom", "")

let enumVariantAtom = Recoil.atom(. "enumVariantDetails", "")

let featureFlagAtom: Recoil.recoilAtom<FeatureFlagUtils.featureFlag> = Recoil.atom(.
  "featureFlag",
  JSON.Encode.null->FeatureFlagUtils.featureFlagType,
)
let paypalAccountStatusAtom: Recoil.recoilAtom<PayPalFlowTypes.setupAccountStatus> = Recoil.atom(.
  "paypalAccountStatusAtom",
  PayPalFlowTypes.Connect_paypal_landing,
)
let userPermissionAtom: Recoil.recoilAtom<UserManagementTypes.permissionJson> = Recoil.atom(.
  "userPermissionAtom",
  PermissionUtils.defaultValueForPermission,
)

let switchMerchantListAtom: Recoil.recoilAtom<
  array<SwitchMerchantUtils.switchMerchantListResponse>,
> = Recoil.atom(. "switchMerchantListAtom", [SwitchMerchantUtils.defaultValue])

let currentTabNameRecoilAtom = Recoil.atom(. "currentTabName", "ActiveTab")
