@react.component
let make = (~initialValues, ~setInitialValues) => {
  open ConnectorUtils
  open CommonAuthHooks
  open LogicUtils

  let connectorInfo = initialValues
  let connectorInfodict =
    connectorInfo->LogicUtils.getDictFromJsonObject->ConnectorListMapper.getProcessorPayloadType
  let {connector_name: connectorName} = connectorInfodict
  let (processorType, _) =
    connectorInfodict.connector_type
    ->connectorTypeTypedValueToStringMapper
    ->connectorTypeTuple
  let {merchantId} = useCommonAuthInfo()->Option.getOr(defaultAuthInfo)

  let copyValueOfWebhookEndpoint = getWebhooksUrl(
    ~connectorName={connectorInfodict.merchant_connector_id},
    ~merchantId,
  )

  let displayValueofWebHookUrl = `${Window.env.apiBaseUrl}.../${connectorName}`

  let connectorDetails = React.useMemo(() => {
    try {
      if connectorName->LogicUtils.isNonEmptyString {
        let dict = switch processorType {
        | PaymentProcessor => Window.getConnectorConfig(connectorName)
        | PayoutProcessor => Window.getPayoutConnectorConfig(connectorName)
        | AuthenticationProcessor => Window.getAuthenticationConnectorConfig(connectorName)
        | PMAuthProcessor => Window.getPMAuthenticationProcessorConfig(connectorName)
        | TaxProcessor => Window.getTaxProcessorConfig(connectorName)
        | PaymentVas => JSON.Encode.null
        }
        dict
      } else {
        JSON.Encode.null
      }
    } catch {
    | Exn.Error(e) => {
        Js.log2("FAILED TO LOAD CONNECTOR CONFIG", e)
        let _ = Exn.message(e)->Option.getOr("Something went wrong")
        JSON.Encode.null
      }
    }
  }, [connectorInfodict.merchant_connector_id])

  let integrationStatusCSS = {
    switch connectorInfodict.status {
    | "active" => "bg-green-950"
    | _ => " "
    }
  }
  let showToast = ToastState.useShowToast()
  let (_, connectorAccountFields, _, _, _, _, _) = getConnectorFields(connectorDetails)
  let handleWebHookCopy = copyValue => {
    Clipboard.writeText(copyValue)
    showToast(~message="Copied to Clipboard!", ~toastType=ToastSuccess)
  }

  <div className="flex flex-col gap-10 p-6">
    <div>
      <div className="flex flex-row gap-4 items-center">
        <GatewayIcon
          gateway={connectorName->String.toUpperCase} className=" w-10 h-10 rounded-sm"
        />
        <p className={`text-2xl font-semibold break-all`}>
          {`${connectorName->getDisplayNameForConnector} Summary`->React.string}
        </p>
      </div>
    </div>
    <div className="flex gap-10 max-w-3xl flex-wrap">
      // <div className="flex flex-col gap-2 ">
      //   <h4 className="text-gray-400"> {"Webhook Url"->React.string} </h4>
      //   <div className="flex flex-row">
      //     {displayValueofWebHookUrl->React.string}
      //     <div className="ml-2" onClick={_ => handleWebHookCopy(copyValueOfWebhookEndpoint)}>
      //       <Icon name="nd-copy" />
      //     </div>
      //   </div>
      // </div>
      <ConnectorWebhookPreview merchantId=connectorInfodict.merchant_connector_id connectorName />
      <div className="flex flex-col gap-0.5-rem ">
        <h4 className="text-gray-400 "> {"Profile"->React.string} </h4>
        {connectorInfodict.profile_id->React.string}
      </div>
      <div className="flex flex-col gap-0.5-rem ">
        <h4 className="text-gray-400 "> {"Integration status"->React.string} </h4>
        <div className="flex flex-row gap-2 items-center ">
          <div className={`w-3 h-3  rounded-full ${integrationStatusCSS}`} />
          {connectorInfodict.status->capitalizeString->React.string}
        </div>
      </div>
    </div>
    <div className="flex flex-col gap-4">
      <div className="flex justify-between border-b pb-4 px-2 items-end">
        <p className="text-md font-semibold"> {"Credentials"->React.string} </p>
        <div className="flex gap-4">
          <Button
            text="Continue" buttonType={Secondary} buttonSize={Small} customButtonStyle="w-fit"
          />
          <FormRenderer.SubmitButton
            text="Save" buttonSize={Small} customSumbitButtonStyle="w-fit"
          />
        </div>
      </div>
      <Form initialValues formClass="grid grid-cols-2 gap-10 flex-wrap max-w-3xl">
        <ConnectorLabelV2 />
        <ConnectorMetadataV2 />
        <ConnectorWebhookDetails />
      </Form>
    </div>
    <div className="flex flex-col gap-4">
      <div className="flex justify-between border-b pb-4 px-2 items-end">
        <p className="text-md font-semibold"> {"Authentication keys"->React.string} </p>
        <div className="flex gap-4">
          <Button
            text="Continue" buttonType={Secondary} buttonSize={Small} customButtonStyle="w-fit"
          />
          <FormRenderer.SubmitButton
            text="Save" buttonSize={Small} customSumbitButtonStyle="w-fit"
          />
        </div>
      </div>
      <ConnectorHelperV2.PreviewCreds
        connectorInfo=connectorInfodict
        connectorAccountFields
        customContainerStyle="grid grid-cols-2 gap-12 flex-wrap max-w-3xl"
        customElementStyle="px-2"
      />
    </div>
    <div className="flex flex-col gap-4">
      <div className="flex justify-between border-b pb-4 px-2 items-end">
        <p className="text-md font-semibold"> {"PMTs"->React.string} </p>
        <div className="flex gap-4">
          <Button
            text="Continue" buttonType={Secondary} buttonSize={Small} customButtonStyle="w-fit"
          />
          <FormRenderer.SubmitButton
            text="Save" buttonSize={Small} customSumbitButtonStyle="w-fit"
          />
        </div>
      </div>
      <ConnectorPaymentMethodV2 initialValues setInitialValues />
    </div>
  </div>
}
