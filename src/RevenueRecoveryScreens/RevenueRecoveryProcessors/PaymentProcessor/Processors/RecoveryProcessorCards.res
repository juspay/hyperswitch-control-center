@react.component
let make = (
  ~connectorsAvailableForIntegration: array<ConnectorTypes.connectorTypes>,
  ~configuredConnectors: array<ConnectorTypes.connectorTypes>,
  ~showAllConnectors=true,
  ~urlPrefix: string,
  ~connectorType=ConnectorTypes.Processor,
  ~setProcessorModal=_ => (),
  ~showTestProcessor=false,
) => {
  open ConnectorUtils
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

  let unConfiguredConnectors =
    connectorsAvailableForIntegration->Array.filter(total =>
      configuredConnectors->Array.find(item => item === total)->Option.isNone
    )

  let (_showModal, setShowModal) = React.useState(_ => false)
  let (searchedConnector, setSearchedConnector) = React.useState(_ => "")
  let searchRef = React.useRef(Nullable.null)

  let handleClick = connectorName => {
    mixpanelEvent(~eventName=`recovery_payment-processors_${connectorName}`)
    RescriptReactRouter.push(
      GlobalVars.appendDashboardPath(~url=`/${urlPrefix}?name=${connectorName}`),
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
          className="font-bold text-xl text-black text-opacity-75 dark:text-white dark:text-opacity-75">
          {heading->React.string}
        </h2>
      </AddDataAttributes>
      <div className="flex w-full justify-start gap-4">
        <RenderIf condition={showSearch}>
          <AddDataAttributes attributes=[("data-testid", "search-processor")]>
            <input
              ref={searchRef->ReactDOM.Ref.domRef}
              type_="text"
              value=searchedConnector
              onChange=handleSearch
              placeholder="Search a processor"
              className={`rounded-md px-4 py-2 focus:outline-none w-1/3 border`}
              id="search-processor"
            />
          </AddDataAttributes>
        </RenderIf>
        <RenderIf
          condition={!featureFlagDetails.isLiveMode &&
          configuredConnectors->Array.length > 0 &&
          showDummyConnectorButton &&
          urlPrefix == "v2/recovery/payment-processors/new"}>
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
            buttonType={Transparent}
            buttonSize={Small}
            textStyle="text-jp-gray-900"
            onClick={_ => setProcessorModal(_ => true)}
          />
        </RenderIf>
        <ProcessorCards.CantFindProcessor showRequestConnectorBtn setShowModal />
      </div>
      <RenderIf condition={connectorList->Array.length > 0}>
        <div
          className={`grid gap-x-5 gap-y-6 ${showDummyConnectorButton
              ? "2xl:grid-cols-4 lg:grid-cols-3"
              : ""} md:grid-cols-2 grid-cols-1 mb-5`}>
          {connectorList
          ->Array.mapWithIndex((connector: ConnectorTypes.connectorTypes, i) => {
            let connectorName = connector->getConnectorNameString
            let connectorInfo = connector->getConnectorInfo
            let size = "w-14 h-14 rounded-sm"

            <ACLDiv
              authorization={userHasAccess(~groupAccess=ConnectorsManage)}
              onClick={_ => ()}
              key={i->string_of_int}
              className="border p-6 gap-4 bg-white rounded flex flex-col justify-between"
              dataAttrStr=connectorName>
              <div className="flex flex-col gap-3 items-start">
                <GatewayIcon gateway={connectorName->String.toUpperCase} className=size />
                <p className={`${ProcessorCards.p1MediumTextStyle} break-all`}>
                  {connectorName->getDisplayNameForConnector(~connectorType)->React.string}
                </p>
              </div>
              <p className="overflow-hidden text-gray-400 flex-1 line-clamp-3">
                {connectorInfo.description->React.string}
              </p>
              <ACLButton
                authorization={userHasAccess(~groupAccess=ConnectorsManage)}
                text="Connect"
                onClick={_ => handleClick(connectorName)}
                buttonType={Transparent}
                buttonSize={Small}
                textStyle="text-jp-gray-900"
                leftIcon={CustomIcon(
                  <Icon
                    name="plus"
                    size=16
                    className="text-jp-gray-900 fill-opacity-50 dark:jp-gray-text_darktheme"
                  />,
                )}
              />
            </ACLDiv>
          })
          ->React.array}
        </div>
      </RenderIf>
      <ProcessorCards.RequestConnector connectorList setShowModal />
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
  <RenderIf condition={unConfiguredConnectorsCount > 0}>
    <RenderIf condition={showAllConnectors}>
      <div className="flex flex-col gap-4">
        {connectorListFiltered->descriptedConnectors(
          ~heading="Connect a new processor",
          ~showRequestConnectorBtn=true,
          ~showDummyConnectorButton=true,
          (),
        )}
      </div>
      // TODO: need a v2 route
      // <RenderIf condition={showModal}>
      //   <HSwitchFeedBackModal
      //     modalHeading="Request a processor"
      //     setShowModal
      //     showModal
      //     modalType={RequestConnectorModal}
      //   />
      // </RenderIf>
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
}
