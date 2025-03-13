module Review = {
  @react.component
  let make = (~reviewFields, ~isUpload=false) => {
    open IntelligentRoutingReviewFieldsEntity
    open APIUtils
    let getURL = useGetURL()
    let _updateDetails = useUpdateMethod()
    let showToast = ToastState.useShowToast()
    let mixpanelEvent = MixpanelHook.useSendEvent()

    let reviewFields = reviewFields->getReviewFields
    let queryParamerters = isUpload ? "upload_data=true" : "upload_data=false"

    let uploadData = async () => {
      try {
        let _url = getURL(
          ~entityName=V1(SIMULATE_INTELLIGENT_ROUTING),
          ~methodType=Post,
          ~queryParamerters=Some(queryParamerters),
        )
        // let _ = await updateDetails(url, JSON.Encode.null, Post)
      } catch {
      | _ => showToast(~message="Fetching the review data failed", ~toastType=ToastError)
      }
    }

    let handleNext = _ => {
      uploadData()->ignore
      RescriptReactRouter.replace(
        GlobalVars.appendDashboardPath(~url="v2/dynamic-routing/dashboard"),
      )
      mixpanelEvent(~eventName="intelligent_routing_upload_data")
    }

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
        customButtonStyle="w-full"
        buttonType={Primary}
        onClick={_ => handleNext()}
      />
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
          "total": 81735,
          "total_amount": 27289187.399992384,
          "file_name": "baseline_data.csv",
          "processors": [
            "PSP1",
            "PSP2",
            "PSP3",
            "PSP4",
            "PSP5",
            "PSP6",
            "PSP7",
            "PSP8",
            "PSP9",
            "PSP10",
            "PSP11",
            "PSP12",
            "PSP13",
          ],
          "payment_methods": ["APPLEPAY", "CARD", "WALLET"],
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

    let steps = ["Preparing sample data", "Apply Rule-based Routing", "Apply Debit Routing"]

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
                  isDisabled={item === Upload}
                />
              })
              ->React.array}
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
          text
          customButtonStyle={`w-full hover:opacity-80 ${text != "Next" ? "cursor-wait" : ""}`}
          buttonType={Primary}
          onClick={_ => handleNext()}
          rightIcon={text != "Next" ? CustomIcon(<Icon name="spinner" size=16 />) : NoIcon}
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

  <div className="h-full w-full">
    {IntelligentRoutingHelper.simulatorBanner}
    <div className="flex flex-row mt-10 py-10">
      <VerticalStepIndicator
        titleElement=intelligentRoutingTitleElement sections currentStep backClick
      />
      <div className="p-12">
        {switch currentStep {
        | {sectionId: "analyze"} => <Analyze onNextClick setReviewFields setIsUpload />
        | {sectionId: "review"} => <Review reviewFields isUpload />
        | _ => React.null
        }}
      </div>
    </div>
  </div>
}
