@react.component
let make = (~setCurrentStep) => {
  <div>
    <ReconConfigurationHelper.Heading
      title="Connect processor data"
    />
    <div className="flex justify-end">
      <Button
        text="Back"
        customButtonStyle="rounded-lg"
        buttonType={Secondary}
        onClick={_ => setCurrentStep(prev => prev->ReconConfigurationUtils.getPrevStep)}
      />
      <Button
        text="Continue"
        customButtonStyle="rounded-lg"
        buttonType={Primary}
        onClick={_ => setCurrentStep(prev => prev->ReconConfigurationUtils.getNextStep)}
      />
    </div>
  </div>
}
