open Typography

@react.component
let make = () => {
  open APIUtils
  open LogicUtils

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (accountData, setAccountData) = React.useState(_ => [])
  let (tabIndex, setTabIndex) = React.useState(_ => 0)

  let getAccountsData = async _ => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let url = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Get,
        ~hyperswitchReconType=#ACCOUNTS_LIST,
      )
      let res = await fetchDetails(url)
      let accountData =
        res->getArrayDataFromJson(ReconEngineAccountsUtils.getAccountPayloadFromDict)
      setAccountData(_ => accountData)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch accounts"))
    }
  }

  React.useEffect(() => {
    getAccountsData()->ignore
    None
  }, [])

  let tabs: array<Tabs.tab> = React.useMemo(() => {
    open Tabs
    accountData->Array.map(account => {
      let renderContent = () => {
        <ReconEngineConnectionDisplay accountId={account.account_id} />
      }
      {
        title: account.account_name,
        renderContent,
      }
    })
  }, [accountData])

  <div className="flex flex-col gap-4 w-full">
    <PageUtils.PageHeading
      title="Connections" customTitleStyle={`${heading.lg.semibold}`} customHeadingStyle="py-0"
    />
    <PageLoaderWrapper screenState>
      <RenderIf condition={accountData->Array.length == 0}>
        <div className="my-4">
          <NoDataFound
            message="No accounts found. Please configure accounts to view connections."
            renderType={Painting}
            customMessageCss={`${body.lg.semibold} text-nd_gray-400`}
          />
        </div>
      </RenderIf>
      <RenderIf condition={accountData->Array.length > 0}>
        <Tabs
          initialIndex={tabIndex >= 0 ? tabIndex : 0}
          tabs
          showBorder=true
          includeMargin=false
          defaultClasses={`!w-max flex flex-auto flex-row items-center justify-center px-6 ${body.md.semibold}`}
          onTitleClick={index => {
            setTabIndex(_ => index)
          }}
          selectTabBottomBorderColor="bg-primary"
          customBottomBorderColor="bg-nd_gray-150 mb-6"
        />
      </RenderIf>
    </PageLoaderWrapper>
  </div>
}
