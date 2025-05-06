@react.component
let make = (~connectorInfo: ConnectorTypes.connectorPayload, ~getConnectorDetails) => {
  open APIUtils
  open ConnectorUtils
  open ConnectorAccountDetailsHelper

  let mixpanelEvent = MixpanelHook.useSendEvent()
  let updateAPIHook = useUpdateMethod(~showErrorToast=false)
  let getURL = useGetURL()
  let showToast = ToastState.useShowToast()

  let (showModal, setShowFeedbackModal) = React.useState(_ => false)
  let {connector_name: connectorName} = connectorInfo
  let (processorType, connectorType) =
    connectorInfo.connector_type
    ->connectorTypeTypedValueToStringMapper
    ->connectorTypeTuple
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

  let {connectorMetaDataFields, connectorWebHookDetails} = getConnectorFields(connectorDetails)

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
      setShowFeedbackModal(_ => false)
      showToast(~message="Details Updated!", ~toastType=ToastSuccess)
    } catch {
    | _ => showToast(~message="Connector Failed to update", ~toastType=ToastError)
    }

    Nullable.null
  }

  let initialValues = React.useMemo(() => {
    [
      (
        "connector_type",
        connectorInfo.connector_type
        ->connectorTypeTypedValueToStringMapper
        ->JSON.Encode.string,
      ),
      ("connector_webhook_details", connectorInfo.connector_webhook_details),
      ("metadata", connectorInfo.metadata),
    ]->LogicUtils.getJsonFromArrayOfJson
  }, (
    connectorInfo.connector_webhook_details,
    connectorInfo.connector_label,
    connectorInfo.metadata,
  ))

  let selectedConnector = React.useMemo(() => {
    connectorTypeFromName->getConnectorInfo
  }, [connectorName])

  let validateMandatoryField = values => {
    let errors = Dict.make()
    let valuesFlattenJson = values->JsonFlattenUtils.flattenObject(true)
    validateOtherDetailsRequiredFields(
      connectorTypeFromName,
      valuesFlattenJson,
      connectorMetaDataFields,
      connectorWebHookDetails,
      errors->JSON.Encode.object,
    )
  }

  <>
    <div
      className="cursor-pointer py-2"
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
        <ConnectorAdditionalDetailsFields
          connector={connectorTypeFromName}
          selectedConnector
          connectorWebHookDetails
          connectorMetaDataFields
        />
        <div className="flex p-1 justify-end mb-2">
          <FormRenderer.SubmitButton text="Submit" />
        </div>
      </Form>
    </Modal>
  </>
}
