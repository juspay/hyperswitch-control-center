open ReactHyperJs

@react.component
let make = (
  ~publishableKey,
  ~paymentStatus,
  ~currency,
  ~setPaymentStatus,
  ~setErrorMessage,
  ~returnUrl,
  ~clientSecret,
  ~themeInitialValues,
) => {
  open LogicUtils
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)

  let themeDict = themeInitialValues->getDictFromJsonObject

  let paymentElementOptions = CheckoutHelper.getOptionReturnUrl(
    ~returnUrl,
    ~themeDict=themeInitialValues->getDictFromJsonObject,
  )

  let loadSDK = async () => {
    try {
      switch Window.env.sdkBaseUrl {
      | Some(url) => {
          let script = DOMUtils.document->DOMUtils.createElement("script")
          script->DOMUtils.setAttribute("src", url)
          DOMUtils.appendChild(script)
          let _ = Some(_ => script->DOMUtils.remove())
          await HyperSwitchUtils.delay(1000)
          setScreenState(_ => PageLoaderWrapper.Success)
        }
      | None => setScreenState(_ => Error("SDK URL Not Configured"))
      }
    } catch {
    | error => {
        Js.Console.error(error)
        setScreenState(_ => Error("Failed to load SDK"))
      }
    }
  }

  React.useEffect(() => {
    loadSDK()->ignore
    None
  }, [])

  let hyperPromise = React.useCallback(async () => {
    Window.loadHyper(
      publishableKey,
      [("isForceInit", true->JSON.Encode.bool)]->getJsonFromArrayOfJson,
    )
  }, [publishableKey])

  // Define element appearance options from theme settings
  let elementOptions: ReactHyperJs.optionsForElements = {
    clientSecret: clientSecret->Option.getOr(""),
    appearance: {
      theme: themeDict->getString("theme", "brutal"),
      labels: themeDict->getString("labels", "above"),
      variables: {
        colorPrimary: themeDict->getString("primary_color", "#fd1717"),
      },
    },
    locale: themeDict->getString("locale", "en-GB"),
  }

  <PageLoaderWrapper
    screenState
    customLoader={<div className="mt-60 w-screen flex flex-col justify-center items-center">
      <div className="animate-spin mb-1">
        <Icon name="spinner" size=20 />
      </div>
    </div>}
    sectionHeight="!h-screen">
    <div>
      {switch Window.checkLoadHyper {
      | Some(_) =>
        <Elements options={elementOptions} stripe={hyperPromise()}>
          <CheckoutForm
            paymentStatus currency setPaymentStatus setErrorMessage paymentElementOptions returnUrl
          />
        </Elements>
      | None => React.null
      }}
    </div>
  </PageLoaderWrapper>
}
