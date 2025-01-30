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
    let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)

    let onSubmit = async () => {
      // try {
      //   setScreenState(_ => PageLoaderWrapper.Loading)
      //   let _ = await stepConfig()
      //   setCurrentStep(prev => getNextStep(prev))
      // } catch {
      // | Exn.Error(e) =>
      //   let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
      //   setScreenState(_ => PageLoaderWrapper.Error(err))
      // }
      setCurrentStep(prev => getNextStep(prev))
    }

    <PageLoaderWrapper screenState={screenState}>
      <ReconConfigurationHelper.SubHeading
        title="Define Order Source"
        subTitle="Enable automatic fetching of your order data to ensure seamless transaction matching and reconciliation"
      />
      <div className="flex flex-col h-full gap-y-10">
        <div className="flex flex-col gap-y-4">
          <p className="text-base text-gray-700 font-semibold">
            {"Where do you want to fetch your data from?"->React.string}
          </p>
          <div className="flex flex-col gap-y-4">
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
                iconName={step->ConnectOrderDataUtils.getIconName}
                onClick={_ => setSelectedStep(_ => step)}
              />
            })
            ->React.array}
          </div>
        </div>
        <div className="flex justify-end items-center">
          <ReconConfigurationHelper.Footer
            currentStep={currentStep} onSubmit={_ => onSubmit()->ignore}
          />
        </div>
      </div>
    </PageLoaderWrapper>
  }
}

type state = {fileContent: option<string>}

type action =
  | SetFileContent(string)
  | SetError(string)

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
    let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)
    let {userInfo: {merchantId}} = React.useContext(UserInfoProvider.defaultContext)

    let toast = (message, toastType) => {
      showToast(~message, ~toastType)
    }

    React.useEffect0(() => {
      let fetchData = async () => {
        try {
          let response = await Fetch.fetch("/basefile.csv")
          let blob = await Fetch.Response.blob(response)

          let fileDict =
            [
              ("uploadedFile", blob->Identity.genericTypeToJson),
              ("fileName", `${merchantId}_20250124.csv`->JSON.Encode.string),
            ]->getJsonFromArrayOfJson

          setFileUploadedDict(prev => {
            let arr = prev->Dict.toArray
            let newDict = [(uploadEvidenceType, fileDict)]->Array.concat(arr)->Dict.fromArray
            newDict
          })
        } catch {
        | error => {
            Js.Console.error2("Error reading CSV file:", error)
            toast("Error loading file", ToastError)
          }
        }
      }

      fetchData()->ignore
      None
    })

    Js.log2("fileUploadedDict", fileUploadedDict)

    let onSubmit = async () => {
      if fileUploadedDict->Dict.get(uploadEvidenceType)->Option.isNone {
        toast("Please upload a file", ToastError)
      } else {
        try {
          setScreenState(_ => PageLoaderWrapper.Loading)
          let _ = await stepConfig()
          setCurrentStep(prev => getNextStep(prev))
        } catch {
        | Exn.Error(e) =>
          let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
          setScreenState(_ => PageLoaderWrapper.Error(err))
        }
      }
    }

    <PageLoaderWrapper screenState={screenState}>
      <ReconConfigurationHelper.SubHeading
        title="Setup API" subTitle="Connect your API to fetch order data from your source"
      />
      <div className="flex flex-col h-full gap-y-3">
        <div className="flex flex-col gap-y-2">
          {if fileUploadedDict->Dict.get(uploadEvidenceType)->Option.isSome {
            <div className="flex gap-4 items-center">
              <p className={`${p1RegularText} text-grey-700`}>
                {"File loaded successfully"->React.string}
              </p>
            </div>
          } else {
            <div className="flex gap-4 items-center">
              <p className={`${p1RegularText} text-grey-700`}>
                {"Loading file..."->React.string}
              </p>
            </div>
          }}
        </div>
        <FormRenderer.FieldRenderer
          field={FormRenderer.makeFieldInfo(
            ~label="Endpoint URL",
            ~name="endPointURL",
            ~placeholder="https://",
            ~isRequired=true,
            ~customInput=InputFields.textInput(~customWidth="w-full"),
          )}
        />
        <FormRenderer.FieldRenderer
          field={FormRenderer.makeFieldInfo(
            ~label="Auth Key",
            ~name="authKey",
            ~placeholder="***********",
            ~isRequired=true,
            ~customInput=InputFields.textInput(~customWidth="w-full"),
          )}
        />
      </div>
      <div className="flex justify-end items-center">
        <ReconConfigurationHelper.Footer
          currentStep={currentStep} onSubmit={_ => onSubmit()->ignore}
        />
      </div>
    </PageLoaderWrapper>
  }
}
