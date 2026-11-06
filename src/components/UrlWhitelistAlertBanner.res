open Typography

module Base = {
  @react.component
  let make = (~heading, ~description, ~wrapperClass="") => {
    <div className={`${wrapperClass} xl:w-max xl:max-w-none`}>
      <AlertV2Binding
        alertType=Warning
        slot={{
          slot: <div className="flex items-start gap-2">
            <Icon name="nd-toast-warning" size=20 className="text-nd_yellow-500 shrink-0" />
            <div className="flex flex-col gap-1">
              <p className={body.md.semibold}> {heading->React.string} </p>
              <p className={body.md.regular}>
                {`${description} To request whitelisting, contact `->React.string}
                <a
                  href=GlobalVars.supportMailtoUrl
                  className="text-nd_primary_blue-450 hover:underline cursor-pointer">
                  {GlobalVars.supportEmail->React.string}
                </a>
                {"."->React.string}
              </p>
            </div>
          </div>,
          maxHeight: "none",
        }}
      />
    </div>
  }
}

module Webhook = {
  @react.component
  let make = () => {
    <Base
      heading="Whitelist your webhook URL"
      wrapperClass="max-w-xl mb-4"
      description="Webhooks are only delivered to whitelisted URLs."
    />
  }
}

module Connector = {
  @react.component
  let make = (~connector: ConnectorTypes.connectorTypes) => {
    open ConnectorUtils
    let displayName = connector->getDisplayNameFromConnectorType

    <RenderIf
      condition={urlWhitelistingRequiredConnectorList->Array.some(item => item == connector)}>
      <Base
        heading="Endpoint whitelisting required"
        wrapperClass="mb-4"
        description={`Requests to ${displayName} are only sent to whitelisted endpoints.`}
      />
    </RenderIf>
  }
}
