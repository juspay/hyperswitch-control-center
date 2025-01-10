module TestLivePayment = {
  @react.component
  let make = (~currentStep, ~setCurrentStep) => {
    <div className="flex flex-col h-full">
      <div className="flex flex-col gap-4 flex-grow p-2 md:p-7">
        <p className="text-medium text-grey-800 font-semibold mb-5">
          {"Test Live Payment"->React.string}
        </p>
      </div>
      <div className="flex justify-end items-center border-t">
        <ReconConfigurationHelper.Footer
          currentStep={currentStep}
          setCurrentStep={setCurrentStep}
          buttonName="Continue"
          onSubmit={_ => ()}
        />
      </div>
    </div>
  }
}

module SetupCompleted = {
  @react.component
  let make = (~currentStep, ~setCurrentStep) => {
    <div className="flex flex-col h-full">
      <div className="flex flex-col gap-4 flex-grow p-2 md:p-7">
        <p className="text-medium text-grey-800 font-semibold mb-5">
          {"Setup Completed"->React.string}
        </p>
      </div>
      <div className="flex justify-end items-center border-t">
        <ReconConfigurationHelper.Footer
          currentStep={currentStep}
          setCurrentStep={setCurrentStep}
          buttonName="Continue"
          onSubmit={_ => ()}
        />
      </div>
    </div>
  }
}
