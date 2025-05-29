module Review = {
  @react.component
  let make = (~reviewFields, ~isUpload=false) => {
    open IntelligentRoutingReviewFieldsEntity
    open APIUtils
    open LogicUtils
    let getURL = useGetURL()
    let updateDetails = useUpdateMethod()
    let showToast = ToastState.useShowToast()
    let mixpanelEvent = MixpanelHook.useSendEvent()
    let (showLoading, setShowLoading) = React.useState(() => false)
    let reviewFields = reviewFields->getReviewFields
    let queryParamerters = isUpload ? "upload_data=true" : "upload_data=false"
    let loaderLottieFile = LottieFiles.useLottieJson("spinner.json")

    let uploadData = async () => {
      try {
        setShowLoading(_ => true)
        let url = getURL(
          ~entityName=V1(SIMULATE_INTELLIGENT_ROUTING),
          ~methodType=Post,
          ~queryParamerters=Some(queryParamerters),
        )
        let response = await updateDetails(url, JSON.Encode.null, Post)

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
  let make = (~onNextClick, ~setReviewFields, ~setIsUpload) => {
    open IntelligentRoutingUtils
    open IntelligentRoutingTypes
    let showToast = ToastState.useShowToast()
    let mixpanelEvent = MixpanelHook.useSendEvent()
    let (selectedField, setSelectedField) = React.useState(() => IntelligentRoutingTypes.Sample)
    let (text, setText) = React.useState(() => "Next")

    React.useEffect(() => {
      setIsUpload(_ => selectedField === Upload)
      None
    }, [selectedField])

    //TODO: wasm function call to fetch review fields
    let getReviewData = async () => {
      try {
        let response = {
          "total": 74894,
          "total_amount": 26317180.359999552,
          "file_name": "baseline_data.csv",
          "processors": ["PSP1", "PSP2", "PSP3", "PSP4", "PSP5"],
          "payment_method_types": ["APPLEPAY", "CARD", "AMAZONPAY"],
        }->Identity.genericTypeToJson
        setReviewFields(_ => response)
      } catch {
      | _ =>
        showToast(
          ~message="Something went wrong while fetching the review data",
          ~toastType=ToastError,
        )
      }
    }

    let steps = ["Preparing sample data"]

    let loadButton = async () => {
      for i in 0 to Array.length(steps) - 1 {
        setText(_ => steps[i]->Option.getOr(""))
        await HyperSwitchUtils.delay(800)
      }
      getReviewData()->ignore
      onNextClick()
      mixpanelEvent(~eventName="intelligent_routing_analyze_data")
    }

    let handleNext = _ => {
      loadButton()->ignore
    }

    let dataSourceHeading = title =>
      <div className="text-nd_gray-400 text-xs font-semibold tracking-wider">
        {title->String.toUpperCase->React.string}
      </div>

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
              ->Array.mapWithIndex((item, index) => {
                let fileTypeHeading = item->getFileTypeHeading
                let fileTypeDescription = item->getFileTypeDescription
                let fileTypeIcon = item->getFileTypeIconName
                let isSelected = selectedField === item

                <StepCard
                  key={Int.toString(index)}
                  stepName={fileTypeHeading}
                  description={fileTypeDescription}
                  isSelected
                  onClick={_ => setSelectedField(_ => item)}
                  iconName=fileTypeIcon
                  isDisabled={item === Upload}
                  showDemoLabel={item === Sample ? true : false}
                />
              })
              ->React.array}
            </>
          | Realtime =>
            <>
              {dataSourceHeading(dataSource->dataTypeVariantToString)}
              {realtime
              ->Array.mapWithIndex((item, index) => {
                let realtimeHeading = item->getRealtimeHeading
                let realtimeDescription = item->getRealtimeDescription
                let realtimeIcon = item->getRealtimeIconName

                <StepCard
                  key={Int.toString(index)}
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
          text
          customButtonStyle={`w-full mt-6 hover:opacity-80 ${text != "Next" ? "cursor-wait" : ""}`}
          buttonType={Primary}
          onClick={_ => handleNext()}
          rightIcon={text != "Next"
            ? CustomIcon(
                <span className="px-3">
                  <span className={`flex items-center mx-2 animate-spin`}>
                    <Loadericon size=14 iconColor="text-white" />
                  </span>
                </span>,
              )
            : NoIcon}
          buttonState={Normal}
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
  let (reviewFields, setReviewFields) = React.useState(_ => Dict.make()->JSON.Encode.object)
  let (isUpload, setIsUpload) = React.useState(() => false)

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
    <div className="flex flex-row h-774-px">
      <VerticalStepIndicator
        titleElement=intelligentRoutingTitleElement sections currentStep backClick
      />
      <div className="mx-12 mt-16 overflow-y-auto">
        {switch currentStep {
        | {sectionId: "analyze"} => <Analyze onNextClick setReviewFields setIsUpload />
        | {sectionId: "review"} => <Review reviewFields isUpload />
        | _ => React.null
        }}
      </div>
    </div>
  </div>
}
