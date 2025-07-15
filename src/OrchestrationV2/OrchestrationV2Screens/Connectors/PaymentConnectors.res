@react.component
let make = () => {
  open ConnectorUtils
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let {showFeedbackModal, setShowFeedbackModal} = React.useContext(GlobalProvider.defaultContext)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (configuredConnectors, setConfiguredConnectors) = React.useState(_ => [])
  let (previouslyConnectedData, setPreviouslyConnectedData) = React.useState(_ => [])
  let (filteredConnectorData, setFilteredConnectorData) = React.useState(_ => [])
  let (offset, setOffset) = React.useState(_ => 0)
  let (searchText, setSearchText) = React.useState(_ => "")
  let (processorModal, setProcessorModal) = React.useState(_ => false)

  let connectorsList = ConnectorInterface.useConnectorArrayMapper(
    ~interface=ConnectorInterface.connectorInterfaceV2,
    ~retainInList=PaymentProcessor,
  )

  let textStyle = HSwitchUtils.getTextClass((H2, Optional))
  let subtextStyle = `${HSwitchUtils.getTextClass((P1, Regular))} text-nd_gray-400`

  let getConnectorListAndUpdateState = async () => {
    try {
      connectorsList->Array.reverse
      sortByDisableField(connectorsList, connectorPayload => connectorPayload.disabled)
      setFilteredConnectorData(_ => connectorsList->Array.map(Nullable.make))
      setPreviouslyConnectedData(_ => connectorsList->Array.map(Nullable.make))

      let list = ConnectorInterface.mapConnectorPayloadToConnectorType(
        ConnectorInterface.connectorInterfaceV2,
        ConnectorTypes.Processor,
        connectorsList,
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
  }, [connectorsList->Array.length])

  let filterLogic = ReactDebounce.useDebounced(ob => {
    open LogicUtils
    let (searchText, arr) = ob
    let filteredList = if searchText->isNonEmptyString {
      arr->Array.filter((obj: Nullable.t<ConnectorTypes.connectorPayloadV2>) => {
        switch Nullable.toOption(obj) {
        | Some(obj) =>
          isContainingStringLowercase(obj.connector_name, searchText) ||
          isContainingStringLowercase(obj.id, searchText) ||
          isContainingStringLowercase(obj.connector_label, searchText)
        | None => false
        }
      })
    } else {
      arr
    }
    setFilteredConnectorData(_ => filteredList)
  }, ~wait=200)

  let isMobileView = MatchMedia.useMobileChecker()

  let connectorsAvailableForIntegration = featureFlagDetails.isLiveMode
    ? connectorListForLive
    : connectorList

  let callMixpanel = eventName => {
    mixpanelEvent(~eventName)
  }

  <div>
    <PageLoaderWrapper screenState>
      <PageUtils.PageHeading
        title="Payment Processors"
        customHeadingStyle="mb-10 text-nd_gray-800"
        subTitle="Connect a test processor and get started with testing your payments"
        customSubTitleStyle="text-nd_gray-400 font-medium !opacity-100"
      />
      <RenderIf
        condition={!featureFlagDetails.isLiveMode && configuredConnectors->Array.length == 0}>
        <div
          className="flex flex-col md:flex-row items-end place-content-between border border-nd_primary_blue-100 rounded-md gap-4 mb-12 bg-nd_primary_blue-25">
          <div className="flex flex-col justify-evenly gap-6 p-6 md:pr-0">
            <div className="flex flex-col gap-2.5 text-nd_gray-700">
              <div>
                <p className={textStyle}> {"No Test Credentials?"->React.string} </p>
                <p className={textStyle}> {"Connect a Dummy Processor"->React.string} </p>
              </div>
              <p className={subtextStyle}>
                {"Start simulating payments and refunds with a dummy processor setup."->React.string}
              </p>
            </div>
            <Button
              text="Connect Now"
              buttonType={Primary}
              customButtonStyle="group w-1/5"
              onClick={_ => {
                setProcessorModal(_ => true)
              }}
            />
          </div>
          <RenderIf condition={!isMobileView}>
            <div className="h-30 hidden laptop:block">
              <img alt="dummy-connector" src="/assets/HyperswitchConnectorImage.svg" />
            </div>
          </RenderIf>
        </div>
      </RenderIf>
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
            entity={PaymentProcessorEntity.connectorEntity(
              "v2/orchestration/connectors",
              ~authorization=userHasAccess(~groupAccess=ConnectorsManage),
              callMixpanel,
            )}
            currrentFetchCount={filteredConnectorData->Array.length}
            collapseTableRow=false
            showAutoScroll=true
          />
        </RenderIf>
        <PaymentProcessorCards
          configuredConnectors connectorsAvailableForIntegration setProcessorModal
        />
        <RenderIf condition={processorModal}>
          <DummyProcessorModal
            processorModal
            setProcessorModal
            urlPrefix="v2/orchestration/connectors/new"
            configuredConnectors
            connectorsAvailableForIntegration
          />
        </RenderIf>
      </div>
    </PageLoaderWrapper>
  </div>
}
