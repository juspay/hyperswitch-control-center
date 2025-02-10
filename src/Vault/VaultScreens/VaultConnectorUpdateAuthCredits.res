@react.component
let make = (~connectorInfo: ConnectorTypes.connectorPayload) => {
  open ConnectorUtils
  open APIUtils
  open LogicUtils
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let getURL = useGetURL()
  let updateAPIHook = useUpdateMethod(~showErrorToast=false)
  let showToast = ToastState.useShowToast()
  let labelFieldDict = ConnectorAuthKeyUtils.connectorLabelDetailField
  let label = labelFieldDict->getString("connector_label", "")
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

  let (processorType, connectorType) =
    connectorInfo.connector_type
    ->connectorTypeTypedValueToStringMapper
    ->connectorTypeTuple
  let {connector_name: connectorName} = connectorInfo
  let connectorTypeFromName = connectorName->getConnectorNameTypeFromString(~connectorType)

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
  let (
    _,
    connectorAccountFields,
    connectorMetaDataFields,
    _,
    connectorWebHookDetails,
    connectorLabelDetailField,
    connectorAdditionalMerchantData,
  ) = getConnectorFields(connectorDetails)

  let initialValues = React.useMemo(() => {
    let authType = switch connectorInfo.connector_account_details {
    | HeaderKey(authKeys) => authKeys.auth_type
    | BodyKey(bodyKey) => bodyKey.auth_type
    | SignatureKey(signatureKey) => signatureKey.auth_type
    | MultiAuthKey(multiAuthKey) => multiAuthKey.auth_type
    | CertificateAuth(certificateAuth) => certificateAuth.auth_type
    | CurrencyAuthKey(currencyAuthKey) => currencyAuthKey.auth_type
    | UnKnownAuthType(_) => ""
    }
    [
      (
        "connector_type",
        connectorInfo.connector_type
        ->connectorTypeTypedValueToStringMapper
        ->JSON.Encode.string,
      ),
      (
        "connector_account_details",
        [("auth_type", authType->JSON.Encode.string)]
        ->Dict.fromArray
        ->JSON.Encode.object,
      ),
      ("connector_webhook_details", connectorInfo.connector_webhook_details),
      ("connector_label", connectorInfo.connector_label->JSON.Encode.string),
      ("metadata", connectorInfo.metadata),
      (
        "additional_merchant_data",
        connectorInfo.additional_merchant_data->checkEmptyJson
          ? JSON.Encode.null
          : connectorInfo.additional_merchant_data,
      ),
    ]->LogicUtils.getJsonFromArrayOfJson
  }, (
    connectorInfo.connector_webhook_details,
    connectorInfo.connector_label,
    connectorInfo.metadata,
  ))

  let validateMandatoryField = values => {
    let errors = Dict.make()
    let valuesFlattenJson = values->JsonFlattenUtils.flattenObject(true)
    validateConnectorRequiredFields(
      connectorTypeFromName,
      valuesFlattenJson,
      connectorAccountFields,
      connectorMetaDataFields,
      connectorWebHookDetails,
      connectorLabelDetailField,
      errors->JSON.Encode.object,
    )
  }

  let selectedConnector = React.useMemo(() => {
    connectorTypeFromName->getConnectorInfo
  }, [connectorName])
  <>
    <Form initialValues validate={validateMandatoryField}>
      <div className="flex flex-col">
        <div className="flex flex-row gap-6">
          <div className="w-1/3">
            <FormRenderer.FieldRenderer
              labelClass="font-semibold"
              field={FormRenderer.makeFieldInfo(
                ~label,
                ~name="connector_label",
                ~placeholder="Enter Connector Label name",
                ~customInput=InputFields.textInput(~customStyle="rounded-xl"),
                ~isRequired=true,
              )}
            />
            <ConnectorAuthKeysHelper.ErrorValidation
              fieldName="connector_label"
              validate={ConnectorAuthKeyUtils.validate(
                ~selectedConnector,
                ~dict=connectorLabelDetailField,
                ~fieldName="connector_label",
                ~isLiveMode={featureFlagDetails.isLiveMode},
              )}
            />
          </div>
          <div className="w-1/3">
            <ConnectorMetadataV2 />
          </div>
        </div>
        <div className="w-1/3 ">
          <ConnectorWebhookDetails />
        </div>
      </div>
    </Form>
  </>
}
