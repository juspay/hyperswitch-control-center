type t

type listener<'ev> = 'ev => unit

type event = {data: string}

@val @scope("window")
external parent: 't = "parent"

@val @scope("window")
external addEventListener: (string, listener<'ev>) => unit = "addEventListener"

@val @scope("window")
external close: unit => unit = "close"

@val @scope("window")
external scrollTo: (float, float) => unit = "scrollTo"

@val @scope("window")
external addEventListener3: (string, listener<'ev>, bool) => unit = "addEventListener"

@val @scope("window")
external removeEventListener: (string, listener<'ev>) => unit = "removeEventListener"

@val @scope("window")
external postMessage: (JSON.t, string) => unit = "postMessage"

@val @scope("window")
external checkLoadHyper: option<ReactHyperJs.hyperloader> = "Hyper"

@val @scope("window")
external loadHyper: (string, JSON.t) => ReactHyperJs.hyperloader = "Hyper"

type rec selectionObj = {\"type": string}
@val @scope("window") external getSelection: unit => selectionObj = "getSelection"

@val @scope("window")
external navigator: JSON.t = "navigator"

@val @scope("window")
external connectorWasmInit: 'a => Promise.t<JSON.t> = "init"

@val @scope("window")
external dynamicRoutingWasmInit: 'a => Promise.t<JSON.t> = "dynamicRoutingInit"

@val @scope("window")
external getConnectorConfig: string => JSON.t = "getConnectorConfig"

@val @scope("window")
external getPayoutConnectorConfig: string => JSON.t = "getPayoutConnectorConfig"

@val @scope("window")
external getThreeDsKeys: unit => array<string> = "getThreeDsKeys"

@val @scope("window")
external getThreeDsDecisionRuleKeys: unit => array<string> = "getThreeDsDecisionRuleKeys"

@val @scope("window")
external getSurchargeKeys: unit => array<string> = "getSurchargeKeys"

@val @scope("window")
external getAllKeys: unit => array<string> = "getAllKeys"

@val @scope("window")
external getKeyType: string => string = "getKeyType"

@val @scope("window")
external getAllConnectors: unit => array<string> = "getAllConnectors"

@val @scope("window")
external getVariantValues: string => array<string> = "getVariantValues"

@val @scope("window")
external getDescriptionCategory: unit => JSON.t = "getDescriptionCategory"

@val @scope("window")
open ConnectorTypes
external getRequestPayload: (wasmRequest, wasmExtraPayload) => JSON.t = "getRequestPayload"

@val @scope("window")
external getResponsePayload: 'a => JSON.t = "getResponsePayload"

@val @scope("window")
external getParsedJson: string => JSON.t = "getParsedJson"

@val @scope("window") external innerWidth: int = "innerWidth"
@val @scope("window") external innerHeight: int = "innerHeight"

@val @scope("window") external globalUrlPrefix: option<string> = "urlPrefix"

@val @scope("window")
external payPalCreateAccountWindow: unit => unit = "payPalCreateAccountWindow"

@val @scope("window")
external isSecureContext: bool = "isSecureContext"

@val @scope("window")
external getAuthenticationConnectorConfig: string => JSON.t = "getAuthenticationConnectorConfig"

@val @scope("window")
external getPMAuthenticationProcessorConfig: string => JSON.t = "getPMAuthenticationProcessorConfig"

@val @scope("window")
external getTaxProcessorConfig: string => JSON.t = "getTaxProcessorConfig"

@val @scope("window")
external getAllPayoutKeys: unit => array<string> = "getAllPayoutKeys"

@val @scope("window")
external getPayoutVariantValues: string => array<string> = "getPayoutVariantValues"

@val @scope("window")
external getPayoutDescriptionCategory: unit => JSON.t = "getPayoutDescriptionCategory"

@val @scope("window")
external getMerchantCategoryCodeWithName: unit => array<JSON.t> = "getMerchantCategoryCodeWithName"

module MatchMedia = {
  type matchEvent = {
    matches: bool,
    media: string,
  }

  type queryResponse = {
    matches: bool,
    addListener: (matchEvent => unit) => unit,
    removeListener: (matchEvent => unit) => unit,
  }
}

@val @scope("window")
external matchMedia: string => MatchMedia.queryResponse = "matchMedia"

@val @scope("window")
external _open: string => unit = "open"

module Location = {
  type location
  @val @scope("window") external location: location = "location"
  @val @scope(("window", "location"))
  external hostname: string = "hostname"

  @val @scope(("window", "location"))
  external reload: unit => unit = "reload"

  @val @scope(("window", "location"))
  external hardReload: bool => unit = "reload"

  @val @scope(("window", "location"))
  external replace: string => unit = "replace"

  @val @scope(("window", "location"))
  external assign: string => unit = "assign"

  @val @scope(("window", "location"))
  external origin: string = "origin"

  @val @scope(("window", "location"))
  external pathName: string = "pathname"

  @val @scope(("window", "location"))
  external href: string = "href"

  @set
  external setHref: (location, string) => unit = "href"
}

module Navigator = {
  @val @scope(("window", "navigator"))
  external userAgent: string = "userAgent"

  @val @scope(("window", "navigator"))
  external browserName: string = "appName"

  @val @scope(("window", "navigator"))
  external browserVersion: string = "appVersion"

  @val @scope(("window", "navigator"))
  external platform: string = "platform"

  @val @scope(("window", "navigator"))
  external browserLanguage: string = "language"
}

module Screen = {
  @val @scope(("window", "screen"))
  external screenHeight: string = "height"

  @val @scope(("window", "screen"))
  external screenWidth: string = "width"
}

type date = {getTimezoneOffset: unit => float}

@new external date: unit => date = "Date"
let date = date()
let timeZoneOffset = date.getTimezoneOffset()->Float.toString

type options = {timeZone: string}
type dateTimeFormat = {resolvedOptions: unit => options}
@val @scope("Intl")
external dateTimeFormat: unit => dateTimeFormat = "DateTimeFormat"

module History = {
  @val @scope(("window", "history"))
  external back: unit => unit = "back"

  @val @scope(("window", "history"))
  external forward: unit => unit = "forward"

  @val @scope(("window", "history"))
  external length: int = "length"
}

module ArrayBuffer = {
  type t
}

module Crypto = {
  module Subtle = {
    @val @scope(("window", "crypto", "subtle"))
    external importKey: (string, ArrayBuffer.t, {..}, bool, array<string>) => Promise.t<string> =
      "importKey"

    @val @scope(("window", "crypto", "subtle"))
    external decrypt: ({..}, string, ArrayBuffer.t) => Promise.t<string> = "decrypt"
  }
}

@val @scope("window")
external prompt: string => string = "prompt"

module Notification = {
  type notification = {
    permission: string,
    requestPermission: unit => Promise.t<string>,
  }

  @val @scope("window")
  external notification: Js.Null_undefined.t<notification> = "Notification"

  let requestPermission = switch notification->Js.Null_undefined.toOption {
  | Some(notif) => notif.requestPermission
  | None => () => Promise.resolve("")
  }
}

module FcWidget = {
  module User = {
    @val @scope(("window", "fcWidget", "user"))
    external setEmail: string => Promise.t<string> = "setEmail"

    @val @scope(("window", "fcWidget", "user"))
    external setFirstName: string => Promise.t<string> = "setFirstName"
  }
}

@val @scope("window")
external fcWidget: 'a = "fcWidget"

type boundingClient = {x: int, y: int, width: int, height: int}
@send external getBoundingClientRect: Dom.element => boundingClient = "getBoundingClientRect"

@val @scope("window")
external appendStyle: HyperSwitchConfigTypes.customStylesTheme => unit = "appendStyle"

@val @scope("window")
external env: HyperSwitchConfigTypes.urlConfig = "_env_"

@val @scope("window")
external validateExtract: (Js.TypedArray2.Uint8Array.t, JSON.t, JSON.t) => JSON.t =
  "validateExtract"

@val @scope("window")
external getDefaultConfig: unit => JSON.t = "getDefaultConfig"
