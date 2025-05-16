open ReactHyperJs

@react.component
let make = () => {
  open LogicUtils

  let {paymentResult, sdkThemeInitialValues} = React.useContext(SDKProvider.defaultContext)
  let (isScriptLoaded, setIsScriptLoaded) = React.useState(() => false)
  let (isHyperReady, setIsHyperReady) = React.useState(() => false)

  let publishableKey = Recoil.useRecoilValueFromAtom(
    HyperswitchAtom.merchantDetailsValueAtom,
  ).publishable_key

  let clientSecret = paymentResult->getDictFromJsonObject->getString("client_secret", "")
  let themeConfig = sdkThemeInitialValues->getDictFromJsonObject

  let loadDOM = async () => {
    try {
      switch Window.env.sdkBaseUrl {
      | Some(url) => {
          let script = DOMUtils.document->DOMUtils.createElement("script")
          script->DOMUtils.setAttribute("src", url)
          script->DOMUtils.elementOnload(_ => setIsScriptLoaded(_ => true))
          DOMUtils.appendChild(script)
        }
      | None => ()
      }
    } catch {
    | _ => ()
    }
  }

  React.useEffect(() => {
    loadDOM()->ignore
    None
  }, [])

  React.useEffect(() => {
    if isScriptLoaded {
      setIsHyperReady(_ => true)
    }
    None
  }, (isScriptLoaded, Window.checkLoadHyper))

  let hyperPromise = React.useCallback(async () => {
    Window.loadHyper(
      publishableKey,
      [("isForceInit", true->JSON.Encode.bool)]->LogicUtils.getJsonFromArrayOfJson,
    )
  }, [publishableKey])

  // Define element appearance options from theme settings
  let elementOptions: ReactHyperJs.optionsForElements = {
    clientSecret,
    appearance: {
      theme: themeConfig->getString("theme", "brutal"),
      labels: themeConfig->getString("labels", "above"),
      variables: {
        colorPrimary: themeConfig->getString("primary_color", "#006DF9"),
      },
    },
    locale: themeConfig->getString("locale", "en-GB"),
  }

  <div>
    {switch (isScriptLoaded, isHyperReady) {
    | (true, true) =>
      <Elements options=elementOptions stripe={hyperPromise()}>
        <CheckoutForm />
      </Elements>
    | _ => React.null
    }}
  </div>
}
