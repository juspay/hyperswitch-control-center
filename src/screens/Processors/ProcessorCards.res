open UIUtils
let p1MediumTextStyle = HSwitchUtils.getTextClass((P1, Medium))

module RequestConnector = {
  @react.component
  let make = (~connectorList, ~setShowModal) => {
    <UIUtils.RenderIf condition={connectorList->Array.length === 0}>
      <div
        className="flex flex-col gap-6 items-center justify-center w-full bg-white rounded-lg border p-8">
        <div className="mb-8 mt-4 max-w-full h-auto">
          <img src={`${LogicUtils.useUrlPrefix()}/notfound.svg`} />
        </div>
        <p className="jp-grey-700 opacity-50">
          {"Uh-oh! Looks like we couldn't find the processor you were searching for."->React.string}
        </p>
        <Button
          text={"Request a processor"} buttonType=Primary onClick={_ => setShowModal(_ => true)}
        />
      </div>
    </UIUtils.RenderIf>
  }
}

module CantFindProcessor = {
  @react.component
  let make = (~showRequestConnectorBtn, ~setShowModal) => {
    let userPermissionJson = Recoil.useRecoilValueFromAtom(HyperswitchAtom.userPermissionAtom)
    let cursorStyles = PermissionUtils.cursorStyles(userPermissionJson.merchantDetailsManage)

    <UIUtils.RenderIf condition={showRequestConnectorBtn}>
      <ACLDiv
        permission=userPermissionJson.merchantDetailsManage
        onClick={_ => setShowModal(_ => true)}
        className={`text-blue-900 underline underline-offset-4 font-medium ${cursorStyles}`}>
        {"Can't find the processor of your choice?"->React.string}
      </ACLDiv>
    </UIUtils.RenderIf>
  }
}

