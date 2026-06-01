open SuperpositionBindings

@react.component
let make = (~remainingPath: list<string>) => {
  let {getCommonSessionDetails} = React.useContext(UserInfoProvider.defaultContext)
  let {orgId, merchantId, profileId} = getCommonSessionDetails()

  let scopeContext =
    [
      ("organization_id", JSON.Encode.string(orgId)),
      ("processor_merchant_id", JSON.Encode.string(merchantId)),
      ("profile_id", JSON.Encode.string(profileId)),
    ]->Js.Dict.fromArray

  Js.log2("scopeContext", scopeContext)

  let content = switch remainingPath {
  | list{"default-config", ..._} => <ConfigManager showResolvedValues=true />
  | list{"overrides", ..._} => <OverrideManager />
  | list{"dimensions", ..._} => <DimensionManager />
  | list{"audit", ..._} => <AuditTrail />
  | _ => <ConfigManager showResolvedValues=true />
  }

  <SuperpositionUIProvider
    config={{
      apiBaseUrl: "http://localhost:8080/v1/superposition",
      orgId: "localorg",
      workspace: "dev",
      scope: {
        context: scopeContext,
      },
      auth: {
        mode: Bearer,
        token: AuthUtils.getUserInfoDetailsFromLocalStorage().token->Option.getOr(""),
      },
      capabilities: {
        config: {
          create: true,
          update: false,
          delete: true,
          ramp: true,
          execute: true,
          editContext: true,
        },
        overrides: {create: true, editContext: true},
        dimensions: {create: true, editContext: true},
      },
      theme: {
        blend: {
          foundationTokens: FoundationTokens.foundationTheme,
        },
      },
    }}>
    <AlertProvider> {content} </AlertProvider>
  </SuperpositionUIProvider>
}
