// %%raw(`import "superposition-embeddable-ui/styles.css"`)

// ─── Enum types ──────────────────────────────────────────────────────────────

type superpositionFeature =
  | @as("config") Config
  | @as("overrides") Overrides
  | @as("dimensions") Dimensions

type routeMode =
  | @as("internal") Internal
  | @as("external") External

type authMode =
  | @as("cookie") Cookie
  | @as("bearer") Bearer
  | @as("custom") Custom

// type themeMode =
//   | @as("light") Light
//   | @as("dark") Dark
//   | @as("system") System

// type scopeMatchMode =
//   | @as("compatible") Compatible
//   | @as("strict") Strict

type workspaceHeaderName =
  | @as("x-workspace") XWorkspace
  | @as("x-tenant") XTenant

type requestCredentials =
  | @as("omit") Omit
  | @as("same-origin") SameOrigin
  | @as("include") Include

// type notifyTone =
//   | @as("info") Info
//   | @as("success") Success
//   | @as("warning") Warning
//   | @as("error") Error_

// type confirmVariant =
//   | @as("default") Default
//   | @as("destructive") Destructive

type tableAlign =
  | @as("left") Left
  | @as("center") Centerf
  | @as("right") Right

// ─── Abstract Web API types ──────────────────────────────────────────────────
// These are opaque JS objects; typed only enough to pass through callbacks.

type fetchRequestInit
type fetchResponse

// ─── Sub-config types ────────────────────────────────────────────────────────

type authConfig = {
  mode: authMode,
  token?: string,
  headers?: Js.Dict.t<string>,
}

type requestCtx = {
  url: string,
  init: fetchRequestInit,
}

type responseCtx = {
  request: requestCtx,
  response: fetchResponse,
}

type networkConfig = {
  interceptRequest?: requestCtx => promise<requestCtx>,
  interceptResponse?: responseCtx => promise<fetchResponse>,
  onUnauthorized?: fetchResponse => unit,
  onForbidden?: fetchResponse => unit,
  onApiError?: JSON.t => unit,
}

type scopeConfig = {
  context?: Js.Dict.t<JSON.t>,
  locked?: bool,
}

type filtersConfig = {
  defaultConfigPrefix?: array<string>,
  dimensions?: array<string>,
}

type featureCapabilities = {
  create?: bool,
  update?: bool,
  delete?: bool,
  ramp?: bool,
  execute?: bool,
  editContext?: bool,
}

type capabilitiesConfig = {
  config?: featureCapabilities,
  overrides?: featureCapabilities,
  dimensions?: featureCapabilities,
}

type routingConfig = {
  mode: routeMode,
  initialFeature?: superpositionFeature,
  currentFeature?: superpositionFeature,
  onNavigate?: superpositionFeature => unit,
  getFeatureHref?: superpositionFeature => string,
}

// type styling = {
//   padding?: string,
//   margin?: string,
//   width?: string,
//   height?: string,
//   opacity?: string,
//   textColor?: string,
//   bgColor?: string,
//   borderColor?: string,
//   borderRadius?: string,
//   fontSize?: string,
//   fontWeight?: string,
//   shadow?: string,
//   textTransform?: string,
// }

// type themeColors = {
//   bg?: string,
//   panel?: string,
//   text?: string,
//   muted?: string,
//   border?: string,
//   primary?: string,
//   success?: string,
//   warning?: string,
//   danger?: string,
// }

// type scaleConfig = {
//   xs?: string,
//   sm?: string,
//   md?: string,
//   lg?: string,
// }

// type shadowConfig = {
//   sm?: string,
//   md?: string,
// }

// type typographyConfig = {
//   fontFamily?: string,
//   fontSize?: string,
// }

// type buttonThemeConfig = {
//   padding?: string,
//   margin?: string,
//   width?: string,
//   height?: string,
//   textColor?: string,
//   bgColor?: string,
//   borderColor?: string,
//   borderRadius?: string,
//   fontSize?: string,
//   fontWeight?: string,
//   shadow?: string,
//   textTransform?: string,
//   primary?: styling,
//   secondary?: styling,
//   danger?: styling,
//   disabledOpacity?: string,
// }

