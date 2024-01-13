type buttonInfo = {
  isFirst: bool,
  isLast: bool,
}

let defaultButtonInfo = {
  isFirst: true,
  isLast: true,
}

let buttonGroupContext = React.createContext(defaultButtonInfo)

module Parent = {
  let make = React.Context.provider(buttonGroupContext)
}
