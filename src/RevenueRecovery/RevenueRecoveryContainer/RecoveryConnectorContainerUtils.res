let useGetDefaultPath = () => {
  let isLiveMode = (HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom).isLiveMode

  if isLiveMode {
    "/dashboard/v2/recovery/invoices"
  } else {
    "/dashboard/v2/recovery/overview"
  }
}
