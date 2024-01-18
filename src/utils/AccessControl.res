open AuthTypes
@react.component
let make = (~isEnabled=true, ~permission=NoAccess, ~children) => {
  let isAccessAllowed = permission === Access
  isEnabled && isAccessAllowed ? children : <UnauthorizedPage />
}
