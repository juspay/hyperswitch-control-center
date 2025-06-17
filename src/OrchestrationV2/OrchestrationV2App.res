@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()

  switch url.path->HSwitchUtils.urlPath {
  | list{"v2", "orchestration-v2", "home", ..._} => <OrchestrationV2Home />
  | list{"v2", "orchestration-v2", "connectors", ..._} => <ConnectorContainerV2 />
  | _ => React.null
  }
}
