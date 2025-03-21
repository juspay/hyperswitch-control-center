open CardUtils
open PageUtils
open HSwitchUtils

let headingStyle = `${getTextClass((P2, Medium))} text-grey-700 uppercase opacity-50 px-2`
let paragraphTextVariant = `${getTextClass((P2, Medium))} text-grey-700 opacity-50`
let subtextStyle = `${getTextClass((P1, Regular))} text-grey-700 opacity-50`
let cardHeaderText = getTextClass((H3, Leading_2))
let hoverStyle = "cursor-pointer group-hover:shadow hover:shadow-homePageBoxShadow group"
let boxCssHover = (~ishoverStyleRequired) =>
  `flex flex-col  bg-white border rounded-md pt-10 pl-10 gap-2 h-12.5-rem ${ishoverStyleRequired
      ? hoverStyle
      : ""}`
let boxCss = "flex flex-col bg-white border rounded-md gap-4 p-7"
let imageTransitionCss = "opacity-50 group-hover:opacity-100 transition ease-in-out duration-300"
let cardHeaderTextStyle = `${cardHeaderText} text-grey-700`

type resourcesTypes = {
  icon: string,
  headerText: string,
  subText: string,
  redirectLink: string,
  id: string,
  access: CommonAuthTypes.authorization,
}

let countries: array<ReactHyperJs.country> = [
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
  let make = () => {
    let merchantDetailsValue = useMerchantDetailsValue()
    let dataDict =
      [
        ("merchant_id", merchantDetailsValue.merchant_id->JSON.Encode.string),
        ("publishable_key", merchantDetailsValue.publishable_key->JSON.Encode.string),
      ]->Dict.fromArray

    <Form initialValues={dataDict->JSON.Encode.object} formClass="md:ml-9 my-4">
      <div className="flex flex-col lg:flex-row gap-3">
        <div>
          <div className="font-semibold text-dark_black md:text-base text-sm">
            {"Merchant ID"->React.string}
          </div>
          <div className="flex items-center">
            <div
              className="font-medium text-dark_black opacity-40" style={overflowWrap: "anywhere"}>
              {merchantDetailsValue.merchant_id->React.string}
            </div>
            <CopyFieldValue fieldkey="merchant_id" />
          </div>
        </div>
        <div>
          <div className="font-semibold text-dark_black md:text-base text-sm">
            {"Publishable Key"->React.string}
          </div>
          <div className="flex items-center">
            <div
              className="font-medium text-dark_black opacity-40" style={overflowWrap: "anywhere"}>
              {merchantDetailsValue.publishable_key->React.string}
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
    let showPopUp = PopUpState.useShowPopUp()
    let mixpanelEvent = MixpanelHook.useSendEvent()
    let handleLogout = APIUtils.useHandleLogout()
    let {userHasAccess, hasAllGroupsAccess} = GroupACLHooks.useUserGroupACLHook()
    let isPlayground = HSLocalStorage.getIsPlaygroundFromLocalStorage()

    let connectorList = ConnectorInterface.useConnectorArrayMapper(
      ~interface=ConnectorInterface.connectorInterfaceV1,
    )

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
              _ => handleLogout()->ignore
            },
          },
        })
      } else {
        mixpanelEvent(~eventName=`try_test_payment`)
        RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url="/sdk"))
      }
    }

    let (title, description) = isConfigureConnector
      ? (
          "Make a test payment - Try our unified checkout",
          "Test your connector by making a payment and visualise the user checkout experience",
        )
      : (
          "Demo our checkout experience",
          "Visualise the checkout experience by putting yourself in your user's shoes.",
        )

    <CardLayout width="w-full md:w-1/2">
      <CardHeader heading=title subHeading=description leftIcon=Some("checkout") />
      <img alt="sdk" className="w-10/12 -mt-7 hidden md:block" src="/assets/sdk.svg" />
      <CardFooter customFooterStyle="!m-1 !mt-2">
        <ACLButton
          text="Try it out"
          authorization={hasAllGroupsAccess([
            userHasAccess(~groupAccess=OperationsManage),
            userHasAccess(~groupAccess=ConnectorsManage),
          ])}
          buttonType={Secondary}
          buttonSize={Medium}
          onClick={handleOnClick}
        />
      </CardFooter>
    </CardLayout>
  }
}

