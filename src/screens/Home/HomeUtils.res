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

let isDefaultBusinessProfile = details => details->Array.length === 1

module MerchantAuthInfo = {
  @react.component
  let make = () => {
    let merchantDetailsValue = MerchantDetailsHook.useMerchantDetailsValue()
    let dataDict =
      [
        ("merchant_id", merchantDetailsValue.merchant_id->JSON.Encode.string),
        ("publishable_key", merchantDetailsValue.publishable_key->JSON.Encode.string),
      ]->Dict.fromArray

    <Form initialValues={dataDict->JSON.Encode.object} formClass="my-4">
      <div className="flex flex-col gap-1">
        <div className="font-semibold text-dark_black md:text-base text-sm">
          {"Merchant ID"->React.string}
        </div>
        <div className="flex items-center">
          <div className="font-medium text-dark_black opacity-40" style={overflowWrap: "anywhere"}>
            {merchantDetailsValue.merchant_id->React.string}
          </div>
          <CopyFieldValue fieldkey="merchant_id" />
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
          "Test your connector by making a payment and visualize the how user checkout experience",
        )

    <CardLayout width="" customStyle="flex flex-col  justify-center rounded-xl p-6 ">
      <div className="flex flex-col 2xl:w-38-rem gap-4  ">
        <img alt="sdk" src="/assets/SDK.png" />
        <CardHeader heading=title subHeading=description />
        <CardFooter customFooterStyle="!ml-1 ">
          <ACLButton
            text="Try It Out"
            authorization={hasAllGroupsAccess([
              userHasAccess(~groupAccess=OperationsManage),
              userHasAccess(~groupAccess=ConnectorsManage),
            ])}
            buttonType={Primary}
            buttonSize={Medium}
            onClick={handleOnClick}
          />
        </CardFooter>
      </div>
    </CardLayout>
  }
}

module ControlCenter = {
  @react.component
  let make = () => {
    let {isLiveMode} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
    let liveModeStyles = isLiveMode
      ? "w-1/2 2xl:w-full"
      : "flex flex-col md:flex-row  gap-5 w-3/4 lg:w-full"
    <div className=liveModeStyles>
      <CardLayout width="" customStyle={isLiveMode ? "" : " rounded-xl p-6 "}>
        <div className="flex flex-col 2xl:w-38-rem gap-4">
          <img alt="sdk" src="/assets/IntegrateProcessorsOver.png" className=" w-1/2 lg:w-fit" />
          <CardHeader
            heading="Integrate a Processor"
            subHeading="Give a headstart by connecting with more than 20+ gateways, payment methods, and networks."
            customSubHeadingStyle="w-full max-w-none"
          />
          <Button
            text="Connect Processors"
            buttonType={Primary}
            buttonSize={Medium}
            onClick={_ => {
              RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url="/connectors"))
            }}
          />
        </div>
      </CardLayout>
      <RenderIf condition={!isLiveMode}>
        <CheckoutCard />
      </RenderIf>
    </div>
  }
}
module DevResources = {
  @react.component
  let make = () => {
    let {isLiveMode} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
    let {checkUserEntity} = React.useContext(UserInfoProvider.defaultContext)
    let mixpanelEvent = MixpanelHook.useSendEvent()
    <div className="flex flex-col mb-5 gap-6 ">
      <PageHeading
        title="Developer resources"
        subTitle="Couple of things developers need in handy can be found right here."
        customHeadingStyle="test-fs-20 font-semibold"
        customSubTitleStyle="text-fs-16 text-nd_gray-400 !opacity-100 font-medium"
      />
      <div className="flex flex-col md:flex-row  gap-5 ">
        <RenderIf condition={!checkUserEntity([#Profile])}>
          <CardLayout width=" " customStyle={isLiveMode ? "" : "h-3/6 rounded-xl"}>
            <div className="flex flex-col w-28-rem 2xl:w-38-rem">
              <CardHeader
                heading="Credentials and Keys"
                subHeading="Your secret credentials to start integrating"
                customSubHeadingStyle="w-full max-w-none"
              />
              <MerchantAuthInfo />
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
            </div>
          </CardLayout>
        </RenderIf>
        <CardLayout width=" " customStyle="rounded-xl">
          <div className="flex flex-col 2xl:w-38-rem gap-4">
            <CardHeader
              heading="Developer docs"
              subHeading="Everything you need to know to get the SDK up and running resides in here."
              customHeadingStyle="!text-fs-18 !font-semibold"
              customSubHeadingStyle="!text-fs-14 !text-nd_gray-400 !opacity-100"
            />
            <img alt="devdocs" src="/assets/DevDocs.png" className="w-3/4 2xl:w-fit" />
            <Button
              text="Visit"
              buttonType={Secondary}
              buttonSize={Medium}
              customButtonStyle="mt-7 2xl:mt-0"
              onClick={_ => {
                mixpanelEvent(~eventName=`dev_docs`)
                "https://hyperswitch.io/docs"->Window._open
              }}
            />
          </div>
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
