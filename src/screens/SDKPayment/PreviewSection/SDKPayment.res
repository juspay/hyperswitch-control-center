module PaymentStatusPage = {
  @react.component
  let make = (
    ~config,
    ~buttonText=?,
    ~buttonOnClick=?,
    ~buttonState=Button.Normal,
    ~isButtonVisible=true,
  ) => {
    open SDKPaymentTypes
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
let make = () => {
  open ReactHyperJs
  open LogicUtils

  let url = RescriptReactRouter.useUrl()
  let filtersFromUrl = url.search->getDictFromUrlSearchParams
  let (paymentIdFromUrl, setPaymentIdFromUrl) = React.useState(_ => None)
  let {
    paymentResult,
    paymentStatus,
    setPaymentStatus,
    clientSecretStatus,
    sdkThemeInitialValues,
  } = React.useContext(SDKProvider.defaultContext)
  let {userInfo: {orgId, merchantId, profileId}} = React.useContext(UserInfoProvider.defaultContext)

  let paymentId = if paymentIdFromUrl->Option.isSome {
    paymentIdFromUrl
  } else {
    paymentResult->getDictFromJsonObject->getOptionString("payment_id")
  }

  let theme =
    sdkThemeInitialValues
    ->getDictFromJsonObject
    ->getString("theme", "default")

  let connectorListFromRecoil = ConnectorInterface.useConnectorArrayMapper(
    ~interface=ConnectorInterface.connectorInterfaceV2,
    ~retainInList=PaymentProcessor,
  )

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

  let getStatusConfig = (status): SDKPaymentTypes.statusConfig => {
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
        iconName: "account-setup-failed",
        statusText: "Something went wrong",
        bgColor: "bg-red-failed_page_bg",
        showErrorMessage: false,
      }
    }
  }

  let getClientSecretFromPaymentId = (~paymentIntentClientSecret) => {
    switch paymentIntentClientSecret {
    | Some(paymentIdFromClientSecret) =>
      let paymentClientSecretSplitArray = paymentIdFromClientSecret->String.split("_")
      Some(
        `${paymentClientSecretSplitArray->getValueFromArray(
            0,
            "",
          )}_${paymentClientSecretSplitArray->getValueFromArray(1, "")}`,
      )

    | None => None
    }
  }

  React.useEffect(() => {
    let status = filtersFromUrl->Dict.get("status")->Option.getOr("")->String.toLowerCase
    let paymentIdFromPaymemtIntentClientSecret = getClientSecretFromPaymentId(
      ~paymentIntentClientSecret=url.search
      ->getDictFromUrlSearchParams
      ->Dict.get("payment_intent_client_secret"),
    )

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

  let backgroundBasedOnTheme = {
    switch theme {
    | "brutal" => "bg-brutal_background_color"
    | "midnight" => "bg-midnight_background_color"
    | "soft" => "bg-soft_background_color"
    | "charcoal" => "bg-charcoal_background_color"
    | "default"
    | _ => "bg-white"
    }
  }

  <>
    {switch paymentStatus {
    | INCOMPLETE =>
      <RenderIf condition={clientSecretStatus == Success}>
        <div
          className={`flex items-center justify-center ${backgroundBasedOnTheme} w-full h-3/4 border-2`}>
          <WebSDK />
        </div>
      </RenderIf>
    | status =>
      let config = getStatusConfig(status)
      let hasPaymentId = paymentId->Option.isSome

      <RenderIf condition={config.statusText->isNonEmptyString}>
        <PaymentStatusPage
          config
          buttonText={successButtonText}
          buttonOnClick={_ => onProceed()->ignore}
          isButtonVisible=hasPaymentId
        />
      </RenderIf>
    }}
    <RenderIf condition={connectorListFromRecoil->Array.length == 0}>
      <HelperComponents.BluredTableComponent
        infoText={"Connect to a payment processor to make your first payment"}
        buttonText={"Connect a connector"}
        moduleName=""
        onClickUrl={`/connectors`}
      />
    </RenderIf>
    <RenderIf
      condition={connectorListFromRecoil->Array.length > 0 && clientSecretStatus == IntialPreview}>
      <div className="flex items-center justify-center w-full h-full">
        <img alt="blurry-sdk" src="/assets/BlurrySDK.svg" height="500px" width="400px" />
      </div>
    </RenderIf>
    <RenderIf condition={clientSecretStatus == Loading}>
      <Loader />
    </RenderIf>
    <RenderIf condition={clientSecretStatus == Error}>
      {
        let config = getStatusConfig(CUSTOMSTATE)
        <PaymentStatusPage
          config
          buttonText={successButtonText}
          buttonOnClick={_ => onProceed()->ignore}
          isButtonVisible=false
        />
      }
    </RenderIf>
  </>
}
