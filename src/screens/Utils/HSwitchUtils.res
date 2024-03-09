open LogicUtils
open HSLocalStorage
open HyperswitchAtom
// open UtilsTypes

module TextFieldRow = {
  @react.component
  let make = (~label, ~children, ~isRequired=true, ~labelWidth="w-72") => {
    <div className="flex mt-5">
      <div
        className={`mt-2 ${labelWidth} text-gray-900/50 dark:text-jp-gray-text_darktheme dark:text-opacity-50 font-semibold text-fs-14`}>
        {label->React.string}
        <UIUtils.RenderIf condition={isRequired}>
          <span className="text-red-500"> {"*"->React.string} </span>
        </UIUtils.RenderIf>
      </div>
      children
    </div>
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
    <UIUtils.RenderIf condition={children->Option.isSome}>
      <div
        className={`bg-no-repeat bg-center bg-hyperswitch_dark_bg bg-fixed ${customPageCss} ${heightWidthCss}`}
        style={ReactDOMStyle.make(
          ~backgroundImage=`url(${backgroundImageUrl})`,
          ~backgroundSize=`cover`,
          (),
        )}>
        {children->Option.getOr(React.null)}
      </div>
    </UIUtils.RenderIf>
  }
}

let feedbackModalOpenCountForConnectors = 4

let errorClass = "text-sm leading-4 font-medium text-start ml-1 mt-2"

let setMerchantDetails = (key, value) => {
  let localStorageData = getInfoFromLocalStorage(~lStorageKey="merchant")
  localStorageData->Dict.set(key, value)

  "merchant"->LocalStorage.setItem(localStorageData->JSON.stringifyAny->Option.getOr(""))
}

// TODO : Remove once user-management flow introduces
let setUserDetails = (key, value) => {
  let localStorageData = getInfoFromLocalStorage(~lStorageKey="user")
  localStorageData->Dict.set(key, value)
  "user"->LocalStorage.setItem(localStorageData->JSON.stringifyAny->Option.getOr(""))
}
let getSearchOptionsForProcessors = (~processorList, ~getNameFromString) => {
  let searchOptionsForProcessors =
    processorList->Array.map(item => (
      `Connect ${item->getNameFromString->capitalizeString}`,
      `/new?name=${item->getNameFromString}`,
    ))
  searchOptionsForProcessors
}

let isValidEmail = value =>
  !Js.Re.test_(
    %re(`/^(([^<>()[\]\.,;:\s@"]+(\.[^<>()[\]\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/`),
    value,
  )

let useMerchantDetailsValue = () => Recoil.useRecoilValueFromAtom(merchantDetailsValueAtom)

let getClientCountry = clientTimeZone => {
  Country.country
  ->Array.find(item => item.timeZones->Array.find(i => i == clientTimeZone)->Option.isSome)
  ->Option.getOr(Country.defaultTimeZone)
}

let getBrowswerDetails = () => {
  open Window
  open Window.Navigator
  open Window.Screen
  open UtilsTypes
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

let getBodyForFeedBack = (values, ~modalType=HSwitchFeedBackModalUtils.FeedBackModal, ()) => {
  open HSwitchFeedBackModalUtils
  let email = getFromMerchantDetails("email")
  let valueDict = values->getDictFromJsonObject
  let rating = valueDict->getInt("rating", 1)

  let bodyFields = [("email", email->JSON.Encode.string)]

  switch modalType {
  | FeedBackModal =>
    bodyFields
    ->Array.pushMany([
      ("category", valueDict->getString("category", "")->JSON.Encode.string),
      ("description", valueDict->getString("feedbacks", "")->JSON.Encode.string),
      ("rating", rating->Float.fromInt->JSON.Encode.float),
    ])
    ->ignore
  | RequestConnectorModal =>
    bodyFields
    ->Array.pushMany([
      ("category", "request_connector"->JSON.Encode.string),
      (
        "description",
        `[${valueDict->getString("connector_name", "")}]-[${valueDict->getString(
            "description",
            "",
          )}]`->JSON.Encode.string,
      ),
    ])
    ->ignore
  }

  bodyFields->Dict.fromArray
}

let getMetaData = (newMetadata, metaData) => {
  switch newMetadata {
  | Some(data) => data
  | None => metaData
  }
}

let returnIntegrationJson = (integrationData: ProviderTypes.integration): JSON.t => {
  [
    ("is_done", integrationData.is_done->JSON.Encode.bool),
    ("metadata", integrationData.metadata),
  ]->getJsonFromArrayOfJson
}

let constructOnboardingBody = (
  ~dashboardPageState,
  ~integrationDetails: ProviderTypes.integrationDetailsType,
  ~is_done: bool,
  ~metadata: option<JSON.t>=?,
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

  [
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
  ]->getJsonFromArrayOfJson
}

let getTextClass = variantType => {
  open UtilsTypes
  switch variantType {
  | (H1, Optional) => "text-fs-28 font-semibold leading-10"
  | (H2, Optional) => "text-2xl font-semibold leading-8"
  | (H3, Leading_1) => "text-xl font-semibold leading-7"
  | (H3, Leading_2) => "text-lg font-semibold leading-7"

  | (P1, Regular) => "text-base font-normal leading-6"
  | (P1, Medium) => "text-base font-medium leading-6"

  | (P2, Regular) => "text-sm font-normal leading-5"
  | (P2, Medium) => "text-sm font-medium leading-5"

  | (P3, Regular) => "text-xs font-normal leading-4"
  | (P3, Medium) => "text-xs font-medium leading-4"
  | (_, _) => ""
  }
}

let checkStripePlusPayPal = (enumDetails: QuickStartTypes.responseType) => {
  enumDetails.stripeConnected.processorID->isNonEmptyString &&
  enumDetails.paypalConnected.processorID->isNonEmptyString &&
  enumDetails.sPTestPayment
}

let checkWooCommerce = (enumDetails: QuickStartTypes.responseType) => {
  enumDetails.setupWoocomWebhook &&
  enumDetails.firstProcessorConnected.processorID->isNonEmptyString
}

let noAccessControlText = "You do not have the required permissions to access this module. Please contact your admin."
let noAccessControlTextForProcessors = "You do not have the required permissions to connect this processor. Please contact admin."
