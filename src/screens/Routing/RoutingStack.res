open APIUtils
@react.component
let make = (~remainingPath, ~previewOnly=false) => {
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let updateDetails = useUpdateMethod(~showErrorToast=false)
  let url = RescriptReactRouter.useUrl()
  let pathVar = url.path->List.toArray->Array.joinWith("/")

  let (records, setRecords) = React.useState(_ => [])
  let (activeRoutingIds, setActiveRoutingIds) = React.useState(_ => [])
  let (routingType, setRoutingType) = React.useState(_ => [])
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (tabIndex, setTabIndex) = React.useState(_ => 0)
  let (deEntryState, setDeEntryState) = React.useState(_ => previewOnly ? #Local : #Checking)
  let (isCutover, setIsCutover) = React.useState(_ => false)
  let debitRoutingValue =
    (
      HyperswitchAtom.businessProfileFromIdAtomInterface->Recoil.useRecoilValueFromAtom
    ).is_debit_routing_enabled->Option.getOr(false)
  let setCurrentTabName = Recoil.useSetRecoilState(HyperswitchAtom.currentTabNameRecoilAtom)
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()

  let (widthClass, marginClass) = React.useMemo(() => {
    previewOnly ? ("w-full", "mx-auto") : ("w-full", "mx-auto ")
  }, [previewOnly])

  let tabs: array<Tabs.tab> = React.useMemo(() => {
    open Tabs
    let hasWorkflowsManageAccess = userHasAccess(~groupAccess=WorkflowsManage) === Access
    let baseTabs = [
      {
        title: "Active configuration",
        renderContent: () => <ActiveRouting routingType isCutover />,
      },
    ]
    hasWorkflowsManageAccess
      ? baseTabs->Array.concat([
          {
            title: "Configuration History",
            renderContent: () => {
              records->Array.length > 0
                ? <History records activeRoutingIds />
                : <DefaultLandingPage
                    height="90%"
                    title="No Routing Rule Configured!"
                    customStyle="py-16"
                    overridingStylesTitle="text-3xl font-semibold"
                  />
            },
          },
        ])
      : baseTabs
  }, (routingType, debitRoutingValue, isCutover))

  let fetchRoutingRecords = async activeIds => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let routingUrl = `${getURL(~entityName=V1(ROUTING), ~methodType=Get)}?limit=100`
      let routingJson = await fetchDetails(routingUrl)
      let configuredRules = routingJson->RoutingUtils.getRecordsObject
      let recordsData =
        configuredRules
        ->Belt.Array.keepMap(JSON.Decode.object)
        ->Array.map(HistoryEntity.itemToObjMapper)

      // To sort the data in a format that active routing always comes at top of the table
      // For ref:https://rescript-lang.org/docs/manual/latest/api/js/array-2#sortinplacewith

      let sortedHistoryRecords =
        recordsData
        ->Array.toSorted((item1, item2) => {
          if activeIds->Array.includes(item1.id) {
            -1.
          } else if activeIds->Array.includes(item2.id) {
            1.
          } else {
            0.
          }
        })
        ->Array.map(Nullable.make)

      setRecords(_ => sortedHistoryRecords)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | Exn.Error(e) =>
      let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
      setScreenState(_ => PageLoaderWrapper.Error(err))
    }
  }

  let fetchActiveRouting = async () => {
    open LogicUtils
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let activeRoutingUrl = getURL(~entityName=V1(ACTIVE_ROUTING), ~methodType=Get)
      let routingJson = await fetchDetails(activeRoutingUrl)

      let routingArr = routingJson->getArrayFromJson([])

      if routingArr->Array.length > 0 {
        let currentActiveIds = []
        routingArr->Array.forEach(ele => {
          let id = ele->getDictFromJsonObject->getString("id", "")
          currentActiveIds->Array.push(id)
        })
        await fetchRoutingRecords(currentActiveIds)
        setActiveRoutingIds(_ => currentActiveIds)
        setRoutingType(_ => routingArr)
      } else {
        await fetchRoutingRecords([])
        let defaultFallback = [("kind", "default"->JSON.Encode.string)]->Dict.fromArray
        setRoutingType(_ => [defaultFallback->JSON.Encode.object])
        setScreenState(_ => PageLoaderWrapper.Success)
      }
    } catch {
    | Exn.Error(e) =>
      let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
      setScreenState(_ => PageLoaderWrapper.Error(err))
    }
  }

  React.useEffect(() => {
    fetchActiveRouting()->ignore
    None
  }, (pathVar, url.search, debitRoutingValue))

  let checkRoutingEntry = async () => {
    open LogicUtils
    try {
      let entryUrl = getURL(~entityName=V1(ROUTING), ~methodType=Get, ~id=Some("entry"))
      let res = await updateDetails(entryUrl, JSON.Encode.null, Post)
      let cutover = res->getDictFromJsonObject->getBool("is_cutover", false)
      setIsCutover(_ => cutover)
      setDeEntryState(_ => #Local)
    } catch {
    | Exn.Error(_) => setDeEntryState(_ => #Local)
    }
  }

  let openDeRoutingPage = async target => {
    open LogicUtils
    try {
      let entryUrl = getURL(~entityName=V1(ROUTING), ~methodType=Get, ~id=Some("entry"))
      let res = await updateDetails(`${entryUrl}?target=${target}`, JSON.Encode.null, Post)
      let redirectUrl = res->getDictFromJsonObject->getString("redirect_url", "")
      if redirectUrl->isNonEmptyString {
        redirectUrl->Window._open
      }
    } catch {
    | Exn.Error(_) => ()
    }
  }

  React.useEffect0(() => {
    if !previewOnly {
      checkRoutingEntry()->ignore
    }
    None
  })

  let getTabName = index => index == 0 ? "active" : "history"

  switch deEntryState {
  | #Checking =>
    <PageLoaderWrapper screenState=PageLoaderWrapper.Loading> {React.null} </PageLoaderWrapper>
  | #Local =>
    <PageLoaderWrapper screenState>
      <div className={`${widthClass} ${marginClass} gap-2.5`}>
        <div className="flex flex-col">
          <PageUtils.PageHeading title="Smart Routing Configurations" />
          <ActiveRouting.LevelWiseRoutingSection
            types=[AUTH_RATE_ROUTING, ADVANCED, VOLUME_SPLIT, DEFAULTFALLBACK]
            onRedirectBaseUrl="routing"
            isCutover
            onDeRedirect={target => openDeRoutingPage(target)->ignore}
          />
        </div>
        <RenderIf condition={!previewOnly}>
          <div className="flex flex-col gap-12">
            <EntityScaffold
              entityName="HyperSwitch Priority Logic"
              remainingPath
              renderList={() =>
                <Tabs
                  initialIndex={tabIndex >= 0 ? tabIndex : 0}
                  tabs
                  onTitleClick={index => {
                    setTabIndex(_ => index)
                    setCurrentTabName(_ => getTabName(index))
                  }}
                />}
            />
          </div>
        </RenderIf>
      </div>
    </PageLoaderWrapper>
  }
}
