external formEventToStr: ReactEvent.Form.t => string = "%identity"
open CardUtils
open PageUtils
open HSwitchUtils

let headingStyle = `${getTextClass(~textVariant=H3, ~h3TextVariant=Leading_1, ())} `
let paragraphTextVariant = `${getTextClass(
    ~textVariant=P2,
    ~paragraphTextVariant=Medium,
    (),
  )} text-grey-700 opacity-50`

let subtextStyle = `${getTextClass(
    ~textVariant=P1,
    ~paragraphTextVariant=Regular,
    (),
  )} text-grey-700 opacity-50`
let cardHeaderText = `${getTextClass(~textVariant=H3, ~h3TextVariant=Leading_2, ())} `
let hoverStyle = "cursor-pointer group-hover:shadow hover:shadow-homePageBoxShadow group"
let boxCssHover = (~ishoverStyleRequired=true, ()) =>
  `flex flex-col  bg-white border rounded-md pt-10 pl-10 gap-2 h-12.5-rem ${ishoverStyleRequired
      ? hoverStyle
      : ""}`
let boxCss = "flex flex-col bg-white border rounded-md gap-4 p-10"
let imageTransitionCss = "opacity-50 group-hover:opacity-100 transition ease-in-out duration-300"
let cardHeaderTextStyle = `${cardHeaderText} text-grey-700`

type resourcesTypes = {
  icon: string,
  headerText: string,
  subText: string,
  redirectLink: string,
  id: string,
}

let trackRedictMixPanelEvents = (
  ~pageName,
  ~destination,
  ~redirectType="internal",
  ~hyperswitchMixPanel: HSMixPanel.functionType,
  (),
) => {
  hyperswitchMixPanel(
    ~pageName,
    ~contextName=`${redirectType}_redirect`,
    ~actionName=`to_${destination}`,
    (),
  )
}

let countries: array<HyperSwitchTypes.country> = [
  {
    isoAlpha3: "USA",
    currency: "USD",
    countryName: "United States",
    isoAlpha2: "US",
  },
  {
    isoAlpha3: "CHE",
    currency: "CHF",
    countryName: "Switzerland",
    isoAlpha2: "CH",
  },
  {
    isoAlpha3: "DEU",
    currency: "EUR",
    countryName: "Germany",
    isoAlpha2: "DE",
  },
  {
    isoAlpha3: "NLD",
    currency: "EUR",
    countryName: "Netherlands",
    isoAlpha2: "NL",
  },
  {
    isoAlpha3: "AUS",
    currency: "AUD",
    countryName: "Australia",
    isoAlpha2: "AU",
  },
  {
    isoAlpha3: "AUT",
    currency: "EUR",
    countryName: "Austria",
    isoAlpha2: "AT",
  },
  {
    isoAlpha3: "GBR",
    currency: "GBP",
    countryName: "United Kingdom",
    isoAlpha2: "GB",
  },
  {
    isoAlpha3: "CAN",
    currency: "CAD",
    countryName: "Canada",
    isoAlpha2: "CA",
  },
  {
    isoAlpha3: "PLN",
    currency: "PLN",
    countryName: "Poland",
    isoAlpha2: "PL",
  },
  {
    isoAlpha3: "CHN",
    currency: "CNY",
    countryName: "China",
    isoAlpha2: "CN",
  },
  {
    isoAlpha3: "SWE",
    currency: "SEK",
    countryName: "Sweden",
    isoAlpha2: "SE",
  },
  {
    isoAlpha3: "HKG",
    currency: "HKD",
    countryName: "Hongkong",
    isoAlpha2: "HK",
  },
]

let isDefaultBusinessProfile = details => details->Js.Array2.length === 1