// type tableThemeConfig = {
//   padding?: string,
//   margin?: string,
//   width?: string,
//   height?: string,
//   textColor?: string,
//   bgColor?: string,
//   borderColor?: string,
//   borderRadius?: string,
//   fontSize?: string,
//   fontWeight?: string,
//   shadow?: string,
//   textTransform?: string,
//   header?: styling,
// }

// type formThemeConfig = {
//   padding?: string,
//   margin?: string,
//   width?: string,
//   height?: string,
//   textColor?: string,
//   bgColor?: string,
//   borderColor?: string,
//   borderRadius?: string,
//   fontSize?: string,
//   fontWeight?: string,
//   shadow?: string,
//   textTransform?: string,
//   label?: styling,
//   removeButton?: styling,
//   helperTextColor?: string,
// }

// type dropdownOptionThemeConfig = {
//   hoverBgColor?: string,
//   selectedBgColor?: string,
//   selectedTextColor?: string,
// }

// type dropdownThemeConfig = {
//   padding?: string,
//   margin?: string,
//   width?: string,
//   height?: string,
//   textColor?: string,
//   bgColor?: string,
//   borderColor?: string,
//   borderRadius?: string,
//   fontSize?: string,
//   fontWeight?: string,
//   shadow?: string,
//   textTransform?: string,
//   control?: styling,
//   menu?: styling,
//   option?: dropdownOptionThemeConfig,
// }

// type iconLockConfig = {
//   size?: string,
//   color?: string,
// }

// type iconThemeConfig = {
//   size?: string,
//   color?: string,
//   lock?: iconLockConfig,
// }

// type searchThemeConfig = {
//   padding?: string,
//   margin?: string,
//   width?: string,
//   height?: string,
//   textColor?: string,
//   bgColor?: string,
//   borderColor?: string,
//   borderRadius?: string,
//   fontSize?: string,
//   fontWeight?: string,
//   shadow?: string,
//   textTransform?: string,
//   placeholderColor?: string,
//   placeholderOpacity?: string,
//   hoverBgColor?: string,
//   hoverTextColor?: string,
//   hoverBorderColor?: string,
//   hoverIconColor?: string,
//   hoverShadow?: string,
//   focusBgColor?: string,
//   focusTextColor?: string,
//   focusBorderColor?: string,
//   focusIconColor?: string,
//   focusShadow?: string,
//   focusOutline?: string,
//   focusOutlineOffset?: string,
//   icon?: iconThemeConfig,
// }

// type toastThemeConfig = {
//   padding?: string,
//   margin?: string,
//   width?: string,
//   height?: string,
//   textColor?: string,
//   bgColor?: string,
//   borderColor?: string,
//   borderRadius?: string,
//   fontSize?: string,
//   fontWeight?: string,
//   shadow?: string,
//   textTransform?: string,
//   success?: styling,
//   error?: styling,
//   warning?: styling,
//   info?: styling,
// }

// type bannerThemeConfig = {
//   padding?: string,
//   margin?: string,
//   width?: string,
//   height?: string,
//   textColor?: string,
//   bgColor?: string,
//   borderColor?: string,
//   borderRadius?: string,
//   fontSize?: string,
//   fontWeight?: string,
//   shadow?: string,
//   textTransform?: string,
//   warning?: styling,
//   info?: styling,
//   error?: styling,
//   success?: styling,
// }

// type blendThemeConfig = {
//   foundationTokens?: JSON.t,
//   componentTokens?: JSON.t,
// }

