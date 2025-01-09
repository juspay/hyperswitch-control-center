@react.component
let make = () => {
  open ConnectOrderDataUtils
  open ConnectOrderDataTypes

  let (selectedStep, setSelectedStep) = React.useState(_ => OrderManagementSystem)

  <div className="flex flex-col w-full gap-4">
    <div className="p-7 flex flex-col gap-4">
      {"Connect Order Data"->React.string}
      {orderDataStepsArr
      ->Array.map(step => {
        let stepName = step->getSelectedStepName
        let isSelected = selectedStep === step
        <ReconConfigurationHelper.StepCard
          key={stepName}
          stepName={stepName}
          isSelected={isSelected}
          iconName={step->getIconName}
          onClick={_ => setSelectedStep(_ => step)}
        />
      })
      ->React.array}
    </div>
  </div>
}
