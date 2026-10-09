let featureFlagAtom: Recoil.recoilAtom<FeatureFlagUtils.featureFlag> = Recoil.atom(
  "featureFlag",
  JSON.Encode.null->FeatureFlagUtils.featureFlagType,
)
