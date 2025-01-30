open APIUtils
@react.component
let make = (~previewOnly=false) => {
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let url = RescriptReactRouter.useUrl()
  let pathVar = url.path->List.toArray->Array.joinWith("/")

  let (records, setRecords) = React.useState(_ => [])
  let (activeRoutingIds, setActiveRoutingIds) = React.useState(_ => [])
  let (routingType, setRoutingType) = React.useState(_ => [])
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)

  let (widthClass, marginClass) = React.useMemo(() => {
    previewOnly ? ("w-full", "mx-auto") : ("w-full", "mx-auto ")
  }, [previewOnly])

  let fetchRoutingRecords = async activeIds => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let routingUrl = `${getURL(~entityName=ROUTING, ~methodType=Get)}?limit=100`
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
      let activeRoutingUrl = getURL(~entityName=ACTIVE_ROUTING, ~methodType=Get)
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
  }, (pathVar, url.search))

  <PageLoaderWrapper screenState>
    <div className={`${widthClass} ${marginClass} gap-2.5`}>
      <div className="flex flex-col ">
        <PageUtils.PageHeading
          title="Smart Routing"
          subTitle="Smart Routing optimizes payment traffic across processors to boost success rates and reduce costs, offering flexible and reliable control"
        />
        <RenderIf condition={!previewOnly}>
          <ActiveRouting routingType />
        </RenderIf>
        <div className="mt-6">
          <div className="font-bold text-black my-2 text-lg">
            {"Smart Routing Configurations"->React.string}
          </div>
          <ActiveRouting.LevelWiseRoutingSection
            types=[VOLUME_SPLIT, ADVANCED, DEFAULTFALLBACK] onRedirectBaseUrl="routing"
          />
        </div>
      </div>
      <RenderIf condition={!previewOnly}>
        <div className="flex flex-col gap-3 mt-4">
          {if records->Array.length > 0 {
            <History records activeRoutingIds customTitle={"Manage Configurations"} />
          } else {
            <DefaultLandingPage
              height="90%"
              title="No Routing Rule Configured!"
              customStyle="py-16"
              overriddingStylesTitle="text-3xl font-semibold"
            />
          }}
        </div>
      </RenderIf>
    </div>
  </PageLoaderWrapper>
}
