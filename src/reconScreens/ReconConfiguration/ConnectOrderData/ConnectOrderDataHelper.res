module SelectSource = {
  @react.component
  let make = (~currentStep, ~setCurrentStep) => {
    open ConnectOrderDataUtils
    open ConnectOrderDataTypes

    let (selectedStep, setSelectedStep) = React.useState(_ => Hyperswitch)
    <div className="flex flex-col h-full">
      <div className="flex flex-col gap-4 flex-grow p-2 md:p-7">
        <p className="text-medium text-grey-800 font-semibold mb-5">
          {"Select your order data source"->React.string}
        </p>
        {orderDataStepsArr
        ->Array.map(step => {
          let stepName = step->getSelectedStepName
          let description = step->getSelectedStepDescription
          let isSelected = selectedStep === step
          <ReconConfigurationHelper.StepCard
            key={stepName}
            stepName={stepName}
            description={description}
            isSelected={isSelected}
            iconName={step->getIconName}
            onClick={_ => setSelectedStep(_ => step)}
          />
        })
        ->React.array}
      </div>
      <div className="flex justify-end items-center border-t">
        <ReconConfigurationHelper.Footer
          currentStep={currentStep} setCurrentStep={setCurrentStep} buttonName="Continue"
        />
      </div>
    </div>
  }
}

module SetupCredentials = {
  @react.component
  let make = (~currentStep, ~setCurrentStep) => {
    <div className="flex flex-col h-full">
      <div className="flex flex-col gap-4 flex-grow p-2 md:p-7">
        <p className="text-medium text-grey-800 font-semibold mb-5">
          {"Setup Your API Connection"->React.string}
        </p>
        <div className="flex gap-6">
          <FormRenderer.FieldRenderer
            field={FormRenderer.makeFieldInfo(
              ~label="Endpoint URL",
              ~name="endPointURL",
              ~placeholder="https://",
              ~isRequired=true,
              ~customInput=InputFields.textInput(~customWidth="w-18-rem"),
            )}
          />
          <FormRenderer.FieldRenderer
            field={FormRenderer.makeFieldInfo(
              ~label="Auth Key",
              ~name="authKey",
              ~placeholder="***********",
              ~isRequired=true,
              ~customInput=InputFields.textInput(~customWidth="w-18-rem"),
            )}
          />
        </div>
        <h1 className="text-sm font-medium text-blue-500 mt-2 px-1.5">
          {"Learn where to find these values ->"->React.string}
        </h1>
      </div>
      <div className="flex justify-end items-center border-t">
        <ReconConfigurationHelper.Footer
          currentStep={currentStep} setCurrentStep={setCurrentStep} buttonName="Continue"
        />
      </div>
    </div>
  }
}
