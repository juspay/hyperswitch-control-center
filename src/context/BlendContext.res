let blendEnabledContext = React.createContext(false)

module Provider = {
  let make = React.Context.provider(blendEnabledContext)
}

let useBlendEnabled = () => {
  React.useContext(blendEnabledContext)
}
