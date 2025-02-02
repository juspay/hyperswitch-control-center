open HSwitchUtils
let p1RegularText = getTextClass((P1, Regular))

module SelectSource = {
  @react.component
  let make = (~currentStep, ~setCurrentStep, ~selectedOrderSource, ~setSelectedOrderSource) => {
    open ConnectOrderDataUtils
    open ReconConfigurationUtils
    open TempAPIUtils
    let stepConfig = useStepConfig()
    let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)

    let onSubmit = async () => {
      try {
        setScreenState(_ => PageLoaderWrapper.Loading)
        let _ = await stepConfig(~step=currentStep->getSubsectionFromStep, ~selectedOrderSource)
        setCurrentStep(prev => getNextStep(prev))
      } catch {
      | Exn.Error(e) =>
        let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
        setScreenState(_ => PageLoaderWrapper.Error(err))
      }
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
              let isSelected = selectedOrderSource === step
              <ReconConfigurationHelper.StepCard
                key={stepName}
                stepName={stepName}
                description={description}
                isSelected={isSelected}
                iconName={step->ConnectOrderDataUtils.getIconName}
                onClick={_ => setSelectedOrderSource(_ => step)}
              />
            })
            ->React.array}
          </div>
        </div>
        <div className="flex justify-end items-center">
          <Button
            text="Next"
            customButtonStyle="rounded w-full"
            buttonType={Primary}
            onClick={_ => onSubmit()->ignore}
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
  let make = (~currentStep, ~setCurrentStep, ~selectedOrderSource) => {
    open ReconConfigurationUtils
    open ConnectOrderDataTypes
    open LogicUtils
    open TempAPIUtils
    open DateTimeUtils

    let (fileUploadedDict, setFileUploadedDict) = React.useState(_ => Dict.make())
    let uploadEvidenceType = "Basefile"->String.toLowerCase->titleToSnake
    let showToast = ToastState.useShowToast()
    let stepConfig = useStepConfig()
    let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)
    let {userInfo: {merchantId}} = React.useContext(UserInfoProvider.defaultContext)

    let toast = (message, toastType) => {
      showToast(~message, ~toastType)
    }

    let date = Js.Date.fromFloat(Date.getTime(Date.make()))->Date.toISOString

    let getDate = () => {
      date->String.slice(~start=0, ~end=4) ++
      date->String.slice(~start=5, ~end=7) ++
      date->String.slice(~start=8, ~end=10)
    }

    let callApiConnectionAPi = async (body: Js.Json.t) => {
      try {
        switch Js.Json.decodeObject(body) {
        | Some(obj) => {
            let extractString = jsonValue =>
              switch jsonValue->Js.Json.decodeString {
              | Some(str) => str
              | None => ""
              }
            let startTime = Js.Dict.get(obj, "startTime")->Option.map(extractString)->Option.getExn
            let endTime = Js.Dict.get(obj, "endTime")->Option.map(extractString)->Option.getExn
            let _ = await stepConfig(
              ~step=currentStep->getSubsectionFromStep,
              ~selectedOrderSource,
              ~startTime,
              ~endTime,
            )
            setCurrentStep(prev => getNextStep(prev))
          }
        | None => toast("Please select a date range", ToastError)
        }
      } catch {
      | Exn.Error(e) =>
        let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
        toast(err, ToastError)
      }
      Nullable.null
    }

    let onSubmit = (values, _) => {
      let metadata = values->Identity.genericTypeToJson
      callApiConnectionAPi(metadata)
    }

    let loadBaseFile = async () => {
      let response = await Fetch.fetch("/basefile.csv")
      let blob = await Fetch.Response.text(response)
      let fileContentBlob = blob->Webapi.Blob.stringToBlobPart
      let target = Webapi.File.makeWithOptions(
        [fileContentBlob],
        `${merchantId}_${(date->toUnixTimestamp /. 1000.0)->Float.toString}_${getDate()}.csv`,
        Webapi__File.makeFilePropertyBag(~_type="text/csv", ()),
      )
      let fileDict =
        [
          ("uploadedFile", target->Identity.genericTypeToJson),
          (
            "fileName",
            `${merchantId}_${(date->toUnixTimestamp /. 1000.0)
                ->Float.toString}_${getDate()}.csv`->JSON.Encode.string,
          ),
        ]->getJsonFromArrayOfJson

      setFileUploadedDict(prev => {
        let arr = prev->Dict.toArray
        let newDict = [(uploadEvidenceType, fileDict)]->Array.concat(arr)->Dict.fromArray
        newDict
      })
    }

    React.useEffect0(() => {
      if selectedOrderSource === Dummy {
        loadBaseFile()->ignore
      }
      None
    })

    let onSubmitDummy = async () => {
      if fileUploadedDict->Dict.get(uploadEvidenceType)->Option.isNone {
        toast("Please upload a file", ToastError)
      } else {
        try {
          setScreenState(_ => PageLoaderWrapper.Loading)
          let _ = await stepConfig(
            ~step=currentStep->getSubsectionFromStep,
            ~fileUploadedDict,
            ~selectedOrderSource,
          )
          setCurrentStep(prev => getNextStep(prev))
        } catch {
        | Exn.Error(e) =>
          let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
          setScreenState(_ => PageLoaderWrapper.Error(err))
        }
      }
    }

    let handleBrowseChange = (event, uploadEvidenceType) => {
      let target = ReactEvent.Form.target(event)
      let fileDict =
        [
          ("uploadedFile", target["files"]["0"]->Identity.genericTypeToJson),
          (
            "fileName",
            `${merchantId}_${(date->toUnixTimestamp /. 1000.0)
                ->Float.toString}_${getDate()}.csv`->JSON.Encode.string,
          ),
        ]->getJsonFromArrayOfJson

      setFileUploadedDict(prev => {
        let arr = prev->Dict.toArray
        let newDict = [(uploadEvidenceType, fileDict)]->Array.concat(arr)->Dict.fromArray
        newDict
      })
    }

    <PageLoaderWrapper screenState={screenState}>
      <ReconConfigurationHelper.SubHeading
        title="Setup API" subTitle="Connect your API to fetch order data from your source"
      />
      <div className="flex flex-col h-full gap-y-3">
        <div className="flex flex-col gap-y-4">
          {switch selectedOrderSource {
          | Hyperswitch =>
            <Form onSubmit>
              <FormRenderer.FieldRenderer
                field={FormRenderer.makeMultiInputFieldInfo(
                  ~label="",
                  ~comboCustomInput=InputFields.dateRangeField(
                    ~startKey="startTime",
                    ~endKey="endTime",
                    ~format="YYYY-MM-DD",
                    ~showTime=false,
                    ~disablePastDates={false},
                    ~disableFutureDates={true},
                    ~predefinedDays=[Today, Yesterday, ThisMonth, LastMonth, LastSixMonths],
                    ~numMonths=2,
                    ~dateRangeLimit=400,
                    ~disableApply=false,
                    ~isTooltipVisible=false,
                  ),
                  ~inputFields=[],
                )}
              />
              <FormRenderer.SubmitButton
                text="Next" customSumbitButtonStyle="w-full mt-10" buttonType={Primary}
              />
            </Form>
          | OrderManagementSystem =>
            <div className="flex flex-col gap-y-4">
              {if fileUploadedDict->Dict.get(uploadEvidenceType)->Option.isNone {
                <label>
                  <p className="cursor-pointer text-gray-500">
                    <div className="flex gap-2 border border-gray-500 rounded-lg p-2 items-center">
                      <Icon name="plus" size=14 />
                      <p> {"Upload Base file"->React.string} </p>
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
              <Button
                text="Next"
                customButtonStyle="w-full"
                buttonType={Primary}
                onClick={_ => onSubmitDummy()->ignore}
              />
            </div>
          | Dummy =>
            <div className="flex flex-col gap-y-4">
              {if fileUploadedDict->Dict.get(uploadEvidenceType)->Option.isNone {
                <label>
                  <p className="cursor-pointer text-gray-500">
                    <div className="flex gap-2 border border-gray-500 rounded-lg p-2 items-center">
                      <Icon name="plus" size=14 />
                      <p> {"Upload Base file"->React.string} </p>
                    </div>
                    <input
                      type_="file"
                      accept=".csv"
                      disabled=true
                      onChange={_ => ()}
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
                    name="cross-skeleton" className="cursor-not-allowed" size=12 onClick={_ => ()}
                  />
                </div>
              }}
              <Button
                text="Next"
                customButtonStyle="rounded w-full"
                buttonType={Primary}
                onClick={_ => onSubmitDummy()->ignore}
              />
            </div>
          }}
        </div>
      </div>
    </PageLoaderWrapper>
  }
}
