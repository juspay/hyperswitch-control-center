@react.component
let make = (~connector, ~connectorInfo: ConnectorTypes.connectorPayload) => {
  open ConnectorUtils
  open APIUtils
  open ConnectorAccountDetailsHelper
  let getURL = useGetURL()
  let updateAPIHook = useUpdateMethod(~showErrorToast=false)
  let showToast = ToastState.useShowToast()

  let (showModal, setShowFeedbackModal) = React.useState(_ => false)
  // Need to remove connector and merge connector and connectorTypeVariants
  let (processorType, connectorType) = connectorInfo.connector_type->connectorTypeTuple
  let connectorTypeFromName = connector->getConnectorNameTypeFromString(~connectorType)

  let connectorDetails = React.useMemo(() => {
    try {
      if connector->LogicUtils.isNonEmptyString {
        let dict = switch processorType {
        | PaymentProcessor => Window.getConnectorConfig(connector)
        | PayoutProcessor => Window.getPayoutConnectorConfig(connector)
        | AuthenticationProcessor => Window.getAuthenticationConnectorConfig(connector)
        | PMAuthProcessor => Window.getPMAuthenticationProcessorConfig(connector)
        | _ => JSON.Encode.null
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
  }, [connector])
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
    [
      ("connector_type", connectorInfo.connector_type->JSON.Encode.string),
      (
        "connector_account_details",
        [("auth_type", connectorInfo.connector_account_details.auth_type->JSON.Encode.string)]
        ->Dict.fromArray
        ->JSON.Encode.object,
      ),
      ("connector_webhook_details", connectorInfo.connector_webhook_details),
      ("connector_label", connectorInfo.connector_label->JSON.Encode.string),
      ("metadata", connectorInfo.metadata),
    ]
    ->Dict.fromArray
    ->JSON.Encode.object
  }, [])

  React.useEffect(() => {
    None
  }, [])

  let onSubmit = async (values, _) => {
    try {
      let url = getURL(
        ~entityName=CONNECTOR,
        ~methodType=Post,
        ~id=Some(connectorInfo.merchant_connector_id),
      )
      let _ = await updateAPIHook(url, values, Post)
      setShowFeedbackModal(_ => false)
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
  }, [connector])
  <>
    <div className="cursor-pointer" onClick={_ => setShowFeedbackModal(_ => true)}>
      <ToolTip
        height=""
        description={`Update the ${connector} creds`}
        toolTipFor={<Icon name="edit" className={`mt-1 ml-1`} />}
        toolTipPosition=Top
        tooltipWidthClass="w-fit"
      />
    </div>
    <Modal
      closeOnOutsideClick=true
      modalHeading={`Update Connector ${connector}`}
      showModal
      setShowModal=setShowFeedbackModal
      childClass="p-1"
      borderBottom=true
      revealFrom=Reveal.Right
      modalClass="w-full md:w-1/3 !h-full overflow-y-scroll !overflow-x-hidden rounded-none text-jp-gray-900">
      {<>
        <Form initialValues validate={validateMandatoryField} onSubmit>
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
          <FormValuesSpy />
        </Form>
      </>}
    </Modal>
  </>
}