module MerchantAuthInfo = {
  @react.component
  let make = (~merchantDetailsValue) => {
    let detail = merchantDetailsValue->HSwitchMerchantAccountUtils.getMerchantDetails
    let dataDict =
      [
        ("merchant_id", detail.merchant_id->Js.Json.string),
        ("publishable_key", detail.publishable_key->Js.Json.string),
      ]->Js.Dict.fromArray

    <Form initialValues={dataDict->Js.Json.object_} formClass="md:ml-9 my-4">
      <div className="flex flex-col md:flex-row gap-3">
        <div>
          <div className="font-semibold text-dark_black"> {"Merchant ID"->React.string} </div>
          <div className="flex items-center">
            <div className="font-medium text-dark_black opacity-40">
              {detail.merchant_id->React.string}
            </div>
            <CopyFieldValue fieldkey="merchant_id" />
          </div>
        </div>
        <div>
          <div className="font-semibold text-dark_black"> {"Publishable Key"->React.string} </div>
          <div className="flex items-center">
            <div
              className="font-medium text-dark_black opacity-40"
              style={ReactDOMStyle.make(~overflowWrap="anywhere", ())}>
              {detail.publishable_key->React.string}
            </div>
            <CopyFieldValue fieldkey="publishable_key" />
          </div>
        </div>
      </div>
    </Form>
  }
}

module InputText = {
  @react.component
  let make = (~setAmount, ~isSDKOpen) => {
    let (value, setValue) = React.useState(_ => "100")
    let showPopUp = PopUpState.useShowPopUp()
    let input: ReactFinalForm.fieldRenderPropsInput = {
      name: "-",
      onBlur: _ev => (),
      onChange: ev => {
        let value = {ev->ReactEvent.Form.target}["value"]
        if value->Js.String2.includes("<script>") || value->Js.String2.includes("</script>") {
          showPopUp({
            popUpType: (Warning, WithIcon),
            heading: `Script Tags are not allowed`,
            description: React.string(`Input cannot contain <script>, </script> tags`),
            handleConfirm: {text: "OK"},
          })
        }
        let value = value->Js.String2.replace("<script>", "")->Js.String2.replace("</script>", "")
        if Js.Re.test_(%re("/^[0-9]*$/"), value) && value->Js.String2.length <= 8 {
          setValue(_ => value)
          setAmount(_ => value->Belt.Int.fromString->Belt.Option.getWithDefault(100) * 100)
        }
      },
      onFocus: _ev => (),
      value: Js.Json.string(value),
      checked: false,
    }

    <TextInput
      input
      placeholder={"Enter amount"}
      isDisabled={isSDKOpen}
      onDisabledStyle="bg-jp-gray-300 dark:bg-gray-800 dark:bg-opacity-10"
      onHoverCss={isSDKOpen ? "bg-jp-gray-300 dark:bg-gray-800 dark:bg-opacity-10" : ""}
    />
  }
}

