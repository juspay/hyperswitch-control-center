%%raw(`require("superposition-embeddable-ui/styles.css")`)

open SuperpositionBindings
open SuperpositionUtils
open LogicUtils

module ConfiguredSuperpositionApp = {
  @react.component
  let make = (
    ~superpositionConfigs: HyperSwitchConfigTypes.superpositionConfig,
    ~remainingPath: list<string>,
  ) => {
    let {getCommonSessionDetails} = React.useContext(UserInfoProvider.defaultContext)
    let {orgId, merchantId, profileId} = getCommonSessionDetails()
    let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
    let canManageConfigurations = userHasAccess(~groupAccess=ConfigurationsManage) == Access
    let superpositionApiBaseUrl = `${APIUtilsTypes.getBaseUrl(OLTP)}/v1/superposition`
    let token = AuthUtils.getUserInfoDetailsFromLocalStorage().token->Option.getOr("")

    let content = switch remainingPath {
    | list{"default-config", ..._} => <ConfigManager showResolvedValues=true editable=false />
    | list{"overrides", ..._} => <OverrideManager />
    | list{"dimensions", ..._} => <DimensionManager editable=false />
    | list{"audit", ..._} => <AuditTrail />
    | _ => <ConfigManager showResolvedValues=true editable=false />
    }

    let config: embeddableConfig = React.useMemo(() => {
      {
        apiBaseUrl: superpositionApiBaseUrl,
        orgId: superpositionConfigs.organization_id,
        workspace: superpositionConfigs.workspace,
        scope: {
          context: getScopeContext(~orgId, ~merchantId, ~profileId),
        },
        auth: {
          mode: Bearer,
          token,
        },
        capabilities: {
          overrides: {
            create: canManageConfigurations,
            update: canManageConfigurations,
          },
        },
        filters: defaultFiltersConfig,
        table: defaultTableConfig,
        theme: defaultThemeConfig,
        layout: defaultLayoutConfig,
      }
    }, (
      superpositionApiBaseUrl,
      superpositionConfigs,
      orgId,
      merchantId,
      profileId,
      token,
      canManageConfigurations,
    ))

    <SuperpositionUIProvider config>
      <AlertProvider> {content} </AlertProvider>
    </SuperpositionUIProvider>
  }
}

@react.component
let make = (~remainingPath: list<string>) =>
  switch Window.env.superpositionConfigs {
  | Some(superpositionConfigs)
    if superpositionConfigs.organization_id->isNonEmptyString &&
      superpositionConfigs.workspace->isNonEmptyString =>
    <ConfiguredSuperpositionApp superpositionConfigs remainingPath />
  | _ => <NoDataFound message="Superposition configuration is missing" renderType=NotFound />
  }
