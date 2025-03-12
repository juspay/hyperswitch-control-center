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

    <div>
      <PageUtils.PageHeading
        title="Review Data Summary"
        subTitle="Review your configured order source, API’s and payment methods"
      />
      <div>
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

    let getReviewData = async () => {
      try {
        let _url = getURL(~entityName=V1(SIMULATE_INTELLIGENT_ROUTING), ~methodType=Get)
        // let _res = await Fetch.fetch(url)
        let response = {
          file_name: "random_data.csv",
          number_of_transaction: 1000,
          number_of_terminal_transactions: 1000,
          number_of_processors: 5,
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

    let handleNext = _ => {
      getReviewData()->ignore
      onNextClick()
    }

    <div className="">
      <PageUtils.PageHeading
        title="Analyze Your Transaction History"
        subTitle="Link your order data source to streamline the reconciliation process"
      />
      <div className="flex flex-col gap-4 mt-4">
        <p className="font-semibold text-nd_gray-700">
          {"Where do you want to fetch your order data from?"->React.string}
        </p>
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
        <Button
          text="Next"
          customButtonStyle="w-full"
          buttonType={Primary}
          onClick={_ => handleNext()}
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

  <div className="flex flex-row gap-x-6">
    <VerticalStepIndicator
      titleElement=intelligentRoutingTitleElement sections currentStep backClick
    />
    <div className=" ml-14">
      {switch currentStep {
      | {sectionId: "analyze"} => <Analyze onNextClick setReviewFields />
      | {sectionId: "review"} => <Review reviewFields />
      | _ => React.null
      }}
    </div>
  </div>
}
