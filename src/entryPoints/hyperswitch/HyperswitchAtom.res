let merchantDetailsValueAtom = Recoil.atom(. "merchantDetailsValue", "")

let businessProfilesAtom = Recoil.atom(. "businessProfileDetails", "")

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
let userPermissionAtom: Recoil.recoilAtom<PermissionUtils.permissionJson> = Recoil.atom(.
  "userPermissionAtom",
  PermissionUtils.defaultValueForPermission,
)