module SDKOverlay = {
  @react.component
  let make = (
    ~merchantDetailsValue,
    ~overlayPaymentModal,
    ~setOverlayPaymentModal,
    ~isConfigureConnector,
    ~customBackButtonRoute="home",
  ) => {
    open HSwitchMerchantAccountUtils
    let hyperswitchMixPanel = HSMixPanel.useSendEvent()
    let url = RescriptReactRouter.useUrl()
    let urlHeaderName = url.path->LogicUtils.getListHead
    let filtersFromUrl = url.search->LogicUtils.getDictFromUrlSearchParams
    let (currency, setCurrency) = React.useState(() => "US,USD")
    let (isSDKOpen, setIsSDKOpen) = React.useState(_ => false)

    let businessProfiles = Recoil.useRecoilValueFromAtom(HyperswitchAtom.businessProfilesAtom)
    let defaultBusinessProfile = businessProfiles->getValueFromBusinessProfile
    let arrayOfBusinessProfile = businessProfiles->getArrayOfBusinessProfile

    let (profile, setProfile) = React.useState(_ => defaultBusinessProfile.profile_id)
    let (amount, setAmount) = React.useState(() => 10000)
    let isSmallDevice = MatchMedia.useMatchMedia("(max-width: 800px)")

    let dropDownOptions = countries->Js.Array2.map((item): SelectBox.dropdownOption => {
      {
        label: `${item.countryName} (${item.currency})`,
        value: `${item.isoAlpha2},${item.currency}`,
      }
    })

    let inputCurrency: ReactFinalForm.fieldRenderPropsInput = {
      name: `input`,
      onBlur: _ev => (),
      onChange: ev => {
        let value = ev->formEventToStr
        setCurrency(_ => value)
      },
      onFocus: _ev => (),
      value: {currency->Js.Json.string},
      checked: true,
    }

    let inputProfileId: ReactFinalForm.fieldRenderPropsInput = {
      name: `input`,
      onBlur: _ev => (),
      onChange: ev => {
        let value = ev->formEventToStr
        setProfile(_ => value)
      },
      onFocus: _ev => (),
      value: {profile->Js.Json.string},
      checked: true,
    }

    let inputProfileName: ReactFinalForm.fieldRenderPropsInput = {
      name: `input`,
      onBlur: _ev => (),
      onChange: ev => {
        let value = ev->formEventToStr
        setProfile(_ => value)
      },
      onFocus: _ev => (),
      value: {profile->Js.Json.string},
      checked: true,
    }

    let disableSelectionForProfile = arrayOfBusinessProfile->isDefaultBusinessProfile

    let rightHeadingComponent =
      <div className="m-10">
        <div className="flex flex-col md:flex-row items-start md:items-end gap-10">
          <div className="flex flex-col justify-start gap-5">
            <div className="flex items-center gap-10">
              <div className="font-medium text-base text-gray-500 dark:text-gray-300 w-32">
                {"Select Profile"->React.string}
              </div>
              <SelectBox
                options={arrayOfBusinessProfile->businessProfileNameDropDownOption}
                input=inputProfileName
                deselectDisable=true
                searchable=true
                buttonText="Profile Name"
                disableSelect={isSDKOpen || disableSelectionForProfile}
                customButtonStyle={isSmallDevice ? "!w-[50vw]" : "!w-[16vw]"}
                textStyle={isSmallDevice ? "w-[40vw]" : "w-[14vw]"}
                allowButtonTextMinWidth=false
                ellipsisOnly=true
              />
            </div>
            <div className="flex items-center gap-10">
              <div className="font-medium text-base text-gray-500 dark:text-gray-300 w-32">
                {"Select Profile Id"->React.string}
              </div>
              <SelectBox
                options={arrayOfBusinessProfile->businessProfileIdDropDownOption}
                input=inputProfileId
                deselectDisable=true
                searchable=true
                buttonText="Profile Id"
                disableSelect={isSDKOpen || disableSelectionForProfile}
                customButtonStyle={isSmallDevice ? "!w-[50vw]" : "!w-[16vw]"}
                textStyle={isSmallDevice ? "w-[40vw]" : "w-[14vw]"}
                allowButtonTextMinWidth=false
                ellipsisOnly=true
              />
            </div>
          </div>
          <div className="flex flex-col justify-start gap-5">
            <div className="flex items-center gap-10">
              <div className="font-medium text-base text-gray-500 dark:text-gray-300 w-32">
                {"Select Currency"->React.string}
              </div>
              <SelectBox
                options={dropDownOptions}
                input=inputCurrency
                deselectDisable=true
                searchable=true
                buttonText="United States (US)"
                disableSelect={isSDKOpen}
                customButtonStyle={isSmallDevice ? "!w-[50vw]" : "!w-[16vw]"}
                textStyle={isSmallDevice ? "w-[40vw]" : "w-[14vw]"}
                allowButtonTextMinWidth=false
                ellipsisOnly=true
              />
            </div>
            <div className="flex items-center gap-10">
              <div className="font-medium text-base text-gray-500 dark:text-gray-300 w-32">
                {"Enter amount"->React.string}
              </div>
              <InputText setAmount isSDKOpen />
            </div>
          </div>
          <Button
            text="Proceed"
            buttonType={Primary}
            buttonSize={Small}
            customButtonStyle="w-[70%]"
            buttonState={amount <= 0 || isSDKOpen ? Disabled : Normal}
            onClick={_ => {
              setIsSDKOpen(_ => true)
              hyperswitchMixPanel(
                ~pageName=url.path->LogicUtils.getListHead,
                ~contextName="sdk",
                ~actionName="proceed",
                (),
              )
            }}
          />
        </div>
      </div>

    React.useEffect1(() => {
      let paymentIntentOptional = filtersFromUrl->Js.Dict.get("payment_intent_client_secret")
      if paymentIntentOptional->Belt.Option.isSome {
        setOverlayPaymentModal(_ => true)
        setIsSDKOpen(_ => true)
      }
      None
    }, [filtersFromUrl])

    React.useEffect1(() => {
      if !overlayPaymentModal {
        setIsSDKOpen(_ => false)
      }
      None
    }, [overlayPaymentModal])

    <UIUtils.RenderIf condition={overlayPaymentModal}>
      <Modal
        modalHeading={isConfigureConnector ? "Explore Checkout" : "Interactive Demo"}
        modalHeadingDescription=""
        showCloseIcon={!isSmallDevice}
        modalParentHeadingClass="flex flex-row"
        headerAlignmentClass={isSmallDevice ? "flex-col" : "flex-row"}
        showBackIcon=true
        onBackClick={() => {
          setOverlayPaymentModal(_ => false)
          RescriptReactRouter.push(`/${customBackButtonRoute}`)
        }}
        rightHeading={isSDKOpen || isSmallDevice ? React.null : rightHeadingComponent}
        headingClass="!bg-transparent dark:!bg-jp-gray-lightgray_background border-b-2 border-jp-gray-940 border-opacity-75 dark:border-jp-gray-960 rounded-xl"
        headerTextClass="flex flex-col md:flex-row !text-2xl font-semibold justify-between h-fit border-b-2"
        showModal={overlayPaymentModal}
        customHeight="!h-full"
        childClass={`flex flex-col md:flex-row justify-center items-center ${isSmallDevice
            ? ""
            : "my-10"} w-full ${isSDKOpen ? isSmallDevice ? "" : "h-3/4" : "h-3/4"}`}
        closeOnOutsideClick=true
        setShowModal={setOverlayPaymentModal}
        onCloseClickCustomFun={_ => {
          if urlHeaderName->pathToVariantMapper === PAYMENTS {
            RescriptReactRouter.push("/payments")
            Window.Location.reload()
          } else {
            RescriptReactRouter.push("/home")
          }
        }}
        paddingClass="!p-0"
        modalClass="w-full h-full dark:!bg-jp-gray-lightgray_background overflow-scroll">
        <UIUtils.RenderIf condition={isSDKOpen}>
          <Payment
            isConfigureConnector
            setOnboardingModal={setIsSDKOpen}
            countryCurrency=currency
            profile_id=profile
            merchantDetailsValue
            amount
          />
        </UIUtils.RenderIf>
      </Modal>
    </UIUtils.RenderIf>
  }
}

