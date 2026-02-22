let p1MediumTextStyle = HSwitchUtils.getTextClass((P1, Medium))

@react.component
let make = (
  ~connectorsAvailableForIntegration: array<ConnectorTypes.connectorTypes>,
  ~configuredConnectors: array<ConnectorTypes.connectorTypes>,
  ~showAllConnectors=true,
  ~connectorType=ConnectorTypes.Processor,
  ~setProcessorModal=_ => (),
  ~urlPrefix: string,
  ~showTestProcessor=false,
) => {
  open ConnectorUtils

  let mixpanelEvent = MixpanelHook.useSendEvent()
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let {setShowSideBar} = React.useContext(GlobalProvider.defaultContext)
  let searchRef = React.useRef(Nullable.null)
  let (searchedConnector, setSearchedConnector) = React.useState(_ => "")

  let unConfiguredConnectors =
    connectorsAvailableForIntegration->Array.filter(total =>
      configuredConnectors->Array.find(item => item === total)->Option.isNone
    )

  let handleClick = connectorName => {
    mixpanelEvent(~eventName=`orchestration_v2_connector_click_${connectorName}`)
    setShowSideBar(_ => false)
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
    ~showSearch=true,
    ~showDummyConnectorButton=false,
    (),
  ) => {
    if connectorList->Array.length > 0 {
      connectorList->Array.sort(sortByName)
    }

    let marginClass = showDummyConnectorButton ? "mt-4 mb-4" : ""
    let customStyleClass = showDummyConnectorButton ? "2xl:grid-cols-4 lg:grid-cols-3" : ""

    <>
      <AddDataAttributes
        attributes=[("data-testid", heading->LogicUtils.titleToSnake->String.toLowerCase)]>
        <h2 className="font-semibold text-xl text-nd_gray-700 dark:text-white dark:text-opacity-75">
          {heading->React.string}
        </h2>
      </AddDataAttributes>
      <div className={`flex w-full justify-between gap-4 ${marginClass} `}>
        <RenderIf condition={showSearch}>
          <AddDataAttributes attributes=[("data-testid", "search-processor")]>
            <input
              ref={searchRef->ReactDOM.Ref.domRef}
              type_="text"
              value=searchedConnector
              onChange=handleSearch
              placeholder="Search a processor"
              className="rounded-md px-4 py-2 focus:outline-none w-1/3 border"
              id="search-processor"
            />
          </AddDataAttributes>
        </RenderIf>
        <div className="flex gap-4">
          <RenderIf condition={!featureFlagDetails.isLiveMode && showDummyConnectorButton}>
            <ACLButton
              authorization={userHasAccess(~groupAccess=ConnectorsManage)}
              leftIcon={CustomIcon(
                <Icon
                  name="nd-plus"
                  size=16
                  className="text-nd_gray-600 fill-opacity-50 dark:jp-gray-text_darktheme"
                />,
              )}
              customIconMargin="ml-4"
              text="Connect a Dummy Processor"
              buttonType={NonFilled}
              buttonSize={Large}
              textStyle="text-nd_gray-600 font-semibold !py-2.5 pr-4 pl-2"
              onClick={_ => setProcessorModal(_ => true)}
            />
          </RenderIf>
        </div>
      </div>
      <div className={`grid gap-x-5 gap-y-6 ${customStyleClass} md:grid-cols-2 grid-cols-1 mb-5`}>
        <RenderIf condition={connectorList->Array.length > 0}>
          {connectorList
          ->Array.mapWithIndex((connector: ConnectorTypes.connectorTypes, i) => {
            let connectorName = connector->getConnectorNameString
            let connectorInfo = connector->getConnectorInfo
            let size = "w-10 h-10 rounded-sm"

            <ACLDiv
              authorization={userHasAccess(~groupAccess=ConnectorsManage)}
              onClick={_ => handleClick(connectorName)}
              key={i->Int.toString}
              className="border p-4 gap-2 bg-white rounded-lg flex flex-col justify-between h-9.5-rem hover:bg-gray-50 hover:cursor-pointer"
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
        </RenderIf>
      </div>
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
          ~showDummyConnectorButton=true,
          (),
        )}
      </div>
    </RenderIf>
  </RenderIf>
}
