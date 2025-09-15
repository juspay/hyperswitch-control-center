open Typography

@react.component
let make = (~accountId) => {
  open APIUtils
  open LogicUtils
  open ReconEngineFileManagementUtils
  open ReconEngineUtils

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let url = RescriptReactRouter.useUrl()

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (ingestionConfigs, setIngestionConfigs) = React.useState(_ => [
    Dict.make()->ingestionConfigItemToObjMapper,
  ])
  let (accountData, setAccountData) = React.useState(_ => Dict.make()->accountItemToObjMapper)
  let (tabIndex, setTabIndex) = React.useState(_ => None)

  let getIngestionDetails = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let ingestionConfigUrl = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Get,
        ~hyperswitchReconType=#INGESTION_CONFIG,
        ~queryParamerters=Some(`account_id=${accountId}`),
      )
      let accountUrl = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Get,
        ~hyperswitchReconType=#ACCOUNTS_LIST,
        ~id=Some(accountId),
      )
      let ingestionConfigsRes = await fetchDetails(ingestionConfigUrl)
      let accountRes = await fetchDetails(accountUrl)
      let ingestionConfigs =
        ingestionConfigsRes->getArrayDataFromJson(ingestionConfigItemToObjMapper)
      let accountData = accountRes->getDictFromJsonObject->accountItemToObjMapper
      setAccountData(_ => accountData)
      setIngestionConfigs(_ => ingestionConfigs)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Custom)
    }
  }

  let tabs: array<Tabs.tab> = React.useMemo(() => {
    open Tabs
    ingestionConfigs->Array.map(config => {
      title: config.name,
      onTabSelection: {_ => ()},
      renderContent: () =>
        <FilterContext
          key="recon-engine-accounts-sources-details" index="recon-engine-accounts-sources-details">
          <ReconEngineAccountSourceTabDetails config />
        </FilterContext>,
    })
  }, [ingestionConfigs])

  React.useEffect(() => {
    getIngestionDetails()->ignore
    None
  }, [])

  let getActiveTabIndex = () => {
    let tabIndexParam =
      url.search
      ->getDictFromUrlSearchParams
      ->getvalFromDict("ingestionConfigTabIndex")
    setTabIndex(_ => tabIndexParam)
  }

  React.useEffect(() => {
    getActiveTabIndex()
    None
  }, [url.search])

  <div className="flex flex-col gap-6 w-full">
    <div className="flex flex-row items-center justify-between">
      <BreadCrumbNavigation
        path=[{title: "Sources", link: `/v1/recon-engine/sources`}]
        currentPageTitle=accountData.account_name
        cursorStyle="cursor-pointer"
        customTextClass="text-nd_gray-400"
        titleTextClass="text-nd_gray-600 font-medium"
        fontWeight="font-medium"
        dividerVal=Slash
        childGapClass="gap-2"
      />
      <ToolTip
        toolTipPosition=Bottom
        description="This feature is available in prod"
        toolTipFor={<Button
          text="Add New Source"
          customButtonStyle="!cursor-not-allowed"
          buttonState=Normal
          buttonType=Primary
          onClick={_ => ()}
          buttonSize=Large
        />}
      />
    </div>
    <div className="flex flex-col gap-2">
      <PageUtils.PageHeading
        title=accountData.account_name
        customTitleStyle={`${heading.lg.semibold}`}
        customHeadingStyle="py-0"
      />
      <PageLoaderWrapper screenState>
        <RenderIf condition={ingestionConfigs->Array.length == 0}>
          <div className="my-4">
            <NoDataFound
              message="No ingestion configs found. Please create a config to view the details."
              renderType={Painting}
              customMessageCss={`${body.lg.semibold} text-nd_gray-400`}
            />
          </div>
        </RenderIf>
        <RenderIf condition={ingestionConfigs->Array.length > 0}>
          <Tabs
            tabs
            showBorder=true
            includeMargin=false
            initialIndex={tabIndex->Option.getOr("0")->getIntFromString(0)}
            defaultClasses={`!w-max flex flex-auto flex-row items-center justify-center ${body.md.semibold}`}
            selectTabBottomBorderColor="bg-primary"
          />
        </RenderIf>
      </PageLoaderWrapper>
    </div>
  </div>
}
