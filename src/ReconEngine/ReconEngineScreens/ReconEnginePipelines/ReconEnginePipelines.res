open Typography

@react.component
let make = () => {
  open PageUtils

  let getAccounts = ReconEngineHooks.useGetAccounts()

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (accountData, setAccountData) = React.useState(_ => [])
  let (refreshTrigger, setRefreshTrigger) = React.useState(_ => false)

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

  <div className="flex flex-col">
    <div className="flex flex-wrap items-center justify-between gap-x-4 gap-y-2">
      <PageHeading
        title="Pipelines"
        customTitleStyle={`${heading.lg.semibold}`}
        customHeadingStyle="py-0 !mb-0"
      />
      <div className="flex flex-wrap items-center gap-3">
        <PortalCapture name=ReconEngineFilterUtils.globalDateFilterPortalName customStyle="-mt-1" />
        <ReconEnginePipelinesUploadModal
          accountData onModalToggle={() => setRefreshTrigger(prev => !prev)}
        />
      </div>
    </div>
    <ReconEnginePipelinesStatCards refreshTrigger />
    <PageLoaderWrapper screenState>
      <ReconEnginePipelinesTable accountData refreshTrigger />
    </PageLoaderWrapper>
  </div>
}