module CheckoutCard = {
  @react.component
  let make = (~merchantDetailsValue) => {
    let url = RescriptReactRouter.useUrl()
    let fetchApi = AuthHooks.useApiFetcher()
    let showPopUp = PopUpState.useShowPopUp()
    let hyperswitchMixPanel = HSMixPanel.useSendEvent()
    let (_authStatus, setAuthStatus) = React.useContext(AuthInfoProvider.authStatusContext)
    let isPlayground = HSLocalStorage.getIsPlaygroundFromLocalStorage()
    let (overlayPaymentModal, setOverlayPaymentModal) = React.useState(_ => false)
    let isConfigureConnector = ListHooks.useListCount(~entityName=CONNECTOR) > 0
    let urlPath = url.path->Belt.List.toArray->Js.Array2.joinWith("_")

    let handleOnClick = _ => {
      if isPlayground {
        showPopUp({
          popUpType: (Warning, WithIcon),
          heading: "Sign Up to Access All Features!",
          description: {
            "To unlock the potential and experience the full range of capabilities, simply sign up today. Join our community of explorers and gain access to an enhanced world of possibilities"->React.string
          },
          handleConfirm: {
            text: "Sign up Now",
            onClick: {
              _ => {
                hyperswitchMixPanel(~eventName=Some(`${urlPath}_tryplayground_register`), ())
                hyperswitchMixPanel(~eventName=Some(`global_tryplayground_register`), ())
                let _res = APIUtils.handleLogout(~fetchApi, ~setAuthStatus)
              }
            },
          },
        })
      } else {
        hyperswitchMixPanel(
          ~pageName=url.path->LogicUtils.getListHead,
          ~contextName="sdk",
          ~actionName="tryitout",
          (),
        )
        setOverlayPaymentModal(_ => true)
      }
    }

    let (title, description) = isConfigureConnector
      ? (
          "Make a test payment - Try our unified checkout",
          "Test your connector be making a payment and visualise the user checkout experience",
        )
      : (
          "Demo our checkout experience",
          "Visualise the checkout experience by putting yourself in your user's shoes.",
        )

    <CardLayout width="w-full md:w-1/2">
      <CardHeader heading=title subHeading=description leftIcon=Some("checkout") />
      <img className="w-10/12 -mt-7 hidden md:block" src="/assets/sdk.svg" />
      <CardFooter customFooterStyle="!m-1 !mt-2">
        <Button
          text="Try it out" buttonType={Secondary} buttonSize={Small} onClick={handleOnClick}
        />
      </CardFooter>
      <SDKOverlay
        merchantDetailsValue overlayPaymentModal setOverlayPaymentModal isConfigureConnector
      />
    </CardLayout>
  }
}

