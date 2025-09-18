open LogicUtils
open HSLocalStorage

module TextFieldRow = {
  @react.component
  let make = (~label, ~children, ~isRequired=true, ~labelWidth="w-72") => {
    <div className="flex mt-5">
      <div
        className={`mt-2 ${labelWidth} text-gray-900/50 dark:text-jp-gray-text_darktheme dark:text-opacity-50 font-semibold text-fs-14`}>
        {label->React.string}
        <RenderIf condition={isRequired}>
          <span className="text-red-500"> {"*"->React.string} </span>
        </RenderIf>
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
    <RenderIf condition={children->Option.isSome}>
      <div
        className={`bg-no-repeat bg-center bg-hyperswitch_dark_bg bg-fixed ${customPageCss} ${heightWidthCss}`}
        style={
          backgroundImage: `url(${backgroundImageUrl})`,
          backgroundSize: `cover`,
        }>
        {children->Option.getOr(React.null)}
      </div>
    </RenderIf>
  }
}

let feedbackModalOpenCountForConnectors = 4

let errorClass = "text-sm leading-4 font-medium text-start ml-1 mt-2"

let getSearchOptionsForProcessors = (~processorList, ~getNameFromString) => {
  let searchOptionsForProcessors =
    processorList->Array.map(item => (
      `Connect ${item->getNameFromString->capitalizeString}`,
      `/new?name=${item->getNameFromString}`,
    ))
  searchOptionsForProcessors
}

let isValidEmail = value =>
  !RegExp.test(
    %re(`/^(([^<>()[\]\.,;:\s@"]+(\.[^<>()[\]\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/`),
    value,
  )

// TODO : Remove once user-management flow introduces
let setUserDetails = (key, value) => {
  let localStorageData = getInfoFromLocalStorage(~lStorageKey="user")
  localStorageData->Dict.set(key, value)
  "user"->LocalStorage.setItem(localStorageData->JSON.stringifyAny->Option.getOr(""))
}

let getClientCountry = clientTimeZone => {
  Country.country
  ->Array.find(item => item.timeZones->Array.find(i => i == clientTimeZone)->Option.isSome)
  ->Option.getOr(Country.defaultTimeZone)
}

let getBrowswerDetails = () => {
  open Window
  open Window.Navigator
  open Window.Screen
  open HSwitchUtilsTypes
  let clientTimeZone = dateTimeFormat().resolvedOptions().timeZone
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

let getTextClass = variantType => {
  open HSwitchUtilsTypes
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

let noAccessControlText = "You do not have the required permissions to access this module. Please contact your admin."
let noAccessControlTextForProcessors = "You do not have the required permissions to connect this processor. Please contact admin."

let urlPath = urlPathList => {
  open GlobalVars
  switch dashboardBasePath {
  | Some(_) =>
    switch urlPathList {
    | list{_, ...rest} => rest
    | _ => urlPathList
    }
  | _ => urlPathList
  }
}

let getConnectorIDFromUrl = (urlList, defaultValue) => {
  open GlobalVars
  switch dashboardBasePath {
  | Some(_) =>
    if urlList->Array.includes("v2") {
      urlList->Array.get(4)->Option.getOr(defaultValue)
    } else {
      urlList->Array.get(2)->Option.getOr(defaultValue)
    }
  | _ => urlList->Array.get(1)->Option.getOr(defaultValue)
  }
}

module AlertBanner = {
  @react.component
  let make = (~bannerContent, ~bannerType: HSwitchUtilsTypes.bannerType, ~customRightAction=?) => {
    let bgClass = switch bannerType {
    | Success => " bg-green-100"
    | Warning => "bg-orange-100"
    | Error => "bg-red-100"
    | Info => "bg-blue-150"
    }

    let iconName = switch bannerType {
    | Success => "green-tick-banner"
    | Warning => "warning-banner"
    | Error => "cross-banner"
    | Info => "info-banner"
    }

    let borderColor = switch bannerType {
    | Success => "border-nd_green-200"
    | Warning => "border-nd_yellow-300"
    | Error => "border-nd_red-200"
    | Info => "border-nd_primary_blue-200"
    }

    <div
      className={`${bgClass} flex justify-between border ${borderColor} text-nd_gray-700 w-full py-4 px-4 rounded-md`}>
      <div className="flex items-center gap-4">
        <Icon name=iconName size=20 />
        {bannerContent}
      </div>
      <div>
        {switch customRightAction {
        | Some(action) => action
        | None => React.null
        }}
      </div>
    </div>
  }
}
