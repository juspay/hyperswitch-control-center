let headerTextStyle = "text-xl font-semibold text-grey-700"
let subTextStyle = "text-base font-normal text-grey-700 opacity-50"
let dividerColor = "bg-grey-700 bg-opacity-20 h-px w-full"
let highlightedText = "text-base font-normal text-blue-700 underline"

module ReplaceAPIKey = {
  @react.component
  let make = (
    ~publishablekeyMerchant,
    ~paymentResponseHashKey,
    ~webhookEndpoint,
    ~previewVariant,
  ) => {
    <div>
      <ProdOnboardingUIUtils.SetupWebhookProcessor
        headerSectionText="Live Domain"
        subtextSectionText="Configure this base url in your application for all server-server calls"
        customRightSection={<HelperComponents.KeyAndCopyArea
          copyValue=HSwitchGlobalVars.hyperSwitchApiPrefix
          shadowClass="shadow shadow-hyperswitch_box_shadow md:!w-max"
        />}
        rightTag={<Icon name="server-tag" size=30 customWidth="50" />}
      />
      <div className={`${dividerColor} px-2`} />
      <ProdOnboardingUIUtils.SetupWebhookProcessor
        headerSectionText="Publishable Key"
        subtextSectionText="Use this key to authenticate all calls from your application's client to Hyperswitch SDK"
        customRightSection={<HelperComponents.KeyAndCopyArea
          copyValue=publishablekeyMerchant
          shadowClass="shadow shadow-hyperswitch_box_shadow md:!w-max"
        />}
        rightTag={<Icon name="client-tag" size=30 customWidth="50" />}
      />
      <div className={`${dividerColor} px-2`} />
      <UIUtils.RenderIf
        condition={previewVariant->Belt.Option.isSome && webhookEndpoint->String.length > 0}>
        <ProdOnboardingUIUtils.SetupWebhookProcessor
          headerSectionText="Merchant Webhook Endpoint"
          subtextSectionText="Provide the endpoint where you would want us to send live payment events"
          customRightSection={<HelperComponents.KeyAndCopyArea
            copyValue=webhookEndpoint shadowClass="shadow shadow-hyperswitch_box_shadow md:!w-max"
          />}
        />
        <div className={`${dividerColor} px-2`} />
        <UIUtils.RenderIf condition={paymentResponseHashKey->String.length > 0}>
          <ProdOnboardingUIUtils.SetupWebhookProcessor
            headerSectionText="Payment Response Hash Key"
            subtextSectionText="Download the provided key to authenticate and verify live events sent by Hyperswitch. Learn more"
            customRightSection={<HelperComponents.KeyAndCopyArea
              copyValue=paymentResponseHashKey
              shadowClass="shadow shadow-hyperswitch_box_shadow md:!w-full"
            />}
          />
        </UIUtils.RenderIf>
        <div className={`${dividerColor} px-2`} />
      </UIUtils.RenderIf>
      <ProdOnboardingUIUtils.SetupWebhookProcessor
        headerSectionText="API Key"
        subtextSectionText="Use this key to authenticate all API requests from your application's server to Hyperswitch server"
        customRightSection={<UserOnboardingUIUtils.DownloadAPIKeyButton
          buttonText="Create and download API key" buttonStyle="!rounded-md"
        />}
        rightTag={<Icon name="server-tag" size=30 customWidth="50" />}
      />
    </div>
  }
}
module SetupWebhookUser = {
  @react.component
  let make = (~webhookEndpoint, ~setWebhookEndpoint, ~paymentResponseHashKey) => {
    let showPopUp = PopUpState.useShowPopUp()
    let webhookEndpoint: ReactFinalForm.fieldRenderPropsInput = {
      name: "webhookEndpoint",
      onBlur: _ev => (),
      onChange: ev => {
        let value = ReactEvent.Form.target(ev)["value"]
        if value->String.includes("<script>") || value->String.includes("</script>") {
          showPopUp({
            popUpType: (Warning, WithIcon),
            heading: `Script Tags are not allowed`,
            description: React.string(`Input cannot contain <script>, </script> tags`),
            handleConfirm: {text: "OK"},
          })
        }
        let val = value->String.replace("<script>", "")->String.replace("</script>", "")
        setWebhookEndpoint(_ => val)
      },
      onFocus: _ev => (),
      value: webhookEndpoint->Js.Json.string,
      checked: true,
    }

    <div>
      <ProdOnboardingUIUtils.SetupWebhookProcessor
        headerSectionText="Merchant Webhook Endpoint"
        subtextSectionText="Provide the endpoint where you would want us to send live payment events"
        customRightSection={<FormRenderer.FieldWrapper label="Webhook Endpoint">
          <TextInput input=webhookEndpoint placeholder="Enter your webhook endpoint here " />
        </FormRenderer.FieldWrapper>}
      />
      <UIUtils.RenderIf condition={paymentResponseHashKey->String.length > 0}>
        <ProdOnboardingUIUtils.SetupWebhookProcessor
          headerSectionText="Payment Response Hash Key"
          subtextSectionText="Download the provided key to authenticate and verify live events sent by Hyperswitch. Learn more"
          customRightSection={<HelperComponents.KeyAndCopyArea
            copyValue=paymentResponseHashKey
            shadowClass="shadow shadow-hyperswitch_box_shadow md:!w-full"
          />}
        />
      </UIUtils.RenderIf>
    </div>
  }
}

