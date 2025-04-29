open ReactHyperJs

module CheckoutForm = {
  @react.component
  let make = (
    ~paymentStatus,
    ~currency,
    ~setPaymentStatus,
    ~setErrorMessage,
    ~paymentElementOptions,
    ~returnUrl,
  ) => {
    let (error, setError) = React.useState(_ => None)
    let (btnState, setBtnState) = React.useState(_ => Button.Normal)
    let hyper = useHyper()
    let elements = useWidgets()

    // Helper function to extract and format error messages
    let extractErrorMessage = responseDict => {
      open LogicUtils
      let unifiedErrorMessage = responseDict->getString("unified_message", "")
      let errorMessage = responseDict->getString("error_message", "")
      unifiedErrorMessage->isNonEmptyString ? unifiedErrorMessage : errorMessage
    }

    // Helper to update payment status based on response
    let updatePaymentStatus = responseDict => {
      let status = responseDict->LogicUtils.getOptionString("status")
      switch status {
      | Some("failed") => setPaymentStatus(_ => FAILED("Failed"))
      | Some("succeeded") => setPaymentStatus(_ => SUCCESS)
      | _ => setPaymentStatus(_ => CUSTOMSTATE)
      }
    }

    let handleSubmit = async () => {
      open LogicUtils
      setBtnState(_ => Button.Loading)
      try {
        let confirmParamsToPass = {
          "elements": elements,
          "confirmParams": [("return_url", returnUrl->JSON.Encode.string)]->getJsonFromArrayOfJson,
        }
        let res = await hyper.confirmPayment(confirmParamsToPass->Identity.genericTypeToJson)
        let responseDict = res->getDictFromJsonObject

        // Handle error message extraction
        let uiErrorMessage = extractErrorMessage(responseDict)
        setErrorMessage(_ => uiErrorMessage)

        // Update payment status if not a validation error
        let errorDict = responseDict->getDictfromDict("error")
        if errorDict->getOptionString("type") !== Some("validation_error") {
          updatePaymentStatus(responseDict)
        }
        setBtnState(_ => Button.Normal)
      } catch {
      | Exn.Error(e) => {
          let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
          let formattedError = err->String.replace("\"", "")->String.replace("\"", "")

          if formattedError == "Something went wrong" {
            setPaymentStatus(_ => CUSTOMSTATE)
            setError(_ => None)
          } else {
            setPaymentStatus(_ => FAILED(formattedError))
            setError(_ => Some(formattedError))
          }
          setBtnState(_ => Button.Normal)
        }
      }
    }

    <div>
      {switch paymentStatus {
      | LOADING => <Loader />
      | INCOMPLETE =>
        <div className="grid grid-row-2 gap-5">
          <div className="row-span-1 bg-white rounded-lg py-6 px-10 flex-1">
            <PaymentElement id="payment-element" options={paymentElementOptions} />
            <Button
              text={`Pay ${currency} ${(5600.00 /. 100.00)->Float.toString}`}
              loadingText="Please wait..."
              buttonState=btnState
              buttonType={Primary}
              buttonSize={Large}
              customButtonStyle="mt-2 w-full rounded-md"
              onClick={_ => handleSubmit()->ignore}
            />
          </div>
          {switch error {
          | Some(errorMessage) => <div className="text-red-500"> {errorMessage->React.string} </div>
          | None => React.null
          }}
        </div>
      | _ => React.null
      }}
    </div>
  }
}

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
      innerLayout: "spaced",
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
