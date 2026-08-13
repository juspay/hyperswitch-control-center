open Typography

@react.component
let make = () => {
  open ReconEngineHooks
  open LogicUtils
  open ReconEngineTypes
  open HSAnalyticsUtils

  let getAccounts = useGetAccounts()
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let {updateExistingKeys, removeKeys, filterValueJson} = React.useContext(
    FilterContext.filterContext,
  )
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

  let setInitialFilters = HSwitchRemoteFilter.useSetInitialFilters(
    ~updateExistingKeys,
    ~startTimeFilterKey,
    ~endTimeFilterKey,
    ~origin="recon_engine_transformed_entries_exceptions",
    ~range=180,
    (),
  )

  React.useEffect(() => {
    fetchAccounts()->ignore
    None
  }, [])

  React.useEffect(() => {
    if selectedAccountId->isNonEmptyString {
      if filterValueJson->getOptionValFromDict("account_ids")->Option.isSome {
        removeKeys(["account_ids"])
      } else if filterValueJson->isEmptyDict {
        setInitialFilters()
      }
    }
    None
  }, (selectedAccountId, filterValueJson))

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

  let dateDropDownTriggerMixpanelCallback = () => {
    mixpanelEvent(~eventName="recon_engine_transformed_entries_exceptions_date_filter_opened")
  }

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
      renderContent: () =>
        <ReconEngineTransformedEntryContent
          key={account.account_id} accountId={account.account_id}
        />,
    })
  }, [accountData])

  <div className="flex flex-col w-full">
    <div className="flex flex-row justify-between items-center">
      <PageUtils.PageHeading
        title="Transformed Entry Exceptions"
        customTitleStyle={`${heading.lg.semibold}`}
        customHeadingStyle="py-0"
      />
      <div className="flex flex-row -ml-1.5">
        <DynamicFilter
          title="ReconEngineTransformedEntryExceptionsDateFilter"
          initialFilters=[]
          options=[]
          popupFilterFields=[]
          initialFixedFilters={initialFixedFilterFields(
            null,
            ~events=dateDropDownTriggerMixpanelCallback,
          )}
          defaultFilterKeys=[startTimeFilterKey, endTimeFilterKey]
          tabNames=[]
          key="ReconEngineTransformedEntryExceptionsDateFilter"
          updateUrlWith=updateExistingKeys
          filterFieldsPortalName={filterFieldsPortalName}
          showCustomFilter=false
          refreshFilters=false
        />
      </div>
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
