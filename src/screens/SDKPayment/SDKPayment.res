@react.component
let make = (
  ~isLoading,
  ~clientSecret,
  ~themeInitialValues,
  ~paymentResponse,
  ~paymentStatus,
  ~setPaymentStatus,
  ~setErrorMessage,
  ~paymentElementOptions,
  ~returnUrl,
  ~setClientSecret,
) => {
  open LogicUtils

  let paymentResponseDict = paymentResponse->getDictFromJsonObject

  let publishableKey = Recoil.useRecoilValueFromAtom(
    HyperswitchAtom.merchantDetailsValueAtom,
  ).publishable_key

  let themeDict = themeInitialValues->getDictFromJsonObject

  let elementOptions: ReactHyperJs.optionsForElements = {
    clientSecret: clientSecret->Option.getOr(""),
    appearance: {
      theme: themeDict->getString("theme", "brutal"),
      labels: themeDict->getString("labels", "above"),
      variables: {
        colorPrimary: themeDict->getString("primary_color", "#fd1717"),
      },
      innerLayout: "spaced",
    },
    locale: themeDict->getString("locale", "en-GB"),
  }

  let loadDOM = async () => {
    try {
      switch Window.env.sdkBaseUrl {
      | Some(url) => {
          let script = DOMUtils.document->DOMUtils.createElement("script")
          script->DOMUtils.setAttribute("src", url)
          DOMUtils.appendChild(script)
          let _ = Some(_ => script->DOMUtils.remove())
          await HyperSwitchUtils.delay(1000)
          // setScreenState(_ => PageLoaderWrapper.Success)
        }
      | None => ()
      // setScreenState(_ => Error("URL Not Configured"))
      }
    } catch {
    | _ => ()
    // setScreenState(_ => Error(""))
    }
  }
  React.useEffect(() => {
    loadDOM()->ignore
    None
  }, [])

  let hyperPromise = React.useCallback(async () => {
    Window.loadHyper(
      publishableKey,
      [("isForceInit", true->JSON.Encode.bool)]->LogicUtils.getJsonFromArrayOfJson,
    )
  }, [publishableKey])

  <div className="w-3/4 flex flex-col p-5 overflow-auto bg-[rgba(124,255,112,0.54)]">
    {switch (isLoading, clientSecret) {
    | (true, None) =>
      <img alt="blurry-sdk" src="/assets/BlurrySDK.svg" height="500px" width="400px" />
    | _ =>
      <WebSDK
        clientSecret
        publishableKey
        paymentStatus
        currency={paymentResponseDict->getString("currency", "USD")}
        setPaymentStatus
        setErrorMessage
        elementOptions
        theme=""
        primaryColor=""
        bgColor=""
        fontFamily=""
        fontSizeBase=""
        paymentElementOptions
        returnUrl
        layout=""
        methodsOrder=[]
        saveViewToSdk=false
        isSpaceAccordion=false
        amount=65400.00
        setClientSecret
      />
    }}
  </div>
}
