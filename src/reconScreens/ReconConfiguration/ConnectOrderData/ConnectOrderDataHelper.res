module SelectSource = {
  @react.component
  let make = (~currentStep, ~setCurrentStep) => {
    open ConnectOrderDataUtils
    open ConnectOrderDataTypes
    open ReconConfigurationUtils
    open TempAPIUtils
    let stepConfig = useStepConfig()
    let (selectedStep, setSelectedStep) = React.useState(_ => Hyperswitch)

    let onSubmit = async () => {
      // API Calls
      try {
        let _ = await stepConfig()
        setCurrentStep(prev => getNextStep(prev))
      } catch {
      | _ => ()
      }
    }

    <div className="flex flex-col h-full">
      <div className="flex flex-col gap-3 flex-grow p-2 md:p-7">
        <p className="text-medium text-grey-800 font-semibold mb-5">
          {"Select your order data source"->React.string}
        </p>
        <div className="flex flex-col gap-4">
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
      </div>
      <div className="flex justify-end items-center border-t">
        <ReconConfigurationHelper.Footer
          currentStep={currentStep}
          setCurrentStep={setCurrentStep}
          buttonName="Continue"
          onSubmit={_ => onSubmit()->ignore}
        />
      </div>
    </div>
  }
}

module SetupAPIConnection = {
  @react.component
  let make = (~currentStep, ~setCurrentStep) => {
    open ReconConfigurationUtils

    <div className="flex flex-col h-full">
      <div className="flex flex-col gap-4 flex-grow p-2 md:p-7">
        <p className="text-medium text-grey-800 font-semibold mb-5">
          {"Setup Your API Connection"->React.string}
        </p>
        <FormRenderer.FieldRenderer
          field={FormRenderer.makeFieldInfo(~label="", ~name="file", ~customInput=(
            ~input,
            ~placeholder as _,
          ) => {
            InputFields.fileInput()(
              ~input={
                ...input,
                onChange: event => {
                  input.onChange(event)
                },
              },
            )
          })}
        />
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
          currentStep={currentStep}
          setCurrentStep={setCurrentStep}
          buttonName="Validate"
          onSubmit={_ => setCurrentStep(prev => prev->getNextStep)}
        />
      </div>
    </div>
  }
}
