@react.component
let make = (~connectorInfo) => {
  open CommonAuthHooks
  open LogicUtils
  let {setShowSideBar} = React.useContext(GlobalProvider.defaultContext)
  let connectorInfodict = ConnectorInterface.mapDictToIndividualConnectorPayload(
    ConnectorInterface.connectorInterfaceV2,
    connectorInfo->LogicUtils.getDictFromJsonObject,
  )
  let mixpanelEvent = MixpanelHook.useSendEvent()

  let (processorType, _) =
    connectorInfodict.connector_type
    ->ConnectorUtils.connectorTypeTypedValueToStringMapper
    ->ConnectorUtils.connectorTypeTuple
  let {connector_name: connectorName} = connectorInfodict
  let {merchantId} = useCommonAuthInfo()->Option.getOr(defaultAuthInfo)
  let showToast = ToastState.useShowToast()

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
    mixpanelEvent(~eventName="vault_onboarding_step4")
    setShowSideBar(_ => true)
    RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url=`/v2/vault/onboarding`))
    showToast(~message="Connector Created Successfully!", ~toastType=ToastSuccess)
  }

  <div className="flex flex-col w-1/2 px-10 gap-8 mt-8 overflow-y-auto">
    <div className="flex flex-col">
      <PageUtils.PageHeading
        title="Review and Connect"
        subTitle="Review your configured processor details, enabled payment methods and associated settings."
        customSubTitleStyle="font-500 font-normal text-nd_gray-700"
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
      onClick={_ => handleClick()}
      buttonSize=Large
      buttonType=Primary
      customButtonStyle="w-full"
    />
  </div>
}
