open HSwitchUtils
let p1RegularText = getTextClass((P1, Regular))

module SelectSource = {
  @react.component
  let make = (~currentStep, ~setCurrentStep) => {
    open ConnectOrderDataUtils
    open ConnectOrderDataTypes
    open ReconConfigurationUtils
    open TempAPIUtils
    let stepConfig = useStepConfig(~step=currentStep->getSubsectionFromStep)
    let (selectedStep, setSelectedStep) = React.useState(_ => Hyperswitch)

    let onSubmit = async () => {
      try {
        let _ = await stepConfig()
        setCurrentStep(prev => getNextStep(prev))
      } catch {
      | _ => ()
      }
    }

    <div className="flex flex-col h-full">
      <div className="flex flex-col gap-3 flex-grow p-2 md:p-7">
        <p className="text-medium text-grey-800 font-semibold mb-5">
          {"Select your order data source"->React.string}
        </p>
        <div className="flex flex-col gap-4">
          {orderDataStepsArr
          ->Array.map(step => {
            let stepName = step->getSelectedStepName
            let description = step->getSelectedStepDescription
            let isSelected = selectedStep === step
            <ReconConfigurationHelper.StepCard
              key={stepName}
              stepName={stepName}
              description={description}
              isSelected={isSelected}
              iconName={step->getIconName}
              onClick={_ => setSelectedStep(_ => step)}
            />
          })
          ->React.array}
        </div>
      </div>
      <div className="flex justify-end items-center border-t">
        <ReconConfigurationHelper.Footer
          currentStep={currentStep}
          setCurrentStep={setCurrentStep}
          buttonName="Continue"
          onSubmit={_ => onSubmit()->ignore}
        />
      </div>
    </div>
  }
}

module SetupAPIConnection = {
  @react.component
  let make = (~currentStep, ~setCurrentStep) => {
    open ReconConfigurationUtils
    open LogicUtils
    open TempAPIUtils

    let (fileUploadedDict, setFileUploadedDict) = React.useState(_ => Dict.make())
    let uploadEvidenceType = "Basefile"->String.toLowerCase->titleToSnake
    let showToast = ToastState.useShowToast()
    let stepConfig = useStepConfig(~step=currentStep->getSubsectionFromStep, ~fileUploadedDict)

    let toast = (message, toastType) => {
      showToast(~message, ~toastType)
    }

    let onSubmit = async () => {
      if fileUploadedDict->Dict.get(uploadEvidenceType)->Option.isNone {
        toast("Please upload a file", ToastError)
      } else {
        try {
          let _ = await stepConfig()
          setCurrentStep(prev => getNextStep(prev))
        } catch {
        | _ => ()
        }
      }
    }

    let handleBrowseChange = (event, uploadEvidenceType) => {
      let target = ReactEvent.Form.target(event)
      let fileDict =
        [
          ("uploadedFile", target["files"]["0"]->Identity.genericTypeToJson),
          ("fileName", target["files"]["0"]["name"]->JSON.Encode.string),
        ]->getJsonFromArrayOfJson

      setFileUploadedDict(prev => {
        let arr = prev->Dict.toArray
        let newDict = [(uploadEvidenceType, fileDict)]->Array.concat(arr)->Dict.fromArray
        newDict
      })
    }

    <div className="flex flex-col h-full">
      <div className="flex flex-col gap-4 flex-grow p-2 md:p-7">
        <p className="text-medium text-grey-800 font-semibold mb-5">
          {"Setup Your API Connection"->React.string}
        </p>
        <div className="flex items-center">
          {if fileUploadedDict->Dict.get(uploadEvidenceType)->Option.isNone {
            <label>
              <p className="cursor-pointer text-gray-500">
                <div className="flex gap-2 border border-gray-500 rounded-lg p-2 items-center">
                  <Icon name="plus" size=14 />
                  <p> {"Upload base file"->React.string} </p>
                </div>
                <input
                  type_="file"
                  accept=".csv"
                  onChange={ev => ev->handleBrowseChange(uploadEvidenceType)}
                  required=true
                  hidden=true
                />
              </p>
            </label>
          } else {
            let fileName =
              fileUploadedDict->getDictfromDict(uploadEvidenceType)->getString("fileName", "")
            let truncatedFileName = truncateFileNameWithEllipses(~fileName, ~maxTextLength=10)

            <div className="flex gap-4 items-center ">
              <p className={`${p1RegularText} text-grey-700`}>
                {truncatedFileName->React.string}
              </p>
              <Icon
                name="cross-skeleton"
                className="cursor-pointer"
                size=12
                onClick={_ => {
                  setFileUploadedDict(prev => {
                    let prevCopy = prev->Dict.copy
                    prevCopy->Dict.delete(uploadEvidenceType)
                    prevCopy
                  })
                }}
              />
            </div>
          }}
        </div>
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
      </div>
      <div className="flex justify-end items-center border-t">
        <ReconConfigurationHelper.Footer
          currentStep={currentStep}
          setCurrentStep={setCurrentStep}
          buttonName="Validate"
          onSubmit={_ => onSubmit()->ignore}
        />
      </div>
    </div>
  }
}
