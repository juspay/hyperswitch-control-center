open CommonAuthTypes
@react.component
let make = (~isEnabled=true, ~authorization, ~children) => {
  let isAccessAllowed = authorization === Access
  isEnabled && isAccessAllowed ? children : <UnauthorizedPage />
}
