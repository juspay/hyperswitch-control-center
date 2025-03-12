module Review = {
  @react.component
  let make = (~reviewFields) => {
    open IntelligentRoutingReviewFieldsEntity

    let reviewFields = reviewFields->getReviewFields

    let handleNext = _ => {
      RescriptReactRouter.replace(
        GlobalVars.appendDashboardPath(~url="v2/intelligent-routing/dashboard"),
      )
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
  let make = (~onNextClick, ~setReviewFields) => {
    open IntelligentRoutingUtils
    open IntelligentRoutingTypes
    open APIUtils

    let getURL = useGetURL()
    let _fetchDetails = useGetMethod()
    let showToast = ToastState.useShowToast()
    let (selectedField, setSelectedField) = React.useState(() => IntelligentRoutingTypes.Sample)
    let (text, setText) = React.useState(() => "Next")

    let getReviewData = async () => {
      try {
        let _url = getURL(~entityName=V1(SIMULATE_INTELLIGENT_ROUTING), ~methodType=Get)
        // let _res = await Fetch.fetch(url)
        let response = {
          file_name: "random_data.csv",
          number_of_transaction: 19000,
          number_of_terminal_transactions: 1000,
          number_of_processors: 5,
          total_amount: 10000,
          most_used_processor: ["Stripe", "Paypal", "Razorpay"],
          payment_method: ["Credit Card", "Debit Card", "UPI"],
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

    let loadButton = async () => {
      Js.log2("added delay", "delay")
      await HyperSwitchUtils.delay(800)
      setText(_ => "Preparing sample data")
      await HyperSwitchUtils.delay(800)
      setText(_ => "Apply Rule-based Routing")
      await HyperSwitchUtils.delay(800)
      setText(_ => "Apply Debit Routing")
      await HyperSwitchUtils.delay(800)
    }

    let handleNext = _ => {
      open Promise
      loadButton()
      ->then(_ => {
        getReviewData()->ignore
        Js.Promise.resolve(onNextClick())
      })
      ->ignore
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

  let backClick = () => {
    RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url="/v2/intelligent-routing"))
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
        | {sectionId: "analyze"} => <Analyze onNextClick setReviewFields />
        | {sectionId: "review"} => <Review reviewFields />
        | _ => React.null
        }}
      </div>
    </div>
  </div>
}
