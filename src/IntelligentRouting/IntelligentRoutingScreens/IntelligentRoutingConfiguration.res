module Review = {
  @react.component
  let make = (~reviewFields, ~isUpload=false, ~fileUInt8Array) => {
    open IntelligentRoutingReviewFieldsEntity
    open APIUtils
    open LogicUtils
    open FormDataUtils

    let getURL = useGetURL()
    let updateDetails = useUpdateMethod()
    let showToast = ToastState.useShowToast()
    let mixpanelEvent = MixpanelHook.useSendEvent()
    let (showLoading, setShowLoading) = React.useState(() => false)
    let queryParamerters = `upload_data=${isUpload ? "true" : "false"}`
    let loaderLottieFile = LottieFiles.useLottieJson("spinner.json")

    let uploadData = async () => {
      try {
        setShowLoading(_ => true)
        let url = getURL(
          ~entityName=V1(SIMULATE_INTELLIGENT_ROUTING),
          ~methodType=Post,
          ~queryParamerters=Some(queryParamerters),
        )
        let formData = formData()

        let getblob = blob([fileUInt8Array], {"type": "text/csv"})
        appendBlob(formData, "csv_data", getblob, "data.csv")

        let jsonData = "{\"algo_type\": \"window_based\"}"
        append(formData, "json", jsonData)

        let response = await updateDetails(
          ~bodyFormData=formData,
          ~headers=Dict.make(),
          url,
          Dict.make()->JSON.Encode.object,
          Post,
          ~contentType=AuthHooks.Unknown,
        )

        let msg = response->getDictFromJsonObject->getString("message", "")->String.toLowerCase
        if msg === "simulation successful" {
          RescriptReactRouter.replace(
            GlobalVars.appendDashboardPath(~url="v2/dynamic-routing/dashboard"),
          )
        }
        setShowLoading(_ => false)
      } catch {
      | _ =>
        setShowLoading(_ => false)
        showToast(~message="Upload data failed", ~toastType=ToastError)
      }
    }

    let handleNext = _ => {
      uploadData()->ignore
      mixpanelEvent(~eventName="intelligent_routing_upload_data")
    }

    let modalBody =
      <div className="">
        <div className="text-xl p-3 m-3 font-semibold text-nd_gray-700">
          {"Running Intelligence Routing "->React.string}
        </div>
        <hr />
        <div className="flex flex-col gap-12 items-center pt-10 pb-6 px-6">
          <div className="w-8">
            <span className="px-3">
              <span className={`flex items-center`}>
                <div className="scale-400 pt-px">
                  <Lottie animationData={loaderLottieFile} autoplay=true loop=true />
                </div>
              </span>
            </span>
          </div>
          <p className="text-center text-nd_gray-600">
            {"Please wait while we are analyzing data. Our intelligent models are working to determine the potential authentication rate uplift."->React.string}
          </p>
        </div>
      </div>

    <div>
      <div className="w-500-px">
        {IntelligentRoutingHelper.stepperHeading(
          ~title="Review Data Summary",
          ~subTitle="Explore insights in the dashboard",
        )}
        <div className="mt-6">
          <VaultCustomerSummary.Details
            data=reviewFields
            getHeading
            getCell
            detailsFields=allColumns
            widthClass=""
            justifyClassName="grid grid-cols-none"
          />
        </div>
        <Button
          text="Explore Insights"
          customButtonStyle={`w-full mt-6 hover:opacity-80 ${showLoading ? "cursor-wait" : ""}`}
          buttonType=Primary
          onClick={_ => handleNext()}
          rightIcon={showLoading
            ? CustomIcon(
                <span className="px-3">
                  <span className={`flex items-center mx-2 animate-spin`}>
                    <Loadericon size=14 iconColor="text-white" />
                  </span>
                </span>,
              )
            : NoIcon}
        />
      </div>
      <Modal
        showModal=showLoading
        closeOnOutsideClick=false
        setShowModal=setShowLoading
        childClass="p-0"
        borderBottom=true
        modalClass="w-full max-w-xl mx-auto my-auto dark:!bg-jp-gray-lightgray_background">
        {modalBody}
      </Modal>
    </div>
  }
}

