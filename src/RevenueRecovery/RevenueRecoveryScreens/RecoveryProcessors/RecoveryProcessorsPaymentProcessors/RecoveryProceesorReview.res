@react.component
let make = (~connectorInfo) => {
  open CommonAuthHooks
  open LogicUtils
  let {setShowSideBar} = React.useContext(GlobalProvider.defaultContext)
  let connectorInfo = connectorInfo->LogicUtils.getDictFromJsonObject

  let connectorInfodict = ConnectorInterface.mapDictToConnectorPayload(
    ConnectorInterface.connectorInterfaceV2,
    connectorInfo,
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

  <div className="flex flex-col px-10 gap-8">
    <div className="flex flex-col ">
      <PageUtils.PageHeading
        title="Review and Connect"
        subTitle="Review your configured processor details, enabled payment methods and associated settings."
        customSubTitleStyle="font-500 font-normal text-nd_gray-400"
      />
      <div className=" flex flex-col py-4 gap-6">
        <div className="flex flex-col gap-0.5-rem ">
          <h4 className="text-nd_gray-400 "> {"Profile"->React.string} </h4>
          {connectorInfodict.profile_id->React.string}
        </div>
        <div className="flex flex-col ">
          <ConnectorHelperV2.PreviewCreds connectorInfo=connectorInfodict connectorAccountFields />
        </div>
        <ConnectorWebhookPreview merchantId connectorName=connectorInfodict.id />
      </div>
    </div>
    <ACLButton
      text="Done"
      onClick={_ => {
        setShowSideBar(_ => true)
      }}
      buttonSize=Large
      buttonType=Primary
      customButtonStyle="w-full"
    />
  </div>
}
