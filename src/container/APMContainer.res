@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()

  {
    switch url.path->HSwitchUtils.urlPath {
    | list{"apm"} => <AltPaymentMethods />
    | _ => React.null
    }
  }
}
