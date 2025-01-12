module APIKeysAndLiveEndpoints = {
  @react.component
  let make = (~currentStep, ~setCurrentStep) => {
    open ReconConfigurationUtils

    <div className="flex flex-col h-full">
      <div className="flex flex-col gap-4 flex-grow p-2 md:p-7">
        <p className="text-medium text-grey-800 font-semibold mb-5">
          {"Setup Your API Keys & Live Endpoints"->React.string}
        </p>
      </div>
      <div className="flex justify-end items-center border-t">
        <ReconConfigurationHelper.Footer
          currentStep={currentStep}
          setCurrentStep={setCurrentStep}
          buttonName="Continue"
          onSubmit={_ => setCurrentStep(prev => prev->getNextStep)}
        />
      </div>
    </div>
  }
}

module WebHooks = {
  @react.component
  let make = (~currentStep, ~setCurrentStep) => {
    open ReconConfigurationUtils

    <div className="flex flex-col h-full">
      <div className="flex flex-col gap-4 flex-grow p-2 md:p-7">
        <p className="text-medium text-grey-800 font-semibold mb-5">
          {"Setup Webhook"->React.string}
        </p>
      </div>
      <div className="flex justify-end items-center border-t">
        <ReconConfigurationHelper.Footer
          currentStep={currentStep}
          setCurrentStep={setCurrentStep}
          buttonName="Continue"
          onSubmit={_ => setCurrentStep(prev => prev->getNextStep)}
        />
      </div>
    </div>
  }
}
