open WooCommerceUtils
open ConnectorTypes
open QuickStartTypes

let steps: array<step> = [PLUGIN_INSTALL, PLUGIN_CONFIGURE, WEBHOOK_SETUP, PROCESSOR_SETUP]

module BaseComponent = {
  @react.component
  let make = (~handleNavigation, ~children) => {
    <QuickStartUIUtils.BaseComponent
      headerText="Hyperswitch for Woocommerce"
      headerLeftIcon="hyperswitch-logo-short"
      nextButton={<Button
        text="Continue"
        buttonType={Primary}
        onClick={_ => handleNavigation(~forward={true})->ignore}
      />}>
      {children}
    </QuickStartUIUtils.BaseComponent>
  }
}

module WooCommerceStepWrapper = {
  @react.component
  let make = (~title: string, ~description: string, ~children) => {
    <div className="flex flex-col gap-6">
      <div>
        <h2 className="text-xl font-semibold"> {title->React.string} </h2>
        <p className="text-gray-500"> {description->React.string} </p>
      </div>
      {children}
    </div>
  }
}

module InstallPlugin = {
  @react.component
  let make = (~handleNavigation, ~title, ~description) => {
    <BaseComponent handleNavigation>
      <WooCommerceStepWrapper title={title} description={description}>
        <div className="bg-gray-50 rounded border p-8 flex flex-col gap-6">
          <div>
            <h2 className="text-xl font-medium">
              {"Hyperswitch's Checkout Plugin"->React.string}
            </h2>
            <p className="text-gray-500">
              {"Use this plugin to get the best checkout experience"->React.string}
            </p>
          </div>
          <UserOnboardingUIUtils.DownloadWordPressPlugin
            currentRoute={WooCommercePlugin} currentTabName="downloadWordpressPlugin"
          />
        </div>
      </WooCommerceStepWrapper>
    </BaseComponent>
  }
}
module ConfigurePlugin = {
  @react.component
  let make = (~handleNavigation, ~title, ~description) => {
    <BaseComponent handleNavigation>
      <WooCommerceStepWrapper title={title} description={description}>
        <div className="p-8 flex flex-col gap-6">
          <div className="flex flex-col gap-6">
            <div className="flex gap-2 items-center">
              <div className="text-grey-0 bg-gray-700 rounded flex items-center px-1">
                {"1"->React.string}
              </div>
              <h2 className="font-medium">
                {"Navigate to WooCommerce Settings > Payments Tab"->React.string}
              </h2>
            </div>
            <div
              className="bg-white p-7 flex flex-col gap-6 border !shadow-hyperswitch_box_shadow rounded-md">
              <img
                style={ReactDOMStyle.make(
                  ~height="400px",
                  ~width="100%",
                  ~objectFit="cover",
                  ~objectPosition="0% 12%",
                  (),
                )}
                src="https://hyperswitch.io/img/site/wordpress_hyperswitch_settings.png"
              />
            </div>
          </div>
          <div className="flex flex-col gap-6">
            <div className="flex gap-2 items-center">
              <div className="text-grey-0 bg-gray-700 rounded flex items-center px-1">
                {"2"->React.string}
              </div>
              <h2 className="font-medium">
                {"Copy-Paste your API keys & below details in your WooCommerce Plugin Settings"->React.string}
              </h2>
            </div>
            <div className="bg-gray-50 p-7">
              <div className="grid grid-cols-3 w-full border-b py-4">
                <div className="col-span-2">
                  <div className="font-medium"> {"API Key"->React.string} </div>
                  <div className="text-gray-500 mt-2">
                    {"Use this key to authenticate all API requests from your application's server"->React.string}
                  </div>
                </div>
                <UserOnboardingUIUtils.DownloadAPIKeyButton
                  buttonText="Download API key"
                  currentRoute={WooCommercePlugin}
                  currentTabName="downloadWordpressPlugin"
                />
              </div>
              <div className="grid grid-cols-3 w-full border-b py-4">
                <div className="col-span-2">
                  <div className="font-medium"> {"Publishable Key"->React.string} </div>
                  <div className="text-gray-500 mt-2">
                    {"Use this key to authenticate all calls from your application's client"->React.string}
                  </div>
                </div>
                <UserOnboardingUIUtils.PublishableKeyArea />
              </div>
              <div className="grid grid-cols-3 w-full py-4">
                <div className="col-span-2">
                  <div className="font-medium"> {"Payment Response Hash Key"->React.string} </div>
                  <div className="text-gray-500 mt-2">
                    {"This helps to authenticate and verify live events send by Hyperswitch."->React.string}
                  </div>
                </div>
                <UserOnboardingUIUtils.PaymentResponseHashKeyArea />
              </div>
            </div>
          </div>
        </div>
      </WooCommerceStepWrapper>
    </BaseComponent>
  }
}

