@react.component
let make = (~currentStep: VerticalStepIndicatorTypes.step, ~setCurrentStep) => {
  open ConnectProcessorsHelper

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
        <Form initialValues={Dict.make()->JSON.Encode.object}>
          <ConnectProcessorsFields currentStep setCurrentStep />
        </Form>
      </div>
    </div>
  </div>
}
