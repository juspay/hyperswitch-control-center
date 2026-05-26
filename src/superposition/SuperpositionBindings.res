// ─── Enum types ──────────────────────────────────────────────────────────────

type superpositionFeature =
  | @as("config") Config
  | @as("overrides") Overrides
  | @as("dimensions") Dimensions
  | @as("audit") Audit

type routeMode =
  | @as("internal") Internal
  | @as("external") External

type authMode =
  | @as("cookie") Cookie
  | @as("bearer") Bearer
  | @as("custom") Custom

type workspaceHeaderName =
  | @as("x-workspace") XWorkspace
  | @as("x-tenant") XTenant

type requestCredentials =
  | @as("omit") Omit
  | @as("same-origin") SameOrigin
  | @as("include") Include

type tableAlign =
  | @as("left") Left
  | @as("center") Center
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
  audit?: featureCapabilities,
}

type routingConfig = {
  mode: routeMode,
  initialFeature?: superpositionFeature,
  currentFeature?: superpositionFeature,
  onNavigate?: superpositionFeature => unit,
  getFeatureHref?: superpositionFeature => string,
}

type tableSerialNumberConfig = {
  enabled?: bool,
  header?: string,
  width?: string,
  startAt?: int,
  align?: tableAlign,
}

type tableConfig = {serialNumber?: tableSerialNumberConfig}

// ─── Theme config ────────────────────────────────────────────────────────────
// Forward blend's FOUNDATION_THEME so the embeddable UI's inner BlendThemeProvider
// gets the same token shape it was built against, instead of inheriting the
// dashboard's outer BlendThemeProvider tokens.

type blendThemeConfig = {foundationTokens?: FoundationTokens.foundationThemeType}

type spThemeConfig = {
  mode?: string,
  blend?: blendThemeConfig,
}

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
  theme?: spThemeConfig,
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

type auditTrailDateRange = {
  startDate: Js.Date.t,
  endDate?: Js.Date.t,
}

type auditAction =
  | @as("INSERT") Insert
  | @as("UPDATE") Update
  | @as("DELETE") Delete

type auditTrailFilters = {
  dateRange?: auditTrailDateRange,
  tables?: array<string>,
  actions?: array<auditAction>,
}

module AuditTrail = {
  @module("superposition-embeddable-ui/audit-trail") @react.component
  external make: (~pageSize: int=?, ~filters: auditTrailFilters=?) => React.element = "AuditTrail"
}
