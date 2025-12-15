@react.component
let make = (
  ~connectorInfo: ConnectorTypes.connectorPayload,
  ~getConnectorDetails,
  ~handleConnectorDetailsUpdate,
) => {
  open ConnectorUtils
  open APIUtils
  open LogicUtils
  open ConnectorAccountDetailsHelper

  let getURL = useGetURL()
  let updateAPIHook = useUpdateMethod(~showErrorToast=false)
  let showToast = ToastState.useShowToast()

  // Need to remove connector and merge connector and connectorTypeVariants
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
        | BillingProcessor => BillingProcessorsUtils.getConnectorConfig(connectorName)
        | VaultProcessor => Window.getConnectorConfig(connectorName)
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
  let {
    connectorAccountFields,
    connectorMetaDataFields,
    connectorWebHookDetails,
    connectorLabelDetailField,
    connectorAdditionalMerchantData,
  } = getConnectorFields(connectorDetails)

  let initialValues = React.useMemo(() => {
    let authType = switch connectorInfo.connector_account_details {
    | HeaderKey(authKeys) => authKeys.auth_type
    | BodyKey(bodyKey) => bodyKey.auth_type
    | SignatureKey(signatureKey) => signatureKey.auth_type
    | MultiAuthKey(multiAuthKey) => multiAuthKey.auth_type
    | CertificateAuth(certificateAuth) => certificateAuth.auth_type
    | CurrencyAuthKey(currencyAuthKey) => currencyAuthKey.auth_type
    | NoKey(noKeyAuth) => noKeyAuth.auth_type
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

  let onSubmit = async (values, _) => {
    try {
      let url = getURL(
        ~entityName=V1(CONNECTOR),
        ~methodType=Post,
        ~id=Some(connectorInfo.merchant_connector_id),
      )
      let _ = await updateAPIHook(url, values, Post)
      switch getConnectorDetails {
      | Some(fun) => fun()->ignore
      | _ => ()
      }
      handleConnectorDetailsUpdate()
      showToast(~message="Details Updated!", ~toastType=ToastSuccess)
    } catch {
    | _ => showToast(~message="Connector Failed to update", ~toastType=ToastError)
    }

    Nullable.null
  }
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

  <Form initialValues validate={validateMandatoryField} onSubmit formClass="w-full py-8">
    <ConnectorConfigurationFields
      connector={connectorTypeFromName}
      connectorAccountFields
      selectedConnector
      connectorMetaDataFields
      connectorWebHookDetails
      connectorLabelDetailField
      connectorAdditionalMerchantData
    />
    <div className="flex p-1 justify-end mb-2">
      <FormRenderer.SubmitButton text="Submit" />
    </div>
  </Form>
}
