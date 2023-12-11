let merchantDetailsValueAtom = Recoil.atom(. "merchantDetailsValue", "")

let businessProfilesAtom = Recoil.atom(. "businessProfileDetails", "")

let connectorListAtom: Recoil.recoilAtom<string> = Recoil.atom(. "connectorListAtom", "")

let enumVariantAtom = Recoil.atom(. "enumVariantDetails", "")

let featureFlagAtom: Recoil.recoilAtom<FeatureFlagUtils.featureFlag> = Recoil.atom(.
  "featureFlag",
  Js.Json.null->FeatureFlagUtils.featureFlagType,
)
