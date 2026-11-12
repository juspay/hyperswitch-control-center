open Typography

@react.component
let make = () => {
  let getURL = APIUtils.useGetURL()
  let fetchDetails = APIUtils.useGetMethod(~showErrorToast=false)
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let manageAuthorization = userHasAccess(~groupAccess=AccountManage)
  let canManage = manageAuthorization === CommonAuthTypes.Access
  let (activeAction, setActiveAction) = React.useState(_ => None)
  let (data, setData) = React.useState(_ => [])
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (offset, setOffset) = React.useState(_ => 0)
  let (showModal, setShowModal) = React.useState(_ => false)
  let getAbortSignal = AbortControllerHook.useAbortController()
  let {merchantId} = React.useContext(UserInfoProvider.defaultContext).getCommonSessionDetails()

  let fetchKeys = async () => {
    let signal = getAbortSignal()
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let url = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~hyperswitchReconType=#API_KEYS,
        ~methodType=Get,
      )
      let response = await fetchDetails(url, ~signal)
      if !(signal->AbortControllerHook.isAborted) {
        setData(_ => response->ReconEngineApiKeysUtils.getItems)
        setScreenState(_ => PageLoaderWrapper.Success)
        setOffset(_ => 0)
      }
    } catch {
    | _ =>
      if !(signal->AbortControllerHook.isAborted) {
        setScreenState(_ => PageLoaderWrapper.Error("Could not load API keys. Please try again."))
      }
    }
  }

  React.useEffect(() => {
    setData(_ => [])
    setShowModal(_ => false)
    setActiveAction(_ => None)
    fetchKeys()->ignore
    None
  }, [merchantId])

  <div className="flex flex-col gap-6">
    <div className="flex flex-wrap items-center justify-between gap-4">
      <PageUtils.PageHeading
        title="API Keys" customTitleStyle={heading.lg.semibold} customHeadingStyle="py-0 !mb-0"
      />
      <ACLButton
        text="Create API key"
        authorization=manageAuthorization
        buttonSize=Small
        leftIcon={CustomIcon(<Icon name="nd-plus" size=16 />)}
        onClick={_ => setShowModal(_ => true)}
      />
    </div>
    <p className={`${body.md.regular} text-nd_gray-600`}>
      {"Manage API keys for your reconciliation integrations. Only key prefixes are visible after creation."->React.string}
    </p>
    <PageLoaderWrapper screenState>
      <LoadedTable
        title="API Keys"
        hideTitle=true
        entity={ReconEngineApiKeysEntity.tableEntity(~canManage, ~onAction=(apiKey, action) => {
          if canManage {
            setActiveAction(_ => Some((apiKey, action)))
          }
        })}
        actualData={data->Array.map(Nullable.make)}
        resultsPerPage=10
        showSerialNumber=true
        totalResults={data->Array.length}
        currentFetchCount={data->Array.length}
        offset
        setOffset
        showAutoScroll=true
        tableheadingClass="h-12"
        tableHeadingTextClass="!font-normal"
        nonFrozenTableParentClass="!rounded-lg"
        loadedTableParentClass="flex flex-col"
        enableEqualWidthCol=false
      />
    </PageLoaderWrapper>
    <RenderIf condition=showModal>
      <ReconEngineApiKeysCreateModal
        key=merchantId
        onClose={() => setShowModal(_ => false)}
        onCreated={() => fetchKeys()->ignore}
      />
    </RenderIf>
    {switch activeAction {
    | Some((apiKey, action)) =>
      <ReconEngineApiKeysManageModal
        key=apiKey.id
        apiKey
        action
        onClose={() => setActiveAction(_ => None)}
        onUpdated={() => {
          setActiveAction(_ => None)
          fetchKeys()->ignore
        }}
      />
    | None => React.null
    }}
  </div>
}