module Analyze = {
  @react.component
  let make = (
    ~onNextClick,
    ~setReviewFields,
    ~setIsUpload,
    ~fileUInt8Array,
    ~setFileUInt8Array,
  ) => {
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
    let (buttonText, setButtonText) = React.useState(() => "Next")
    let (file, setFile) = React.useState(() => None)
    let (upload, setUpload) = React.useState(() => false)
    let inputRef = React.useRef(Nullable.null)

    React.useEffect(() => {
      setIsUpload(_ => selectedField === Upload)
      None
    }, [selectedField])

    let getReviewData = async () => {
      try {
        let url = getURL(~entityName=V1(GET_REVIEW_FIELDS), ~methodType=Get)
        let res = await fetchDetails(url)
        let reviewFields =
          res->getDictFromJsonObject->IntelligentRoutingReviewFieldsEntity.itemToObjMapper
        setReviewFields(_ => reviewFields)
        onNextClick()
      } catch {
      | _ =>
        setButtonText(_ => "Next")
        showToast(
          ~message="Something went wrong while fetching the review fields data",
          ~toastType=ToastError,
        )
      }
    }

    let steps = ["Preparing sample data"]

    let handleNextClick = async () => {
      for i in 0 to Array.length(steps) - 1 {
        setButtonText(_ => steps[i]->Option.getOr(""))
        await HyperSwitchUtils.delay(800)
      }
      if !upload {
        getReviewData()->ignore
      } else {
        onNextClick()
      }
      mixpanelEvent(~eventName="intelligent_routing_analyze_data")
    }

    let handleNext = _ => {
      handleNextClick()->ignore
    }

    let handleFileUpload = ev => {
      let files = ReactEvent.Form.target(ev)["files"]
      let file = files["0"]

      let arr = [0]
      let index = arr->Array.get(0)->Option.getOr(0)
      switch files[index] {
      | Some(value) => {
          let fileReader = FileReader.reader
          fileReader.readAsArrayBuffer(value)

          fileReader.onload = e => {
            let target = ReactEvent.Form.target(e)
            let file = target["result"]

            let config = Window.getDefaultConfig()

            let uint8array = FileReader.makeUint8Array(file)

            let metadata = {file_name: value["name"]}->Identity.genericTypeToJson

            try {
              let dict = Window.validateExtract(uint8array, config, metadata)
              let data = getFileData(dict)

              setFileUInt8Array(_ => data.data)
              setReviewFields(_ => data.stats)
              setUpload(_ => true)
            } catch {
            | _ => showToast(~message="Invalid file. Please try again.", ~toastType=ToastError)
            }
          }
        }
      | None => ()
      }

      let fileSize = file["size"]
      if fileSize > 10 * 1024 * 1024 {
        showToast(~message="File size should be less than 10MB", ~toastType=ToastError)
        setFile(_ => None)
      }
      setFile(_ => Some(file))
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

    let fileName = switch file {
    | Some(file) => file["name"]
    | None => "No file selected"
    }
    let fileSize = switch file {
    | Some(file) => file["size"]
    | None => 0
    }
    let fileSizeDisplay = if fileSize / 1024 / 1024 > 1 {
      `${(fileSize / 1024 / 1024)->Int.toString} MB`
    } else if fileSize / 1024 > 1 {
      ` ${(fileSize / 1024)->Int.toString}KB`
    } else {
      `${fileSize->Int.toString} B`
    }

    let downloadTemplateFile = () => {
      open Promise
      let downloadURL = `${GlobalVars.getHostUrl}/dynamo-simulation-template/simulator_template.csv`
      fetchApi(
        downloadURL,
        ~method_=Get,
        ~xFeatureRoute=featureFlagDetails.xFeatureRoute,
        ~forceCookies=false,
        ~contentType=AuthHooks.Headers("text/csv"),
      )
      ->then(resp => {
        Fetch.Response.blob(resp)
      })
      ->then(content => {
        DownloadUtils.download(~fileName=`simulator_template.csv`, ~content, ~fileType="text/csv")
        showToast(~toastType=ToastSuccess, ~message="File download complete")
        resolve()
      })
      ->catch(_ => {
        showToast(
          ~toastType=ToastError,
          ~message="Oops, something went wrong with the download. Please try again.",
        )
        resolve()
      })
      ->ignore
    }

    let fileUploadComponent = {
      upload
        ? <div
            className="border ring-grey-outline rounded-lg bg-nd_gray-25 p-4 flex flex-col items-center gap-6">
            <div
              className="border ring-grey-outline rounded-lg bg-white flex justify-between w-full p-4">
              <div className="flex gap-2">
                <Icon name="nd-file" size=35 />
                <div className="flex flex-col">
                  <div className="text-nd_gray-600"> {fileName->React.string} </div>
                  <div className="text-nd_gray-400"> {fileSizeDisplay->React.string} </div>
                </div>
              </div>
              <Icon name="trash-alt" onClick={_ => resetUploadFile()} className="cursor-pointer" />
            </div>
          </div>
        : <div
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
                <div className="text-nd_primary_blue-500 font-medium" onClick={_ => downloadTemplateFile()}>
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
                onChange={handleFileUpload}
              />
              <Button
                text={upload ? "File Uploaded" : "Upload File"}
                onClick={_ => triggerInput()}
                leftIcon={CustomIcon(<Icon name="nd-arrow-up" />)}
              />
            </div>
          </div>
    }

    let dataSourceHeading = title =>
      <div className="text-nd_gray-400 text-xs font-semibold tracking-wider">
        {title->String.toUpperCase->React.string}
      </div>

    let noFileUploaded =
      selectedField === Upload && fileUInt8Array->Js.TypedArray2.Uint8Array.length === 0

    let buttonState = noFileUploaded ? Button.Disabled : Button.Normal

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

                <StepCard
                  stepName={fileTypeHeading}
                  description={fileTypeDescription}
                  isSelected
                  onClick={_ => setSelectedField(_ => item)}
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
          text=buttonText
          customButtonStyle={`w-full mt-6 hover:opacity-80 ${buttonText != "Next"
              ? "cursor-wait"
              : ""}`}
          buttonType=Primary
          onClick={_ => handleNext()}
          rightIcon={buttonText != "Next"
            ? CustomIcon(
                <span className="px-3">
                  <span className={`flex items-center mx-2 animate-spin`}>
                    <Loadericon size=14 iconColor="text-white" />
                  </span>
                </span>,
              )
            : NoIcon}
          buttonState
          showTooltip=noFileUploaded
          tooltipText="Please upload a file"
          toolTipPosition=Right
        />
      </div>
    </div>
  }
}

@react.component
let make = () => {
  open IntelligentRoutingUtils
  open VerticalStepIndicatorTypes
  open VerticalStepIndicatorUtils
  let {setShowSideBar} = React.useContext(GlobalProvider.defaultContext)
  let (reviewFields, setReviewFields) = React.useState(_ =>
    Dict.make()->IntelligentRoutingReviewFieldsEntity.itemToObjMapper
  )
  let (isUpload, setIsUpload) = React.useState(() => false)
  let (fileUInt8Array, setFileUInt8Array) = React.useState(_ => Js.TypedArray2.Uint8Array.make([]))

  let (currentStep, setNextStep) = React.useState(() => {
    sectionId: "analyze",
    subSectionId: None,
  })

  let getNextStep = (currentStep: step): option<step> => {
    findNextStep(sections, currentStep)
  }

  let onNextClick = () => {
    switch getNextStep(currentStep) {
    | Some(nextStep) => setNextStep(_ => nextStep)
    | None => ()
    }
  }

  React.useEffect(() => {
    Window.dynamicRoutingWasmInit()->ignore
    setShowSideBar(_ => false)
    None
  }, [])

  let backClick = () => {
    RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url="/v2/dynamic-routing"))
    setShowSideBar(_ => true)
  }

  let intelligentRoutingTitleElement =
    <>
      <h1 className="text-medium font-semibold text-gray-600">
        {`Simulate Intelligent Routing`->React.string}
      </h1>
    </>

  <div className="h-774-px w-full">
    {IntelligentRoutingHelper.simulatorBanner}
    <div className="flex flex-row mt-5 py-10 h-890-px">
      <VerticalStepIndicator
        titleElement=intelligentRoutingTitleElement sections currentStep backClick
      />
      <div className="mx-12 mt-16 overflow-y-auto">
        {switch currentStep {
        | {sectionId: "analyze"} =>
          <Analyze onNextClick setReviewFields setIsUpload fileUInt8Array setFileUInt8Array />
        | {sectionId: "review"} => <Review reviewFields isUpload fileUInt8Array />
        | _ => React.null
        }}
      </div>
    </div>
  </div>
}