@react.component
let make = (~pageView, ~setPageView, ~previewState: option<ProdOnboardingTypes.previewStates>) => {
  open APIUtils
  open ProdOnboardingTypes
  let updateDetails = useUpdateMethod()
  let showToast = ToastState.useShowToast()
  let merchantDetails =
    Recoil.useRecoilValueFromAtom(HyperswitchAtom.merchantDetailsValueAtom)
    ->LogicUtils.safeParse
    ->LogicUtils.getDictFromJsonObject

  let publishablekeyMerchant = merchantDetails->LogicUtils.getString("publishable_key", "")
  let paymentResponseHashKey =
    merchantDetails->LogicUtils.getString("payment_response_hash_key", "")
  let webhookUrl =
    merchantDetails
    ->LogicUtils.getJsonObjectFromDict("webhook_details")
    ->LogicUtils.getDictFromJsonObject
    ->LogicUtils.getString("webhook_url", "")

  let (webhookEndpoint, setWebhookEndpoint) = React.useState(_ => webhookUrl)
  let (buttonState, setButtonState) = React.useState(_ => Button.Normal)

  let setMerchantDetailsValue = Recoil.useSetRecoilState(HyperswitchAtom.merchantDetailsValueAtom)
  let merchantId = HSLocalStorage.getFromMerchantDetails("merchant_id")

  let headerText = switch pageView {
  | REPLACE_API_KEYS => "Replace API keys & Live Endpoints"
  | SETUP_WEBHOOK_USER => "Setup Webhooks On Your End"

  | _ => ""
  }
  let subHeaderText = switch pageView {
  | REPLACE_API_KEYS => "Point your application's client and server to our live environment"
  | SETUP_WEBHOOK_USER => "Create webhook endpoints to allow us to receive and notify you of payment events"

  | _ => ""
  }
  let backButtonEnabled = switch pageView {
  | REPLACE_API_KEYS => false
  | _ => true
  }

  let updateLiveEndpoint = async () => {
    try {
      let url = getURL(~entityName=USERS, ~userType=#MERCHANT_DATA, ~methodType=Post, ())
      let body = ProdOnboardingUtils.getProdApiBody(~parentVariant=#ConfigureEndpoint, ())
      let _ = await updateDetails(url, body, Post)
      setPageView(_ => pageView->ProdOnboardingUtils.getPageView)
      showToast(~message=`Details updated`, ~toastType=ToastState.ToastSuccess, ())
      setButtonState(_ => Normal)
    } catch {
    | _ => setButtonState(_ => Normal)
    }
  }

  let updateMerchantDetails = async _ => {
    try {
      setButtonState(_ => Loading)
      let mercahantUpdateBody =
        [("webhook_url", webhookEndpoint->Js.Json.string)]->Dict.fromArray->Js.Json.object_
      let body = mercahantUpdateBody->MerchantAccountUtils.getSettingsPayload(merchantId)
      let url = getURL(~entityName=MERCHANT_ACCOUNT, ~methodType=Post, ())
      let merchantInfo = await updateDetails(url, body, Post)
      setMerchantDetailsValue(._ => merchantInfo->Js.Json.stringify)
      updateLiveEndpoint()->ignore
    } catch {
    | _ => setButtonState(_ => Normal)
    }
  }

  let handleSubmit = _ => {
    switch pageView {
    | SETUP_WEBHOOK_USER => updateMerchantDetails()->ignore
    | _ => setPageView(_ => pageView->ProdOnboardingUtils.getPageView)
    }
  }
  <div className="flex flex-col gap-12 p-11">
    <div className="flex justify-between flex-wrap gap-4">
      <div className="flex flex-col gap-2">
        <p className=headerTextStyle> {headerText->React.string} </p>
        <p className=subTextStyle> {subHeaderText->React.string} </p>
      </div>
      <UIUtils.RenderIf condition={previewState->Belt.Option.isNone}>
        <div className="flex gap-4">
          <UIUtils.RenderIf condition={backButtonEnabled}>
            <Button
              text="Back"
              buttonSize={Small}
              buttonType={PrimaryOutline}
              customButtonStyle="!rounded-md"
              onClick={_ => {
                setPageView(_ => pageView->ProdOnboardingUtils.getBackPageView)
              }}
            />
          </UIUtils.RenderIf>
          <Button
            text={"Connect and Proceed"}
            buttonSize={Small}
            buttonType={Primary}
            customButtonStyle="!rounded-md"
            buttonState={buttonState}
            onClick={_ => handleSubmit()}
          />
        </div>
      </UIUtils.RenderIf>
    </div>
    <ProdOnboardingUIUtils.WarningBlock
      customComponent={Some(<>
        <p className={`${subTextStyle} !opacity-100`}>
          {"Not integrated with Hyperswitch yet? Visit our"->React.string}
        </p>
        <p
          className={`${highlightedText} cursor-pointer`}
          onClick={_ => Window._open("https://hyperswitch.io/docs")}>
          {"Developer Docs"->React.string}
        </p>
        <p className={`${subTextStyle} !opacity-100`}>
          {`to complete the integration`->React.string}
        </p>
      </>)}
      warningText=" Developer docs to complete integration"
    />
    {switch pageView {
    | REPLACE_API_KEYS =>
      <ReplaceAPIKey
        publishablekeyMerchant paymentResponseHashKey webhookEndpoint previewVariant={None}
      />
    | SETUP_WEBHOOK_USER =>
      <SetupWebhookUser webhookEndpoint setWebhookEndpoint paymentResponseHashKey />
    | _ => <> </>
    }}
    {switch previewState {
    | Some(previewVariant) =>
      <ReplaceAPIKey
        publishablekeyMerchant
        paymentResponseHashKey
        webhookEndpoint
        previewVariant={Some(previewVariant)}
      />
    | _ => React.null
    }}
  </div>
}
