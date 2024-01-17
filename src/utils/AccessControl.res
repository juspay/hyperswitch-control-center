open PermissionUtils
let isAccessAllowed = permission =>
  getAccessValue(~permissionValue=permission, ~permissionList=[]) !== NoAccess

@react.component
let make = (~isEnabled, ~acl=?, ~children) => {
  let {setDashboardPageState} = React.useContext(GlobalProvider.defaultContext)

  let updateRoute = () => {
    Js.log("jnjdcjscsndn inside")
    setDashboardPageState(_ => #HOME)
    RescriptReactRouter.replace("/home")
    React.null
  }

  Js.log("jnjdcjscsndn")

  let abc = isAccessAllowed(acl->Option.getWithDefault(UnknownPermission("")))

  Js.log2("jnjdcjscsndn abcabcabc", abc)
  let r = false

  isEnabled ? children : updateRoute()
}
