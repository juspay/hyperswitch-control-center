open Typography

@react.component
let make = () => {
  open ReconEngineHooks
  open LogicUtils
  open ReconEngineTypes
  open HSAnalyticsUtils

  let getAccounts = useGetAccounts()
  let {removeKeys, filterValueJson, filterValue} = React.useContext(FilterContext.filterContext)
  let url = RescriptReactRouter.useUrl()
  let basePath = GlobalVars.appendDashboardPath(
    ~url="/v1/recon-engine/exceptions/transformed-entries",
  )

  let (accountData, setAccountData) = React.useState((_): array<accountType> => [])
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)

  let selectedAccountId = React.useMemo(() => {
    let accountIdFromUrl =
      url.search->getDictFromUrlSearchParams->getValueFromDict("account_id", "")
    switch accountData->Array.find(account => account.account_id === accountIdFromUrl) {
    | Some(account) => account.account_id
    | None =>
      (
        accountData->getValueFromArray(0, Dict.make()->ReconEngineUtils.accountItemToObjMapper)
      ).account_id
    }
  }, (url.search, accountData))

  let fetchAccounts = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let accounts = await getAccounts()
      setAccountData(_ => accounts)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch accounts"))
    }
  }

  React.useEffect(() => {
    fetchAccounts()->ignore
    None
  }, [])

  React.useEffect(() => {
    if (
      selectedAccountId->isNonEmptyString &&
        filterValueJson->getOptionValFromDict("account_ids")->Option.isSome
    ) {
      removeKeys(["account_ids"])
    }
    None
  }, (selectedAccountId, filterValue))

  React.useEffect(() => {
    if selectedAccountId->isNonEmptyString {
      let accountIdFromUrl =
        url.search->getDictFromUrlSearchParams->getValueFromDict("account_id", "")
      if accountIdFromUrl !== selectedAccountId {
        RescriptReactRouter.replace(`${basePath}?account_id=${selectedAccountId}`)
      }
    }
    None
  }, (selectedAccountId, url.search))

  let initialTabIndex = React.useMemo(() => {
    selectedAccountId->isNonEmptyString
      ? accountData
        ->Array.findIndexOpt(account => account.account_id === selectedAccountId)
        ->Option.getOr(0)
      : 0
  }, (selectedAccountId, accountData))

  let resetFiltersForAccountSwitch = () => {
    let keysToRemove =
      filterValueJson
      ->Dict.keysToArray
      ->Array.filter(key => key !== startTimeFilterKey && key !== endTimeFilterKey)
      ->Array.concat(["account_ids"])
    removeKeys(keysToRemove)
  }

  let onTitleClick = idx => {
    switch accountData->Array.get(idx) {
    | Some(account) =>
      RescriptReactRouter.push(`${basePath}?account_id=${account.account_id}`)
      resetFiltersForAccountSwitch()
    | None => ()
    }
  }

  let tabs: array<Tabs.tab> = React.useMemo(() => {
    accountData->Array.map((account): Tabs.tab => {
      title: account.account_name,
      renderContent: () => {
        <RenderIf condition={selectedAccountId === account.account_id}>
          <ReconEngineTransformedEntryContent
            key={account.account_id} accountId={account.account_id}
          />
        </RenderIf>
      },
    })
  }, (accountData, selectedAccountId))

  <div className="flex flex-col w-full">
    <div className="flex flex-row justify-between items-center">
      <PageUtils.PageHeading
        title="Transformed Entry Exceptions"
        customTitleStyle={`${heading.lg.semibold}`}
        customHeadingStyle="py-0"
      />
      <PortalCapture name=ReconEngineFilterUtils.globalDateFilterPortalName customStyle="-mt-1" />
    </div>
    <PageLoaderWrapper screenState>
      <RenderIf condition={accountData->isEmptyArray}>
        <div className="my-4">
          <NoDataFound
            message="No accounts found. Please create an account to view the sources."
            renderType={Painting}
            customMessageCss={`${body.lg.semibold} text-nd_gray-400`}
          />
        </div>
      </RenderIf>
      <RenderIf condition={accountData->isNonEmptyArray}>
        <Tabs tabs initialIndex=initialTabIndex onTitleClick />
      </RenderIf>
    </PageLoaderWrapper>
  </div>
}
