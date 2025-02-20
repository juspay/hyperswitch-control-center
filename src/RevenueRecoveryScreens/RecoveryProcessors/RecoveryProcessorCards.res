let p1MediumTextStyle = HSwitchUtils.getTextClass((P1, Medium))

module RequestConnector = {
  @react.component
  let make = (~connectorList, ~setShowModal) => {
    <RenderIf condition={connectorList->Array.length === 0}>
      <div
        className="flex flex-col gap-6 items-center justify-center w-full bg-white rounded-lg border p-8">
        <div className="mb-8 mt-4 max-w-full h-auto">
          <img alt="notfound" src={`${LogicUtils.useUrlPrefix()}/notfound.svg`} />
        </div>
        <p className="jp-grey-700 opacity-50">
          {"Uh-oh! Looks like we couldn't find the processor you were searching for."->React.string}
        </p>
        <Button
          text={"Request a processor"} buttonType=Primary onClick={_ => setShowModal(_ => true)}
        />
      </div>
    </RenderIf>
  }
}

module CantFindProcessor = {
  @react.component
  let make = (~showRequestConnectorBtn, ~setShowModal) => {
    <RenderIf condition={showRequestConnectorBtn}>
      <div
        className="flex flex-row items-center gap-2 text-primary cursor-pointer"
        onClick={_ => setShowModal(_ => true)}>
        <ToolTip />
        {"Request a processor"->React.string}
      </div>
    </RenderIf>
  }
}

