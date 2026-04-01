@react.component
let make = (~children) => {
  let {devBlendEnabled} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  <BlendContext.Provider value=devBlendEnabled> children </BlendContext.Provider>
}