module ControlCenter = {
  @react.component
  let make = () => {
    let {isLiveMode} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
    let {checkUserEntity} = React.useContext(UserInfoProvider.defaultContext)
    let mixpanelEvent = MixpanelHook.useSendEvent()

    let isLiveModeEnabledStyles = isLiveMode
      ? "flex flex-col md:flex-row gap-5 w-full"
      : "flex flex-col gap-5 md:w-1/2 w-full"

    <div className="flex flex-col gap-5 md:flex-row">
      <RenderIf condition={!isLiveMode}>
        <CheckoutCard />
      </RenderIf>
      <div className=isLiveModeEnabledStyles>
        <CardLayout width="w-full" customStyle={isLiveMode ? "" : "h-4/6"}>
          <CardHeader
            heading="Integrate a connector"
            subHeading="Give a headstart to the control centre by connecting with more than 20+ gateways, payment methods, and networks."
            leftIcon=Some("connector")
          />
          <CardFooter customFooterStyle="mt-5">
            <Button
              text="+  Connect"
              buttonType={Secondary}
              buttonSize={Medium}
              onClick={_ => {
                RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url="/connectors"))
              }}
            />
            <img
              alt="connector-list"
              className="inline-block absolute bottom-0 right-0 lg:block lg:w-40 md:w-24 w-24"
              src="/assets/connectorsList.svg"
            />
          </CardFooter>
        </CardLayout>
        <RenderIf condition={!checkUserEntity([#Profile])}>
          <CardLayout width="w-full" customStyle={isLiveMode ? "" : "h-3/6"}>
            <CardHeader
              heading="Credentials and Keys"
              subHeading="Your secret credentials to start integrating"
              leftIcon=Some("merchantInfo")
              customSubHeadingStyle="w-full max-w-none"
            />
            <MerchantAuthInfo />
            <CardFooter customFooterStyle="lg:-mt-0 lg:mb-12">
              <Button
                text="Go to API keys"
                buttonType={Secondary}
                buttonSize={Medium}
                onClick={_ => {
                  mixpanelEvent(~eventName="redirect_to_api_keys")
                  RescriptReactRouter.push(
                    GlobalVars.appendDashboardPath(~url="/developer-api-keys"),
                  )
                }}
              />
            </CardFooter>
          </CardLayout>
        </RenderIf>
      </div>
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
              buttonSize={Medium}
              onClick={_ => {
                mixpanelEvent(~eventName=`dev_docs`)
                "https://hyperswitch.io/docs"->Window._open
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
          <CardFooter customFooterStyle="mt-5">
            <Button
              text="Explore"
              buttonType={Secondary}
              buttonSize={Medium}
              onClick={_ => {
                mixpanelEvent(~eventName=`dev_tech_blog`)
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
  let dateTime = Date.now()
  let hours = Js.Date.fromFloat(dateTime)->Js.Date.getHours->Int.fromFloat

  if hours < 12 {
    "Good morning"
  } else if hours < 18 {
    "Good afternoon"
  } else {
    "Good evening"
  }
}

let homepageStepperItems = ["Configure control center", "Integrate into your app", "Go Live"]

let responseDataMapper = (res: JSON.t, mapper: (Dict.t<JSON.t>, string) => JSON.t) => {
  open LogicUtils
  let arrayFromJson = res->getArrayFromJson([])
  let resDict = Dict.make()

  arrayFromJson->Array.forEach(value => {
    let value1 = value->getDictFromJsonObject
    let key = value1->Dict.keysToArray->Array.get(0)->Option.getOr("")
    resDict->Dict.set(key, value1->mapper(key))
  })
  resDict
}

module LowRecoveryCodeBanner = {
  @react.component
  let make = (~recoveryCode) => {
    <HSwitchUtils.AlertBanner
      bannerText={`You are low on recovery-codes. Only ${recoveryCode->Int.toString} left.`}
      bannerType=Warning>
      <Button
        text="Regenerate recovery-codes"
        buttonType={Secondary}
        onClick={_ =>
          RescriptReactRouter.push(
            GlobalVars.appendDashboardPath(~url=`/account-settings/profile`),
          )}
      />
    </HSwitchUtils.AlertBanner>
  }
}
