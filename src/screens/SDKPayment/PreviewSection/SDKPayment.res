module PaymentStatusPage = {
  type statusConfig = {
    iconName: string,
    statusText: string,
    bgColor: string,
    showErrorMessage: bool,
  }

  @react.component
  let make = (
    ~config,
    ~buttonText=?,
    ~buttonOnClick=?,
    ~buttonState=Button.Normal,
    ~isButtonVisible=true,
  ) => {
    let {errorMessage} = React.useContext(SDKProvider.defaultContext)
    let headerTextStyle = "text-xl font-semibold text-grey-700"

    <div className="w-4/5 flex flex-col gap-4 p-9 h-full w-full justify-between rounded shadow">
      <div
        className={`p-4 h-5/6 ${config.bgColor} flex flex-col justify-center items-center gap-8`}>
        <Icon name=config.iconName size=120 />
        <AddDataAttributes attributes=[("data-testid", "paymentStatus")]>
          <p className=headerTextStyle> {config.statusText->React.string} </p>
        </AddDataAttributes>
        <RenderIf condition={config.showErrorMessage}>
          <p className="text-center"> {errorMessage->React.string} </p>
        </RenderIf>
      </div>
      <RenderIf
        condition={isButtonVisible && buttonText->Option.isSome && buttonOnClick->Option.isSome}>
        <Button
          text={buttonText->Option.getExn}
          buttonSize={Large}
          buttonType={Primary}
          customButtonStyle="w-full"
          onClick={buttonOnClick->Option.getExn}
          buttonState
        />
      </RenderIf>
    </div>
  }
}

@react.component
let make = (
  ~checkIsSDKOpen: SDKPaymentUtils.sdkHandlingTypes,
  ~setCheckIsSDKOpen,
  ~initialValuesForCheckoutForm,
) => {
  open ReactHyperJs

  let url = RescriptReactRouter.useUrl()
  let filtersFromUrl = url.search->LogicUtils.getDictFromUrlSearchParams
  let (paymentIdFromUrl, setPaymentIdFromUrl) = React.useState(_ => None)
  let {paymentResult, paymentStatus, setPaymentStatus} = React.useContext(
    SDKProvider.defaultContext,
  )
  let {userInfo: {orgId, merchantId, profileId}} = React.useContext(UserInfoProvider.defaultContext)

  let paymentId = if paymentIdFromUrl->Option.isSome {
    paymentIdFromUrl
  } else {
    paymentResult->LogicUtils.getDictFromJsonObject->LogicUtils.getOptionString("payment_id")
  }

  let successButtonText: string = "Go to Payment Operations"

  let onProceed = async () => {
    switch paymentId {
    | Some(val) =>
      RescriptReactRouter.replace(
        GlobalVars.appendDashboardPath(~url=`/payments/${val}/${profileId}/${merchantId}/${orgId}`),
      )
    | None => ()
    }
  }

  let getStatusConfig = (status): PaymentStatusPage.statusConfig => {
    switch status {
    | SUCCESS => {
        iconName: "account-setup-completed",
        statusText: "Payment Successful",
        bgColor: "bg-green-success_page_bg",
        showErrorMessage: false,
      }
    | FAILED => {
        iconName: "account-setup-failed",
        statusText: "Payment Failed",
        bgColor: "bg-red-failed_page_bg",
        showErrorMessage: true,
      }
    | CHECKCONFIGURATION => {
        iconName: "processing",
        statusText: "Check your Configurations",
        bgColor: "bg-yellow-pending_page_bg",
        showErrorMessage: false,
      }
    | PROCESSING => {
        iconName: "processing",
        statusText: "Payment Pending",
        bgColor: "bg-yellow-pending_page_bg",
        showErrorMessage: false,
      }
    | _ => {
        iconName: "",
        statusText: "",
        bgColor: "",
        showErrorMessage: false,
      }
    }
  }

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

  React.useEffect(() => {
    open SDKPaymentUtils

    let status = filtersFromUrl->Dict.get("status")->Option.getOr("")->String.toLowerCase
    let paymentIdFromPaymemtIntentClientSecret = getClientSecretFromPaymentId(
      ~paymentIntentClientSecret=url.search
      ->LogicUtils.getDictFromUrlSearchParams
      ->Dict.get("payment_intent_client_secret"),
    )

    if paymentIdFromPaymemtIntentClientSecret->Option.isSome {
      setCheckIsSDKOpen(_ => {
        initialPreview: false,
        isLoaded: false,
        isLoading: false,
        isError: false,
      })
    }

    if status === "succeeded" {
      setPaymentStatus(_ => SUCCESS)
    } else if status === "failed" {
      setPaymentStatus(_ => FAILED)
    } else if status === "processing" {
      setPaymentStatus(_ => PROCESSING)
    } else {
      setPaymentStatus(_ => INCOMPLETE)
    }

    setPaymentIdFromUrl(_ => paymentIdFromPaymemtIntentClientSecret)

    None
  }, [])

  <div className="w-full h-full flex items-center justify-center p-5 overflow-auto">
    {switch paymentStatus {
    | INCOMPLETE =>
      <RenderIf condition={checkIsSDKOpen.isLoaded}>
        <WebSDK initialValuesForCheckoutForm />
      </RenderIf>
    | status =>
      let config = getStatusConfig(status)
      let hasPaymentId = paymentId->Option.isSome

      <RenderIf condition={config.statusText->LogicUtils.isNonEmptyString}>
        <PaymentStatusPage
          config
          buttonText={successButtonText}
          buttonOnClick={_ => onProceed()->ignore}
          isButtonVisible=hasPaymentId
        />
      </RenderIf>
    }}
    <RenderIf condition={checkIsSDKOpen.initialPreview}>
      <img alt="blurry-sdk" src="/assets/BlurrySDK.svg" height="500px" width="400px" />
    </RenderIf>
    <RenderIf condition={checkIsSDKOpen.isLoading}>
      <Loader />
    </RenderIf>
  </div>
}
