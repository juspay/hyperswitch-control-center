@react.component
let make = () => {
  open APIUtils
  open HierarchicalConfigTypes
  open HierarchicalConfigUtils

  let getURL = useGetURL()
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let connectorsManageAccess = userHasAccess(~groupAccess=ConnectorsManage)
  let fetchList = useUpdateMethod(~showErrorToast=false)
  let {updateTransactionEntity} = OMPSwitchHooks.useUserInfo()
  let {getResolvedUserInfo} = React.useContext(UserInfoProvider.defaultContext)
  let {transactionEntity, merchantId} = getResolvedUserInfo()
  let (resourceType, setResourceType) = React.useState(_ => ApplePay)
  let (resources, setResources) = React.useState(_ => [])
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (showAddModal, setShowAddModal) = React.useState(_ => false)
  let (showLinkModal, setShowLinkModal) = React.useState(_ => false)
  let (resourceToLink, setResourceToLink) = React.useState(_ => None)
  let (offset, setOffset) = React.useState(_ => 0)

  let fetchResources = async (~resourceType) => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let url = getURL(~entityName=V1(RESOURCES_LIST), ~methodType=Post)
      let response = await fetchList(url, getListPayload(~resourceType), Post)
      setResources(_ => response->getResourcesFromResponse)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | Exn.Error(e) =>
      setResources(_ => [])
      setScreenState(_ => PageLoaderWrapper.Error(
        getApiErrorMessage(~error=e, ~fallback="Failed to fetch resources"),
      ))
    }
  }

  React.useEffect(() => {
    setOffset(_ => 0)
    fetchResources(~resourceType)->ignore
    None
  }, (transactionEntity, merchantId, resourceType))

  let refreshFor = createdType =>
    if createdType == resourceType {
      fetchResources(~resourceType)->ignore
    } else {
      setResourceType(_ => createdType)
    }

  let onAddSuccess = createdType => {
    setShowAddModal(_ => false)
    refreshFor(createdType)
  }

  let onLinkClick = resource => {
    mixpanelEvent(~eventName=`hierarchical_config_${(resourceType :> string)}_link_clicked`)
    setResourceToLink(_ => Some(resource))
    setShowLinkModal(_ => true)
  }

  let credentialName = resourceType->getCredentialName
  let typeLabel = resourceType->getResourceTypeLabel

  let resourceTable =
    <div className="mt-6">
      <PageLoaderWrapper screenState>
        <LoadedTable
          title="Hierarchical Resources"
          hideTitle=true
          actualData={resources->Array.map(Nullable.make)}
          totalResults={resources->Array.length}
          resultsPerPage=50
          offset
          setOffset
          currentFetchCount={resources->Array.length}
          entity={HierarchicalConfigTableEntity.hierarchicalConfigEntity(
            ~resourceType,
            ~onLinkClick,
            ~authorization=connectorsManageAccess,
          )}
          showSerialNumber=true
          noDataMsg={`No ${typeLabel} ${credentialName}s yet. Click 'Add new resource' to create one.`}
        />
      </PageLoaderWrapper>
    </div>

  let tabs: array<Tabs.tab> = resourceTypes->Array.map(tabResourceType => {
    let tab: Tabs.tab = {
      title: tabResourceType->getResourceTypeLabel,
      renderContent: () => resourceTable,
    }
    tab
  })

  <div className="flex flex-col gap-6">
    <div className="flex items-center justify-between">
      <PageUtils.PageHeading
        title="Hierarchical Resources"
        subTitle="Manage Apple Pay certificates and Google Pay keys used across your merchant, profiles and connectors"
      />
      <div className="flex items-center gap-4">
        <OMPSwitchHelper.OMPViews
          views=[OMPSwitchUtils.merchant]
          selectedEntity=transactionEntity
          onChange=updateTransactionEntity
          entityMapper=UserInfoUtils.transactionEntityMapper
        />
        <ACLButton
          text="Add new resource"
          buttonType=Primary
          authorization=connectorsManageAccess
          onClick={_ => {
            mixpanelEvent(~eventName="hierarchical_config_add_certificate_clicked")
            setShowAddModal(_ => true)
          }}
        />
      </div>
    </div>
    <Tabs
      tabs
      initialIndex={resourceType->getResourceTypeTabIndex}
      onTitleClick={index => setResourceType(_ => index->getResourceTypeFromTabIndex)}
    />
    <AddCertificateModal
      showModal=showAddModal
      setShowModal=setShowAddModal
      onSuccess=onAddSuccess
      onResourceCreated=refreshFor
    />
    <LinkResourceModal
      showModal=showLinkModal setShowModal=setShowLinkModal resource=resourceToLink resourceType
    />
  </div>
}