module ControlCenter = {
  @react.component
  let make = () => {
    let url = RescriptReactRouter.useUrl()
    let hyperswitchMixPanel = HSMixPanel.useSendEvent()
    let merchantDetailsValue = useMerchantDetailsValue()
    let {testLiveMode} =
      HyperswitchAtom.featureFlagAtom
      ->Recoil.useRecoilValueFromAtom
      ->LogicUtils.safeParse
      ->FeatureFlagUtils.featureFlagType

    let pageName = url.path->getPageNameFromUrl

    let isLiveModeEnabledStyles = testLiveMode
      ? "flex flex-col md:flex-row gap-5 w-full"
      : "flex flex-col gap-5 md:w-1/2 w-full"

    <div className="flex flex-col gap-5 md:flex-row">
      <div className=isLiveModeEnabledStyles>
        <CardLayout width="w-full" customStyle={testLiveMode ? "" : "h-3/6"}>
          <CardHeader
            heading="Integrate a connector"
            subHeading="Give a headstart to the control centre by connecting with more than 20+ gateways, payment methods, and networks."
            leftIcon=Some("connector")
          />
          <img
            className="inline-block absolute right-5 bottom-5 hidden lg:block"
            src="/assets/connectorsList.svg"
          />
          <CardFooter>
            <Button
              text="+  Connect"
              buttonType={Secondary}
              buttonSize={Small}
              hswitchMixPanelPageName="home"
              hswitchMixPanelActionName="connector"
              hswitchMixPanelContextName="connect"
              onClick={_ => {
                trackRedictMixPanelEvents(
                  ~pageName,
                  ~destination="connectors",
                  ~hyperswitchMixPanel,
                  (),
                )
                RescriptReactRouter.push("/connectors")
              }}
            />
          </CardFooter>
        </CardLayout>
        <CardLayout width="w-full" customStyle={testLiveMode ? "" : "h-4/6"}>
          <CardHeader
            heading="Credentials and Keys"
            subHeading="Your secret credentials to start integrating hyperswitch."
            leftIcon=Some("merchantInfo")
            customSubHeadingStyle="w-full max-w-none"
          />
          <MerchantAuthInfo merchantDetailsValue />
          <CardFooter>
            <Button
              text="Go to API keys"
              buttonType={Secondary}
              buttonSize={Small}
              hswitchMixPanelPageName="home"
              hswitchMixPanelActionName="apikey"
              hswitchMixPanelContextName="goto"
              onClick={_ => {
                trackRedictMixPanelEvents(
                  ~pageName,
                  ~destination="developers_api_keys",
                  ~hyperswitchMixPanel,
                  (),
                )
                RescriptReactRouter.push("/developer-api-keys")
              }}
            />
          </CardFooter>
        </CardLayout>
      </div>
      <UIUtils.RenderIf condition={!testLiveMode}>
        <CheckoutCard merchantDetailsValue />
      </UIUtils.RenderIf>
    </div>
  }
}

