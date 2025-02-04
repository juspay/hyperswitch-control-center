@react.component
let make = (~setCurrentStep) => {
  <div>
    <RecoveryConfigurationHelper.SubHeading
      title="Configure Recovery Plan"
      subTitle="Choose one processor for now. You can connect more processors later"
    />
    <div className="flex justify-end items-center">
      <Button
        text="Next"
        customButtonStyle="rounded w-full"
        buttonType={Primary}
        onClick={_ => setCurrentStep(_ => ConnectorTypes.AutomaticFlow)}
      />
    </div>
  </div>
}
