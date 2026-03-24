let blendEnabledContext = React.createContext(false)

module Provider = {
  let make = React.Context.provider(blendEnabledContext)
}

let useBlendEnabled = () => {
  React.useContext(blendEnabledContext)
}

@react.component
let make = (~children) => {
  let {devBlendEnabled} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  <Provider value=devBlendEnabled> children </Provider>
}
