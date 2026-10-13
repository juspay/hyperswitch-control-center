open ReactHyperJs

let getOptionReturnUrl = (~themeConfig, ~returnUrl, ~showSavedCards) => {
  let layoutType = themeConfig->LogicUtils.getString("layout", "tabs")
  let isSpacedLayout = layoutType == "spaced"

  {
    displaySavedPaymentMethods: showSavedCards,
    showCardFormByDefault: false,
    subscriptionEvents: ["surchargeInfo", "appliedOffersInfo"],
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
  let (displaySurchargeAmount, setDisplaySurchargeAmount) = React.useState(_ => 0.0)
  let (offerAmountMinor, setOfferAmountMinor) = React.useState(_ => 0.0)
  let hyper = useHyper()
  let elements = useWidgets()
  let paymentResponseDict = paymentResult->getDictFromJsonObject
  let currency = paymentResponseDict->getString("currency", "USD")
  let amount = paymentResponseDict->getInt("amount", 0)->Int.toFloat

  let handlePaymentElementChange = event => {
    let eventDict = event->getDictFromJsonObject
    let payload = eventDict->getDictfromDict("payload")
    switch eventDict->getString("eventName", "") {
    | "surchargeInfo" =>
      setDisplaySurchargeAmount(_ => payload->getFloat("displayTotalSurchargeAmount", 0.0))
    | "appliedOffersInfo" =>
      let discount =
        payload
        ->getArrayFromDict("offers", [])
        ->Array.reduce(0.0, (total, offer) => {
          let offerDict = offer->getDictFromJsonObject
          if offerDict->getString("currency", "") === currency {
            total +. offerDict->getFloat("offerAmount", 0.0)
          } else {
            total
          }
        })
      setOfferAmountMinor(_ => discount)
    | _ => ()
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
      | RequiresCapture => setPaymentStatus(_ => REQUIRESCAPTURE)
      | RequiresCustomerAction
      | RequiresMerchantAction
      | RequiresPaymentMethod
      | RequiresConfirmation =>
        setPaymentStatus(_ => CHECKCONFIGURATION)
      | Cancelled
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

  // Offers use minor units; the SDK's display surcharge already uses major units.
  let payableAmount = Math.max(
    CurrencyUtils.convertCurrencyFromLowestDenomination(
      ~amount=amount -. offerAmountMinor,
      ~currency,
    ) +.
    displaySurchargeAmount,
    0.0,
  )
  let displayAmount =
    payableAmount->Float.toFixedWithPrecision(
      ~digits=CurrencyUtils.getAmountPrecisionDigits(currency),
    )

  <div>
    {switch paymentStatus {
    | LOADING => <Loader />
    | INCOMPLETE =>
      <>
        <div className="w-full">
          <PaymentElement
            id="payment-element" options={paymentElementOptions} onChange=handlePaymentElementChange
          />
          <Button
            text={`Pay ${currency} ${displayAmount}`}
            dataTestId="sdk-pay-button"
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
