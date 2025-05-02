open ReactHyperJs

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
  let paymentElementOptions = CheckoutHelper.getOptionReturnUrl(
    ~returnUrl,
    ~themeConfig,
    ~showSavedCards,
  )

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
      <div className="grid grid-row-2 gap-5">
        <div className="row-span-1 bg-white rounded-lg py-6 px-10 flex-1">
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
      </div>
    | _ => React.null
    }}
  </div>
}
