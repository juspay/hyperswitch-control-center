let buildHyperswitch: array<UserOnboardingTypes.sectionContentType> = [
  {
    headerIcon: "migrate-from-stripe",
    headerText: "Migrate from Stripe",
    buttonText: "Start Integration",
    customIconCss: "!w-96",
    url: "migrate-from-stripe",
    isIconImg: true,
    imagePath: "/assets/MigrateFromStripe.svg",
    subTextCustomValues: ["Low Code", "Blazing Fast Go-Live", "Stripe Compatible"],
  },
  {
    headerIcon: "woocommerce-plugin",
    headerText: "WooCommerce Integration",
    buttonText: "Start Integration",
    customIconCss: "!w-96",
    url: "woocommerce-plugin",
    rightIcon: <Icon name="new-setup" size=25 className="w-20" />,
    isIconImg: true,
    imagePath: "/assets/WooCommercePlugin.svg",
    subTextCustomValues: [
      "No Code, Blazing Fast Go-Live",
      "A Seamless Checkout Experience",
      "Orders Management",
    ],
  },
]

let integrateHyperswitch: array<UserOnboardingTypes.sectionContentType> = [
  {
    headerIcon: "github",
    headerText: "Clone a sample project",
    buttonText: "Start Integration",
    customIconCss: "!w-15",
    url: "sample-projects",
    subTextCustomValues: ["Supports 20+ languages", "Minimal integration steps", "Fastest!"],
    buttonType: Primary,
    rightIcon: <Icon name="quickSetup" size=25 className="w-28" />,
  },
  {
    headerIcon: "integrate-from-scratch",
    headerText: "Standard Integration",
    buttonText: "Start Integration",
    customIconCss: "!w-20",
    url: "integrate-from-scratch",
    subTextCustomValues: [
      "40+ Payment Processors",
      "60+ Payment Methods",
      "Unlimited Customizations",
    ],
  },
]

module DefaultDocsPage = {
  @react.component
  let make = () => {
    <div className="flex flex-col gap-12 p-8">
      <UserOnboardingUIUtils.Section
        sectionHeaderText="Integrate Hyperswitch"
        sectionSubText="Start by cloning a project or Integrating from scratch"
        subSectionArray=integrateHyperswitch
      />
      <div className="border-1 bg-grey-700 opacity-50 w-full" />
      <UserOnboardingUIUtils.Section
        sectionHeaderText="Other Integration" sectionSubText="" subSectionArray=buildHyperswitch
      />
    </div>
  }
}
@react.component
let make = () => {
  open UserOnboardingTypes
  let url = RescriptReactRouter.useUrl()
  let searchParams = url.search
  let filtersFromUrl =
    LogicUtils.getDictFromUrlSearchParams(searchParams)
    ->Dict.get("type")
    ->Belt.Option.getWithDefault("")
  let (currentRoute, setCurrentRoute) = React.useState(_ => OnboardingDefault)
  let {
    integrationDetails,
    setIntegrationDetails,
    dashboardPageState,
    setDashboardPageState,
  } = React.useContext(GlobalProvider.defaultContext)

  React.useEffect1(() => {
    if dashboardPageState !== #HOME {
      RescriptReactRouter.push("/onboarding")
    }
    None
  }, [dashboardPageState])

  React.useEffect1(() => {
    let routeType = switch filtersFromUrl {
    | "migrate-from-stripe" => MigrateFromStripe
    | "integrate-from-scratch" => IntegrateFromScratch
    | "sample-projects" => SampleProjects
    | "woocommerce-plugin" => WooCommercePlugin
    | _ => OnboardingDefault
    }
    setCurrentRoute(_ => routeType)
    setDashboardPageState(_ => #INTEGRATION_DOC)
    None
  }, [url.search])

  open APIUtils
  let updateDetails = useUpdateMethod(~showErrorToast=false, ())

  let skipAndContinue = async () => {
    try {
      let url = getURL(~entityName=INTEGRATION_DETAILS, ~methodType=Post, ())
      let metaDataDict = Dict.fromArray([("is_skip", true->Js.Json.boolean)])->Js.Json.object_
      let body = HSwitchUtils.constructOnboardingBody(
        ~dashboardPageState,
        ~integrationDetails,
        ~is_done=false,
        ~metadata=metaDataDict,
        (),
      )
      let _ = await updateDetails(url, body, Post)
      setIntegrationDetails(_ => body->ProviderHelper.getIntegrationDetails)
    } catch {
    | _ => ()
    }
    setDashboardPageState(_ => #HOME)
  }

  let markAsDone = async () => {
    try {
      let url = getURL(~entityName=INTEGRATION_DETAILS, ~methodType=Post, ())
      let body = HSwitchUtils.constructOnboardingBody(
        ~dashboardPageState,
        ~integrationDetails,
        ~is_done=true,
        ~metadata=[
          ("is_skip", false->Js.Json.boolean),
          (
            "integrationType",
            currentRoute->UserOnboardingUtils.variantToTextMapperForBuildHS->Js.Json.string,
          ),
        ]
        ->Dict.fromArray
        ->Js.Json.object_,
        (),
      )
      let _ = await updateDetails(url, body, Post)
      setIntegrationDetails(_ => body->ProviderHelper.getIntegrationDetails)
      setDashboardPageState(_ => #HOME)
    } catch {
    | Js.Exn.Error(e) =>
      let err = Js.Exn.message(e)->Belt.Option.getWithDefault("Something went wrong")
      Js.Exn.raiseError(err)
    }
  }

  <div
    className="h-screen w-full bg-no-repeat bg-cover "
    style={ReactDOMStyle.make(
      ~backgroundImage=`url(/images/hyperswitchImages/PostLoginBackground.svg)`,
      (),
    )}>
    <div
      className="h-screen w-screen  md:w-pageWidth11 md:mx-auto overflow-hidden grid grid-cols-1 md:grid-cols-[12rem,1fr,18rem] md:grid-rows-[4rem,1fr] py-10 px-4 gap-x-2 gap-y-8 grid-flow-row md:grid-flow-row">
      <div className="justify-self-center md:justify-self-start row-span-1">
        <Icon name="hyperswitch-text-icon" size=28 className="cursor-pointer w-40 " />
      </div>
      <div
        className="row-span-1 col-span-1 flex justify-center items-start w-full text-lg font-semibold">
        {currentRoute->UserOnboardingUtils.getMainPageText->React.string}
      </div>
      <Button
        text="Skip & Explore Dashboard"
        customButtonStyle="row-span-1 col-span-1 justify-self-center md:justify-self-end !rounded-md"
        buttonType={PrimaryOutline}
        onClick={_ => skipAndContinue()->ignore}
      />
      <div
        className="h-75-vh md:h-full w-full col-span-1 md:col-span-3 border rounded-md bg-white overflow-scroll">
        {switch currentRoute {
        | MigrateFromStripe
        | IntegrateFromScratch
        | SampleProjects =>
          <IntegrationDocs currentRoute markAsDone />
        | WooCommercePlugin => <IntegrationDocs currentRoute markAsDone languageSelection=false />
        | _ => <DefaultDocsPage />
        }}
      </div>
    </div>
  </div>
}
