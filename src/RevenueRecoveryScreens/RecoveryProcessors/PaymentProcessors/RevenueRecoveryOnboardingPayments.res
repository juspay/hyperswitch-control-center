@react.component
let make = (
  ~currentStep,
  ~setConnectorID,
  ~connector,
  ~setConnectorName,
  ~onNextClick,
  ~setNextStep,
  ~profileId,
  ~onPreviousClick,
) => {
  open APIUtils
  open LogicUtils
  open VerticalStepIndicatorTypes
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod(~showErrorToast=false)
  let (initialValues, setInitialValues) = React.useState(_ => Dict.make()->JSON.Encode.object)

  let onSubmit = async (values, _form: ReactFinalForm.formApi) => {
    try {
      let connectorUrl = getURL(~entityName=CONNECTOR, ~methodType=Post, ~id=None)
      let response = await updateDetails(connectorUrl, values, Post)
      let connectorId = response->getDictFromJsonObject->getString("merchant_connector_id", "")
      setConnectorID(_ => connectorId)
      onNextClick(currentStep, setNextStep)
    } catch {
    | _ => ()
    }
    Nullable.null
  }

  <Form onSubmit initialValues>
    {switch currentStep {
    | {sectionId: "connectProcessor", subSectionId: Some("selectProcessor")} =>
      <div>
        <PaymentProcessorsAuthKeys
          initialValues setInitialValues profileId connector setConnectorName
        />
        <Button
          text="Next"
          buttonType=Primary
          onClick={_ => onNextClick(currentStep, setNextStep)->ignore}
          customButtonStyle="w-full"
        />
      </div>
    | {sectionId: "connectProcessor", subSectionId: Some("activePaymentMethods")}
    | {sectionId: "connectProcessor", subSectionId: Some("setupWebhookProcessor")} =>
      <div>
        <Button text="Previous" onClick={_ => onPreviousClick(currentStep, setNextStep)->ignore} />
        <Button
          text="Next"
          buttonType=Primary
          onClick={_ => onNextClick(currentStep, setNextStep)->ignore}
          customButtonStyle="w-full"
        />
        {"payment"->React.string}
      </div>
    | _ => React.null
    }}
    //<FormValuesSpy />
  </Form>
}