// type themeConfig = {
//   mode?: themeMode,
//   colors?: themeColors,
//   radius?: scaleConfig,
//   spacing?: scaleConfig,
//   shadow?: shadowConfig,
//   typography?: typographyConfig,
//   button?: buttonThemeConfig,
//   table?: tableThemeConfig,
//   form?: formThemeConfig,
//   dropdown?: dropdownThemeConfig,
//   icon?: iconThemeConfig,
//   search?: searchThemeConfig,
//   toast?: toastThemeConfig,
//   banner?: bannerThemeConfig,
//   pageTitle?: styling,
//   jsonValue?: styling,
//   tooltip?: styling,
//   blend?: blendThemeConfig,
// }

type tableSerialNumberConfig = {
  enabled?: bool,
  header?: string,
  width?: string,
  startAt?: int,
  align?: tableAlign,
}

type tableConfig = {serialNumber?: tableSerialNumberConfig}

// type layoutConfig = {
//   adminContentMinHeight?: string,
//   modalWidth?: string,
//   modalMinWidth?: string,
//   modalMaxWidth?: string,
//   modalMaxHeight?: string,
//   confirmWidth?: string,
//   alertMinWidth?: string,
//   tableMinWidth?: string,
//   tableEmptyMinHeight?: string,
//   compactControlPadding?: string,
// }

// type notifyInput = {
//   tone: notifyTone,
//   title: string,
//   description?: string,
// }

// type confirmInput = {
//   title: string,
//   description?: string,
//   confirmLabel?: string,
//   cancelLabel?: string,
//   variant?: confirmVariant,
// }

// type renderModalInput = {
//   @as("open") isOpen: bool,
//   onClose: unit => unit,
//   title: string,
//   children: React.element,
//   footer?: React.element,
// }

// type uiConfig = {
//   notify?: notifyInput => unit,
//   confirm?: confirmInput => promise<bool>,
//   renderModal?: renderModalInput => React.element,
//   portalContainer?: string,
//   modalZIndex?: int,
//   alertZIndex?: int,
//   showBoundaryFilter?: bool,
// }

// ─── Root config ─────────────────────────────────────────────────────────────

type embeddableConfig = {
  apiBaseUrl: string,
  apiBasePath?: string,
  credentials?: requestCredentials,
  workspaceHeaderName?: workspaceHeaderName,
  orgId: string,
  workspace: string,
  auth?: authConfig,
  network?: networkConfig,
  scope?: scopeConfig,
  filters?: filtersConfig,
  capabilities?: capabilitiesConfig,
  readOnly?: bool,
  strict?: bool,
  features?: array<superpositionFeature>,
  routing?: routingConfig,
  table?: tableConfig,
  // theme?: themeConfig,
  // layout?: layoutConfig,
  // ui?: uiConfig,
  messages?: Js.Dict.t<string>,
}

// ─── Component bindings ───────────────────────────────────────────────────────

module SuperpositionUIProvider = {
  @module("superposition-embeddable-ui") @react.component
  external make: (~config: embeddableConfig, ~children: React.element) => React.element =
    "SuperpositionUIProvider"
}

module AlertProvider = {
  @module("superposition-embeddable-ui") @react.component
  external make: (~children: React.element) => React.element = "AlertProvider"
}

module SuperpositionAdmin = {
  @module("superposition-embeddable-ui") @react.component
  external make: (
    ~defaultFeature: superpositionFeature=?,
    ~defaultTab: superpositionFeature=?,
    ~allowConfigEditing: bool=?,
    ~allowDimensionEditing: bool=?,
  ) => React.element = "SuperpositionAdmin"
}

module ConfigManager = {
  @module("superposition-embeddable-ui/config-manager") @react.component
  external make: (
    ~pageSize: int=?,
    ~prefix: array<string>=?,
    ~showResolvedValues: bool=?,
    ~editable: bool=?,
  ) => React.element = "ConfigManager"
}

module OverrideManager = {
  @module("superposition-embeddable-ui/override-manager") @react.component
  external make: (~pageSize: int=?, ~defaultConfigPrefix: array<string>=?) => React.element =
    "OverrideManager"
}

module DimensionManager = {
  @module("superposition-embeddable-ui/dimension-manager") @react.component
  external make: (~pageSize: int=?, ~editable: bool=?) => React.element = "DimensionManager"
}
