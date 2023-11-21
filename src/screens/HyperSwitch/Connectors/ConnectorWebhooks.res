let highlightedText = "text-base font-normal text-blue-700 underline"
let subTextStyle = "text-base font-normal text-grey-700 opacity-50"
let headerTextStyle = "text-xl font-semibold text-grey-700"

module SetupWebhookProcessor = {
  @react.component
  let make = (~connectorName="", ~headerSectionText, ~subtextSectionText, ~customRightSection) => {
    <div className="flex flex-col gap-8">
      <div className="flex flex-col bg-jp-gray-light_gray_bg p-10 gap-6">
        <div className="flex flex-col gap-2 col-span-1">
          <p className={`${subTextStyle} !opacity-100`}> {headerSectionText->React.string} </p>
          <p className=subTextStyle> {subtextSectionText->React.string} </p>
        </div>
        <div className="col-span-1"> {customRightSection} </div>
      </div>
    </div>
  }
}

module KeyAndCopyArea = {
  @react.component
  let make = (~copyValue, ~contextName, ~actionName, ~shadowClass="") => {
    let showToast = ToastState.useShowToast()
    let hyperswitchMixPanel = HSMixPanel.useSendEvent()
    let url = RescriptReactRouter.useUrl()
    <div
      className={`flex flex-col md:flex-row gap-4 border rounded-md py-2 px-4 items-center w-full md:w-max bg-white flex-wrap ${shadowClass}`}>
      <p className="text-base text-grey-700 opacity-70 break-all overflow-scroll">
        {copyValue->React.string}
      </p>
      <div
        className="py-1 px-4 border rounded-md flex gap-2 items-center cursor-pointer"
        onClick={_ => {
          Clipboard.writeText(copyValue)
          showToast(~message="Copied to Clipboard!", ~toastType=ToastSuccess, ())
          hyperswitchMixPanel(
            ~pageName=`${url.path->LogicUtils.getListHead}`,
            ~contextName,
            ~actionName,
            (),
          )
        }}>
        <img src={`/assets/CopyToClipboard.svg`} />
        <p className="text-lg text-normal text-grey-700 opacity-50"> {"Copy"->React.string} </p>
      </div>
    </div>
  }
}

@react.component
let make = (~connectorName, ~setCurrentStep, ~currentStep, ~isUpdateFlow) => {
  let merchantId = HSLocalStorage.getFromMerchantDetails("merchant_id")
  let hyperswitchMixPanel = HSMixPanel.useSendEvent()
  let url = RescriptReactRouter.useUrl()
  let copyValue = ConnectorUtils.getWebhooksUrl(~connectorName, ~merchantId)

  <div className="flex flex-col ">
    <div className="flex justify-between border-b p-2 md:px-10 md:py-6">
      <div className="flex gap-2 items-center">
        <GatewayIcon
          gateway={connectorName->Js.String2.toUpperCase} className="w-14 h-14 rounded-full"
        />
        <h2 className="text-xl font-semibold">
          {connectorName->LogicUtils.capitalizeString->React.string}
        </h2>
      </div>
      <div className="self-center">
        <Button
          text="Proceed"
          buttonType={Primary}
          onClick={_ => {
            ConnectorUtils.getMixpanelForConnectorOnSubmit(
              ~connectorName,
              ~currentStep,
              ~isUpdateFlow,
              ~url,
              ~hyperswitchMixPanel,
            )
            setCurrentStep(_ => ConnectorTypes.PaymentMethods)
          }}
        />
      </div>
    </div>
    <div className="flex flex-col gap-8 p-2 md:p-10">
      <div className="flex flex-col gap-2 ">
        <p className=headerTextStyle>
          {`Setup Webhook on ${connectorName->LogicUtils.capitalizeString}`->React.string}
        </p>
        <p className=subTextStyle>
          {"Configure hyperswitch's webhook on your processor's end"->React.string}
        </p>
      </div>
      <SetupWebhookProcessor
        connectorName
        headerSectionText="Hyperswitch Webhook Endpoint"
        subtextSectionText="Configure this endpoint in the processors dashboard under webhook settings for us to receive events from the processor"
        customRightSection={<KeyAndCopyArea
          copyValue
          contextName="setup_webhook_processor"
          actionName="hs_webhookcopied"
          shadowClass="shadow shadow-hyperswitch_box_shadow !w-max"
        />}
      />
    </div>
  </div>
}
