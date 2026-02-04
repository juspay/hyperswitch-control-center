@react.component
let make = (
  ~connectorInfo: ConnectorTypes.connectorPayload,
  ~updateMerchantDetails,
  ~setShowEditForm,
) => {
  open ConnectorUtils
  open APIUtils
  open LogicUtils

  let getURL = useGetURL()
  let updateAPIHook = useUpdateMethod(~showErrorToast=false)
  let showToast = ToastState.useShowToast()

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
      setShowEditForm(_ => false)
      showToast(~message="FRM Credentials Updated!", ~toastType=ToastSuccess)
    } catch {
    | _ => showToast(~message="Failed to update FRM credentials", ~toastType=ToastError)
    }

    Nullable.null
  }

  <Form
    onSubmit={onSubmit}
    initialValues
    validate={values => FRMUtils.validate(~values, ~selectedFRMInfo)}
    formClass="w-full py-4">
    {FRMHelper.frmIntegFormFields(~selectedFRMInfo)}
    <div className="flex p-1 gap-4 justify-end mt-2">
      <Button text="Cancel" buttonType={Secondary} onClick={_ => setShowEditForm(_ => false)} />
      <FormRenderer.SubmitButton text="Submit" />
    </div>
  </Form>
}
