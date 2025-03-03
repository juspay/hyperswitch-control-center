@react.component
let make = () => {
  open ConnectorUtils
  let {showFeedbackModal, setShowFeedbackModal} = React.useContext(GlobalProvider.defaultContext)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (configuredConnectors, setConfiguredConnectors) = React.useState(_ => [])
  let (previouslyConnectedData, setPreviouslyConnectedData) = React.useState(_ => [])
  let (filteredConnectorData, setFilteredConnectorData) = React.useState(_ => [])
  let (offset, setOffset) = React.useState(_ => 0)
  let (searchText, setSearchText) = React.useState(_ => "")
  let (processorModal, setProcessorModal) = React.useState(_ => false)
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let connectorList = ConnectorInterface.useConnectorArrayMapper(
    ~interface=ConnectorInterface.connectorInterfaceV1,
    ~retainInList=PayoutProcessor,
  )

  let getConnectorListAndUpdateState = async () => {
    try {
      connectorList->Array.reverse
      ConnectorUtils.sortByDisableField(connectorList, connectorPayload =>
        connectorPayload.disabled
      )
      setFilteredConnectorData(_ => connectorList->Array.map(Nullable.make))
      setPreviouslyConnectedData(_ => connectorList->Array.map(Nullable.make))

      let list = ConnectorInterface.mapConnectorPayloadToConnectorType(
        ConnectorInterface.connectorInterfaceV1,
        ConnectorTypes.PayoutProcessor,
        connectorList,
      )
      setConfiguredConnectors(_ => list)

      setScreenState(_ => Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch"))
    }
  }

  React.useEffect(() => {
    getConnectorListAndUpdateState()->ignore
    None
  }, [])

  let filterLogic = ReactDebounce.useDebounced(ob => {
    open LogicUtils
    let (searchText, arr) = ob
    let filteredList = if searchText->isNonEmptyString {
      arr->Array.filter((obj: Nullable.t<ConnectorTypes.connectorPayload>) => {
        switch Nullable.toOption(obj) {
        | Some(obj) =>
          isContainingStringLowercase(obj.connector_name, searchText) ||
          isContainingStringLowercase(obj.merchant_connector_id, searchText) ||
          isContainingStringLowercase(obj.connector_label, searchText)
        | None => false
        }
      })
    } else {
      arr
    }
    setFilteredConnectorData(_ => filteredList)
  }, ~wait=200)

  <div>
    <PageLoaderWrapper screenState>
      <PageUtils.PageHeading
        title="Payout Processors"
        customHeadingStyle="mb-10"
        subTitle="Connect and manage payout processors for disbursements and settlements"
      />
      <div className="flex flex-col gap-14">
        <RenderIf condition={showFeedbackModal}>
          <HSwitchFeedBackModal
            showModal={showFeedbackModal}
            setShowModal={setShowFeedbackModal}
            modalHeading="Tell us about your integration experience"
            feedbackVia="connected_a_connector"
          />
        </RenderIf>
        <RenderIf condition={configuredConnectors->Array.length > 0}>
          <LoadedTable
            title="Connected Processors"
            actualData=filteredConnectorData
            totalResults={filteredConnectorData->Array.length}
            filters={<TableSearchFilter
              data={previouslyConnectedData}
              filterLogic
              placeholder="Search Processor or Merchant Connector Id or Connector Label"
              customSearchBarWrapperWidth="w-full lg:w-1/2"
              customInputBoxWidth="w-full"
              searchVal=searchText
              setSearchVal=setSearchText
            />}
            resultsPerPage=20
            offset
            setOffset
            entity={PayoutProcessorTableEntity.payoutProcessorEntity(
              "payoutconnectors",
              ~authorization=userHasAccess(~groupAccess=ConnectorsManage),
            )}
            currrentFetchCount={filteredConnectorData->Array.length}
            collapseTableRow=false
          />
        </RenderIf>
        <ProcessorCards
          configuredConnectors
          connectorsAvailableForIntegration={payoutConnectorList}
          connectorType={PayoutProcessor}
          urlPrefix="payoutconnectors/new"
          setProcessorModal
        />
        <RenderIf condition={processorModal}>
          <DummyProcessorModal
            processorModal
            setProcessorModal
            urlPrefix="payoutconnectors/new"
            configuredConnectors
            connectorsAvailableForIntegration={payoutConnectorList}
          />
        </RenderIf>
      </div>
    </PageLoaderWrapper>
  </div>
}
