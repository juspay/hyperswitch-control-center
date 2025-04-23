let p1MediumTextStyle = HSwitchUtils.getTextClass((P1, Medium))

module RequestConnector = {
  @react.component
  let make = (~connectorList, ~setShowModal) => {
    let mixpanelEvent = MixpanelHook.useSendEvent()

    let handleClick = () => {
      mixpanelEvent(~eventName="vault_request_processor")
      setShowModal(_ => true)
    }
    <RenderIf condition={connectorList->Array.length === 0}>
      <div
        className="flex flex-col gap-6 items-center justify-center w-full bg-white rounded-lg border p-8">
        <div className="mb-8 mt-4 max-w-full h-auto">
          <img alt="notfound" src={`${LogicUtils.useUrlPrefix()}/notfound.svg`} />
        </div>
        <p className="jp-grey-700 opacity-50">
          {"Uh-oh! Looks like we couldn't find the processor you were searching for."->React.string}
        </p>
        <Button text={"Request a processor"} buttonType=Primary onClick={_ => handleClick()} />
      </div>
    </RenderIf>
  }
}

module CantFindProcessor = {
  @react.component
  let make = (~showRequestConnectorBtn) => {
    let mixpanelEvent = MixpanelHook.useSendEvent()
    let handleClick = () => {
      mixpanelEvent(~eventName="vault_request_processor")
      "https://hyperswitch-io.slack.com/?redir=%2Fssb%2Fredirect"->Window._open
    }
    <RenderIf condition={showRequestConnectorBtn}>
      <div
        className="flex flex-row items-center gap-2 text-primary cursor-pointer font-semibold"
        onClick={_ => handleClick()}>
        <ToolTip iconOpacityVal="100" />
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

  let handleClick = connectorName => {
    mixpanelEvent(~eventName=`vault_connector_click_${connectorName}`)
    setShowSideBar(_ => false)
    RescriptReactRouter.push(
      GlobalVars.appendDashboardPath(~url=`v2/vault/onboarding/new?name=${connectorName}`),
    )
  }
  let unConfiguredConnectorsCount = unConfiguredConnectors->Array.length

  let descriptedConnectors = (
    connectorList: array<ConnectorTypes.connectorTypes>,
    ~heading: string,
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
      </div>
      <div
        className={`grid gap-x-5 gap-y-6 
              2xl:grid-cols-3 lg:grid-cols-3 md:grid-cols-2 grid-cols-3 mb-5`}>
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
              className="border p-4 gap-2 bg-white rounded-lg flex flex-col  justify-between h-9.5-rem hover:bg-gray-50 hover:cursor-pointer"
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
        <VaultConnectorHelper.VaultRequestProcessorCard />
      </div>
    </>
  }

  <RenderIf condition={unConfiguredConnectorsCount > 0}>
    <RenderIf condition={showAllConnectors}>
      <div className="flex flex-col gap-4">
        {connectorsAvailableForIntegration->descriptedConnectors(
          ~heading="",
          ~showDummyConnectorButton=false,
          (),
        )}
      </div>
    </RenderIf>
    <RenderIf condition={showTestProcessor}>
      {showTestProcessor
      ->dummyConnectorList
      ->descriptedConnectors(~heading="", ~showDummyConnectorButton=false, ())}
    </RenderIf>
  </RenderIf>
}
