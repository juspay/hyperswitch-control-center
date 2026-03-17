let blendEnabledContext = React.createContext(false)

module Provider = {
  let make = React.Context.provider(blendEnabledContext)
}

let useBlendEnabled = () => {
  let featureFlags = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  featureFlags.devBlendEnabled
}

@react.component
let make = (~children) => {
  let isBlendEnabled = useBlendEnabled()
  <Provider value=isBlendEnabled> children </Provider>
}
