type stepperValueType = {
  collapsedText: string,
  renderComponent: React.element,
  isSelectable: bool,
}

module StepperRenderedComponent = {
  @react.component
  let make = (
    ~headerText=None,
    ~overrideStyles="",
    ~btnText="",
    ~isBtnVisible=true,
    ~customOnClick=() => (),
    ~isDisabled=false,
    ~customHeaderComponent=React.null,
  ) => {
    let stepCompHeight = isBtnVisible ? "h-25" : "h-15"
    <div className={`flex ${stepCompHeight} flex-col gap-4 rounded-md mb-8 ${overrideStyles}`}>
      <UIUtils.RenderIf condition={headerText->Belt.Option.isSome}>
        <p className="text-grey-50 text-lg">
          {headerText->Belt.Option.getWithDefault("")->React.string}
        </p>
      </UIUtils.RenderIf>
      <UIUtils.RenderIf condition={customHeaderComponent !== React.null}>
        {customHeaderComponent}
      </UIUtils.RenderIf>
    </div>
  }
}

let getMixpanelEvent = (
  url: RescriptReactRouter.url,
  ~actionName,
  ~hyperswitchMixPanel: HSMixPanel.functionType,
) => {
  [url.path->LogicUtils.getListHead, "global"]->Js.Array2.forEach(ele =>
    hyperswitchMixPanel(~pageName=ele, ~contextName="onboarding_checklist", ~actionName, ())
  )
}

let skipAndContinue = async (
  ~updateDetails: (Js.String2.t, Js.Json.t, Fetch.requestMethod) => promise<Js.Json.t>,
  ~body,
  ~setIntegrationDetails,
) => {
  try {
    let url = APIUtils.getURL(~entityName=INTEGRATION_DETAILS, ~methodType=Post, ())
    let _res = await updateDetails(url, body, Post)
    setIntegrationDetails(_ => body->ProviderHelper.getIntegrationDetails)
  } catch {
  | _ => ()
  }
}

let getStepperValue = (~integrationDetails: ProviderTypes.integrationDetailsType) => {
  [
    {
      collapsedText: "Free tier activated",
      renderComponent: <StepperRenderedComponent
        customHeaderComponent={<p className="text-grey-50 text-lg">
          {"10K free transactions per month. Explore detailed pricing"->React.string}
          <a
            href="https://hyperswitch.io/pricing"
            target="_blank"
            className="text-lg text-status-blue ml-1 underline underline-offset-4">
            {"here"->React.string}
          </a>
        </p>}
        isBtnVisible=false
      />,
      isSelectable: false,
    },
    {
      collapsedText: "Dashboard configured",
      renderComponent: <StepperRenderedComponent
        headerText=Some("Stripe & Paypal test processors with routing is pre-configured")
        isBtnVisible=false
      />,
      isSelectable: false,
    },
    {
      collapsedText: "Integrate Hyperswitch",
      renderComponent: <StepperRenderedComponent
        headerText=Some({
          integrationDetails.integration_checklist.is_done
            ? "You can always find the Docs inside Developer Section"
            : "Resume integration from where you have left off"
        })
        btnText={integrationDetails.integration_checklist.is_done
          ? "Go to Developer Docs"
          : "Resume Integration"}
      />,
      isSelectable: true,
    },
  ]
}

module VerticalStepper = {
  @react.component
  let make = (~onboardingStep, ~stepperValue) => {
    let selectedStepTextStyle = index =>
      index === onboardingStep
        ? "text-blue-800 font-bold"
        : "text-jp-gray-banner_black font-semibold"

    let selectedStepStyle = index =>
      index < onboardingStep ? "bg-blue-800 " : " bg-jp-gray-700 opacity-50"

    let selectedIcon = index => {
      index < onboardingStep ? <Icon name="blue-tick" size=20 /> : <Icon name="unticked" size=20 />
    }

    <div className={`flex flex-col items-start justify-around`}>
      {stepperValue
      ->Array.mapWithIndex((value, index) => {
        let isLast = stepperValue->Js.Array2.length - 1 === index
        <div className="flex flex-row gap-4 justify-start h-40">
          <div className="flex flex-col items-center ">
            <div className="flex flex-col items-center "> {index->selectedIcon} </div>
            <UIUtils.RenderIf condition={!isLast}>
              {if onboardingStep === index {
                <div className="h-full w-full flex flex-col justify-center items-center">
                  <div className={`w-0.5 h-1/3 ${index->selectedStepStyle}`} />
                  <div className={`w-0.5 h-2/3 bg-jp-gray-700 opacity-50`} />
                </div>
              } else {
                <div className={`w-0.5 h-full ${index->selectedStepStyle} `} />
              }}
            </UIUtils.RenderIf>
          </div>
          <div key={index->string_of_int} className="flex flex-col gap-3">
            <div key={index->string_of_int} className={`text-xl ${index->selectedStepTextStyle}`}>
              {value.collapsedText->React.string}
            </div>
            {value.renderComponent}
          </div>
        </div>
      })
      ->React.array}
    </div>
  }
}
