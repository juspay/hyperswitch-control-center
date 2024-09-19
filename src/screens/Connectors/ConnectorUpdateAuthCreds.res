@react.component
let make = (~connectorInfo: ConnectorTypes.connectorPayload, ~getConnectorDetails) => {
  open ConnectorUtils
  open APIUtils
  open LogicUtils
  open ConnectorAccountDetailsHelper
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let getURL = useGetURL()
  let updateAPIHook = useUpdateMethod(~showErrorToast=false)
  let showToast = ToastState.useShowToast()

  let (showModal, setShowFeedbackModal) = React.useState(_ => false)
  // Need to remove connector and merge connector and connectorTypeVariants
  let (processorType, connectorType) = connectorInfo.connector_type->connectorTypeTuple
  let {connector_name: connectorName, merchant_connector_id: connectorId} = connectorInfo
  let connectorTypeFromName = connectorName->getConnectorNameTypeFromString(~connectorType)

  React.useEffect(() => {
    RescriptReactRouter.replace(
      GlobalVars.appendDashboardPath(~url=`/connectors/${connectorId}?name=${connectorName}`),
    )
    None
  }, [])

  let connectorDetails = React.useMemo(() => {
    try {
      if connectorName->LogicUtils.isNonEmptyString {
        let dict = switch processorType {
        | PaymentProcessor => Window.getConnectorConfig(connectorName)
        | PayoutProcessor => Window.getPayoutConnectorConfig(connectorName)
        | AuthenticationProcessor => Window.getAuthenticationConnectorConfig(connectorName)
        | PMAuthProcessor => Window.getPMAuthenticationProcessorConfig(connectorName)
        | TaxProcessor => Window.getTaxProcessorConfig(connectorName)
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
  }, [connectorName])
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
        ~entityName=CONNECTOR,
        ~methodType=Post,
        ~id=Some(connectorInfo.merchant_connector_id),
      )
      let _ = await updateAPIHook(url, values, Post)
      switch getConnectorDetails {
      | Some(fun) => fun()->ignore
      | _ => ()
      }
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
  }, [connectorName])
  <>
    <div
      className="cursor-pointer"
      onClick={_ => {
        mixpanelEvent(~eventName=`processor_update_creds_${connectorName}`)
        setShowFeedbackModal(_ => true)
      }}>
      <ToolTip
        height=""
        description={`Update the ${connectorName} creds`}
        toolTipFor={<Icon size=18 name="edit" className={`mt-1 ml-1`} />}
        toolTipPosition=Top
        tooltipWidthClass="w-fit"
      />
    </div>
    <Modal
      closeOnOutsideClick=true
      modalHeading={`Update Connector ${connectorName}`}
      showModal
      setShowModal=setShowFeedbackModal
      childClass="p-1"
      borderBottom=true
      revealFrom=Reveal.Right
      modalClass="w-full md:w-1/3 !h-full overflow-y-scroll !overflow-x-hidden rounded-none text-jp-gray-900">
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
    </Modal>
  </>
}
