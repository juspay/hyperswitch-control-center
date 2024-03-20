open UIUtils
open ProcessorCards
open ConnectorUtils

@react.component
let make = (~processorModal, ~setProcessorModal, ~showIcons) => {
  let searchRef = React.useRef(Nullable.null)

  let (searchedConnector, setSearchedConnector) = React.useState(_ => "")

  let handleSearch = event => {
    let val = ref(ReactEvent.Form.currentTarget(event)["value"])
    setSearchedConnector(_ => val.contents)
  }

  let userPermissionJson = Recoil.useRecoilValueFromAtom(HyperswitchAtom.userPermissionAtom)

  let (_, setShowModal) = React.useState(_ => false)

  let urlPrefix = "connectors/new"

  let handleClick = connectorName => {
    RescriptReactRouter.push(`${urlPrefix}?name=${connectorName}`)
  }

  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

  let descriptedConnectors = (
    connectorList: array<ConnectorTypes.connectorTypes>,
    heading,
    showRequestConnectorBtn,
    ~showSearch=true,
    ~showDummyConnectorButton=true,
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
        <RenderIf condition={showDummyConnectorButton}>
          <ACLButton
            access={userPermissionJson.connectorsManage}
            text="+ Connect a Dummy Processor"
            buttonType={Transparent}
            buttonSize={Small}
            textStyle="text-jp-gray-900"
            // onClick={_ => {
            //   setProcessorModal(_ => true)
            // }}
          />
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
                  {connectorName
                  ->getDisplayNameForConnector(~connectorType=ConnectorTypes.Processor)
                  ->React.string}
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
    ~showDummyConnectorButton=false,
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
        <RenderIf condition={showDummyConnectorButton}>
          <ACLButton
            access={userPermissionJson.connectorsManage}
            text="+ Connect a Dummy Processor"
            buttonType={Transparent}
            buttonSize={Small}
            textStyle="text-jp-gray-900"
            onClick={_ => {
              setProcessorModal(_ => true)
            }}
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
              description={connectorName->getDisplayNameForConnector(
                ~connectorType=ConnectorTypes.Processor,
              )}
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

  <Modal
    modalHeading="Connect a Dummy Processor"
    showModal=processorModal
    setShowModal=setProcessorModal
    modalClass="w-1/2 m-auto">
    <RenderIf condition={showIcons}>
      {featureFlagDetails.testProcessors
      ->ConnectorUtils.dummyConnectorList
      ->iconsConnectors(
        "Connect a test processor",
        false,
        ~showSearch=false,
        ~showDummyConnectorButton=false,
        (),
      )}
    </RenderIf>
    <RenderIf condition={!showIcons}>
      {featureFlagDetails.testProcessors
      ->ConnectorUtils.dummyConnectorList
      ->descriptedConnectors(
        "Connect a test processor",
        false,
        ~showSearch=false,
        ~showDummyConnectorButton=false,
        (),
      )}
    </RenderIf>
  </Modal>
}
