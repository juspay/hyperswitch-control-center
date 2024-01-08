@react.component
let make = (
  ~returnUrl,
  ~onProceed: (~paymentId: option<string>) => promise<unit>,
  ~sdkWidth="w-[60%]",
  ~isTestCredsNeeded=true,
  ~customWidth="w-full md:w-1/2",
  ~paymentStatusStyles="p-11",
  ~successButtonText="Proceed",
  ~keyValue,
  ~initialValues: SDKPaymentTypes.paymentType,
) => {
  open APIUtils
  open LogicUtils
  open HyperSwitchTypes

  let updateDetails = useUpdateMethod(~showErrorToast=false, ())
  let (clientSecret, setClientSecret) = React.useState(_ => None)
  let (paymentStatus, setPaymentStatus) = React.useState(_ => INCOMPLETE)
  let (paymentId, setPaymentId) = React.useState(_ => None)
  let merchantDetailsValue = HSwitchUtils.useMerchantDetailsValue()
  let publishableKey = merchantDetailsValue->getDictFromJsonObject->getString("publishable_key", "")
  let paymentElementOptions = CheckoutHelper.getOptionReturnUrl(returnUrl)
  let elementOptions = CheckoutHelper.getOption(clientSecret)
  let url = RescriptReactRouter.useUrl()
  let searchParams = url.search
  let filtersFromUrl = getDictFromUrlSearchParams(searchParams)

  let getClientSecretFromPaymentId = (~paymentIntentClientSecret) => {
    switch paymentIntentClientSecret {
    | Some(paymentIdFromClientSecret) =>
      let paymentClientSecretSplitArray = paymentIdFromClientSecret->String.split("_")
      Some(
        `${paymentClientSecretSplitArray->LogicUtils.getValueFromArray(
            0,
            "",
          )}_${paymentClientSecretSplitArray->LogicUtils.getValueFromArray(1, "")}`,
      )

    | None => None
    }
  }

  let getClientSecret = async () => {
    open SDKPaymentUtils
    try {
      let url = `${HSwitchGlobalVars.hyperSwitchApiPrefix}/payments`
      let paymentData =
        initialValues
        ->Identity.genericTypeToJson
        ->Js.Json.stringify
        ->safeParse
        ->getTypedValueForPayment
      paymentData.currency = paymentData.currency->getCurrencyValue
      let body = paymentData->Identity.genericTypeToJson
      let response = await updateDetails(url, body, Post)
      let clientSecret = response->getDictFromJsonObject->getOptionString("client_secret")
      setPaymentId(_ => response->getDictFromJsonObject->getOptionString("payment_id"))
      setClientSecret(_ => clientSecret)
      setPaymentStatus(_ => INCOMPLETE)
    } catch {
    | _ => setPaymentStatus(_ => FAILED(""))
    }
  }

  React.useEffect1(() => {
    let status =
      filtersFromUrl->Dict.get("status")->Belt.Option.getWithDefault("")->String.toLowerCase
    let paymentIdFromPaymemtIntentClientSecret = getClientSecretFromPaymentId(
      ~paymentIntentClientSecret=url.search
      ->LogicUtils.getDictFromUrlSearchParams
      ->Dict.get("payment_intent_client_secret"),
    )
    if status === "succeeded" {
      setPaymentStatus(_ => SUCCESS)
    } else if status === "failed" {
      setPaymentStatus(_ => FAILED(""))
    } else if status === "processing" {
      setPaymentStatus(_ => PROCESSING)
    } else {
      setPaymentStatus(_ => INCOMPLETE)
    }
    setPaymentId(_ => paymentIdFromPaymemtIntentClientSecret)
    if status->String.length <= 0 && keyValue->String.length > 0 {
      getClientSecret()->ignore
    }
    None
  }, [keyValue])

  <div className={`flex flex-col gap-12 h-full ${paymentStatusStyles}`}>
    {switch paymentStatus {
    | SUCCESS =>
      <ProdOnboardingUIUtils.BasicAccountSetupSuccessfulPage
        iconName="account-setup-completed"
        statusText="Payment Successful"
        buttonText=successButtonText
        buttonOnClick={_ => onProceed(~paymentId)->ignore}
        customWidth
        bgColor="bg-green-success_page_bg"
        isButtonVisible={paymentId->Belt.Option.isSome}
      />

    | FAILED(_err) =>
      <ProdOnboardingUIUtils.BasicAccountSetupSuccessfulPage
        iconName="account-setup-failed"
        statusText="Payment Failed"
        buttonText=successButtonText
        buttonOnClick={_ => onProceed(~paymentId)->ignore}
        customWidth
        bgColor="bg-red-failed_page_bg"
        isButtonVisible={paymentId->Belt.Option.isSome}
      />
    | CHECKCONFIGURATION =>
      <ProdOnboardingUIUtils.BasicAccountSetupSuccessfulPage
        iconName="processing"
        statusText="Check your Configurations"
        buttonText=successButtonText
        buttonOnClick={_ => onProceed(~paymentId)->ignore}
        customWidth
        bgColor="bg-yellow-pending_page_bg"
        isButtonVisible={paymentId->Belt.Option.isSome}
      />

    | PROCESSING =>
      <ProdOnboardingUIUtils.BasicAccountSetupSuccessfulPage
        iconName="processing"
        statusText="Payment Pending"
        buttonText=successButtonText
        buttonOnClick={_ => onProceed(~paymentId)->ignore}
        customWidth
        bgColor="bg-yellow-pending_page_bg"
        isButtonVisible={paymentId->Belt.Option.isSome}
      />
    | _ => React.null
    }}
    {switch clientSecret {
    | Some(val) =>
      if isTestCredsNeeded {
        <div className="flex gap-8">
          <div className=sdkWidth>
            <WebSDK
              clientSecret=val
              publishableKey
              sdkType=ELEMENT
              paymentStatus
              currency={initialValues.currency->SDKPaymentUtils.getCurrencyValue}
              setPaymentStatus
              elementOptions
              paymentElementOptions
              returnUrl
              amount={initialValues.amount}
              setClientSecret
            />
          </div>
          <TestCredentials />
        </div>
      } else {
        <WebSDK
          clientSecret=val
          publishableKey
          sdkType=ELEMENT
          paymentStatus
          currency={initialValues.currency->SDKPaymentUtils.getCurrencyValue}
          setPaymentStatus
          elementOptions
          paymentElementOptions
          returnUrl
          amount={initialValues.amount}
          setClientSecret
        />
      }
    | None => React.null
    }}
  </div>
}
