open HSwitchUtils
let p1MediumTextStyle = HSwitchUtils.getTextClass((P1, Medium))
let p1RegularText = getTextClass((P1, Regular))

module APIKeysAndLiveEndpoints = {
  @react.component
  let make = (
    ~currentStep,
    ~setCurrentStep,
    ~selectedProcessor,
    ~setSelectedProcessor,
    ~selectedOrderSource,
  ) => {
    open ReconConfigurationUtils
    open ConnectorUtils
    open ConnectorTypes
    open TempAPIUtils
    open ConnectOrderDataTypes

    let connectorList = []

    switch selectedOrderSource {
    | Hyperswitch => connectorList->Array.push(Processors(STRIPE))
    | OrderManagementSystem => connectorList->Array.push(Processors(PAYU))
    | Dummy => connectorList->Array.push(Processors(PAYU))
    }

    let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
    let stepConfig = useStepConfig()
    let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)
    let showToast = ToastState.useShowToast()

    let toast = (message, toastType) => {
      showToast(~message, ~toastType)
    }

    let onSubmit = async () => {
      if selectedProcessor === "" {
        toast("Please select a processor", ToastError)
      } else {
        try {
          setScreenState(_ => PageLoaderWrapper.Loading)
          let _ = await stepConfig(
            ~step=currentStep->getSubsectionFromStep,
            ~paymentEntity=selectedProcessor->String.toUpperCase,
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

    <PageLoaderWrapper screenState={screenState}>
      <ReconConfigurationHelper.SubHeading
        title="Where do you process your payments?"
        subTitle="Choose one processor for now. You can connect more processors later"
      />
      <div className="flex flex-col h-full gap-y-10">
        <div className="flex flex-col gap-y-4">
          <p className="text-base text-gray-700 font-semibold">
            {"Select a processor"->React.string}
          </p>
          <div className={`grid gap-x-5 gap-y-6 md:grid-cols-2 grid-cols-1`}>
            {connectorList
            ->Array.mapWithIndex((processor: ConnectorTypes.connectorTypes, i) => {
              let processorName = processor->ConnectorUtils.getConnectorNameString
              let processorInfo = processor->getConnectorInfo
              let size = "w-14 h-14 rounded-sm"

              {
                switch selectedOrderSource {
                | Dummy =>
                  <ACLDiv
                    authorization={userHasAccess(~groupAccess=ConnectorsManage)}
                    onClick={_ => setSelectedProcessor(_ => processorName)}
                    key={i->string_of_int}
                    className={`${selectedProcessor === processorName
                        ? "border-blue-500"
                        : ""} border p-6 gap-4 bg-white rounded flex flex-col justify-between cursor-pointer`}
                    dataAttrStr=processorName>
                    <div className="flex flex-col gap-3 items-start">
                      <Icon name="lightbulb" className=size />
                      <p className={`${p1MediumTextStyle} break-all`}>
                        {"Dummy Processor"->React.string}
                      </p>
                    </div>
                    <p className="overflow-hidden text-gray-400 flex-1 line-clamp-3">
                      {"Dummy Processor is used for testing purposes"->React.string}
                    </p>
                  </ACLDiv>
                | _ =>
                  <ACLDiv
                    authorization={userHasAccess(~groupAccess=ConnectorsManage)}
                    onClick={_ => setSelectedProcessor(_ => processorName)}
                    key={i->string_of_int}
                    className={`${selectedProcessor === processorName
                        ? "border-blue-500"
                        : ""} border p-6 gap-4 bg-white rounded flex flex-col justify-between cursor-pointer`}
                    dataAttrStr=processorName>
                    <div className="flex flex-col gap-3 items-start">
                      <GatewayIcon gateway={processorName->String.toUpperCase} className=size />
                      <p className={`${p1MediumTextStyle} break-all`}>
                        {processorName
                        ->getDisplayNameForConnector(~connectorType=Processor)
                        ->React.string}
                      </p>
                    </div>
                    <p className="overflow-hidden text-gray-400 flex-1 line-clamp-3">
                      {processorInfo.description->React.string}
                    </p>
                  </ACLDiv>
                }
              }
            })
            ->React.array}
          </div>
        </div>
        <div className="flex justify-end items-center border-t">
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

module WebHooks = {
  @react.component
  let make = (~currentStep, ~setCurrentStep, ~selectedProcessor, ~selectedOrderSource) => {
    open ReconConfigurationUtils
    open LogicUtils
    open TempAPIUtils
    open ConnectOrderDataTypes
    open DateTimeUtils

    let (fileUploadedDict, setFileUploadedDict) = React.useState(_ => Dict.make())
    let uploadEvidenceType = "PSPfile"->String.toLowerCase->titleToSnake
    let showToast = ToastState.useShowToast()
    let stepConfig = useStepConfig()
    let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)

    let date = Js.Date.fromFloat(Date.getTime(Date.make()))->Date.toISOString

    let getDate = () => {
      date->String.slice(~start=0, ~end=4) ++
      date->String.slice(~start=5, ~end=7) ++
      date->String.slice(~start=8, ~end=10)
    }

    let toast = (message, toastType) => {
      showToast(~message, ~toastType)
    }

    let handleBrowseChange = (event, uploadEvidenceType) => {
      let target = ReactEvent.Form.target(event)
      let fileDict =
        [
          ("uploadedFile", target["files"]["0"]->Identity.genericTypeToJson),
          (
            "fileName",
            `${selectedProcessor->String.toUpperCase}_${(date->toUnixTimestamp /. 1000.0)
                ->Float.toString}_${getDate()}.csv`->JSON.Encode.string,
          ),
        ]->getJsonFromArrayOfJson

      setFileUploadedDict(prev => {
        let arr = prev->Dict.toArray
        let newDict = [(uploadEvidenceType, fileDict)]->Array.concat(arr)->Dict.fromArray
        newDict
      })
    }

    let loadPSPFile = async () => {
      if selectedOrderSource === Dummy {
        let response = await Fetch.fetch("/pspfile.csv")
        let blob = await Fetch.Response.text(response)
        let fileContentBlob = blob->Webapi.Blob.stringToBlobPart
        let target = Webapi.File.makeWithOptions(
          [fileContentBlob],
          `${selectedProcessor->String.toUpperCase}_${(date->toUnixTimestamp /. 1000.0)
              ->Float.toString}_${getDate()}.csv`,
          Webapi__File.makeFilePropertyBag(~_type="text/csv", ()),
        )
        let fileDict =
          [
            ("uploadedFile", target->Identity.genericTypeToJson),
            (
              "fileName",
              `${selectedProcessor->String.toUpperCase}_${(date->toUnixTimestamp /. 1000.0)
                  ->Float.toString}_${getDate()}.csv`->JSON.Encode.string,
            ),
          ]->getJsonFromArrayOfJson

        setFileUploadedDict(prev => {
          let arr = prev->Dict.toArray
          let newDict = [(uploadEvidenceType, fileDict)]->Array.concat(arr)->Dict.fromArray
          newDict
        })
      }
    }

    React.useEffect0(() => {
      loadPSPFile()->ignore
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
            ~selectedOrderSource,
            ~fileUploadedDict,
            ~paymentEntity=selectedProcessor->String.toUpperCase,
          )
          setCurrentStep(prev => getNextStep(prev))
        } catch {
        | Exn.Error(e) =>
          let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
          setScreenState(_ => PageLoaderWrapper.Error(err))
        }
      }
    }

    let (initialValues, _) = React.useState(_ =>
      JSON.Encode.object(Dict.fromArray([("api-key", JSON.Encode.string(""))]))
    )

    // let copyToClipboard = (ev, value: string) => {
    //   ev->ReactEvent.Mouse.stopPropagation
    //   Clipboard.writeText(value)
    //   showToast(~message="Copied to Clipboard!", ~toastType=ToastSuccess)
    // }

    // let getAPIKey = () => {
    //   switch Js.Json.decodeObject(initialValues) {
    //   | Some(obj) =>
    //     switch Js.Dict.get(obj, "api-key") {
    //     | Some(value) =>
    //       switch Js.Json.decodeString(value) {
    //       | Some(apiKey) => apiKey
    //       | None => ""
    //       }
    //     | None => ""
    //     }
    //   | None => ""
    //   }
    // }

    let callApiConnectionAPi = async (body: Js.Json.t) => {
      try {
        setScreenState(_ => PageLoaderWrapper.Loading)
        switch Js.Json.decodeObject(body) {
        | Some(obj) => {
            let extractString = jsonValue =>
              switch jsonValue->Js.Json.decodeString {
              | Some(str) => str
              | None => ""
              }
            let intervalStart =
              Js.Dict.get(obj, "startKey")
              ->Option.map(extractString)
              ->Option.getExn
              ->toUnixTimestamp /. 1000.0
            let intervalEnd =
              Js.Dict.get(obj, "endKey")
              ->Option.map(extractString)
              ->Option.getExn
              ->toUnixTimestamp /. 1000.0
            let apiKey =
              Js.Dict.get(obj, "api-key")
              ->Option.map(extractString)
              ->Option.getExn
            let _ = await stepConfig(
              ~step=currentStep->getSubsectionFromStep,
              ~selectedOrderSource,
              ~intervalStart,
              ~intervalEnd,
              ~apiKey,
            )
            setCurrentStep(prev => getNextStep(prev))
          }
        | None => setScreenState(_ => PageLoaderWrapper.Error("Failed to Fetch!"))
        }
      } catch {
      | Exn.Error(e) =>
        let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
        setScreenState(_ => PageLoaderWrapper.Error(err))
      }
      Nullable.null
    }

    let onSubmit = (values, _) => {
      let metadata = values->Identity.genericTypeToJson
      callApiConnectionAPi(metadata)
    }

    <PageLoaderWrapper screenState={screenState}>
      <ReconConfigurationHelper.SubHeading
        title="Set up PSP API connection"
        subTitle="Configure your PSP API connection to fetch transactions"
      />
      <div className="flex flex-col h-full gap-y-3">
        <div className="flex flex-col gap-y-4">
          <p className="text-base text-gray-700 font-semibold"> {"PSP Data"->React.string} </p>
          {switch selectedOrderSource {
          | Hyperswitch =>
            <Form initialValues onSubmit>
              <div className="flex flex-row items-center w-full gap-x-4">
                <FormRenderer.FieldRenderer
                  labelClass="font-semibold !text-black"
                  field={FormRenderer.makeFieldInfo(~label="", ~name="api-key", ~customInput=(
                    ~input,
                    ~placeholder as _,
                  ) =>
                    InputFields.textInput(~customStyle="w-[500px] rounded-xl", ~isDisabled=true)(
                      ~input,
                      ~placeholder="",
                    )
                  )}
                />
              </div>
              <FormRenderer.FieldRenderer
                field={FormRenderer.makeMultiInputFieldInfo(
                  ~label="Date Range",
                  ~comboCustomInput=InputFields.dateRangeField(
                    ~startKey="startKey",
                    ~endKey="endKey",
                    ~format="YYYY-MM-DDTHH:mm:ss",
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
                  ~isRequired=true,
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
                      <p> {"Upload PSP file"->React.string} </p>
                    </div>
                    <input
                      type_="file"
                      accept=".csv"
                      onChange={ev => handleBrowseChange(ev, uploadEvidenceType)}
                      required=true
                      hidden=true
                    />
                  </p>
                </label>
              } else {
                let fileName =
                  fileUploadedDict->getDictfromDict(uploadEvidenceType)->getString("fileName", "")
                let truncatedFileName = truncateFileNameWithEllipses(~fileName, ~maxTextLength=15)
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
                      <p> {"Upload PSP file"->React.string} </p>
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
                let truncatedFileName = truncateFileNameWithEllipses(~fileName, ~maxTextLength=15)

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
