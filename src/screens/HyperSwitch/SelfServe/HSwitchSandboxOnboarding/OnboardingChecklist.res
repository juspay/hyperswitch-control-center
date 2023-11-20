@react.component
let make = () => {
  open APIUtils
  let url = RescriptReactRouter.useUrl()
  let updateDetails = useUpdateMethod()
  let {
    integrationDetails,
    setIntegrationDetails,
    setDashboardPageState,
    setShowProdIntentForm,
  } = React.useContext(GlobalProvider.defaultContext)

  let stepperValue = HSwitchVerticalStepper.getStepperValue(~integrationDetails)

  let typeOfIntegrationDocs =
    LogicUtils.getDictFromUrlSearchParams(url.search)
    ->Js.Dict.get("type")
    ->Belt.Option.getWithDefault("")

  let markAsDone = currentRoute =>
    async () => {
      try {
        let url = getURL(~entityName=INTEGRATION_DETAILS, ~methodType=Post, ())
        let body = HSwitchUtils.constructOnboardingBody(
          ~dashboardPageState=#INTEGRATION_DOC,
          ~integrationDetails,
          ~is_done=true,
          ~metadata=[
            ("is_skip", false->Js.Json.boolean),
            (
              "integrationType",
              currentRoute->UserOnboardingUtils.variantToTextMapperForBuildHS->Js.Json.string,
            ),
          ]
          ->Js.Dict.fromArray
          ->Js.Json.object_,
          (),
        )
        let _res = await updateDetails(url, body, Post)
        setIntegrationDetails(_ => body->ProviderHelper.getIntegrationDetails)
        RescriptReactRouter.replace("/home")
        setDashboardPageState(_ => #HOME)
        setShowProdIntentForm(_ => true)
      } catch {
      | _ => ()
      }
    }

  let handleBackButton = () => {
    RescriptReactRouter.push("/home")
    setDashboardPageState(_ => #HOME)
  }
  let isFromOnboardingChecklist = integrationDetails.integration_checklist.is_done

  <div
    className="flex gap-10 h-screen w-screen bg-no-repeat bg-cover w-full"
    style={ReactDOMStyle.make(
      ~backgroundImage=`url(/images/hyperswitchImages/PostLoginBackground.svg)`,
      (),
    )}>
    <div className="h-full w-1/3 border bg-white shadow shadow-sidebarShadow">
      <Button
        text={"Back to home"}
        customButtonStyle="bg-white !rounded-md !ml-6 !mt-10"
        buttonType=Secondary
        buttonSize={Small}
        leftIcon=FontAwesome("arrow-left")
        onClick={_ => handleBackButton()}
      />
      <p className="font-semibold text-xl p-6"> {"Onboarding Checklist"->React.string} </p>
      <div className="p-6">
        <HSwitchVerticalStepper.VerticalStepper
          onboardingStep={integrationDetails.integration_checklist.is_done ? 3 : 2} stepperValue
        />
      </div>
    </div>
    <div className="overflow-auto w-full">
      {<div className="bg-grey-700 bg-opacity-20 h-px w-4/5">
        <div className="py-8 px-2">
          {switch (url.path, typeOfIntegrationDocs) {
          | (list{"onboarding-checklist"}, "migrate-from-stripe") =>
            <IntegrationDocs
              currentRoute={MigrateFromStripe}
              markAsDone={markAsDone(MigrateFromStripe)}
              isFromOnboardingChecklist
            />
          | (list{"onboarding-checklist"}, "integrate-from-scratch") =>
            <IntegrationDocs
              currentRoute={IntegrateFromScratch}
              markAsDone={markAsDone(IntegrateFromScratch)}
              isFromOnboardingChecklist
            />
          | (list{"onboarding-checklist"}, "sample-projects") =>
            <IntegrationDocs
              currentRoute={SampleProjects}
              markAsDone={markAsDone(SampleProjects)}
              isFromOnboardingChecklist
            />
          | (list{"onboarding-checklist"}, "woocommerce-plugin") =>
            <IntegrationDocs
              currentRoute={WooCommercePlugin}
              languageSelection=false
              markAsDone={markAsDone(WooCommercePlugin)}
              isFromOnboardingChecklist
            />
          | _ =>
            <div className="flex flex-col gap-12 p-8">
              <UserOnboardingUIUtils.Section
                sectionHeaderText="Integrate Hyperswitch"
                sectionSubText="Start by cloning a project or Integrating from scratch"
                subSectionArray=UserOnboarding.integrateHyperswitch
                customRedirection="onboarding-checklist"
                isFromOnboardingChecklist
              />
              <div className="border-1 bg-grey-700 opacity-50 w-full" />
              <UserOnboardingUIUtils.Section
                sectionHeaderText="Other Integration"
                sectionSubText=""
                subSectionArray=UserOnboarding.buildHyperswitch
                customRedirection="onboarding-checklist"
                isFromOnboardingChecklist
              />
            </div>
          }}
        </div>
      </div>}
    </div>
  </div>
}
