open LogicUtils
open HSLocalStorage
open HyperswitchAtom

type browserDetailsObject = {
  userAgent: string,
  browserVersion: string,
  platform: string,
  browserName: string,
  browserLanguage: string,
  screenHeight: string,
  screenWidth: string,
  timeZoneOffset: string,
  clientCountry: Country.timezoneType,
}

let feedbackModalOpenCountForConnectors = 4

external objToJson: {..} => Js.Json.t = "%identity"
let errorClass = "text-sm leading-4 font-medium text-start ml-1 mt-2"

type pageLevelVariant =
  | HOME
  | PAYMENTS
  | REFUNDS
  | DISPUTES
  | CONNECTOR
  | ROUTING
  | ANALYTICS_PAYMENTS
  | ANALYTICS_REFUNDS
  | SETTINGS
  | DEVELOPERS
module TextFieldRow = {
  @react.component
  let make = (~label, ~children, ~isRequired=true, ~labelWidth="w-72") => {
    <div className="flex mt-5">
      <div
        className={`mt-2 ${labelWidth} text-gray-900/50 dark:text-jp-gray-text_darktheme dark:text-opacity-50 font-semibold text-fs-14`}>
        {label->React.string}
        {if isRequired {
          <span className="text-red-500"> {"*"->React.string} </span>
        } else {
          React.null
        }}
      </div>
      children
    </div>
  }
}

let setMerchantDetails = (key, value) => {
  let localStorageData = getInfoFromLocalStorage(~lStorageKey="merchant")
  localStorageData->Js.Dict.set(key, value)

  "merchant"->LocalStorage.setItem(
    localStorageData->Js.Json.stringifyAny->Belt.Option.getWithDefault(""),
  )
}

// TODO : Remove once user-management flow introduces
let setUserDetails = (key, value) => {
  let localStorageData = getInfoFromLocalStorage(~lStorageKey="user")
  localStorageData->Js.Dict.set(key, value)
  "user"->LocalStorage.setItem(
    localStorageData->Js.Json.stringifyAny->Belt.Option.getWithDefault(""),
  )
}
let getSearchOptionsForProcessors = (~processorList, ~getNameFromString) => {
  let searchOptionsForProcessors =
    processorList->Js.Array2.map(item => (
      `Connect ${item->getNameFromString->capitalizeString}`,
      `/new?name=${item->getNameFromString}`,
    ))
  searchOptionsForProcessors
}

module ConnectorCustomCell = {
  @react.component
  let make = (~connectorName) => {
    let size = switch connectorName->ConnectorUtils.getConnectorNameTypeFromString {
    | PHONYPAY | PRETENDPAY | FAUXPAY => "w-5 h-5"
    | _ => "w-7 h-7"
    }

    if connectorName->Js.String2.length > 0 {
      <div className="flex items-center flex-wrap break-all">
        <GatewayIcon gateway={connectorName->Js.String2.toUpperCase} className={`${size} mr-1`} />
        <div className="capitalize"> {connectorName->React.string} </div>
      </div>
    } else {
      "NA"->React.string
    }
  }
}
module HelpDeskSection = {
  @react.component
  let make = (~helpdeskModal, ~setHelpdeskModal) => {
    let hyperswitchMixPanel = HSMixPanel.useSendEvent()
    let url = RescriptReactRouter.useUrl()
    let textStyle = "font-medium text-fs-14"
    let {setShowFeedbackModal} = React.useContext(GlobalProvider.defaultContext)
    let handleMixpanelEvents = eventName => {
      [url.path->LogicUtils.getListHead, `global`]->Js.Array2.forEach(ele =>
        hyperswitchMixPanel(~pageName=ele, ~contextName="helpdesk", ~actionName=eventName, ())
      )
    }
    let handleFeedbackClicked = _ => {
      setShowFeedbackModal(_ => true)
      "submitfeedback"->handleMixpanelEvents
    }

    let hoverEffectStyle = "flex gap-3 cursor-pointer hover:border hover:border-blue-700 hover:rounded-md hover:!shadow-[0_0_4px_2px_rgba(0,_112,_255,_0.15)] p-3 border border-transparent"
    <>
      <UIUtils.RenderIf condition={helpdeskModal}>
        <FramerMotion.Motion.Div
          initial={{scale: 0.0}}
          animate={{scale: 1.0}}
          exit={{scale: 0.0}}
          transition={{duration: 0.3}}
          style={transformOrigin: "top"}
          className="absolute top-14 right-0 bg-white p-4 border shadow-[-22px_-8px_41px_-15px_rgba(0,0,0,_0.25)] w-60 flex flex-col gap-2.5 z-10 rounded-md">
          <div className=hoverEffectStyle onClick={_ => handleFeedbackClicked()}>
            <Icon name="feedback" size=16 />
            <p className=textStyle> {"Submit feedback"->React.string} </p>
          </div>
          <div
            className=hoverEffectStyle
            onClick={_ => {
              "contactonslack"->handleMixpanelEvents
              Window._open("https://hyperswitch-io.slack.com/ssb/redirect")
            }}>
            <Icon size=16 name="slack" />
            <p className=textStyle> {"Connect on Slack"->React.string} </p>
          </div>
          <div
            className=hoverEffectStyle
            onClick={_ => {
              "joindiscord"->handleMixpanelEvents
              Window._open("https://discord.gg/an7gRdWkhw")
            }}>
            <Icon size=16 name="discord" />
            <p className=textStyle> {"Join Discord"->React.string} </p>
          </div>
        </FramerMotion.Motion.Div>
      </UIUtils.RenderIf>
      <Icon
        className="cursor-pointer ml-auto"
        name="help-desk"
        size=30
        onClick={ev => {
          open ReactEvent.Mouse
          ev->stopPropagation
          setHelpdeskModal(prevValue => {
            let globalEventText = !prevValue ? "global_helpdesk_open" : "global_helpdesk_close"
            let localEventText = !prevValue ? "helpdesk_open" : "helpdesk_close"
            let currentPath = url.path->LogicUtils.getListHead

            [`${currentPath}_${localEventText}`, globalEventText]->Js.Array2.forEach(ele =>
              hyperswitchMixPanel(~eventName=Some(ele), ())
            )
            !prevValue
          })
        }}
      />
    </>
  }
}

