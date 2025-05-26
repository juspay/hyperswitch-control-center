open ReactHyperJs

let getOptionReturnUrl = (~themeConfig, ~returnUrl, ~showSavedCards) => {
  let layoutType = themeConfig->LogicUtils.getString("layout", "tabs")
  let isSpacedLayout = layoutType == "spaced"

  {
    displaySavedPaymentMethods: showSavedCards,
    showCardFormByDefault: false,
    wallets: {
      walletReturnUrl: returnUrl,
      applePay: "auto",
      googlePay: "auto",
      style: {
        theme: "dark",
        type_: "default",
        height: 48,
      },
    },
    layout: {
      \"type": isSpacedLayout ? "accordion" : layoutType,
      defaultCollapsed: false,
      radios: true,
      spacedAccordionItems: isSpacedLayout,
    },
  }
}
@react.component
let make = () => {
  open LogicUtils

  let {
    isGuestMode,
    paymentStatus,
    setPaymentStatus,
    paymentResult,
    setErrorMessage,
    sdkThemeInitialValues,
    initialValuesForCheckoutForm,
  } = React.useContext(SDKProvider.defaultContext)
  let returnUrl = {`${GlobalVars.getHostUrlWithBasePath}/sdk`}
  let themeConfig = sdkThemeInitialValues->getDictFromJsonObject
  let showSavedCards = !isGuestMode && initialValuesForCheckoutForm.show_saved_card === Some("yes")
  let paymentElementOptions = getOptionReturnUrl(~returnUrl, ~themeConfig, ~showSavedCards)

  let (error, setError) = React.useState(_ => None)
  let (btnState, setBtnState) = React.useState(_ => Button.Normal)
  let hyper = useHyper()
  let elements = useWidgets()
  let paymentResponseDict = paymentResult->getDictFromJsonObject
  let currency = paymentResponseDict->getString("currency", "USD")
  let amount = paymentResponseDict->getInt("amount", 0)->Int.toFloat

  let extractErrorMessage = responseDict => {
    let unifiedErrorMessage = responseDict->getString("unified_message", "")
    let errorMessage = responseDict->getString("error_message", "")
    unifiedErrorMessage->isNonEmptyString ? unifiedErrorMessage : errorMessage
  }

  let updatePaymentStatus = responseDict => {
    let status = responseDict->getOptionString("status")
    switch status {
    | Some("failed") => setPaymentStatus(_ => FAILED)
    | Some("succeeded") => setPaymentStatus(_ => SUCCESS)
    | _ => setPaymentStatus(_ => CUSTOMSTATE)
    }
  }

  let handleSubmit = async () => {
    setBtnState(_ => Button.Loading)
    try {
      let confirmParamsToPass = {
        "elements": elements,
        "confirmParams": [("return_url", returnUrl->JSON.Encode.string)]->getJsonFromArrayOfJson,
      }
      let res = await hyper.confirmPayment(confirmParamsToPass->Identity.genericTypeToJson)

      let responseDict = res->getDictFromJsonObject

      // Check for submitSuccessful: false and throw error
      if responseDict->getBool("submitSuccessful", true) === false {
        let errorDict = responseDict->getDictfromDict("error")
        let errorMessage = errorDict->getString("message", "Something went wrong")
        Js.Exn.raiseError(errorMessage)
      }

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
        setPaymentStatus(_ => FAILED)
        setError(_ => Some(err))
        setBtnState(_ => Button.Normal)
      }
    }
  }

  <div>
    {switch paymentStatus {
    | LOADING => <Loader />
    | INCOMPLETE =>
      <>
        <div className="w-full">
          <PaymentElement id="payment-element" options={paymentElementOptions} />
          <Button
            text={`Pay ${currency} ${(amount /. 100.00)->Float.toString}`}
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
      </>
    | _ => React.null
    }}
  </div>
}
