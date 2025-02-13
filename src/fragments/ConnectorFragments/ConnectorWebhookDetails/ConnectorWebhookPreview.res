@react.component
let make = (
  ~merchantId,
  ~connectorName,
  ~textCss="",
  ~showFullText=false,
  ~showFullCopy=false,
  ~containerClass="flex",
  ~hideLabel=false,
) => {
  let showToast = ToastState.useShowToast()
  let copyValueOfWebhookEndpoint = `${Window.env.apiBaseUrl}/webhooks/${merchantId}/${connectorName}`
  let displayValueOfWebhookEndpoint = `${Window.env.apiBaseUrl}...${connectorName}`
  let handleWebHookCopy = copyValue => {
    Clipboard.writeText(copyValue)
    showToast(~message="Copied to Clipboard!", ~toastType=ToastSuccess)
  }
  let valueOfWebhookEndPoint = {
    showFullText ? copyValueOfWebhookEndpoint : displayValueOfWebhookEndpoint
  }

  <div className="flex flex-col gap-2">
    <RenderIf condition={!hideLabel}>
      <h4 className="text-gray-400 "> {"Webhook Url"->React.string} </h4>
    </RenderIf>
    <div className=containerClass>
      <p className=textCss> {valueOfWebhookEndPoint->React.string} </p>
      <div className="ml-2">
        <RenderIf condition={!showFullCopy}>
          <div onClick={_ => handleWebHookCopy(copyValueOfWebhookEndpoint)}>
            <Icon name="nd-copy" />
          </div>
        </RenderIf>
        <RenderIf condition={showFullCopy}>
          <Button
            leftIcon={CustomIcon(<Icon name="nd-copy" />)}
            text="Copy"
            customButtonStyle="ml-4 w-5"
            onClick={_ => handleWebHookCopy(copyValueOfWebhookEndpoint)}
          />
        </RenderIf>
      </div>
    </div>
  </div>
}