let pathToVariantMapper = routeName => {
  switch routeName {
  | "home" => HOME
  | "payments" => PAYMENTS
  | "refunds" => REFUNDS
  | "disputes" => DISPUTES
  | "connectors" => CONNECTOR
  | "routing" => ROUTING
  | "analytics-payments" => ANALYTICS_PAYMENTS
  | "analytics-refunds" => ANALYTICS_REFUNDS
  | "settings" => SETTINGS
  | "developers" => DEVELOPERS
  | _ => HOME
  }
}

let isValidEmail = value =>
  !Js.Re.test_(
    %re(`/^(([^<>()[\]\.,;:\s@"]+(\.[^<>()[\]\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/`),
    value,
  )

let isUserJourneyAnalyticsAccessAvailable = email => email->Js.String2.includes("juspay")

let convertJsonArrayToArrayOfString = (. val) => {
  val
  ->Js.Json.decodeArray
  ->Belt.Option.getWithDefault([])
  ->Js.Array2.map(ele => ele->Js.Json.decodeString->Belt.Option.getWithDefault(""))
}

let useMerchantDetailsValue = () =>
  Recoil.useRecoilValueFromAtom(merchantDetailsValueAtom)->safeParse

let getClientCountry = clientTimeZone => {
  Country.country
  ->Js.Array2.find(item =>
    item.timeZones->Js.Array2.find(i => i == clientTimeZone)->Belt.Option.isSome
  )
  ->Belt.Option.getWithDefault(Country.defaultTimeZone)
}

let getBrowswerDetails = () => {
  open Window
  open Window.Navigator
  open Window.Screen
  let clientTimeZone = dateTimeFormat(.).resolvedOptions(.).timeZone
  let clientCountry = clientTimeZone->getClientCountry
  {
    userAgent,
    browserVersion,
    platform,
    browserName,
    browserLanguage,
    screenHeight,
    screenWidth,
    timeZoneOffset,
    clientCountry,
  }
}

module BackgroundImageWrapper = {
  @react.component
  let make = (
    ~children=?,
    ~backgroundImageUrl="/images/hyperswitchImages/PostLoginBackground.svg",
    ~customPageCss="",
    ~isBackgroundFullScreen=true,
  ) => {
    let heightWidthCss = isBackgroundFullScreen ? "h-screen w-screen" : "h-full w-full"
    <UIUtils.RenderIf condition={children->Belt.Option.isSome}>
      <div
        className={`bg-no-repeat bg-center bg-hyperswitch_dark_bg bg-fixed ${customPageCss} ${heightWidthCss}`}
        style={ReactDOMStyle.make(
          ~backgroundImage=`url(${backgroundImageUrl})`,
          ~backgroundSize=`cover`,
          (),
        )}>
        {children->Belt.Option.getWithDefault(React.null)}
      </div>
    </UIUtils.RenderIf>
  }
}

