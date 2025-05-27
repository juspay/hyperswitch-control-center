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

  let handleSubmit = async () => {
    setBtnState(_ => Button.Loading)
    try {
      let confirmParamsToPass = {
        "elements": elements,
        "confirmParams": [("return_url", returnUrl->JSON.Encode.string)]->getJsonFromArrayOfJson,
      }
      let res = await hyper.confirmPayment(confirmParamsToPass->Identity.genericTypeToJson)

      let responseDict = res->getDictFromJsonObject
      let status = responseDict->getString("status", "")
      let statusType = PaymentsLifeCycleUtils.getstatusVariantTypeFromString(status)

      // Check for submitSuccessful: false and throw error
      if !(responseDict->getBool("submitSuccessful", true)) {
        let errorType =
          responseDict->getDictfromDict("error")->getString("type", "Something went wrong")
        Js.Exn.raiseError(errorType)
      }

      // Handle error message extraction
      setErrorMessage(_ =>
        `${(statusType :> string)} - ${responseDict->getString("error_message", "")}`
      )

      switch statusType {
      | Succeeded => setPaymentStatus(_ => SUCCESS)
      | Failed => setPaymentStatus(_ => FAILED)
      | Processing => setPaymentStatus(_ => PROCESSING)
      | RequiresCustomerAction
      | RequiresMerchantAction
      | RequiresPaymentMethod
      | RequiresConfirmation =>
        setPaymentStatus(_ => CHECKCONFIGURATION)
      | Cancelled
      | RequiresCapture
      | PartiallyCaptured
      | PartiallyCapturedAndCapturable
      | Full_Refunded
      | Partial_Refunded
      | Dispute_Present
      | Null =>
        setPaymentStatus(_ => CUSTOMSTATE)
      }
      setBtnState(_ => Button.Normal)
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
        if err !== "validation_error" {
          setPaymentStatus(_ => FAILED)
          setError(_ => Some(err))
        }
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
