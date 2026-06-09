open SuperpositionBindings
open SuperpositionUtils

@react.component
let make = (~remainingPath: list<string>) => {
  let {getCommonSessionDetails} = React.useContext(UserInfoProvider.defaultContext)
  let {orgId, merchantId, profileId} = getCommonSessionDetails()
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let superpositionApiBaseUrl = `${Window.env.apiBaseUrl}/v1/superposition`
  let scopeContext =
    [
      (getDimensionsForFixedContext(Org), JSON.Encode.string(orgId)),
      (getDimensionsForFixedContext(Merchant), JSON.Encode.string(merchantId)),
      (getDimensionsForFixedContext(Profile), JSON.Encode.string(profileId)),
    ]->Js.Dict.fromArray

  let content = switch remainingPath {
  | list{"default-config", ..._} => <ConfigManager showResolvedValues=true editable=false />
  | list{"overrides", ..._} => <OverrideManager />
  | list{"dimensions", ..._} => <DimensionManager editable=false />
  | list{"audit", ..._} => <AuditTrail />
  | _ => <ConfigManager showResolvedValues=true />
  }

  let superpositionConfigs = switch Window.env.superpositionConfigs {
  | Some(configs) => configs
  | None => {
      organization_id: "",
      workspace: "",
    }
  }

  <SuperpositionUIProvider
    config={{
      apiBaseUrl: superpositionApiBaseUrl,
      orgId: superpositionConfigs.organization_id,
      workspace: superpositionConfigs.workspace,
      scope: {
        context: scopeContext,
      },
      auth: {
        mode: Bearer,
        token: AuthUtils.getUserInfoDetailsFromLocalStorage().token->Option.getOr(""),
      },
      capabilities: {
        overrides: {
          create: userHasAccess(~groupAccess=ConfigurationsManage) == Access,
          update: userHasAccess(~groupAccess=ConfigurationsManage) == Access,
        },
      },
      table: {
        defaultConfig: {
          searchAlign: Left,
        },
        overrides: {
          searchAlign: Left,
        },
        dimensions: {
          searchAlign: Left,
        },
        audit: {
          searchAlign: Left,
        },
      },
      theme: {
        colors: {
          surfaceMuted: "#ffffff",
        },
        blend: {
          foundationTokens: FoundationTokens.foundationTheme,
        },
        radius: {
          sm: "4px",
          md: "6px",
          lg: "8px",
        },
        spacing: {
          xs: "4px",
          sm: "12px",
          md: "16px",
          lg: "20px",
        },
        typography: {
          fontFamily: "Inter, -apple-system, BlinkMacSystemFont, \"Segoe UI\", Roboto, system-ui, sans-serif",
          fontSize: "14px",
        },
        card: {
          padding: "16px",
          borderRadius: "8px",
          shadow: "0px 2px 2px 0px rgba(0, 0, 0, 0.04)",
        },
        button: {
          danger: {
            bgColor: "#FFF1F2",
            textColor: "#cd5454",
            borderColor: "#FECACA",
            borderRadius: "12px",
            shadow: "none",
          },
        },
        search: {
          align: Left,
          width: "320px",
          height: "38px",
          padding: "8px 12px",
          borderRadius: "8px",
          fontSize: "14px",
          fontWeight: "500",
          shadow: "none",
        },
      },
      layout: {
        modalWidth: "min(640px, calc(100vw - 48px))",
        modalMinWidth: "min(360px, calc(100vw - 32px))",
        modalMaxWidth: "640px",
        modalMaxHeight: "min(82vh, 760px)",
        overrideEditorModalWidth: "min(820px, calc(100vw - 48px))",
        overrideEditorModalMaxWidth: "820px",
        overrideEditorModalMaxHeight: "min(86vh, 820px)",
        overrideDetailsModalWidth: "min(720px, calc(100vw - 48px))",
        overrideDetailsModalMaxWidth: "720px",
        overrideDetailsModalMaxHeight: "min(80vh, 680px)",
        overrideListGap: "16px",
        overrideCardPadding: "16px",
        tableEmptyMinHeight: "160px",
      },
    }}>
    <AlertProvider> {content} </AlertProvider>
  </SuperpositionUIProvider>
}