type processors = FRMPlayer | Connector | PayoutConnector

let filterList = (items, ~removeFromList=FRMPlayer, ()) => {
  items->Js.Array2.filter(dict => {
    let connectorType = dict->getString("connector_type", "")
    let isPayoutConnector = connectorType == "payout_processor"
    let isConnector = connectorType !== "payment_vas" && !isPayoutConnector

    switch removeFromList {
    | Connector => !isConnector
    | FRMPlayer => isConnector
    | PayoutConnector => isPayoutConnector
    }
  })
}

let getProcessorsListFromJson = (json, ~removeFromList=FRMPlayer, ()) => {
  json->getArrayFromJson([])->Js.Array2.map(getDictFromJsonObject)->filterList(~removeFromList, ())
}

let getPageNameFromUrl = url => {
  url->LogicUtils.getListHead
}

let getBodyForFeedBack = (values, ~modalType=HSwitchFeedBackModalUtils.FeedBackModal, ()) => {
  open HSwitchFeedBackModalUtils
  let email = getFromMerchantDetails("email")
  let valueDict = values->getDictFromJsonObject
  let rating = valueDict->getInt("rating", 1)
  let timestamp =
    Js.Date.now()
    ->Js.Date.fromFloat
    ->Js.Date.toISOString
    ->TimeZoneHook.formattedISOString("YYYY-MM-DD hh:mm:ss")

  let bodyFields = [("created_at", timestamp->Js.Json.string), ("email", email->Js.Json.string)]

  switch modalType {
  | FeedBackModal =>
    bodyFields
    ->Array.pushMany([
      ("category", valueDict->getString("category", "")->Js.Json.string),
      ("description", valueDict->getString("feedbacks", "")->Js.Json.string),
      ("rating", rating->Belt.Float.fromInt->Js.Json.number),
    ])
    ->ignore
  | RequestConnectorModal =>
    bodyFields
    ->Array.pushMany([
      ("category", "request_connector"->Js.Json.string),
      (
        "description",
        `[${valueDict->getString("connector_name", "")}]-[${valueDict->getString(
            "description",
            "",
          )}]`->Js.Json.string,
      ),
    ])
    ->ignore
  }

  bodyFields->Js.Dict.fromArray
}

let getMetaData = (newMetadata, metaData) => {
  switch newMetadata {
  | Some(data) => data
  | None => metaData
  }
}

let returnIntegrationJson = (integrationData: ProviderTypes.integration): Js.Json.t => {
  Js.Dict.fromArray([
    ("is_done", integrationData.is_done->Js.Json.boolean),
    ("metadata", integrationData.metadata),
  ])->Js.Json.object_
}

