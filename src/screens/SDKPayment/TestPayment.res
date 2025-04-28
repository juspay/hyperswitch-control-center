module BasicAccountSetupSuccessfulPage = {
  @react.component
  let make = (
    ~iconName,
    ~statusText,
    ~buttonText,
    ~buttonOnClick,
    ~errorMessage="",
    ~customWidth="w-full",
    ~bgColor="bg-green-success_page_bg",
    ~buttonState=Button.Normal,
    ~isButtonVisible=true,
  ) => {
    let headerTextStyle = "text-xl font-semibold text-grey-700"
    <div className={`flex flex-col gap-4 p-9 h-full ${customWidth} justify-between rounded shadow`}>
      <div className={`p-4 h-5/6 ${bgColor} flex flex-col justify-center items-center gap-8`}>
        <Icon name=iconName size=120 />
        <AddDataAttributes attributes=[("data-testid", "paymentSuccess")]>
          <p className=headerTextStyle> {statusText->React.string} </p>
        </AddDataAttributes>
        <RenderIf condition={statusText == "Payment Failed"}>
          <p className="text-center"> {errorMessage->React.string} </p>
        </RenderIf>
      </div>
      <RenderIf condition={isButtonVisible}>
        <Button
          text=buttonText
          buttonSize={Large}
          buttonType={Primary}
          customButtonStyle="w-full"
          onClick={_ => buttonOnClick()}
          buttonState
        />
      </RenderIf>
    </div>
  }
}

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
  open ReactHyperJs

  let updateDetails = useUpdateMethod(~showErrorToast=false)
  let (clientSecret, setClientSecret) = React.useState(_ => None)
  let (paymentStatus, setPaymentStatus) = React.useState(_ => INCOMPLETE)
  let (paymentId, setPaymentId) = React.useState(_ => None)
  let (errorMessage, setErrorMessage) = React.useState(_ => "")
  let merchantDetailsValue = HSwitchUtils.useMerchantDetailsValue()
  let publishableKey = merchantDetailsValue.publishable_key
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
    try {
      let url = `${Window.env.apiBaseUrl}/payments`
      let paymentData = initialValues->Identity.genericTypeToJson->JSON.stringify->safeParse
      paymentData->getDictFromJsonObject->Dict.delete("country_currency")
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

  React.useEffect(() => {
    let status = filtersFromUrl->Dict.get("status")->Option.getOr("")->String.toLowerCase
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
    if status->String.length <= 0 && keyValue->isNonEmptyString {
      getClientSecret()->ignore
    }
    None
  }, [keyValue])

  <div className={`flex flex-col gap-12 h-full ${paymentStatusStyles}`}>
    {switch paymentStatus {
    | SUCCESS =>
      <BasicAccountSetupSuccessfulPage
        iconName="account-setup-completed"
        statusText="Payment Successful"
        buttonText=successButtonText
        buttonOnClick={_ => onProceed(~paymentId)->ignore}
        customWidth
        bgColor="bg-green-success_page_bg"
        isButtonVisible={paymentId->Option.isSome}
      />

    | FAILED(_err) =>
      <BasicAccountSetupSuccessfulPage
        iconName="account-setup-failed"
        statusText="Payment Failed"
        buttonText=successButtonText
        buttonOnClick={_ => onProceed(~paymentId)->ignore}
        errorMessage
        customWidth
        bgColor="bg-red-failed_page_bg"
        isButtonVisible={paymentId->Option.isSome}
      />
    | CHECKCONFIGURATION =>
      <BasicAccountSetupSuccessfulPage
        iconName="processing"
        statusText="Check your Configurations"
        buttonText=successButtonText
        buttonOnClick={_ => onProceed(~paymentId)->ignore}
        customWidth
        bgColor="bg-yellow-pending_page_bg"
        isButtonVisible={paymentId->Option.isSome}
      />

    | PROCESSING =>
      <BasicAccountSetupSuccessfulPage
        iconName="processing"
        statusText="Payment Pending"
        buttonText=successButtonText
        buttonOnClick={_ => onProceed(~paymentId)->ignore}
        customWidth
        bgColor="bg-yellow-pending_page_bg"
        isButtonVisible={paymentId->Option.isSome}
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
              paymentStatus
              setErrorMessage
              currency={initialValues.currency}
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
          paymentStatus
          setErrorMessage
          currency={initialValues.currency}
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
