@react.component
let make = (~initialValues, ~setInitialValues) => {
  <div className="flex flex-col gap-4">
    <div className="flex justify-between border-b pb-4 px-2 items-end">
      <p className="text-md font-semibold"> {"Authentication keys"->React.string} </p>
      <div className="flex gap-4">
        <FormRenderer.SubmitButton text="Submit" buttonSize={Small} />
        <Button
          text="Continue"
          buttonType={Secondary}
          buttonSize={Small}
          // onClick={_ => setCurrentStep(prev => getNextStep(prev))}
        />
      </div>
    </div>
    <ConnectorAuthKeys initialValues setInitialValues showVertically=false />
    <ConnectorPaymentMethodV2 initialValues setInitialValues />
  </div>
}
