@react.component
let make = (~connectorInfo) => {
  open CommonAuthHooks
  open RevenueRecoveryOnboardingUtils
  open LogicUtils

  let {setShowSideBar} = React.useContext(GlobalProvider.defaultContext)
  let connectorInfodict = ConnectorInterface.mapDictToConnectorPayload(
    ConnectorInterface.connectorInterfaceV2,
    connectorInfo->LogicUtils.getDictFromJsonObject,
  )
  let (processorType, _) =
    connectorInfodict.connector_type
    ->ConnectorUtils.connectorTypeTypedValueToStringMapper
    ->ConnectorUtils.connectorTypeTuple
  let {connector_name: connectorName} = connectorInfodict
  let {merchantId} = useCommonAuthInfo()->Option.getOr(defaultAuthInfo)

  let connectorAccountFields = React.useMemo(() => {
    try {
      if connectorName->LogicUtils.isNonEmptyString {
        let dict = switch processorType {
        | PaymentProcessor => Window.getConnectorConfig(connectorName)
        | PayoutProcessor => Window.getPayoutConnectorConfig(connectorName)
        | AuthenticationProcessor => Window.getAuthenticationConnectorConfig(connectorName)
        | PMAuthProcessor => Window.getPMAuthenticationProcessorConfig(connectorName)
        | TaxProcessor => Window.getTaxProcessorConfig(connectorName)
        | BillingProcessor => BillingProcessorsUtils.getConnectorConfig(connectorName)
        | PaymentVas => JSON.Encode.null
        }
        let connectorAccountDict = dict->getDictFromJsonObject->getDictfromDict("connector_auth")
        let bodyType = connectorAccountDict->Dict.keysToArray->getValueFromArray(0, "")
        let connectorAccountFields = connectorAccountDict->getDictfromDict(bodyType)
        connectorAccountFields
      } else {
        Dict.make()
      }
    } catch {
    | Exn.Error(e) => {
        Js.log2("FAILED TO LOAD CONNECTOR CONFIG", e)
        let _ = Exn.message(e)->Option.getOr("Something went wrong")
        Dict.make()
      }
    }
  }, [connectorInfodict.id])

  let handleClick = () => {
    setShowSideBar(_ => true)
    RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url=`/v2/recovery/connectors`))
  }

  let revenueRecovery =
    connectorInfodict.feature_metadata->getDictFromJsonObject->getDictfromDict("revenue_recovery")

  let max_retry_count = revenueRecovery->getInt("max_retry_count", 0)
  let billing_connector_retry_threshold =
    revenueRecovery->getInt("billing_connector_retry_threshold", 0)
  let paymentConnectors =
    revenueRecovery->getObj("billing_account_reference", Dict.make())->Dict.toArray

  <PageWrapper
    title="Review and Connect"
    subTitle="Review your configured processor details, enabled payment methods and associated settings.">
    <div className=" flex flex-col py-4 gap-9">
      <div className="flex flex-col gap-0.5-rem ">
        <h4 className="text-nd_gray-400 "> {"Profile"->React.string} </h4>
        {connectorInfodict.profile_id->React.string}
      </div>
      <div className="flex flex-col ">
        <ConnectorHelperV2.PreviewCreds connectorInfo=connectorInfodict connectorAccountFields />
      </div>
      <div className="flex flex-col gap-0.5-rem ">
        <h4 className="text-nd_gray-400 "> {"Max Retry Count"->React.string} </h4>
        {max_retry_count->Int.toString->React.string}
      </div>
      <div className="flex flex-col gap-0.5-rem ">
        <h4 className="text-nd_gray-400 "> {"Billing Connector Retry Threshold"->React.string} </h4>
        {billing_connector_retry_threshold->Int.toString->React.string}
      </div>
      <div className="flex flex-col gap-0.5-rem ">
        <h4 className="text-nd_gray-400 "> {"Payment Connectors"->React.string} </h4>
        {paymentConnectors
        ->Array.map(item => {
          let (key, value) = item
          <div> {`${key} : ${value->JSON.Decode.string->Option.getOr("")}`->React.string} </div>
        })
        ->React.array}
      </div>
      <ConnectorWebhookPreview merchantId connectorName=connectorInfodict.id />
      <ACLButton
        text="Done"
        onClick={_ => handleClick()}
        buttonSize=Large
        buttonType=Primary
        customButtonStyle="w-full"
      />
    </div>
  </PageWrapper>
}
