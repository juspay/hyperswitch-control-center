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
let boxCssHover = (~ishoverStyleRequired, ()) =>
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

let isDefaultBusinessProfile = details => details->Array.length === 1

module MerchantAuthInfo = {
  @react.component
  let make = (~merchantDetailsValue) => {
    let detail = merchantDetailsValue->MerchantAccountUtils.getMerchantDetails
    let dataDict =
      [
        ("merchant_id", detail.merchant_id->Js.Json.string),
        ("publishable_key", detail.publishable_key->Js.Json.string),
      ]->Dict.fromArray

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

module CheckoutCard = {
  @react.component
  let make = () => {
    let fetchApi = AuthHooks.useApiFetcher()
    let showPopUp = PopUpState.useShowPopUp()
    let mixpanelEvent = MixpanelHook.useSendEvent()
    let (_authStatus, setAuthStatus) = React.useContext(AuthInfoProvider.authStatusContext)
    let {setIsSidebarExpanded} = React.useContext(SidebarProvider.defaultContext)
    let isPlayground = HSLocalStorage.getIsPlaygroundFromLocalStorage()
    let connectorList =
      HyperswitchAtom.connectorListAtom
      ->Recoil.useRecoilValueFromAtom
      ->LogicUtils.safeParse
      ->LogicUtils.getObjectArrayFromJson
    let isConfigureConnector = connectorList->Array.length > 0

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
                let _ = APIUtils.handleLogout(~fetchApi, ~setAuthStatus, ~setIsSidebarExpanded)
              }
            },
          },
        })
      } else {
        mixpanelEvent(~eventName=`try_test_payment`, ())
        RescriptReactRouter.replace("/sdk")
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
    </CardLayout>
  }
}

module ControlCenter = {
  @react.component
  let make = () => {
    let merchantDetailsValue = useMerchantDetailsValue()
    let {isLiveMode} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

    let isLiveModeEnabledStyles = isLiveMode
      ? "flex flex-col md:flex-row gap-5 w-full"
      : "flex flex-col gap-5 md:w-1/2 w-full"

    <div className="flex flex-col gap-5 md:flex-row">
      <div className=isLiveModeEnabledStyles>
        <CardLayout width="w-full" customStyle={isLiveMode ? "" : "h-3/6"}>
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
              onClick={_ => {
                RescriptReactRouter.push("/connectors")
              }}
            />
          </CardFooter>
        </CardLayout>
        <CardLayout width="w-full" customStyle={isLiveMode ? "" : "h-4/6"}>
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
              onClick={_ => {
                RescriptReactRouter.push("/developer-api-keys")
              }}
            />
          </CardFooter>
        </CardLayout>
      </div>
      <UIUtils.RenderIf condition={!isLiveMode}>
        <CheckoutCard />
      </UIUtils.RenderIf>
    </div>
  }
}

module DevResources = {
  @react.component
  let make = () => {
    let mixpanelEvent = MixpanelHook.useSendEvent()
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
                mixpanelEvent(~eventName=`dev_docs`, ())
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
                mixpanelEvent(~eventName=`contribute_in_open_source`, ())
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
  | #ConfigurationType => value->getString(key, "")->Js.Json.string
  | #FirstProcessorConnected
  | #SecondProcessorConnected
  | #StripeConnected
  | #PaypalConnected
  | #IntegrationMethod =>
    value->getJsonObjectFromDict(key)
  | #TestPayment => value->getJsonObjectFromDict(key)
  | #ConfiguredRouting | #SPRoutingConfigured => value->getJsonObjectFromDict(key)
  }
}

let responseDataMapper = (res: Js.Json.t) => {
  open LogicUtils
  let arrayFromJson = res->getArrayFromJson([])
  let resDict = Dict.make()

  arrayFromJson->Array.forEach(value => {
    let value1 = value->getDictFromJsonObject
    let key = value1->Dict.keysToArray->Belt.Array.get(0)->Belt.Option.getWithDefault("")
    resDict->Dict.set(key, value1->getValueMapped(key))
  })
  resDict
}
