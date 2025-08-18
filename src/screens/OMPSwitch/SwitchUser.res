@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()
  let {setActiveProductValue} = React.useContext(ProductSelectionProvider.defaultContext)
  let internalSwitch = OMPSwitchHooks.useInternalSwitch(~setActiveProductValue)
  let switchUser = async () => {
    let val = url.search
    Js.log(val)
    None
  }
  React.useEffect(() => {
    switchUser()->ignore
    None
  }, [])
  React.null
}
