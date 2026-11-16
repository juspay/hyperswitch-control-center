open APIUtils
open LogicUtils
open SuperpositionTypes
open SuperpositionUtils

let useScope = () => {
  let {orgId, merchantId, profileId} = React.useContext(
    UserInfoProvider.defaultContext,
  ).getCommonSessionDetails()
  let providerMerchantId = OMPSwitchHooks.useProviderMerchantId()

  React.useMemo(
    () => getScopeContext(~orgId, ~processorMerchantId=merchantId, ~profileId, ~providerMerchantId),
    (orgId, merchantId, profileId, providerMerchantId),
  )
}

let useCanManageConfigurations = () => {
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  userHasAccess(~groupAccess=ConfigurationsManage) == Access
}

let getDisplayPrefixes = () =>
  Window.env.superpositionConfigs->Option.mapOr([], configs =>
    configs.display_configs->Array.map(getConfigKey)
  )

// The proxy checks these against the org and workspace it is configured for.
let getProxyHeaders = () =>
  switch Window.env.superpositionConfigs {
  | Some(configs) =>
    [("x-org-id", configs.organization_id), ("x-workspace", configs.workspace)]->Dict.fromArray
  | None => Dict.make()
  }

let isConfigured = () =>
  switch Window.env.superpositionConfigs {
  | Some(configs) =>
    configs.organization_id->isNonEmptyString && configs.workspace->isNonEmptyString
  | None => false
  }

type api = {
  loadConfigs: unit => promise<configsData>,
  loadSpecializations: unit => promise<configsData>,
  explain: string => promise<array<explainStep>>,
  putContext: (
    ~condition: Dict.t<JSON.t>,
    ~override: Dict.t<JSON.t>,
    ~description: string,
    ~changeReason: string,
  ) => promise<unit>,
  removeKeys: (~context: context, ~keys: array<string>, ~changeReason: string) => promise<unit>,
  listAudit: unit => promise<array<auditLog>>,
}