@react.component
let make = (
  ~connectorsAvailableForIntegration: array<ConnectorTypes.connectorTypes>,
  ~configuredConnectors: array<ConnectorTypes.connectorTypes>,
  ~showAllConnectors=true,
  ~connectorType=ConnectorTypes.Processor,
  ~setProcessorModal=_ => (),
  ~showTestProcessor=false,
) => {
  open ConnectorUtils

  let mixpanelEvent = MixpanelHook.useSendEvent()
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let {setShowSideBar} = React.useContext(GlobalProvider.defaultContext)

  let unConfiguredConnectors =
    connectorsAvailableForIntegration->Array.filter(total =>
      configuredConnectors->Array.find(item => item === total)->Option.isNone
    )

  let (showModal, setShowModal) = React.useState(_ => false)
  let (searchedConnector, setSearchedConnector) = React.useState(_ => "")
  let searchRef = React.useRef(Nullable.null)

  let leftIcon =
    <div id="leftIcon" className="self-center py-3 pl-5 pr-4">
      <Icon size=18 name="search" />
    </div>

  let handleClick = connectorName => {
    mixpanelEvent(~eventName=`connect_processor_${connectorName}`)
    setShowSideBar(_ => false)
    RescriptReactRouter.push(
      GlobalVars.appendDashboardPath(~url=`v2/recovery/connectors/new?name=${connectorName}`),
    )
  }
  let unConfiguredConnectorsCount = unConfiguredConnectors->Array.length

  let handleSearch = event => {
    let val = ref(ReactEvent.Form.currentTarget(event)["value"])
    setSearchedConnector(_ => val.contents)
  }

  let descriptedConnectors = (
    connectorList: array<ConnectorTypes.connectorTypes>,
    ~heading: string,
    ~showRequestConnectorBtn,
    ~showSearch=true,
    ~showDummyConnectorButton=false,
    (),
  ) => {
    if connectorList->Array.length > 0 {
      connectorList->Array.sort(sortByName)
    }
    <>
      <AddDataAttributes
        attributes=[("data-testid", heading->LogicUtils.titleToSnake->String.toLowerCase)]>
        <h2
          className="font-semibold text-xl text-nd_gray-600  dark:text-white dark:text-opacity-75">
          {heading->React.string}
        </h2>
      </AddDataAttributes>
      <div className="flex w-full justify-between gap-4 mt-4 mb-4">
        <RenderIf condition={showSearch}>
          <AddDataAttributes attributes=[("data-testid", "search-processor")]>
            <div
              className="flex flex-row  border border-gray-300 rounded-2xl  focus:outline-none w-1/3 font-500 ">
              {leftIcon}
              <input
                ref={searchRef->ReactDOM.Ref.domRef}
                type_="text"
                value=searchedConnector
                onChange=handleSearch
                placeholder="Search a processor"
                className={`outline-none`}
                id="search-processor"
              />
            </div>
          </AddDataAttributes>
        </RenderIf>
        <RenderIf
          condition={!featureFlagDetails.isLiveMode &&
          configuredConnectors->Array.length > 0 &&
          showDummyConnectorButton}>
          <ACLButton
            authorization={userHasAccess(~groupAccess=ConnectorsManage)}
            leftIcon={CustomIcon(
              <Icon
                name="plus"
                size=16
                className="text-jp-gray-900 fill-opacity-50 dark:jp-gray-text_darktheme"
              />,
            )}
            text="Connect a Dummy Processor"
            buttonType={Secondary}
            buttonSize={Large}
            textStyle="text-jp-gray-900"
            onClick={_ => setProcessorModal(_ => true)}
          />
        </RenderIf>
        <CantFindProcessor showRequestConnectorBtn setShowModal />
      </div>
      <RenderIf condition={connectorList->Array.length > 0}>
        <div
          className={`grid gap-x-5 gap-y-6 
              2xl:grid-cols-3 lg:grid-cols-3 md:grid-cols-2 grid-cols-3 mb-5`}>
          {connectorList
          ->Array.mapWithIndex((connector: ConnectorTypes.connectorTypes, i) => {
            let connectorName = connector->getConnectorNameString
            let connectorInfo = connector->getConnectorInfo
            let size = "w-14 h-14 rounded-sm"

            <ACLDiv
              authorization={userHasAccess(~groupAccess=ConnectorsManage)}
              onClick={_ => handleClick(connectorName)}
              key={i->Int.toString}
              className="border p-6 gap-4 bg-white rounded-lg flex flex-col  justify-between h-12.5-rem hover:bg-gray-50 hover:cursor-pointer"
              dataAttrStr=connectorName>
              <div className="flex flex-row gap-3 items-center">
                <GatewayIcon gateway={connectorName->String.toUpperCase} className=size />
                <p className={`${p1MediumTextStyle} break-all`}>
                  {connectorName->getDisplayNameForConnector(~connectorType)->React.string}
                </p>
              </div>
              <p className="overflow-hidden text-nd_gray-400 flex-1 line-clamp-3">
                {connectorInfo.description->React.string}
              </p>
            </ACLDiv>
          })
          ->React.array}
        </div>
      </RenderIf>
      <RequestConnector connectorList setShowModal />
    </>
  }

  let connectorListFiltered = {
    if searchedConnector->LogicUtils.isNonEmptyString {
      connectorsAvailableForIntegration->Array.filter(item =>
        item->getConnectorNameString->String.includes(searchedConnector->String.toLowerCase)
      )
    } else {
      connectorsAvailableForIntegration
    }
  }
  <div className="mt-10">
    <RenderIf condition={unConfiguredConnectorsCount > 0}>
      <RenderIf condition={showAllConnectors}>
        <div className="flex flex-col gap-4">
          {connectorListFiltered->descriptedConnectors(
            ~heading="Connect a new processor",
            ~showRequestConnectorBtn=true,
            ~showDummyConnectorButton=false,
            (),
          )}
        </div>
        <RenderIf condition={showModal}>
          <HSwitchFeedBackModal
            modalHeading="Request a processor"
            setShowModal
            showModal
            modalType={RequestConnectorModal}
          />
        </RenderIf>
      </RenderIf>
      <RenderIf condition={showTestProcessor}>
        {showTestProcessor
        ->dummyConnectorList
        ->descriptedConnectors(
          ~heading="",
          ~showRequestConnectorBtn=false,
          ~showSearch=false,
          ~showDummyConnectorButton=false,
          (),
        )}
      </RenderIf>
    </RenderIf>
  </div>
}
