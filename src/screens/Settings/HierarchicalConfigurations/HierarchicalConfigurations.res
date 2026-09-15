@react.component
let make = () => {
  open APIUtils
  open LogicUtils

  let getURL = useGetURL()
  let fetchList = useUpdateMethod(~showErrorToast=false)
  let {updateTransactionEntity} = OMPSwitchHooks.useUserInfo()
  let {getResolvedUserInfo} = React.useContext(UserInfoProvider.defaultContext)
  let {transactionEntity} = getResolvedUserInfo()
  let (resources, setResources) = React.useState(_ => [])
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (showAddModal, setShowAddModal) = React.useState(_ => false)
  let (offset, setOffset) = React.useState(_ => 0)

  let fetchResources = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let url = getURL(~entityName=V1(RESOURCES_LIST), ~methodType=Post)
      let payload =
        [
          ("type", HierarchicalConfigUtils.applePayCertificateResourceType->JSON.Encode.string),
        ]->Dict.fromArray
      let response = await fetchList(url, payload->JSON.Encode.object, Post)
      let resourceList =
        response
        ->getDictFromJsonObject
        ->getArrayFromDict("resources", [])
        ->Array.filterMap(JSON.Decode.object)
        ->Array.map(HierarchicalConfigUtils.itemToObjectMapper)
      setResources(_ => resourceList)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | Exn.Error(e) =>
      let message =
        Exn.message(e)->Option.getOr("")->safeParse->getDictFromJsonObject->getString("message", "")
      setResources(_ => [])
      setScreenState(_ => PageLoaderWrapper.Error(
        getErrorMessage(~message, ~error="", ~fallback="Failed to fetch resources"),
      ))
    }
  }

  React.useEffect(() => {
    fetchResources()->ignore
    None
  }, [transactionEntity])

  let onAddSuccess = () => {
    setShowAddModal(_ => false)
    fetchResources()->ignore
  }

  <div className="flex flex-col gap-6">
    <div className="flex items-center justify-between">
      <PageUtils.PageHeading
        title="Hierarchical Configurations"
        subTitle="Manage certificates used to configure connectors"
      />
      <div className="flex items-center gap-4">
        <OMPSwitchHelper.OMPViews
          views=[OMPSwitchUtils.merchant]
          selectedEntity=transactionEntity
          onChange=updateTransactionEntity
          entityMapper=UserInfoUtils.transactionEntityMapper
        />
        <Button
          text="Add new certificate" buttonType=Primary onClick={_ => setShowAddModal(_ => true)}
        />
      </div>
    </div>
    <PageLoaderWrapper screenState>
      <LoadedTable
        title="Hierarchical Configurations"
        hideTitle=true
        actualData={resources->Array.map(Nullable.make)}
        totalResults={resources->Array.length}
        resultsPerPage=50
        offset
        setOffset
        currentFetchCount={resources->Array.length}
        entity={HierarchicalConfigTableEntity.hierarchicalConfigEntity()}
        showSerialNumber=true
        noDataMsg="No data available"
      />
    </PageLoaderWrapper>
    <RenderIf condition=showAddModal>
      <AddCertificateModal
        showModal=showAddModal setShowModal=setShowAddModal onSuccess=onAddSuccess
      />
    </RenderIf>
  </div>
}
