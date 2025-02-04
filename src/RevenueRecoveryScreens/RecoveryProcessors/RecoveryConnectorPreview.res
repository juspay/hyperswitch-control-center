module ConnectorSummaryGrid = {
  open CommonAuthHooks
  open ConnectorPreview
  open RecoveryConnectorPreviewHelper
  @react.component
  let make = (
    ~connectorInfo: ConnectorTypes.connectorPayload,
    ~updateStepValue=None,
    ~getConnectorDetails=None,
  ) => {
    open ConnectorUtils

    let businessProfiles = HyperswitchAtom.businessProfilesAtom->Recoil.useRecoilValueFromAtom
    let defaultBusinessProfile = businessProfiles->MerchantAccountUtils.getValueFromBusinessProfile
    let currentProfileName =
      businessProfiles
      ->Array.find((ele: HSwitchSettingTypes.profileEntity) =>
        ele.profile_id === connectorInfo.profile_id
      )
      ->Option.getOr(defaultBusinessProfile)
    let {merchantId} = useCommonAuthInfo()->Option.getOr(defaultAuthInfo)
    let copyValueOfWebhookEndpoint = getWebhooksUrl(
      ~connectorName={connectorInfo.merchant_connector_id},
      ~merchantId,
    )
    let (processorType, _) =
      connectorInfo.connector_type
      ->connectorTypeTypedValueToStringMapper
      ->connectorTypeTuple
    let {connector_name: connectorName} = connectorInfo

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
    }, [connectorInfo.merchant_connector_id])
    let (_, connectorAccountFields, _, _, _, _, _) = getConnectorFields(connectorDetails)

    <div className="flex flex-col gap-7 ml-2 mt-5 mb-12">
      <AddDataAttributes attributes=[("data-testid", "connector_status"->String.toLowerCase)]>
        <PreviewRow
          title="Integration status" subTitle={connectorInfo.status->String.toUpperCase}
        />
      </AddDataAttributes>
      <div>
        <PreviewRow title="Webhook Endpoint" subTitle={""} />
        <KeyAndCopyArea copyValue={copyValueOfWebhookEndpoint} />
      </div>
      <PreviewRow
        title="Profile"
        subTitle={`${currentProfileName.profile_name} - ${connectorInfo.profile_id}`}
      />
      <RenderIf
        condition={connectorInfo.connector_name->getConnectorNameTypeFromString ==
          Processors(FIUU)}>
        <div
          className="flex border items-start bg-blue-800 border-blue-810 text-sm rounded-md gap-2 px-4 py-3">
          <Icon name="info-vacent" size=18 />
          <div>
            <p className="mb-3">
              {"To ensure mandates work correctly with Fiuu, please verify that the Source Verification Key for webhooks is set accurately in your configuration. Without the correct Source Verification Key, mandates may not function as expected."->React.string}
            </p>
            <p>
              {"Please review your webhook settings and confirm that the Source Verification Key is properly configured to avoid any integration issues."->React.string}
            </p>
          </div>
        </div>
      </RenderIf>
      <RecoveryConnectorPreviewHelper.PreviewCreds connectorAccountFields connectorInfo />
    </div>
  }
}

@react.component
let make = (~connectorInfo, ~isUpdateFlow, ~showMenuOption=true, ~getConnectorDetails=None) => {
  open ConnectorUtils
  let {feedback} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

  let mixpanelEvent = MixpanelHook.useSendEvent()

  let {setShowFeedbackModal} = React.useContext(GlobalProvider.defaultContext)

  let connectorInfo =
    connectorInfo->LogicUtils.getDictFromJsonObject->ConnectorListMapper.getProcessorPayloadType
  let connectorCount =
    HyperswitchAtom.connectorListAtom
    ->Recoil.useRecoilValueFromAtom
    ->getProcessorsListFromJson(~removeFromList=ConnectorTypes.FRMPlayer)
    ->Array.length
  let isFeedbackModalToBeOpen =
    feedback && !isUpdateFlow && connectorCount <= HSwitchUtils.feedbackModalOpenCountForConnectors

  let mixpanelEventName = isUpdateFlow ? "processor_step3_onUpdate" : "processor_step3"

  <div>
    <RecoveryConfigurationHelper.SubHeading
      title="Review and Connect"
      subTitle="Review your configured processor details, enabled payment methods and associated settings."
    />
    <ConnectorSummaryGrid
      connectorInfo updateStepValue={Some(ConnectorTypes.PaymentMethods)} getConnectorDetails
    />
    <Button
      customButtonStyle="rounded w-full"
      buttonType={Primary}
      onClick={_ => {
        mixpanelEvent(~eventName=mixpanelEventName)
        if isFeedbackModalToBeOpen {
          setShowFeedbackModal(_ => true)
        }
        RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url="v2/recovery/connectors"))
      }}
      text="Done"
    />
  </div>
}
