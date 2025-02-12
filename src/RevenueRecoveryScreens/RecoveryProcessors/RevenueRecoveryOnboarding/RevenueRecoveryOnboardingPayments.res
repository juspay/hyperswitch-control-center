@react.component
let make = (
  ~currentStep,
  ~setConnectorId,
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

  let connector = UrlUtils.useGetFilterDictFromUrl("")->LogicUtils.getString("name", "")

  let onSubmit = async (values, _form: ReactFinalForm.formApi) => {
    try {
      let connectorUrl = getURL(~entityName=CONNECTOR, ~methodType=Post, ~id=None)
      let response = await updateDetails(connectorUrl, values, Post)
      let connectorId = response->getDictFromJsonObject->getString("merchant_connector_id", "")
      setConnectorId(_ => connectorId)
      onNextClick(currentStep, setNextStep)
    } catch {
    | _ => ()
    }
    Nullable.null
  }

  let updatedInitialVal = React.useMemo(() => {
    let initialValuesToDict = initialValues->getDictFromJsonObject
    // TODO: Refactor for generic case
    initialValuesToDict->Dict.set("connector_name", `${connector}`->JSON.Encode.string)
    initialValuesToDict->Dict.set("connector_label", `${connector}`->JSON.Encode.string)
    initialValuesToDict->Dict.set("connector_type", "payment_processor"->JSON.Encode.string)
    initialValuesToDict->Dict.set("profile_id", profileId->JSON.Encode.string)
    initialValuesToDict->JSON.Encode.object
  }, [connector, profileId])

  <div>
    <Form onSubmit initialValues>
      {switch currentStep {
      | {sectionId: "connectProcessor", subSectionId: Some("selectProcessor")} =>
        <div>
          <ConnectorAuthKeys
            initialValues={updatedInitialVal} setInitialValues showVertically=true
          />
          <Button
            text="Next"
            buttonType=Primary
            onClick={_ => onNextClick(currentStep, setNextStep)->ignore}
          />
        </div>
      | {sectionId: "connectProcessor", subSectionId: Some("activePaymentMethods")}
      | {sectionId: "connectProcessor", subSectionId: Some("setupWebhookProcessor")} =>
        <div>
          <Button
            text="Previous" onClick={_ => onPreviousClick(currentStep, setNextStep)->ignore}
          />
          <Button
            text="Next"
            buttonType=Primary
            onClick={_ => onNextClick(currentStep, setNextStep)->ignore}
          />
          {"payment"->React.string}
        </div>
      | _ => React.null
      }}
      //<FormValuesSpy />
    </Form>
  </div>
}
