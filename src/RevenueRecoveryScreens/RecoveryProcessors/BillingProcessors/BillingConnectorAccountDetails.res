@react.component
let make = (~setCurrentStep) => {
  <div>
    <div className="flex justify-between p-2">
      <RecoveryConfigurationHelper.SubHeading
        title="Choose your Billing Platform"
        subTitle="Choose one processor for now. You can connect more processors later"
      />
    </div>
    <div className="flex justify-end items-center">
      <Button
        text="Next"
        customButtonStyle="rounded w-full"
        buttonType={Primary}
        onClick={_ => setCurrentStep(_ => ConnectorTypes.SummaryAndTest)}
      />
    </div>
  </div>
}
