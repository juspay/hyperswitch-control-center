module SFTPSetup = {
  @react.component
  let make = (~setCurrentStep) => {
    <div className="flex flex-col gap-y-5 mt-10">
      <h3 className="font-semibold px-1.5">
        {"Enter credentials for SFTP Setup"->React.string}
      </h3>
      <div className="flex justify-end">
        <Button
          text="Continue"
          customButtonStyle="rounded-lg"
          buttonType={Primary}
          onClick={_ => setCurrentStep(prev => prev->ReconConfigurationUtils.getNextStep)}
        />
      </div>
    </div>
  }
}

module APIBased = {
  @react.component
  let make = (~setCurrentStep) => {
    <div className="flex flex-col gap-y-5 mt-10">
      <h3 className="font-semibold px-1.5">
        {"Enter credentials for API Based Setup"->React.string}
      </h3>
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
      <div className="flex justify-end">
        <Button
          text="Continue"
          customButtonStyle="rounded-lg"
          buttonType={Primary}
          onClick={_ => setCurrentStep(prev => prev->ReconConfigurationUtils.getNextStep)}
        />
      </div>
    </div>
  }
}

module WebHooks = {
  @react.component
  let make = (~setCurrentStep) => {
    <div className="flex flex-col gap-y-5 mt-10">
      <h3 className="font-semibold px-1.5">
        {"Enter credentials for Web Hooks Setup"->React.string}
      </h3>
      <div className="flex justify-end">
        <Button
          text="Continue"
          customButtonStyle="rounded-lg"
          buttonType={Primary}
          onClick={_ => setCurrentStep(prev => prev->ReconConfigurationUtils.getNextStep)}
        />
      </div>
    </div>
  }
}

module ManualUpload = {
  @react.component
  let make = (~setCurrentStep) => {
    <div className="flex flex-col gap-y-5 mt-10">
      <h3 className="font-semibold px-1.5">
        {"Upload your file manually"->React.string}
      </h3>
      <div className="flex justify-end">
        <Button
          text="Continue"
          customButtonStyle="rounded-lg"
          buttonType={Primary}
          onClick={_ => setCurrentStep(prev => prev->ReconConfigurationUtils.getNextStep)}
        />
      </div>
    </div>
  }
}

module OrderManagementSystem = {
  open ConnectOrderDataUtils
  open ConnectOrderDataTypes

  @react.component
  let make = (~setCurrentStep) => {
    let (initialValues, setInitialValues) = React.useState(_ => Dict.make()->JSON.Encode.object)
    let (selectedFlowType, setSelectedFlowType) = React.useState(_ => SFTPSetup)

    React.useEffect(() => {
      setInitialValues(_ => {
        let initialValuesDict = Dict.make()
        initialValuesDict->Dict.set(
          "orderManagementFlowType",
          getFlowTypeNameString(selectedFlowType)->JSON.Encode.string,
        )
        initialValuesDict->JSON.Encode.object
      })
      None
    }, [])

    <div className="px-6">
      <Form initialValues={initialValues}>
        <FormRenderer.FieldRenderer
          field={FormRenderer.makeFieldInfo(
            ~label="",
            ~name="orderManagementFlowType",
            ~customInput=(~input, ~placeholder as _) => {
              InputFields.radioInput(
                ~options=connectOrderDataFlowOptions->Array.map((
                  item
                ): SelectBox.dropdownOption => {
                  {
                    label: item->getFlowTypeLabel,
                    value: item,
                  }
                }),
                ~isHorizontal=true,
                ~buttonText="options",
                ~customStyle="flex gap-2 !overflow-visible hover:bg-white cursor-pointer",
                ~customSelectStyle="text-blue-812",
              )(
                ~input={
                  ...input,
                  onChange: event => {
                    input.onChange(event)
                    setSelectedFlowType(_ =>
                      getFlowTypeVariantFromString(event->Identity.formReactEventToString)
                    )
                  },
                },
                ~placeholder="",
              )
            },
          )}
        />
        {switch selectedFlowType {
        | SFTPSetup => <SFTPSetup setCurrentStep />
        | APIBased => <APIBased setCurrentStep />
        | WebHooks => <WebHooks setCurrentStep />
        | ManualUpload => <ManualUpload setCurrentStep />
        }}
      </Form>
    </div>
  }
}

module Hyperswitch = {
  @react.component
  let make = (~setCurrentStep) => {
    <div>
      <p> {"Hyperswitch"->React.string} </p>
      <div className="flex justify-end">
        <Button
          text="Continue"
          customButtonStyle="rounded-lg"
          buttonType={Primary}
          onClick={_ => setCurrentStep(prev => prev->ReconConfigurationUtils.getNextStep)}
        />
      </div>
    </div>
  }
}

module BigQuery = {
  @react.component
  let make = (~setCurrentStep) => {
    <div>
      <p> {"Big Query"->React.string} </p>
      <div className="flex justify-end">
        <Button
          text="Continue"
          customButtonStyle="rounded-lg"
          buttonType={Primary}
          onClick={_ => setCurrentStep(prev => prev->ReconConfigurationUtils.getNextStep)}
        />
      </div>
    </div>
  }
}

module GoogleDrive = {
  @react.component
  let make = (~setCurrentStep) => {
    <div>
      <p> {"Google Drive"->React.string} </p>
      <div className="flex justify-end">
        <Button
          text="Continue"
          customButtonStyle="rounded-lg"
          buttonType={Primary}
          onClick={_ => setCurrentStep(prev => prev->ReconConfigurationUtils.getNextStep)}
        />
      </div>
    </div>
  }
}
