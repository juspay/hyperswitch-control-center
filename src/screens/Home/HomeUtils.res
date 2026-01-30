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
  open Typography
  @react.component
  let make = () => {
    let showToast = ToastState.useShowToast()
    let handleCopy = copyValue => {
      Clipboard.writeText(copyValue)
      showToast(~message="Copied to Clipboard!", ~toastType=ToastSuccess)
    }
    let merchantDetailsValue = MerchantDetailsHook.useMerchantDetailsValue()

    <div className="flex flex-col gap-2">
      <div className="flex flex-col gap-2">
        <div className={`${body.md.medium} text-nd_gray-400`}> {"Merchant ID"->React.string} </div>
        <div className="flex items-center gap-2">
          <div className={`${body.lg.medium} text-nd_gray-600`} style={overflowWrap: "anywhere"}>
            {merchantDetailsValue.merchant_id->React.string}
          </div>
          <div onClick={_ => handleCopy(merchantDetailsValue.merchant_id)}>
            <Icon name="nd-copy" size=16 />
          </div>
        </div>
      </div>
      <div className="flex flex-col gap-2">
        <div className={`${body.md.medium} text-nd_gray-400`}>
          {"Publishable Key"->React.string}
        </div>
        <div className="flex items-center gap-2">
          <div className={`${body.lg.medium} text-nd_gray-600`} style={overflowWrap: "anywhere"}>
            {merchantDetailsValue.publishable_key->React.string}
          </div>
          <div onClick={_ => handleCopy(merchantDetailsValue.publishable_key)}>
            <Icon name="nd-copy" size=16 />
          </div>
        </div>
      </div>
    </div>
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

    let connectorList = ConnectorListInterface.useFilteredConnectorList()

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
        RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url="/sdk"))
      }
    }

    let (title, description) = isConfigureConnector
      ? (
          "Make a test payment - Try our unified checkout",
          "Test your payment connector by initiating a transaction and visualise the user checkout experience",
        )
      : (
          "Demo our checkout experience",
          "Test your payment connector by initiating a transaction and visualize the user checkout experience",
        )

    <CardLayout width="" customStyle="flex-1 rounded-xl p-6 gap-4">
      <div className="flex flex-col gap-4 ">
        <img alt="sdk" src="/assets/SDK.png" />
        <CardHeader heading=title subHeading=description />
      </div>
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
    </CardLayout>
  }
}

module ControlCenter = {
  @react.component
  let make = () => {
    let {isLiveMode} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
    let liveModeStyles = isLiveMode ? "w-1/2 " : "flex flex-col md:flex-row gap-5 "
    <div className=liveModeStyles>
      <CardLayout width="" customStyle="flex-1 rounded-xl p-6 gap-4">
        <div className="flex flex-col gap-4">
          <img alt="sdk" src="/assets/IntegrateProcessorsOver.png" />
          <CardHeader
            heading="Integrate a Processor"
            subHeading="Give a headstart by connecting with more than 20+ gateways, payment methods, and networks."
          />
        </div>
        <Button
          text="Connect Processors"
          buttonType={Primary}
          buttonSize={Medium}
          onClick={_ => {
            RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url="/connectors"))
          }}
        />
      </CardLayout>
      <RenderIf condition={!isLiveMode}>
        <CheckoutCard />
      </RenderIf>
    </div>
  }
}
module PlatformOverview = {
  @react.component
  let make = () => {
    <div className="flex flex-col md:flex-row gap-5 w-1/2">
      <CardLayout width="" customStyle="flex-1 rounded-xl p-6 gap-4">
        <div className="flex flex-col gap-4">
          <img alt="sdk" src="/assets/IntegrateProcessorsOver.png" />
          <CardHeader
            heading="Platform Merchant Account"
            subHeading="Platform merchant can create API keys for connected merchants and act on their behalf. This enables you to initiate and manage payments seamlessly for all connected accounts."
          />
        </div>
      </CardLayout>
    </div>
  }
}
module DevResources = {
  open Typography
  @react.component
  let make = () => {
    let {checkUserEntity} = React.useContext(UserInfoProvider.defaultContext)
    let mixpanelEvent = MixpanelHook.useSendEvent()
    <div className="flex flex-col mb-5 gap-6 ">
      <PageHeading
        title="Developer resources"
        subTitle="Couple of things developers need in handy can be found right here."
        customTitleStyle={`!${heading.md.semibold}`}
        customSubTitleStyle="!text-fs-16 !text-nd_gray-400 !opacity-100 font-medium !mt-1"
        showPermLink=false
      />
      <div className="flex flex-col md:flex-row  gap-5 ">
        <RenderIf condition={!checkUserEntity([#Profile])}>
          <CardLayout width="" customStyle={"flex-1 rounded-xl p-6 gap-6"}>
            <div className="flex flex-col gap-7 ">
              <CardHeader
                heading="Credentials and Keys"
                subHeading="Your secret credentials to start integrating"
                customHeadingStyle={`!${heading.sm.semibold}`}
                customSubHeadingStyle="!text-fs-14 !text-nd_gray-400 !opacity-100 !-mt-0.5"
              />
              <MerchantAuthInfo />
            </div>
            <Button
              text="Go to API keys"
              buttonType={Secondary}
              buttonSize={Medium}
              onClick={_ => {
                mixpanelEvent(~eventName="redirect_to_api_keys")
                RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url="/developer-api-keys"))
              }}
            />
          </CardLayout>
        </RenderIf>
        <CardLayout width="" customStyle="flex-1 rounded-xl p-6 gap-4">
          <div className="flex flex-col gap-4 ">
            <CardHeader
              heading="Developer docs"
              subHeading="Everything you need to know to get the SDK up and running resides in here."
              customHeadingStyle={`!${heading.sm.semibold}`}
              customSubHeadingStyle="!text-fs-14 !text-nd_gray-400 !opacity-100 !-mt-0.5"
            />
            <img alt="devdocs" src="/assets/DevDocs.png" />
          </div>
          <Button
            text="Visit"
            buttonType={Secondary}
            buttonSize={Medium}
            onClick={_ => {
              mixpanelEvent(~eventName=`dev_docs`)
              "https://hyperswitch.io/docs"->Window._open
            }}
          />
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
      bannerContent={<p>
        {`You are low on recovery-codes. Only ${recoveryCode->Int.toString} left.`->React.string}
      </p>}
      bannerType=Warning
      customRightAction={<Button
        text="Regenerate recovery-codes"
        buttonType={Secondary}
        onClick={_ =>
          RescriptReactRouter.push(
            GlobalVars.appendDashboardPath(~url=`/account-settings/profile`),
          )}
      />}
    />
  }
}
