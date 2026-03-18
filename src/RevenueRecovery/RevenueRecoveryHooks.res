let useGetDefaultPath = () => {
  let isLiveMode = (HyperswitchAtom.featureFlagAtom->Jotai.useAtomValue).isLiveMode

  if isLiveMode {
    "/v2/recovery/invoices"
  } else {
    "/v2/recovery/overview"
  }
}
