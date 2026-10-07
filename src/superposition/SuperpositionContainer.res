@react.component
let make = () => {
  open HSwitchUtils
  open SuperpositionBindings

  let url = RescriptReactRouter.useUrl()

  let content = switch url.path->urlPath {
  | list{"configuration-management-default-config", ..._} =>
    <ConfigManager showResolvedValues=true editable=false />
  | list{"configuration-management-overrides", ..._} => <OverrideManager />
  | list{"configuration-management-dimensions", ..._} => <DimensionManager editable=false />
  | list{"configuration-management-audit", ..._} => <AuditTrail />
  | _ => <ConfigManager showResolvedValues=true editable=false />
  }

  <SuperpositionApp content />
}
