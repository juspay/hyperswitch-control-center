@react.component
let make = () => {
  open HSwitchUtils
  let pageViewEvent = MixpanelHook.usePageView()
  let url = RescriptReactRouter.useUrl()

  {
    switch url.path->urlPath {
    | list{"v2", "recon", "home"} => <div> {"Home"->React.string} </div>
    | list{"v2", "recon", "analytics"} => <div> {"analytics"->React.string} </div>
    | _ => React.null
    }
  }
}