module DevResources = {
  @react.component
  let make = () => {
    let hyperswitchMixPanel = HSMixPanel.useSendEvent()
    let url = RescriptReactRouter.useUrl()
    let pageName = url.path->getPageNameFromUrl

    <div className="mb-5">
      <PageHeading
        title="Developer resources"
        subTitle="Couple of things developers need in handy can be found right here."
      />
      <div className="flex flex-col md:flex-row gap-5">
        <CardLayout width="w-full">
          <CardHeader
            heading="Developer docs"
            subHeading="Everything you need to know to get the SDK up and running resides in here."
            leftIcon=Some("docs")
          />
          <CardFooter customFooterStyle="mt-5">
            <Button
              text="Visit"
              buttonType={Secondary}
              buttonSize={Small}
              onClick={_ => {
                trackRedictMixPanelEvents(
                  ~pageName,
                  ~destination="docs",
                  ~redirectType="external",
                  ~hyperswitchMixPanel,
                  (),
                )
                "https://hyperswitch.io/docs"->Window._open
              }}
            />
          </CardFooter>
        </CardLayout>
        <CardLayout width="w-full">
          <CardHeader
            heading="Contribute in open source"
            subHeading="We welcome all your suggestions, feedbacks, and queries. Hop on to the Open source rail!."
            leftIcon=Some("contribution")
          />
          <CardFooter customFooterStyle="mt-5">
            <Button
              text="Contribute"
              buttonType={Secondary}
              buttonSize={Small}
              onClick={_ => {
                trackRedictMixPanelEvents(
                  ~pageName,
                  ~destination="github",
                  ~redirectType="external",
                  ~hyperswitchMixPanel,
                  (),
                )
                "https://github.com/juspay/hyperswitch"->Window._open
              }}
            />
          </CardFooter>
        </CardLayout>
        <CardLayout width="w-full">
          <CardHeader
            heading="Product and tech blog"
            subHeading="Learn about payments, payment orchestration and all the tech behind it."
            leftIcon=Some("blogs")
          />
          <CardFooter>
            <Button
              text="Explore"
              buttonType={Secondary}
              buttonSize={Small}
              onClick={_ => {
                trackRedictMixPanelEvents(
                  ~pageName,
                  ~destination="blog",
                  ~redirectType="external",
                  ~hyperswitchMixPanel,
                  (),
                )
                "https://hyperswitch.io/blog"->Window._open
              }}
            />
          </CardFooter>
        </CardLayout>
      </div>
    </div>
  }
}

let getGreeting = () => {
  let dateTime = Js.Date.now()
  let hours = Js.Date.fromFloat(dateTime)->Js.Date.getHours->Belt.Int.fromFloat

  if hours < 12 {
    "Good morning"
  } else if hours < 18 {
    "Good afternoon"
  } else {
    "Good evening"
  }
}

let homepageStepperItems = ["Configure control center", "Integrate into your app", "Go Live"]

let getValueMapped = (value, key) => {
  open LogicUtils
  let keyVariant = key->QuickStartUtils.stringToVariantMapperForUserData
  switch keyVariant {
  | #ProductionAgreement
  | #IntegrationCompleted
  | #SPTestPayment
  | #DownloadWoocom
  | #ConfigureWoocom
  | #SetupWoocomWebhook =>
    value->getBool(key, false)->Js.Json.boolean
  | #FirstProcessorConnected
  | #SecondProcessorConnected
  | #StripeConnected
  | #PaypalConnected
  | #IsMultipleConfiguration
  | #IntegrationMethod =>
    value->getJsonObjectFromDict(key)
  | #TestPayment => value->getJsonObjectFromDict(key)
  | #ConfiguredRouting | #SPRoutingConfigured => value->getJsonObjectFromDict(key)
  }
}

let responseDataMapper = (res: Js.Json.t) => {
  open LogicUtils
  let arrayFromJson = res->getArrayFromJson([])
  let resDict = Js.Dict.empty()

  let _a = arrayFromJson->Js.Array2.map(value => {
    let value1 = value->getDictFromJsonObject
    let key = value1->Js.Dict.keys->Belt.Array.get(0)->Belt.Option.getWithDefault("")
    resDict->Js.Dict.set(key, value1->getValueMapped(key))
  })
  resDict
}
