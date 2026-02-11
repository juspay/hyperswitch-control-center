open Typography

@react.component
let make = () => {
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let (accountData, setAccountData) = React.useState(_ => [])
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let getAccounts = ReconEngineHooks.useGetAccounts()

  let getAccountsData = async _ => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let accountData = await getAccounts()
      setAccountData(_ => accountData)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch"))
    }
  }

  React.useEffect(() => {
    getAccountsData()->ignore
    None
  }, [])

  let tabs: array<Tabs.tab> = React.useMemo(() => {
    open Tabs
    accountData->Array.map(account => {
      {
        title: account.account_name,
        renderContent: () =>
          <FilterContext
            key={`recon-engine-transaction-${account.account_id}`}
            index={`recon-engine-transaction-${account.account_id}`}>
            <ReconEngineTransactionsContent account />
          </FilterContext>,
      }
    })
  }, [accountData])

  <div className="flex flex-col gap-4 w-full">
    <div className="flex flex-row justify-between items-center">
      <PageUtils.PageHeading
        title="Transactions" customTitleStyle={`${heading.lg.semibold}`} customHeadingStyle="py-0"
      />
      <div className="flex-shrink-0">
        <Button
          text="Generate Report"
          buttonType=Primary
          buttonSize=Large
          buttonState=Disabled
          onClick={_ => {
            mixpanelEvent(~eventName="recon_engine_transactions_generate_reports_clicked")
          }}
        />
      </div>
    </div>
    <PageLoaderWrapper screenState>
      <RenderIf condition={accountData->Array.length == 0}>
        <div className="my-4">
          <NoDataFound
            message="No recon rules found. Please create a recon rule to view the transactions."
            renderType={Painting}
            customMessageCss={`${body.lg.semibold} text-nd_gray-400`}
          />
        </div>
      </RenderIf>
      <RenderIf condition={accountData->Array.length > 0}>
        <Tabs
          tabs
          showBorder=true
          includeMargin=false
          defaultClasses={`!w-max flex flex-auto flex-row items-center justify-center !text-red-500 ${body.lg.semibold}`}
          selectTabBottomBorderColor="bg-primary"
          customBottomBorderColor="bg-nd_gray-150 mb-4"
        />
      </RenderIf>
    </PageLoaderWrapper>
  </div>
}
