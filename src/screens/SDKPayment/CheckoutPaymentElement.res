@react.component
let make = (~themeInitialValues, ~paymentResponse) => {
  open ReactHyperJs
  open LogicUtils

  let hyper = useHyper()
  let elements = useWidgets()

  let paymentResponseDict = paymentResponse->getDictFromJsonObject
  let currency = paymentResponseDict->getString("currency", "USD")
  let amount = paymentResponseDict->getInt("amount", 10000)->Int.toFloat

  let (errorMessage, setErrorMessage) = React.useState(_ => "")
  let (paymentStatus, setPaymentStatus) = React.useState(_ => INCOMPLETE)

  let (btnState, setBtnState) = React.useState(_ => Button.Normal)
  let themeDict = themeInitialValues->getDictFromJsonObject
  let layoutType = themeDict->getString("layout", "tabs")
  let isSpacedLayout = layoutType == "spaced"
  let primaryColor = `bg-[${themeDict->getString("primary_color", "#fd1717")}]`

  let paymentElementOptions: checkoutElementOptions = {
    layout: {
      \"type": isSpacedLayout ? "accordion" : layoutType,
      defaultCollapsed: false,
      radios: true,
      spacedAccordionItems: isSpacedLayout,
    },
    sdkHandleConfirmPayment: {
      handleConfirm: true,
      buttonText: "SDK Pay Now",
      confirmParams: {
        return_url: "https://example.com/complete",
      },
    },
  }

  React.useEffect(() => {
    let paymentElement = elements.getElement("payment")
    switch paymentElement->Nullable.toOption {
    | Some(ele) => ele.update(paymentElementOptions->Identity.genericTypeToJson)
    | None => ()
    }
    None
  }, [elements])

  let handleSubmit = async () => {
    try {
      let confirmParamsToPass = {
        "elements": elements,
        "confirmParams": [("return_url", "returnUrl"->JSON.Encode.string)]->getJsonFromArrayOfJson,
      }
      let res = await hyper.confirmPayment(confirmParamsToPass->Identity.genericTypeToJson)
      let responseDict = res->getDictFromJsonObject

      let unifiedErrorMessage = responseDict->getString("unified_message", "")
      let errorMessage = responseDict->getString("error_message", "")
      let uiErrorMessage =
        unifiedErrorMessage->isNonEmptyString ? unifiedErrorMessage : errorMessage
      setErrorMessage(_ => uiErrorMessage)

      let errorDict = responseDict->getDictfromDict("error")
      if errorDict->getOptionString("type") !== Some("validation_error") {
        let status = responseDict->getOptionString("status")
        switch status {
        | Some(str) =>
          switch str {
          | "failed" => setPaymentStatus(_ => FAILED("Failed"))
          | "succeeded" => setPaymentStatus(_ => SUCCESS)
          | _ => setPaymentStatus(_ => CUSTOMSTATE)
          }
        | None => setPaymentStatus(_ => CUSTOMSTATE)
        }
      }
    } catch {
    | Exn.Error(e) => {
        Js.log2("hbcdsbhdnjsnd", e)
        let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
        let str = err->String.replace("\"", "")->String.replace("\"", "")
        if str == "Something went wrong" {
          setPaymentStatus(_ => CUSTOMSTATE)
        } else {
          setPaymentStatus(_ => FAILED(err))
        }
      }
    }
    setBtnState(_ => Button.Normal)
  }

  <>
    <PaymentElement id="paymentElement" options=paymentElementOptions />
    <Button
      text={`Pay ${currency} ${(amount /. 100.00)->Float.toString}`}
      loadingText="Please wait..."
      buttonState=btnState
      buttonType={Primary}
      buttonSize={Large}
      customButtonStyle={`mt-2 w-full rounded-md !${primaryColor}`}
      onClick={_ => {
        setBtnState(_ => Button.Loading)
        handleSubmit()->ignore
      }}
    />
  </>
}
