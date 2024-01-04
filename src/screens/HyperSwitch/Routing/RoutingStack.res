open APIUtils
@react.component
let make = (~remainingPath, ~previewOnly=false) => {
  let fetchDetails = useGetMethod()
  let url = RescriptReactRouter.useUrl()
  let pathVar = url.path->Belt.List.toArray->Array.joinWith("/")

  let (records, setRecords) = React.useState(_ => [])
  let (activeRoutingIds, setActiveRoutingIds) = React.useState(_ => [])
  let (routingType, setRoutingType) = React.useState(_ => [])
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (tabIndex, setTabIndex) = React.useState(_ => 0)

  let setCurrentTabName = Recoil.useSetRecoilState(RoutingUtils.currentTabNameRecoilAtom)

  let (widthClass, marginClass) = React.useMemo1(() => {
    previewOnly ? ("w-full", "mx-auto") : ("w-full", "mx-auto ")
  }, [previewOnly])

  let tabs: array<Tabs.tab> = React.useMemo(() => {
    open Tabs
    [
      {
        title: "Manage rules",
        renderContent: () => {
          records->Array.length > 0
            ? <History records activeRoutingIds />
            : <DefaultLandingPage
                height="90%"
                title="No Routing Rule Configured!"
                customStyle="py-16"
                overriddingStylesTitle="text-3xl font-semibold"
              />
        },
      },
      {
        title: "Active configuration",
        renderContent: () => <ActiveRouting routingType />,
      },
    ]
  })

  let fetchRoutingRecords = async activeIds => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let routingUrl = `${getURL(~entityName=ROUTING, ~methodType=Get, ())}?limit=100`
      let routingJson = await fetchDetails(routingUrl)
      let configuredRules = routingJson->RoutingUtils.getRecordsObject

      let recordsData =
        configuredRules
        ->Js.Json.array
        ->Js.Json.decodeArray
        ->Belt.Option.getWithDefault([])
        ->Belt.Array.keepMap(Js.Json.decodeObject)
        ->Array.map(HistoryEntity.itemToObjMapper)

      // To sort the data in a format that active routing always comes at top of the table
      // For ref:https://rescript-lang.org/docs/manual/latest/api/js/array-2#sortinplacewith

      let sortedHistoryRecords =
        recordsData
        ->Js.Array2.sortInPlaceWith((item1, item2) => {
          if activeIds->Array.includes(item1.id) {
            -1
          } else if activeIds->Array.includes(item2.id) {
            1
          } else {
            0
          }
        })
        ->Array.map(Js.Nullable.return)

      setRecords(_ => sortedHistoryRecords)
      setScreenState(_ => PageLoaderWrapper.Success)

      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | Js.Exn.Error(e) =>
      let err = Js.Exn.message(e)->Belt.Option.getWithDefault("Failed to Fetch!")
      setScreenState(_ => PageLoaderWrapper.Error(err))
    }
  }

  let fetchActiveRouting = async () => {
    open LogicUtils
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let activeRoutingUrl = `${getURL(~entityName=ROUTING, ~methodType=Get, ())}/active`
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
        let defaultFallback = [("kind", "default"->Js.Json.string)]->Dict.fromArray
        setRoutingType(_ => [defaultFallback->Js.Json.object_])
        setScreenState(_ => PageLoaderWrapper.Success)
      }
    } catch {
    | Js.Exn.Error(e) =>
      let err = Js.Exn.message(e)->Belt.Option.getWithDefault("Failed to Fetch!")
      setScreenState(_ => PageLoaderWrapper.Error(err))
    }
  }

  React.useEffect2(() => {
    fetchActiveRouting()->ignore
    None
  }, (pathVar, url.search))

  let getTabName = index => index == 0 ? "active" : "history"

  <PageLoaderWrapper screenState>
    <div className={`${widthClass} ${marginClass} gap-2.5`}>
      <div className="flex flex-col gap-6">
        <PageUtils.PageHeading
          title="Smart routing configuration"
          subTitle="Smart routing stack helps you to increase success rates and reduce costs by optimising your payment traffic across the various processors in the most customised yet reliable way. Set it up based on the preferred level of control"
        />
        <ActiveRouting.LevelWiseRoutingSection types=[VOLUME_SPLIT, ADVANCED, DEFAULTFALLBACK] />
      </div>
      <UIUtils.RenderIf condition={!previewOnly}>
        <div className="flex flex-col gap-12">
          <EntityScaffold
            entityName="HyperSwitch Priority Logic"
            remainingPath
            renderList={() =>
              <Tabs
                initialIndex={tabIndex >= 0 ? tabIndex : 0}
                tabs
                showBorder=false
                includeMargin=false
                lightThemeColor="black"
                defaultClasses="!w-max flex flex-auto flex-row items-center justify-center px-6 font-semibold text-body"
                onTitleClick={indx => {
                  setTabIndex(_ => indx)
                  setCurrentTabName(._ => getTabName(indx))
                }}
              />}
          />
          <UIUtils.RenderIf condition={tabIndex == 0}>
            <div>
              <p
                className="font-bold text-xl text-black text-opacity-75 dark:text-white dark:text-opacity-75">
                {"Launching Soon"->React.string}
              </p>
              <ActiveRouting.LevelWiseRoutingSection types=[COST] />
            </div>
          </UIUtils.RenderIf>
        </div>
      </UIUtils.RenderIf>
    </div>
  </PageLoaderWrapper>
}
