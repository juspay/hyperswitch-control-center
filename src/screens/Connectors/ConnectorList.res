@react.component
let make = (~isPayoutFlow=false) => {
  open UIUtils
  open ConnectorUtils
  let {showFeedbackModal, setShowFeedbackModal} = React.useContext(GlobalProvider.defaultContext)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (configuredConnectors, setConfiguredConnectors) = React.useState(_ => [])
  let (previouslyConnectedData, setPreviouslyConnectedData) = React.useState(_ => [])
  let (filteredConnectorData, setFilteredConnectorData) = React.useState(_ => [])
  let (offset, setOffset) = React.useState(_ => 0)
  let (searchText, setSearchText) = React.useState(_ => "")
  let (processorModal, setProcessorModal) = React.useState(_ => false)
  let fetchConnectorListResponse = ConnectorListHook.useFetchConnectorList()
  let userPermissionJson = Recoil.useRecoilValueFromAtom(HyperswitchAtom.userPermissionAtom)
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

  let textStyle = HSwitchUtils.getTextClass((H2, Optional))
  let subtextStyle = `${HSwitchUtils.getTextClass((P1, Regular))} text-grey-700 opacity-50`

  let getConnectorListAndUpdateState = async () => {
    try {
      let response = await fetchConnectorListResponse()
      let removeFromList = isPayoutFlow ? ConnectorTypes.PayoutConnector : ConnectorTypes.FRMPlayer

      // TODO : maintain separate list for multiple types of connectors
      let connectorsList =
        response
        ->ConnectorListMapper.getArrayOfConnectorListPayloadType
        ->getProcessorsListFromJson(~removeFromList, ())
      connectorsList->Array.reverse
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

  React.useEffect1(() => {
    getConnectorListAndUpdateState()->ignore
    None
  }, [isPayoutFlow])

  let filterLogic = ReactDebounce.useDebounced(ob => {
    open LogicUtils
    let (searchText, arr) = ob
    let filteredList = if searchText->isNonEmptyString {
      arr->Array.filter((obj: Nullable.t<ConnectorTypes.connectorPayload>) => {
        switch Nullable.toOption(obj) {
        | Some(obj) =>
          isContainingStringLowercase(obj.connector_name, searchText) ||
          isContainingStringLowercase(obj.profile_id, searchText)
        | None => false
        }
      })
    } else {
      arr
    }
    setFilteredConnectorData(_ => filteredList)
  }, ~wait=200)

  let entityPrefix = isPayoutFlow ? "payout" : ""
  let urlPrefix = isPayoutFlow ? "payoutconnectors/new" : "connectors/new"
  let isMobileView = MatchMedia.useMobileChecker()

  let connectorsAvailableForIntegration = featureFlagDetails.isLiveMode
    ? connectorListForLive
    : isPayoutFlow
    ? payoutConnectorList
    : connectorList

  <div>
    <PageLoaderWrapper screenState>
      <RenderIf
        condition={!featureFlagDetails.isLiveMode &&
        configuredConnectors->Array.length == 0 &&
        urlPrefix == "connectors/new"}>
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
            <div className="h-30 md:w-[37rem] flex justify-end hidden laptop:block">
              <img src="/assets/DummyConnectorImage.svg" />
            </div>
          </RenderIf>
        </div>
      </RenderIf>
      <PageUtils.PageHeading
        title={isPayoutFlow ? "Payout Processors" : `Payment Processors`}
        customHeadingStyle="mb-10"
        subTitle={isPayoutFlow
          ? "Connect and manage payout processors for disbursements and settlements"
          : "Connect a test processor and get started with testing your payments"}
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
              placeholder="Search Processor or Country or Business Label"
              customSearchBarWrapperWidth="w-full lg:w-1/3"
              customInputBoxWidth="w-full"
              searchVal=searchText
              setSearchVal=setSearchText
            />}
            resultsPerPage=20
            offset
            setOffset
            entity={ConnectorTableUtils.connectorEntity(
              `${entityPrefix}connectors`,
              ~permission=userPermissionJson.connectorsManage,
            )}
            currrentFetchCount={filteredConnectorData->Array.length}
            collapseTableRow=false
          />
        </RenderIf>
        <ProcessorCards
          configuredConnectors connectorsAvailableForIntegration urlPrefix setProcessorModal
        />
        <RenderIf condition={processorModal}>
          <DummyProcessorModal
            processorModal
            setProcessorModal
            urlPrefix
            configuredConnectors
            connectorsAvailableForIntegration
          />
        </RenderIf>
      </div>
    </PageLoaderWrapper>
  </div>
}