module ConfigureWebHook = {
  @react.component
  let make = (~handleNavigation, ~title, ~description) => {
    let businessProfiles = Recoil.useRecoilValueFromAtom(HyperswitchAtom.businessProfilesAtom)
    let defaultBusinessProfile = businessProfiles->MerchantAccountUtils.getValueFromBusinessProfile
    <BaseComponent handleNavigation>
      <WooCommerceStepWrapper title={title} description={description}>
        <div className="p-8 flex flex-col gap-6">
          <div className="flex flex-col gap-6">
            <div className="flex gap-2 items-center">
              <div className="text-grey-0 bg-gray-700 rounded flex items-center px-1">
                {"1"->React.string}
              </div>
              <h2 className="font-medium">
                {"Enable Hyperswitch Webhook in “Enable Webhook” Section (Ignore if enabled)"->React.string}
              </h2>
            </div>
            <div
              className="bg-white p-7 flex flex-col gap-6 border !shadow-hyperswitch_box_shadow rounded-md">
              <img
                style={ReactDOMStyle.make(
                  ~height="250px",
                  ~width="100%",
                  ~objectFit="cover",
                  ~objectPosition="0% 40%",
                  (),
                )}
                src="https://hyperswitch.io/img/site/wordpress_hyperswitch_settings.png"
              />
            </div>
          </div>
          <div className="flex flex-col gap-6">
            <div className="flex gap-2 items-center">
              <div className="text-grey-0 bg-gray-700 rounded flex items-center px-1">
                {"2"->React.string}
              </div>
              <h2 className="font-medium">
                {"Copy the URL under “Enable Webhook” section & paste here"->React.string}
              </h2>
            </div>
            <div className="bg-gray-50 p-7">
              <div className="grid grid-cols-2 w-full py-4">
                <div>
                  <div className="font-medium"> {"API Key"->React.string} </div>
                  <div className="text-gray-500 mt-2">
                    {"Use this key to authenticate all API requests from your application's server"->React.string}
                  </div>
                </div>
                <PaymentSettings
                  webhookOnly=true showFormOnly=true profileId={defaultBusinessProfile.profile_id}
                />
              </div>
            </div>
          </div>
          <div className="flex flex-col gap-6">
            <div className="flex gap-2 items-center">
              <div className="text-grey-0 bg-gray-700 rounded flex items-center px-1">
                {"3"->React.string}
              </div>
              <h2 className="font-medium">
                {"Scroll to the bottom & click on \"Save Changes\""->React.string}
              </h2>
            </div>
            <div
              className="bg-white p-7 flex flex-col gap-6 border !shadow-hyperswitch_box_shadow rounded-md">
              <img
                style={ReactDOMStyle.make(
                  ~height="150px",
                  ~width="100%",
                  ~objectFit="cover",
                  ~objectPosition="0% 100%",
                  (),
                )}
                src="https://hyperswitch.io/img/site/wordpress_hyperswitch_settings.png"
              />
            </div>
          </div>
        </div>
      </WooCommerceStepWrapper>
    </BaseComponent>
  }
}

