@react.component
let make = (~setCurrentStep) => {
  open ConnectOrderDataUtils
  open ConnectOrderDataTypes

  let (selectedStep, setSelectedStep) = React.useState(_ => OrderManagementSystem);

  <div className="flex flex-col">
    <ReconConfigurationHelper.Heading
      title="Connect order data"
      subTitle="Enable automatic fetching of your order data to ensure seamless transaction matching and reconciliation"
    />
    <div className="flex">
      <div className="flex-[3] border-r border-grey-outline border-dashed">
        <div className="p-7 flex flex-col gap-4">
          {orderDataStepsArr
          ->Array.map(step => {
            let stepName = step->getStepName;
            let isSelected = selectedStep === step;

            <ReconConfigurationHelper.StepCard 
              key={stepName}
              stepName={stepName}
              isSelected={isSelected}
              iconName={step->getIconName}
              onClick={(_) => setSelectedStep(_ => step)}
            />
          })
          ->React.array}
        </div>
      </div>
      <div className="flex-[4]">
        {switch (selectedStep) {
        | OrderManagementSystem => <ConnectOrderDataHelper.OrderManagementSystem setCurrentStep />
        | Hyperswitch => <ConnectOrderDataHelper.Hyperswitch setCurrentStep />
        | BigQuery => <ConnectOrderDataHelper.BigQuery setCurrentStep/>
        | GoogleDrive => <ConnectOrderDataHelper.GoogleDrive setCurrentStep />
        }}
      </div>
    </div>
  </div>
}
