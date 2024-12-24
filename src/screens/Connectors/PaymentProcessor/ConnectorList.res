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
  let connectorListFromRecoil = HyperswitchAtom.connectorListAtom->Recoil.useRecoilValueFromAtom
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

  let textStyle = HSwitchUtils.getTextClass((H2, Optional))
  let subtextStyle = `${HSwitchUtils.getTextClass((P1, Regular))} text-grey-700 opacity-50`

  let getConnectorListAndUpdateState = async () => {
    try {
      // TODO : maintain separate list for multiple types of connectors
      let connectorsList =
        connectorListFromRecoil->getProcessorsListFromJson(~removeFromList=ConnectorTypes.FRMPlayer)
      connectorsList->Array.reverse
      ConnectorUtils.sortByDisableField(connectorsList, connectorPayload =>
        connectorPayload.disabled
      )
      setFilteredConnectorData(_ => connectorsList->Array.map(Nullable.make))
      setPreviouslyConnectedData(_ => connectorsList->Array.map(Nullable.make))
      setConfiguredConnectors(_ =>
        connectorsList->ConnectorUtils.getConnectorTypeArrayFromListConnectors
      )
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

  let isMobileView = MatchMedia.useMobileChecker()

  let connectorsAvailableForIntegration = featureFlagDetails.isLiveMode
    ? connectorListForLive
    : connectorList

  <div>
    <PageLoaderWrapper screenState>
      <RenderIf
        condition={!featureFlagDetails.isLiveMode && configuredConnectors->Array.length == 0}>
        <div
          className="flex flex-col md:flex-row border rounded-md bg-white gap-4 shadow-generic_shadow mb-12">
          <div className="flex flex-col justify-evenly gap-6 pl-14 pb-14 pt-14 pr-2 md:pr-0">
            <div className="flex flex-col gap-2.5">
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
              rightIcon={CustomIcon(
                <Icon name="thin-right-arrow" size=20 className="cursor-pointer" />,
              )}
              onClick={_ => {
                setProcessorModal(_ => true)
              }}
            />
          </div>
          <RenderIf condition={!isMobileView}>
            <div className="h-30 md:w-[37rem] justify-end hidden laptop:block">
              <img alt="dummy-connector" src="/assets/DummyConnectorImage.svg" />
            </div>
          </RenderIf>
        </div>
      </RenderIf>
      <PageUtils.PageHeading
        title="Payment Processors"
        customHeadingStyle="mb-10"
        subTitle="Connect a test processor and get started with testing your payments"
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
            entity={ConnectorTableUtils.connectorEntity(
              "connectors",
              ~authorization=userHasAccess(~groupAccess=ConnectorsManage),
            )}
            currrentFetchCount={filteredConnectorData->Array.length}
            collapseTableRow=false
          />
        </RenderIf>
        <ProcessorCards
          configuredConnectors
          connectorsAvailableForIntegration
          urlPrefix="connectors/new"
          setProcessorModal
        />
        <RenderIf condition={processorModal}>
          <DummyProcessorModal
            processorModal
            setProcessorModal
            urlPrefix="connectors/new"
            configuredConnectors
            connectorsAvailableForIntegration
          />
        </RenderIf>
      </div>
    </PageLoaderWrapper>
  </div>
}