@react.component
let make = () => {
  let usePostEnumDetails = EnumVariantHook.usePostEnumDetails()
  let enumDetails = Recoil.useRecoilValueFromAtom(HyperswitchAtom.enumVariantAtom)
  let (selectedConnector, setSelectedConnector) = React.useState(_ => UnknownConnector(""))
  let (initialValues, setInitialValues) = React.useState(_ => Dict.make()->Js.Json.object_)
  let (connectorConfigureState, setConnectorConfigureState) = React.useState(_ => Select_processor)
  let (stepInView, setStepInView) = React.useState(_ => PLUGIN_INSTALL)
  let {setDashboardPageState} = React.useContext(GlobalProvider.defaultContext)
  let (buttonState, setButtonState) = React.useState(_ => Button.Normal)
  let connectorName = selectedConnector->ConnectorUtils.getConnectorNameString
  let activeBusinessProfile =
    HyperswitchAtom.businessProfilesAtom
    ->Recoil.useRecoilValueFromAtom
    ->MerchantAccountUtils.getValueFromBusinessProfile

  let naviagteToHome = _ => {
    setDashboardPageState(_ => #HOME)
    RescriptReactRouter.replace("/home")
  }

  let handleNavigation = async (~forward: bool) => {
    let enums = enumDetails->LogicUtils.safeParse->QuickStartUtils.getTypedValueFromDict
    let isAnyConnectorConfigured = enums.firstProcessorConnected.processorID->String.length > 0

    try {
      if forward && !(stepInView->enumToValueMapper(enums)) {
        let currentStepVariant = stepInView->variantToEnumMapper
        let _ = await Boolean(true)->usePostEnumDetails(currentStepVariant)
      }
    } catch {
    | _ => ()
    }
    setStepInView(prev => {
      switch prev {
      | PLUGIN_INSTALL => forward ? PLUGIN_CONFIGURE : PLUGIN_INSTALL
      | PLUGIN_CONFIGURE => forward ? WEBHOOK_SETUP : PLUGIN_INSTALL
      | WEBHOOK_SETUP =>
        if forward && isAnyConnectorConfigured {
          COMPLETED_WOOCOMMERCE
        } else if forward {
          PROCESSOR_SETUP
        } else {
          PLUGIN_CONFIGURE
        }
      | PROCESSOR_SETUP => forward ? PROCESSOR_SETUP : WEBHOOK_SETUP
      | COMPLETED_WOOCOMMERCE => COMPLETED_WOOCOMMERCE
      }
    })
  }

  React.useEffect1(() => {
    let enums = enumDetails->LogicUtils.safeParse->QuickStartUtils.getTypedValueFromDict
    let currentPending = steps->Array.find(step => {
      step->enumToValueMapper(enums) === false
    })

    switch currentPending {
    | Some(step) => setStepInView(_ => step)
    | None => setStepInView(_ => COMPLETED_WOOCOMMERCE)
    }
    None
  }, [enumDetails])

  let (title, description) = switch stepInView {
  | PLUGIN_INSTALL => (
      "Download and Install Plugin",
      "Start by downloading our Plugin, and installing it on your WordPress Admin Dashboard. Activate the Plugin post installation.",
    )
  | PLUGIN_CONFIGURE => ("Configure Plugin", "Configure our WooCommerce plugin details")
  | WEBHOOK_SETUP => (
      "Setup Webhook & Save Changes",
      "Configure WooCommerce webhook on our end & complete setup",
    )
  | PROCESSOR_SETUP | COMPLETED_WOOCOMMERCE => ("", "")
  }
  React.useEffect1(() => {
    let defaultJsonOnNewConnector =
      [("profile_id", activeBusinessProfile.profile_id->Js.Json.string)]
      ->Dict.fromArray
      ->Js.Json.object_
    setInitialValues(_ => defaultJsonOnNewConnector)
    None
  }, [activeBusinessProfile.profile_id, connectorName])

  <div className="flex bg-blue-background_blue">
    <HSSelfServeSidebar
      heading={"Hyperswitch for Woocommerce"}
      sidebarOptions={enumDetails->getSidebarOptionsForWooCommerceIntegration(stepInView)}
    />
    <div className="flex-1 flex flex-col items-center justify-center ml-12">
      {switch stepInView {
      | PLUGIN_INSTALL => <InstallPlugin handleNavigation title description />
      | PLUGIN_CONFIGURE => <ConfigurePlugin handleNavigation title description />
      | WEBHOOK_SETUP => <ConfigureWebHook handleNavigation title description />
      | PROCESSOR_SETUP =>
        switch connectorConfigureState {
        | Select_processor =>
          <WooCommerceUIUtils.SelectProcessor
            selectedConnector setSelectedConnector setConnectorConfigureState connectorArray=[]
          />
        | Configure_keys =>
          <SetupConnector.ConfigureProcessor
            selectedConnector initialValues setInitialValues setConnectorConfigureState
          />
        | Setup_payment_methods =>
          <WooCommerceUIUtils.SelectPaymentMethods
            initialValues
            selectedConnector
            setInitialValues
            setConnectorConfigureState
            buttonState
            setButtonState
          />
        | Summary =>
          <QuickStartUIUtils.BaseComponent
            headerText={connectorName->LogicUtils.capitalizeString}
            customIcon={<GatewayIcon
              gateway={connectorName->String.toUpperCase} className="w-6 h-6 rounded-md"
            />}
            customCss="show-scrollbar"
            backButton={<Button
              text="Back"
              buttonType={PrimaryOutline}
              onClick={_ => handleNavigation(~forward={false})->ignore}
            />}
            nextButton={<Button
              text="Continue & Proceed"
              buttonSize=Small
              buttonState
              customButtonStyle="rounded-md"
              buttonType={Primary}
              onClick={_ => handleNavigation(~forward={true})->ignore}
            />}>
            <ConnectorPreview.ConnectorSummaryGrid
              connectorInfo={initialValues
              ->LogicUtils.getDictFromJsonObject
              ->ConnectorTableUtils.getProcessorPayloadType}
              connector=connectorName
              setScreenState={_ => ()}
              isPayoutFlow=false
            />
          </QuickStartUIUtils.BaseComponent>
        | _ => React.null
        }
      | COMPLETED_WOOCOMMERCE =>
        <div className="bg-white rounded h-40-rem">
          <ProdOnboardingUIUtils.BasicAccountSetupSuccessfulPage
            iconName="account-setup-completed"
            statusText="WooCommerce Plugin Setup Successfully Completed"
            buttonText="Go To Home"
            buttonOnClick={naviagteToHome}
            customWidth="w-30-rem text-center"
          />
        </div>
      }}
    </div>
  </div>
}