let constructOnboardingBody = (
  ~dashboardPageState,
  ~integrationDetails: ProviderTypes.integrationDetailsType,
  ~is_done: bool,
  ~metadata: option<Js.Json.t>=?,
  (),
) => {
  let copyOfIntegrationDetails = integrationDetails
  switch dashboardPageState {
  | #INTEGRATION_DOC => {
      copyOfIntegrationDetails.integration_checklist.is_done = is_done
      copyOfIntegrationDetails.integration_checklist.metadata = getMetaData(
        metadata,
        copyOfIntegrationDetails.integration_checklist.metadata,
      )
    }

  | #AUTO_CONNECTOR_INTEGRATION => {
      copyOfIntegrationDetails.connector_integration.is_done = is_done
      copyOfIntegrationDetails.connector_integration.metadata = getMetaData(
        metadata,
        copyOfIntegrationDetails.connector_integration.metadata,
      )
      copyOfIntegrationDetails.pricing_plan.is_done = is_done
      copyOfIntegrationDetails.pricing_plan.metadata = getMetaData(
        metadata,
        copyOfIntegrationDetails.pricing_plan.metadata,
      )
    }

  | #HOME => {
      copyOfIntegrationDetails.account_activation.is_done = is_done
      copyOfIntegrationDetails.account_activation.metadata = getMetaData(
        metadata,
        copyOfIntegrationDetails.account_activation.metadata,
      )
    }

  | _ => ()
  }

  Js.Dict.fromArray([
    (
      "integration_checklist",
      copyOfIntegrationDetails.integration_checklist->returnIntegrationJson,
    ),
    (
      "connector_integration",
      copyOfIntegrationDetails.connector_integration->returnIntegrationJson,
    ),
    ("pricing_plan", copyOfIntegrationDetails.pricing_plan->returnIntegrationJson),
    ("account_activation", copyOfIntegrationDetails.account_activation->returnIntegrationJson),
  ])->Js.Json.object_
}
module OnboardingChecklistTile = {
  @react.component
  let make = (~setShowOnboardingModal) => {
    let hyperswitchMixPanel = HSMixPanel.useSendEvent()
    let url = RescriptReactRouter.useUrl()
    <div
      className="absolute bottom-0 right-0 cursor-pointer px-5 py-2 bg-white h-20 w-[26rem] flex justify-between items-center !shadow-checklistShadow"
      onClick={_ => {
        setShowOnboardingModal(_ => true)

        [url.path->LogicUtils.getListHead, "global"]->Js.Array2.forEach(ele =>
          hyperswitchMixPanel(~eventName=Some(`${ele}_onboarding_checklist`), ())
        )
      }}>
      <div className="w-full flex nowrap items-center gap-2">
        <div className="font-semibold text-xl"> {"Onboarding Checklist"->React.string} </div>
        <span className="relative flex h-3 w-3">
          <span
            className="animate-ping absolute inline-flex h-full w-full rounded-full bg-sky-400 opacity-75"
          />
          <span className="relative inline-flex rounded-full h-3 w-3 bg-sky-500" />
        </span>
      </div>
      <Icon name="arrow-without-tail" />
    </div>
  }
}

let isEmptyString = str => str->Js.String2.length <= 0

let parseUrl = url => {
  url
  ->Js.Global.decodeURI
  ->Js.String2.split("&")
  ->Belt.Array.keepMap(str => {
    let arr = str->Js.String2.split("=")
    let key = arr->Belt.Array.get(0)->Belt.Option.getWithDefault("-")
    let val = arr->Belt.Array.sliceToEnd(1)->Js.Array2.joinWith("=")
    key === "" || val === "" ? None : Some((key, val))
  })
  ->Js.Dict.fromArray
}

type textVariantType =
  | H1
  | H2
  | H3
  | P1
  | P2
  | P3
type paragraphTextType = Regular | Medium
type h3TextType = Leading_1 | Leading_2

let getTextClass = (~textVariant, ~h3TextVariant=Leading_1, ~paragraphTextVariant=Regular, ()) => {
  switch (textVariant, h3TextVariant, paragraphTextVariant) {
  | (H1, _, _) => "text-fs-28 font-semibold leading-10"
  | (H2, _, _) => "text-2xl font-semibold leading-8"
  | (H3, Leading_1, _) => "text-xl font-semibold leading-7"
  | (H3, Leading_2, _) => "text-lg font-semibold leading-7"

  | (P1, _, Regular) => "text-base font-normal leading-6"
  | (P1, _, Medium) => "text-base font-medium leading-6"

  | (P2, _, Regular) => "text-sm font-normal leading-5"
  | (P2, _, Medium) => "text-sm font-medium leading-5"

  | (P3, _, Regular) => "text-xs font-normal leading-4"
  | (P3, _, Medium) => "text-xs font-medium leading-4"
  }
}

module CardLoader = {
  @react.component
  let make = () => {
    <div className="w-full h-full flex justify-center items-center">
      <div className="w-24 h-24 scale-[0.5]">
        <div className="-mt-5 -ml-12">
          <Loader />
        </div>
      </div>
    </div>
  }
}

let checkStripePlusPayPal = (enumDetails: QuickStartTypes.responseType) => {
  enumDetails.stripeConnected.processorID->Js.String2.length > 0 &&
  enumDetails.paypalConnected.processorID->Js.String2.length > 0 &&
  enumDetails.sPTestPayment
    ? true
    : false
}

let checkWooCommerce = (enumDetails: QuickStartTypes.responseType) => {
  enumDetails.setupWoocomWebhook &&
  enumDetails.firstProcessorConnected.processorID->Js.String2.length > 0
    ? true
    : false
}
