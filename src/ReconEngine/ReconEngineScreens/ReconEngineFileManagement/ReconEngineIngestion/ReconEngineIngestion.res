open Typography

@react.component
let make = () => {
  open APIUtils
  let (showModal, setShowModal) = React.useState(_ => false)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let (accountData, setAccountData) = React.useState(_ => [])

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
        res->LogicUtils.getArrayDataFromJson(ReconEngineOverviewUtils.accountItemToObjMapper)
      setAccountData(_ => accountData)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => ()
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
            key="recon-engine-ingestion-history" index="recon-engine-ingestion-history">
            <ReconEngineIngestionHistory account showModal />
          </FilterContext>,
      }
    })
  }, (accountData, showModal))

  <div className="flex flex-col w-full gap-6">
    <div className="flex flex-row justify-between">
      <PageUtils.PageHeading
        title="File Management"
        subTitle="Manage your files for the Recon Engine"
        customSubTitleStyle={body.lg.medium}
        customTitleStyle={`${heading.lg.semibold} py-0`}
      />
      <Button
        text="Upload File"
        buttonType=Primary
        leftIcon={FontAwesome("upload")}
        onClick={_ => {
          setShowModal(_ => true)
        }}
        customButtonStyle="!my-3"
        buttonSize=Medium
      />
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
          defaultClasses={`!w-max flex flex-auto flex-row items-center justify-center ${body.md.semibold}`}
          selectTabBottomBorderColor="bg-primary"
        />
      </RenderIf>
    </PageLoaderWrapper>
    <RenderIf condition={showModal}>
      <ReconEngineFileUploadModal showModal setShowModal />
    </RenderIf>
  </div>
}
