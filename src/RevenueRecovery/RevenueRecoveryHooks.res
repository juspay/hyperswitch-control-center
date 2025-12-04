let useGetDefaultPath = () => {
  let isLiveMode = (HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom).isLiveMode

  if isLiveMode {
    "/v2/recovery/invoices"
  } else {
    "/v2/recovery/overview"
  }
}
