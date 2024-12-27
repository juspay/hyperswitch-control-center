@react.component
let make = (~setCurrentStep) => {
  <div>
    <ReconConfigurationHelper.Heading title="Schedule Recon Reports" />
    <div className="flex justify-end">
      <Button
        text="Back"
        customButtonStyle="rounded-lg"
        buttonType={Secondary}
        onClick={_ => setCurrentStep(prev => prev->ReconConfigurationUtils.getPrevStep)}
      />
      <Button
        text="Submit"
        customButtonStyle="rounded-lg"
        buttonType={Primary}
        onClick={_ => setCurrentStep(prev => prev->ReconConfigurationUtils.getNextStep)}
      />
    </div>
  </div>
}
