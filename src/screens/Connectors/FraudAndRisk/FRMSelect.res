module NewProcessorCards = {
  open FRMInfo
  @react.component
  let make = (~configuredFRMs: array<ConnectorTypes.connectorTypes>) => {
    let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
    let mixpanelEvent = MixpanelHook.useSendEvent()
    let frmAvailableForIntegration = frmList
    let unConfiguredFRMs = frmAvailableForIntegration->Array.filter(total =>
      configuredFRMs
      ->Array.find(item =>
        item->ConnectorUtils.getConnectorNameString === total->ConnectorUtils.getConnectorNameString
      )
      ->Option.isNone
    )

    let handleClick = frmName => {
      mixpanelEvent(~eventName=`connect_frm_${frmName}`)
      RescriptReactRouter.push(
        GlobalVars.appendDashboardPath(~url=`/fraud-risk-management/new?name=${frmName}`),
      )
    }
    let unConfiguredFRMCount = unConfiguredFRMs->Array.length

    let descriptedFRMs = (frmList: array<ConnectorTypes.connectorTypes>, heading) => {
      <>
        <h2
          className="font-bold text-xl text-black text-opacity-75 dark:text-white dark:text-opacity-75">
          {heading->React.string}
        </h2>
        <div className="grid gap-4 lg:grid-cols-4 md:grid-cols-2 grid-cols-1 mb-5">
          {frmList
          ->Array.mapWithIndex((frm, i) => {
            let frmName = frm->ConnectorUtils.getConnectorNameString
            let frmInfo = frm->ConnectorUtils.getConnectorInfo

            <CardUtils.CardLayout key={Int.toString(i)} width="w-full">
              <div className="flex gap-2 items-center mb-3">
                <GatewayIcon
                  gateway={frmName->String.toUpperCase} className="w-10 h-10 rounded-lg"
                />
                <h1 className="text-xl font-semibold break-all">
                  {frmName->LogicUtils.capitalizeString->React.string}
                </h1>
              </div>
              <div className="overflow-hidden text-gray-400 flex-1 mb-6">
                {frmInfo.description->React.string}
              </div>
              <ACLButton
                text="Connect"
                authorization={userHasAccess(~groupAccess=ConnectorsManage)}
                buttonType=Secondary
                buttonSize=Small
                onClick={_ => handleClick(frmName)}
                leftIcon={CustomIcon(
                  <Icon
                    name="plus"
                    size=16
                    className="text-jp-gray-900 fill-opacity-50 dark:jp-gray-text_darktheme"
                  />,
                )}
              />
            </CardUtils.CardLayout>
          })
          ->React.array}
        </div>
      </>
    }

    let headerText = "Connect a new fraud & risk management player"

    <RenderIf condition={unConfiguredFRMCount > 0}>
      <div className="flex flex-col gap-4"> {unConfiguredFRMs->descriptedFRMs(headerText)} </div>
    </RenderIf>
  }
}

@react.component
let make = () => {
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let isMobileView = MatchMedia.useMatchMedia("(max-width: 844px)")
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let (
    configuredFRMs: array<ConnectorTypes.connectorPayload>,
    setConfiguredFRMs,
  ) = React.useState(_ => [])
  let (filteredFRMData, setFilteredFRMData) = React.useState(_ => [])
  let (offset, setOffset) = React.useState(_ => 0)
  let (searchText, setSearchText) = React.useState(_ => "")
  let connectorList = ConnectorInterface.useConnectorArrayMapper(
    ~interface=ConnectorInterface.connectorInterfaceV1,
    ~retainInList=PaymentProcessor,
  )
  let frmConnectorList = ConnectorInterface.useConnectorArrayMapper(
    ~interface=ConnectorInterface.connectorInterfaceV1,
    ~retainInList=PaymentVas,
  )

  let customUI =
    <HelperComponents.BluredTableComponent
      infoText="No connectors configured yet. Try connecting a connector."
      buttonText="Take me to connectors"
      onClickElement={React.null}
      onClickUrl="connectors"
      moduleName="Fraud & Risk Management"
      moduleSubtitle="Connect and configure processors to screen transactions and mitigate fraud"
    />

  let getConnectorList = async _ => {
    try {
      let processorsList =
        connectorList->Array.filter(item => item.connector_type === PaymentProcessor)

      let connectorsCount = processorsList->Array.length
      if connectorsCount > 0 {
        setConfiguredFRMs(_ => frmConnectorList)
        setFilteredFRMData(_ => frmConnectorList->Array.map(Nullable.make))
        setScreenState(_ => Success)
      } else {
        setScreenState(_ => Custom)
      }
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch"))
    }
  }

  React.useEffect(() => {
    getConnectorList()->ignore
    None
  }, [])
  // TODO: Convert it to remote filter
  let filterLogic = ReactDebounce.useDebounced(ob => {
    open LogicUtils
    let (searchText, arr) = ob
    let filteredList = if searchText->isNonEmptyString {
      arr->Array.filter((frmPlayer: Nullable.t<ConnectorTypes.connectorPayload>) => {
        switch Nullable.toOption(frmPlayer) {
        | Some(frmPlayer) =>
          isContainingStringLowercase(frmPlayer.connector_name, searchText) ||
          isContainingStringLowercase(frmPlayer.merchant_connector_id, searchText) ||
          isContainingStringLowercase(frmPlayer.connector_label, searchText)
        | None => false
        }
      })
    } else {
      arr
    }
    setFilteredFRMData(_ => filteredList)
  }, ~wait=200)

  <PageLoaderWrapper screenState customUI>
    <div className="flex flex-col gap-10 ">
      <PageUtils.PageHeading
        title="Fraud & Risk Management"
        subTitle="Connect and configure processors to screen transactions and mitigate fraud"
      />
      <RenderIf condition={configuredFRMs->Array.length > 0}>
        <LoadedTable
          title="Connected Processors"
          actualData={filteredFRMData}
          totalResults={filteredFRMData->Array.length}
          filters={<TableSearchFilter
            data={configuredFRMs->Array.map(Nullable.make)}
            filterLogic
            placeholder="Search Processor or Merchant Connector Id or Connector Label"
            customSearchBarWrapperWidth="w-full lg:w-1/2"
            customInputBoxWidth="w-full"
            searchVal={searchText}
            setSearchVal={setSearchText}
          />}
          resultsPerPage=20
          offset
          setOffset
          entity={FRMTableUtils.connectorEntity(
            "fraud-risk-management",
            ~authorization={userHasAccess(~groupAccess=ConnectorsManage)},
          )}
          currrentFetchCount={configuredFRMs->Array.length}
          collapseTableRow=false
          showAutoScroll=true
        />
      </RenderIf>
      <NewProcessorCards
        configuredFRMs={ConnectorInterface.mapConnectorPayloadToConnectorType(
          ConnectorInterface.connectorInterfaceV1,
          ConnectorTypes.FRMPlayer,
          configuredFRMs,
        )}
      />
      <RenderIf condition={!isMobileView}>
        <img alt="frm-banner" className="w-full max-w-[1400px] mb-10" src="/assets/frmBanner.svg" />
      </RenderIf>
    </div>
  </PageLoaderWrapper>
}
