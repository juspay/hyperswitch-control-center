@react.component
let make = () => {
  open HSwitchUtils

  let url = RescriptReactRouter.useUrl()

  if SuperpositionHooks.isConfigured() {
    switch url.path->urlPath {
    | list{"specializations", ..._} => <SuperpositionSpecializations />
    | list{"audit-log", ..._} => <SuperpositionAuditTrail showHeading=true />
    | _ => <SuperpositionFeatures />
    }
  } else {
    <NoDataFound message="Superposition configuration is missing" renderType=NotFound />
  }
}
