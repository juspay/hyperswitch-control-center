@react.component
let make = (
  ~connectorInfo: ConnectorTypes.connectorPayload,
  ~getConnectorDetails=None,
  ~updateMerchantDetails,
) => {
  open ConnectorUtils
  open APIUtils
  open LogicUtils

  let getURL = useGetURL()
  let updateAPIHook = useUpdateMethod(~showErrorToast=false)
  let showToast = ToastState.useShowToast()

  let (showModal, setShowFeedbackModal) = React.useState(_ => false)
  let connectorName = connectorInfo.connector_name

  let connectorType = connectorName->getConnectorNameTypeFromString(~connectorType=FRMPlayer)

  let selectedFRMInfo = connectorType->ConnectorUtils.getConnectorInfo

  let initialValues = React.useMemo(() => {
    let frmAccountDetailsDict =
      [
        ("auth_type", connectorType->FRMInfo.getFRMAuthType->JSON.Encode.string),
      ]->getJsonFromArrayOfJson
    [
      (
        "connector_type",
        connectorInfo.connector_type
        ->connectorTypeTypedValueToStringMapper
        ->JSON.Encode.string,
      ),
      ("connector_account_details", frmAccountDetailsDict),
    ]->getJsonFromArrayOfJson
  }, [connectorInfo.merchant_connector_id])

  let onSubmit = async (values, _) => {
    try {
      let url = getURL(
        ~entityName=V1(FRAUD_RISK_MANAGEMENT),
        ~methodType=Post,
        ~id=Some(connectorInfo.merchant_connector_id),
      )
      let _ = await updateAPIHook(url, values, Post)
      let _ = await updateMerchantDetails()
      switch getConnectorDetails {
      | Some(fun) => fun()->ignore
      | _ => ()
      }
      setShowFeedbackModal(_ => false)
      showToast(~message="FRM Credentials Updated!", ~toastType=ToastSuccess)
    } catch {
    | _ => showToast(~message="Failed to update FRM credentials", ~toastType=ToastError)
    }

    Nullable.null
  }

  <>
    <div
      className="cursor-pointer py-2"
      onClick={_ => {
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
      modalHeading={`Update FRM Connector ${connectorName}`}
      showModal
      setShowModal=setShowFeedbackModal
      childClass="p-1"
      borderBottom=true
      revealFrom=Reveal.Right
      modalClass="w-full md:w-1/3 !h-full overflow-y-scroll !overflow-x-hidden rounded-none text-jp-gray-900">
      <Form
        onSubmit={onSubmit}
        initialValues
        validate={values => FRMUtils.validate(~values, ~selectedFRMInfo)}>
        {FRMHelper.frmIntegFormFields(~selectedFRMInfo)}
        <div className="flex p-1 justify-end mb-2">
          <FormRenderer.SubmitButton text="Submit" />
        </div>
        <FormValuesSpy />
      </Form>
    </Modal>
  </>
}