@react.component
let make = (
  ~connectorsAvailableForIntegration: array<ConnectorTypes.connectorTypes>,
  ~configuredConnectors: array<ConnectorTypes.connectorTypes>,
  ~showIcons: bool,
  ~showTestProcessor: bool,
  ~urlPrefix: string,
) => {
  open ConnectorUtils
  let userPermissionJson = Recoil.useRecoilValueFromAtom(HyperswitchAtom.userPermissionAtom)
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

  let unConfiguredConnectors =
    connectorsAvailableForIntegration->Array.filter(total =>
      configuredConnectors->Array.find(item => item === total)->Option.isNone
    )

  let (showModal, setShowModal) = React.useState(_ => false)
  let (searchedConnector, setSearchedConnector) = React.useState(_ => "")
  let searchRef = React.useRef(Nullable.null)

  let handleClick = connectorName => {
    RescriptReactRouter.push(`${urlPrefix}?name=${connectorName}`)
  }
  let unConfiguredConnectorsCount = unConfiguredConnectors->Array.length

  let handleSearch = event => {
    let val = ref(ReactEvent.Form.currentTarget(event)["value"])
    setSearchedConnector(_ => val.contents)
  }

  let descriptedConnectors = (
    connectorList: array<ConnectorTypes.connectorTypes>,
    heading,
    showRequestConnectorBtn,
    ~showSearch=true,
    (),
  ) => {
    <>
      <AddDataAttributes
        attributes=[("data-testid", heading->LogicUtils.titleToSnake->String.toLowerCase)]>
        <h2
          className="font-bold text-xl text-black text-opacity-75 dark:text-white dark:text-opacity-75">
          {heading->React.string}
        </h2>
      </AddDataAttributes>
      <div className="flex w-full justify-between">
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
        <CantFindProcessor showRequestConnectorBtn setShowModal />
      </div>
      <RenderIf condition={connectorList->Array.length > 0}>
        <div
          className="grid gap-x-5 gap-y-6 2xl:grid-cols-4 lg:grid-cols-3 md:grid-cols-2 grid-cols-1 mb-5">
          {connectorList
          ->Array.mapWithIndex((connector: ConnectorTypes.connectorTypes, i) => {
            let connectorName = connector->getConnectorNameString
            let connectorInfo = connector->getConnectorInfo
            let size = "w-14 h-14 rounded-sm"

            <ACLDiv
              permission={userPermissionJson.connectorsManage}
              onClick={_ => handleClick(connectorName)}
              key={i->string_of_int}
              className="border p-6 gap-4 bg-white rounded flex flex-col justify-between"
              dataAttrStr=connectorName>
              <div className="flex flex-col gap-3 items-start">
                <GatewayIcon gateway={connectorName->String.toUpperCase} className=size />
                <p className={`${p1MediumTextStyle} break-all`}>
                  {connectorName->getDisplayNameForConnector->React.string}
                </p>
              </div>
              <p className="overflow-hidden text-gray-400 flex-1 line-clamp-3">
                {connectorInfo.description->React.string}
              </p>
              <ACLButton
                access={userPermissionJson.connectorsManage}
                text="+ Connect"
                buttonType={Transparent}
                buttonSize={Small}
                textStyle="text-jp-gray-900"
              />
            </ACLDiv>
          })
          ->React.array}
        </div>
      </RenderIf>
      <RequestConnector connectorList setShowModal />
    </>
  }

  let iconsConnectors = (
    connectorList: array<ConnectorTypes.connectorTypes>,
    heading,
    showRequestConnectorBtn,
    ~showSearch=true,
    (),
  ) => {
    <>
      <AddDataAttributes
        attributes=[("data-testid", heading->LogicUtils.titleToSnake->String.toLowerCase)]>
        <h2
          className="font-bold text-xl text-black text-opacity-75 dark:text-white dark:text-opacity-75">
          {heading->React.string}
        </h2>
      </AddDataAttributes>
      <div className="flex w-full justify-between">
        <RenderIf condition={showSearch}>
          <input
            {...DOMUtils.domProps({
              "data-testid": "search-processor",
            })}
            ref={searchRef->ReactDOM.Ref.domRef}
            type_="text"
            value=searchedConnector
            onChange=handleSearch
            placeholder="Search a processor"
            className={`rounded-md px-4 py-2 focus:outline-none w-1/3 border`}
          />
        </RenderIf>
        <CantFindProcessor showRequestConnectorBtn setShowModal />
      </div>
      <RenderIf condition={connectorList->Array.length > 0}>
        <div className="bg-white rounded-md flex gap-2 flex-wrap p-4 border">
          {connectorList
          ->Array.mapWithIndex((connector, i) => {
            let connectorName = connector->getConnectorNameString
            let cursorStyles = PermissionUtils.cursorStyles(userPermissionJson.connectorsManage)

            <ACLDiv
              key={i->string_of_int}
              permission=userPermissionJson.connectorsManage
              className={`p-2 ${cursorStyles}`}
              noAccessDescription=HSwitchUtils.noAccessControlTextForProcessors
              tooltipWidthClass="w-30"
              description={connectorName->getDisplayNameForConnector}
              onClick={_ => handleClick(connectorName)}>
              <AddDataAttributes attributes=[("data-testid", connectorName->String.toLowerCase)]>
                <GatewayIcon
                  gateway={connectorName->String.toUpperCase} className="w-14 h-14 rounded-sm"
                />
              </AddDataAttributes>
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
  <RenderIf condition={unConfiguredConnectorsCount > 0}>
    <div className="flex flex-col gap-4">
      {if showIcons {
        <>
          {connectorListFiltered->iconsConnectors("Connect a new processor", true, ())}
          {<RenderIf condition={featureFlagDetails.testProcessors && showTestProcessor}>
            {featureFlagDetails.testProcessors
            ->dummyConnectorList
            ->iconsConnectors("Connect a test processor", false, ~showSearch=false, ())}
          </RenderIf>}
        </>
      } else {
        <>
          <RenderIf condition={featureFlagDetails.testProcessors && showTestProcessor}>
            {featureFlagDetails.testProcessors
            ->dummyConnectorList
            ->descriptedConnectors("Connect a test processor", false, ~showSearch=false, ())}
          </RenderIf>
          {connectorListFiltered->descriptedConnectors("Connect a new processor", true, ())}
        </>
      }}
    </div>
    <RenderIf condition={showModal}>
      <HSwitchFeedBackModal
        modalHeading="Request a processor" setShowModal showModal modalType={RequestConnectorModal}
      />
    </RenderIf>
  </RenderIf>
}
