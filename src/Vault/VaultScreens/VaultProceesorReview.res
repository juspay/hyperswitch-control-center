@react.component
let make = (~connectorInfo, ~copyValueOfWebhookEndpoint) => {
  open ConnectorUtils

  let {setShowSideBar} = React.useContext(GlobalProvider.defaultContext)
  let connectorInfodict =
    connectorInfo->LogicUtils.getDictFromJsonObject->ConnectorListMapper.getProcessorPayloadType
  let (processorType, _) =
    connectorInfodict.connector_type
    ->connectorTypeTypedValueToStringMapper
    ->connectorTypeTuple
  let {connector_name: connectorName} = connectorInfodict
  let showToast = ToastState.useShowToast()
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

  let handleWebHookCopy = copyValue => {
    Clipboard.writeText(copyValue)
    showToast(~message="Copied to Clipboard!", ~toastType=ToastSuccess)
  }

  let handleClick = () => {
    setShowSideBar(_ => true)
    RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url=`/v2/vault/onboarding/`))
  }

  let (_, connectorAccountFields, _, _, _, _, _) = getConnectorFields(connectorDetails)

  <>
    <div className="flex flex-col px-10 gap-8">
      <div className="flex flex-col ">
        <PageUtils.PageHeading
          title="Review and Connect"
          subTitle="Review your configured processor details, enabled payment methods and associated settings."
          customSubTitleStyle="font-500 font-normal text-gray-800"
        />
        <div className=" flex flex-col py-4 gap-6">
          <div className="flex flex-col gap-0.5-rem ">
            <h4 className="text-gray-400 "> {"Profile"->React.string} </h4>
            {connectorInfodict.profile_id->React.string}
          </div>
          <div className="flex flex-col ">
            <ConnectorHelperV2.PreviewCreds
              connectorInfo=connectorInfodict connectorAccountFields
            />
          </div>
          <div className="flex flex-col gap-2 ">
            <h4 className="text-gray-400"> {"Webhook Url"->React.string} </h4>
            <div className="flex flex-row">
              {copyValueOfWebhookEndpoint->React.string}
              <div className="ml-2" onClick={_ => handleWebHookCopy(copyValueOfWebhookEndpoint)}>
                <Icon name="nd-copy" />
              </div>
            </div>
          </div>
        </div>
      </div>
      <ACLButton
        text="Done"
        onClick={_ => handleClick()}
        buttonSize=Large
        buttonType=Primary
        customButtonStyle="w-full"
      />
    </div>
  </>
}
