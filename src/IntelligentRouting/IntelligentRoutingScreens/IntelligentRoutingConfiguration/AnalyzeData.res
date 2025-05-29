@react.component
let make = (~onNextClick, ~setReviewFields, ~setIsUpload, ~fileUInt8Array, ~setFileUInt8Array) => {
  open IntelligentRoutingUtils
  open IntelligentRoutingTypes
  open APIUtils
  open LogicUtils
  let getURL = useGetURL()
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let fetchDetails = APIUtils.useGetMethod()
  let fetchApi = AuthHooks.useApiFetcher()
  let showToast = ToastState.useShowToast()
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let (selectedField, setSelectedField) = React.useState(() => IntelligentRoutingTypes.Sample)
  let (file, setFile) = React.useState(() => None)
  let (upload, setUpload) = React.useState(() => false)
  let inputRef = React.useRef(Nullable.null)
  let (buttonState, setButtonState) = React.useState(() => Button.Normal)

  let getReviewData = async () => {
    try {
      let url = getURL(~entityName=V1(GET_REVIEW_FIELDS), ~methodType=Get)
      let res = await fetchDetails(url)
      let reviewFields =
        res->getDictFromJsonObject->IntelligentRoutingReviewFieldsEntity.itemToObjMapper
      setReviewFields(_ => reviewFields)
    } catch {
    | _ =>
      showToast(
        ~message="Something went wrong while fetching the review fields data",
        ~toastType=ToastError,
      )
    }
  }

  let handleNextClick = async () => {
    setButtonState(_ => Button.Loading)
    await HyperSwitchUtils.delay(800)
    if !upload {
      await getReviewData()
    }
    onNextClick()
    mixpanelEvent(~eventName="intelligent_routing_analyze_data")
  }

  let handleNext = _ => {
    handleNextClick()->ignore
  }

  let validaData = (fileData, metadata) => {
    try {
      let uint8array = FileReader.makeUint8Array(fileData)
      let config = Window.getDefaultConfig()
      Ok(Window.validateExtract(uint8array, config, metadata))
    } catch {
    | _ => Error("Error validating data")
    }
  }
  let readFileAsArrayBuffer = (file, metadata) =>
    Promise.make((resolve, _) => {
      let reader = FileReader.reader
      reader.readAsArrayBuffer(file)
      reader.onload = e => {
        let target = ReactEvent.Form.target(e)
        switch target["result"]->Nullable.toOption {
        | Some(fileData) =>
          switch validaData(fileData, metadata) {
          | Ok(dict) => {
              let data = getFileData(dict)
              setFileUInt8Array(_ => data.data)
              setReviewFields(_ => data.stats)
              setUpload(_ => true)
              resolve(Ok(dict))
            }
          | Error(err) => resolve(Error("Error validating data: " ++ err))
          }
        | None => resolve(Error("Error on loading file"))
        }
      }
    })

  let handleFileUpload = async ev => {
    try {
      let files = ReactEvent.Form.target(ev)["files"]
      switch files[0] {
      | Some(value) =>
        let fileSize = value["size"]
        if fileSize > 10 * 1024 * 1024 {
          showToast(~message="File size should be less than 10MB", ~toastType=ToastError)
          setFile(_ => None)
        } else {
          let metadata = {file_name: value["name"]}->Identity.genericTypeToJson
          switch await readFileAsArrayBuffer(value, metadata) {
          | Ok(_) => setFile(_ => Some(value))
          | Error(_) => Js.Exn.raiseError("Error reading file")
          }
        }
      | None =>
        showToast(~message="No file selected. Please choose a file.", ~toastType=ToastError)
        setFile(_ => None)
      }
    } catch {
    | _ =>
      showToast(~message="An unexpected error occurred. Please try again.", ~toastType=ToastError)
      setFile(_ => None)
      setFileUInt8Array(_ => Js.TypedArray2.Uint8Array.make([]))
      setUpload(_ => false)
    }
  }

  let triggerInput = _ => {
    switch inputRef.current->Nullable.toOption {
    | Some(inputElement) => inputElement->DOMUtils.click()
    | None => ()
    }
  }

  let resetUploadFile = () => {
    setFileUInt8Array(_ => Js.TypedArray2.Uint8Array.make([]))
    setUpload(_ => false)
  }

  let downloadTemplateFile = async () => {
    try {
      let downloadURL = Window.env.dynamoSimulationTemplateUrl->Option.getOr("")
      let blob = await fetchApi(
        downloadURL,
        ~method_=Get,
        ~xFeatureRoute=featureFlagDetails.xFeatureRoute,
        ~forceCookies=false,
        ~contentType=AuthHooks.Headers("text/csv"),
      )
      let content = await Fetch.Response.blob(blob)
      DownloadUtils.download(~fileName=`simulator_template.csv`, ~content, ~fileType="text/csv")
      showToast(~message="File download complete", ~toastType=ToastSuccess)
    } catch {
    | _ =>
      showToast(
        ~message="Oops, something went wrong with the download. Please try again.",
        ~toastType=ToastError,
      )
    }
  }

  let fileUploadComponent =
    <>
      <RenderIf condition={upload}>
        <div
          className="border ring-grey-outline rounded-lg bg-nd_gray-25 p-4 flex flex-col items-center gap-6">
          <div
            className="border ring-grey-outline rounded-lg bg-white flex justify-between w-full p-4">
            <div className="flex gap-2">
              <Icon name="nd-file" size=35 />
              <div className="flex flex-col">
                <div className="text-nd_gray-600"> {getFileName(file)->React.string} </div>
                <div className="text-nd_gray-400">
                  {getDisplayFileSize(getFileSize(file))->React.string}
                </div>
              </div>
            </div>
            <Icon name="trash-alt" onClick={_ => resetUploadFile()} className="cursor-pointer" />
          </div>
        </div>
      </RenderIf>
      <RenderIf condition={!upload}>
        <div
          className="border ring-grey-outline rounded-lg bg-nd_gray-25 p-4 flex flex-col items-center gap-6">
          <div
            className="border ring-grey-outline rounded-lg bg-white p-4 flex justify-between w-full">
            <div className="text-nd_gray-700 font-medium">
              {"Download sample file"->React.string}
            </div>
            <div className="flex gap-2 cursor-pointer">
              <span>
                <Icon name="nd-arrow-down" />
              </span>
              <div
                className="text-nd_primary_blue-500 font-medium"
                onClick={_ => downloadTemplateFile()->ignore}>
                {"Download"->React.string}
              </div>
            </div>
          </div>
          <div>
            <input
              type_="file"
              className="hidden"
              accept={".csv"}
              ref={inputRef->ReactDOM.Ref.domRef}
              onChange={e => handleFileUpload(e)->ignore}
            />
            <Button
              text={upload ? "File Uploaded" : "Upload File"}
              onClick={_ => triggerInput()}
              leftIcon={CustomIcon(<Icon name="nd-arrow-up" />)}
            />
          </div>
        </div>
      </RenderIf>
    </>

  let dataSourceHeading = title =>
    <div className="text-nd_gray-400 text-xs font-semibold tracking-wider">
      {title->String.toUpperCase->React.string}
    </div>

  let errorInUploadFlow =
    selectedField === Upload && fileUInt8Array->Js.TypedArray2.Uint8Array.length === 0

  React.useEffect(() => {
    setIsUpload(_ => selectedField === Upload)
    None
  }, [selectedField])

  <div className="w-500-px">
    {IntelligentRoutingHelper.stepperHeading(
      ~title="Choose Your Data Source",
      ~subTitle="Select a data source to begin your simulation",
    )}
    <div className="flex flex-col gap-4 mt-10">
      {dataSource
      ->Array.map(dataSource => {
        switch dataSource {
        | Historical =>
          <>
            {dataSourceHeading(dataSource->dataTypeVariantToString)}
            {fileTypes
            ->Array.map(item => {
              let fileTypeHeading = item->getFileTypeHeading
              let fileTypeDescription = item->getFileTypeDescription
              let fileTypeIcon = item->getFileTypeIconName
              let isSelected = selectedField === item

              let handleCardClick = _ => {
                setSelectedField(_ => item)
              }

              <StepCard
                stepName={fileTypeHeading}
                description={fileTypeDescription}
                isSelected
                onClick={_ => handleCardClick()}
                iconName=fileTypeIcon
                showDemoLabel={item === Sample ? true : false}
              />
            })
            ->React.array}
            <RenderIf condition={selectedField === Upload}> {fileUploadComponent} </RenderIf>
          </>
        | Realtime =>
          <>
            {dataSourceHeading(dataSource->dataTypeVariantToString)}
            {realtime
            ->Array.map(item => {
              let realtimeHeading = item->getRealtimeHeading
              let realtimeDescription = item->getRealtimeDescription
              let realtimeIcon = item->getRealtimeIconName

              <StepCard
                stepName={realtimeHeading}
                description={realtimeDescription}
                isSelected=false
                onClick={_ => ()}
                iconName=realtimeIcon
                isDisabled={item === StreamLive}
              />
            })
            ->React.array}
          </>
        }
      })
      ->React.array}
      <Button
        text="Next"
        customButtonStyle="w-full mt-6 hover:opacity-80"
        buttonType=Primary
        onClick={_ => handleNext()}
        buttonState={errorInUploadFlow ? Button.Disabled : buttonState}
        loadingText={upload ? "Analysing data" : "Preparing sample data"}
        showTooltip=errorInUploadFlow
        tooltipText="Please upload a file"
        toolTipPosition=Right
      />
    </div>
  </div>
}
