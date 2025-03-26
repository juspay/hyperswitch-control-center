@react.component
let make = (~currentStep: VerticalStepIndicatorTypes.step, ~setCurrentStep) => {
  open APIUtils
  open ConnectProcessorsHelper
  open ConnectProcessorsUtils
  open ReconConfigurationUtils
  open VerticalStepIndicatorUtils

  let mixpanelEvent = MixpanelHook.useSendEvent()
  let updateDetails = useUpdateMethod()
  let getURL = useGetURL()

  let getNextStep = (currentStep: VerticalStepIndicatorTypes.step): option<
    VerticalStepIndicatorTypes.step,
  > => {
    findNextStep(sections, currentStep)
  }

  let onNextClick = async () => {
    let url = getURL(~entityName=V1(USERS), ~userType=#USER_DATA, ~methodType=Post)
    let body = getRequestBody(~isOrderDataSet=true, ~isProcessorDataSet=true)
    let _ = await updateDetails(url, body->Identity.genericTypeToJson, Post)

    switch getNextStep(currentStep) {
    | Some(nextStep) => setCurrentStep(_ => nextStep)
    | None => ()
    }
  }

  let onSubmit = async (_values, _form: ReactFinalForm.formApi) => {
    mixpanelEvent(~eventName="recon_onboarding_step2")
    onNextClick()->ignore
    Nullable.null
  }

  <div className="flex flex-col h-full gap-y-10">
    <div className="flex flex-col h-full gap-y-10">
      <ReconConfigurationHelper.SubHeading
        title="Where do you process your payments?"
        subTitle="Choose one processor for now. You can connect more processors later"
      />
      <div className="flex flex-col gap-y-4">
        <p className="text-base text-gray-700 font-semibold">
          {"Select a processor"->React.string}
        </p>
        <Form
          initialValues={Dict.make()->JSON.Encode.object}
          validate={validateProcessorFields}
          onSubmit>
          <ConnectProcessorsFields />
        </Form>
      </div>
    </div>
  </div>
}
