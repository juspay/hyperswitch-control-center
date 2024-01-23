open AuthTypes
@react.component
let make = (~isEnabled=true, ~permission, ~children) => {
  let isAccessAllowed = permission === Access
  isEnabled && isAccessAllowed ? children : <UnauthorizedPage />
}