let useSuperpositionApi = (): api => {
  let getURL = useGetURL()
  let getMethod = useGetMethod(~showErrorToast=false)
  let updateMethod = useUpdateMethod(~showErrorToast=false)
  let scope = useScope()

  let request = async (~path, ~method: Fetch.requestMethod, ~query=?, ~body=JSON.Encode.null) => {
    let url = getURL(
      ~entityName=V1(SUPERPOSITION),
      ~methodType=method,
      ~id=Some(path),
      ~queryParameters=query,
    )
    switch method {
    | Get => await getMethod(url, ~headers=getProxyHeaders())
    | _ => await updateMethod(url, body, method, ~headers=getProxyHeaders())
    }
  }

  let scopeBody = () => [("context", scope->JSON.Encode.object)]->getJsonFromArrayOfJson

  let listDefaultsAndDimensions = () =>
    Promise.all([
      request(~path="default-config", ~method=Get, ~query="all=true"),
      request(~path="dimension", ~method=Get, ~query="all=true"),
    ])

  let listContexts = (~matchStrategy, ~sortBy) =>
    request(
      ~path="context",
      ~method=Get,
      ~query=`all=true&dimension_match_strategy=${matchStrategy}&sort_on=weight&sort_by=${sortBy}&${scope->getDimensionQuery}`,
    )

  let toConfigsData = (~defaultsAndDimensions, ~contexts, ~resolved) => {
    let getResponse = index =>
      defaultsAndDimensions->Array.get(index)->Option.getOr(JSON.Encode.null)
    {
      defaults: getResponse(0)->getListFromResponse->Array.map(parseDefaultConfig),
      dimensions: getResponse(1)
      ->getListFromResponse
      ->Array.map(parseDimension)
      ->Array.filter(dimension => !(dimension->isReservedDimension)),
      contexts: contexts->getListFromResponse->Array.map(parseContext),
      resolved,
    }
  }

  let loadConfigs = async () => {
    let resolvePromise =
      request(~path="config/resolve/detailed", ~method=Post, ~body=scopeBody())
      ->Promise.thenResolve(json => Some(json->parseResolved))
      ->Promise.catch(_ => Promise.resolve(None))
    let (defaultsAndDimensions, contexts) = await Promise.all2((
      listDefaultsAndDimensions(),
      listContexts(~matchStrategy="non_conflicting", ~sortBy="asc"),
    ))
    let resolved = await resolvePromise
    toConfigsData(~defaultsAndDimensions, ~contexts, ~resolved)
  }

  let loadSpecializations = async () => {
    let (defaultsAndDimensions, contexts) = await Promise.all2((
      listDefaultsAndDimensions(),
      listContexts(~matchStrategy="subset", ~sortBy="desc"),
    ))
    toConfigsData(~defaultsAndDimensions, ~contexts, ~resolved=None)
  }

  let explain = async key => {
    let response = await request(
      ~path=`config/resolve/explain/${key->encodeURIComponent}`,
      ~method=Post,
      ~body=scopeBody(),
    )
    response->parseExplainTimeline
  }

  let putContext = async (~condition, ~override, ~description, ~changeReason) => {
    let body =
      [
        ("context", condition->JSON.Encode.object),
        ("override", override->JSON.Encode.object),
        ("description", description->JSON.Encode.string),
        ("change_reason", changeReason->JSON.Encode.string),
      ]->getJsonFromArrayOfJson
    let _ = await request(~path="context", ~method=Put, ~body)
  }

  let replaceOverride = async (~context: context, ~override, ~changeReason) => {
    let body =
      [
        ("context", [("id", context.id->JSON.Encode.string)]->getJsonFromArrayOfJson),
        ("override", override->getJsonFromArrayOfJson),
        ("change_reason", changeReason->JSON.Encode.string),
      ]->getJsonFromArrayOfJson
    let _ = await request(~path="context/overrides", ~method=Patch, ~body)
  }

  let removeKeys = async (~context: context, ~keys, ~changeReason) => {
    let remaining =
      context.override->Dict.toArray->Array.filter(((key, _)) => !(keys->Array.includes(key)))
    if remaining->isNonEmptyArray {
      await replaceOverride(~context, ~override=remaining, ~changeReason)
    } else {
      // DELETE takes no reason and the deleted row keeps its last one, so record it first.
      await replaceOverride(~context, ~override=context.override->Dict.toArray, ~changeReason)
      let _ = await request(~path=`context/${context.id->encodeURIComponent}`, ~method=Delete)
    }
  }

  let listAudit = async () => {
    let response = await request(
      ~path="audit",
      ~method=Get,
      ~query=`count=100&page=1&sort_by=desc&${scope->getDimensionQuery}`,
    )
    response
    ->getListFromResponse
    ->Array.map(parseAuditLog)
    ->Array.filter(log => !(log->isNoOpAuditUpdate))
  }

  {loadConfigs, loadSpecializations, explain, putContext, removeKeys, listAudit}
}

type configsPage = {
  screenState: PageLoaderWrapper.viewType,
  rows: array<configRow>,
  dimensions: array<dimension>,
  contexts: array<context>,
  reload: unit => unit,
}

let useConfigsPage = (~specializations=false): configsPage => {
  let api = useSuperpositionApi()
  let scope = useScope()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (data, setData) = React.useState(_ => None)

  let load = async (~silent=false) => {
    if !silent {
      setScreenState(_ => PageLoaderWrapper.Loading)
    }
    try {
      let configs = await (specializations ? api.loadSpecializations() : api.loadConfigs())
      setData(_ => Some(configs))
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | Exn.Error(e) =>
      setScreenState(_ => PageLoaderWrapper.Error(
        Exn.message(e)->Option.getOr("Could not load features"),
      ))
    }
  }

  React.useEffect(() => {
    load()->ignore
    None
  }, [scope])

  let rows = React.useMemo(
    () =>
      data->Option.mapOr([], data =>
        buildConfigRows(~data, ~scope, ~displayPrefixes=getDisplayPrefixes())
      ),
    (data, scope),
  )

  {
    screenState,
    rows,
    dimensions: data->Option.mapOr([], data => data.dimensions),
    contexts: data->Option.mapOr([], data => data.contexts),
    reload: () => load(~silent=true)->ignore,
  }
}
