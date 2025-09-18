open Typography

@react.component
let make = () => {
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (accountData, setAccountData) = React.useState(_ => [])
  let getAccounts = ReconEngineHooks.useGetAccounts()

  let getAccountsData = async _ => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let accountData = await getAccounts()
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

  <div className="flex flex-col gap-8">
    <PageUtils.PageHeading
      title="Transformation" customTitleStyle={`${heading.lg.semibold}`} customHeadingStyle="py-0"
    />
    <PageLoaderWrapper screenState>
      <RenderIf condition={accountData->Array.length == 0}>
        <div className="my-4">
          <NoDataFound
            message="No accounts found. Please create an account to view the sources."
            renderType={Painting}
            customMessageCss={`${body.lg.semibold} text-nd_gray-400`}
          />
        </div>
      </RenderIf>
      <RenderIf condition={accountData->Array.length > 0}>
        <Accordion
          initialExpandedArray=[0]
          accordion={accountData->Array.map((account): Accordion.accordion => {
            {
              title: account.account_name,
              renderContent: () => <ReconEngineAccountTransformationConfigs account={account} />,
              renderContentOnTop: Some(
                () => {
                  <ReconEngineAccountTransformationAccordionOnTop account={account} />
                },
              ),
            }
          })}
          accordianTopContainerCss="border border-nd_gray-150 rounded-lg"
          accordianBottomContainerCss="p-4 !bg-nd_gray-25"
          contentExpandCss="p-0"
          titleStyle={`${body.lg.semibold} text-nd_gray-800`}
          gapClass="flex flex-col gap-8"
        />
      </RenderIf>
    </PageLoaderWrapper>
  </div>
}
