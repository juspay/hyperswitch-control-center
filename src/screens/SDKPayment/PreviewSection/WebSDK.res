open ReactHyperJs

@react.component
let make = () => {
  open LogicUtils

  let {paymentResult, sdkThemeInitialValues} = React.useContext(SDKProvider.defaultContext)
  let (hyperPromise, setHyperPromise) = React.useState(() => None)

  let publishableKey = Recoil.useRecoilValueFromAtom(
    HyperswitchAtom.merchantDetailsValueAtom,
  ).publishable_key

  let clientSecret = paymentResult->getDictFromJsonObject->getString("client_secret", "")
  let themeConfig = sdkThemeInitialValues->getDictFromJsonObject

  let loadSDK = async () => {
    try {
      switch Window.env.sdkBaseUrl {
      | Some(url) => {
          let script = DOMUtils.document->DOMUtils.createElement("script")
          script->DOMUtils.setAttribute("src", url)
          DOMUtils.appendChild(script)
          let _ = Some(_ => script->DOMUtils.remove())
          await HyperSwitchUtils.delay(1000)
        }
      | None => ()
      }
    } catch {
    | error => Console.error(error)
    }
  }

  React.useEffect(() => {
    loadSDK()->ignore
    None
  }, [])

  React.useEffect1(() => {
    let promise = ReactHyperJs.loadHyper(
      publishableKey,
      [("isForceInit", true->Js.Json.boolean)]->getJsonFromArrayOfJson,
    )
    setHyperPromise(_ => Some(promise))
    None
  }, [publishableKey])

  // Define element appearance options from theme settings
  let elementOptions: ReactHyperJs.optionsForElements = {
    clientSecret,
    appearance: {
      theme: themeConfig->getString("theme", "brutal"),
      labels: themeConfig->getString("labels", "above"),
      variables: {
        colorPrimary: themeConfig->getString("primary_color", "#fd1717"),
      },
    },
    locale: themeConfig->getString("locale", "en-GB"),
  }

  <div className="w-4/5">
    {switch hyperPromise {
    | Some(p) =>
      <ReactHyperJs.Elements options=elementOptions stripe=p>
        <CheckoutForm />
      </ReactHyperJs.Elements>
    | _ => React.null
    }}
  </div>
}
