open ConnectorTypes
open LogicUtils
open Typography

module CustomConnectorCellWithDefaultIcon = {
  @react.component
  let make = (
    ~connector: connectorPayloadCommonType,
    ~connectorType: option<connector>=?,
    ~customIconStyle="w-6 h-6 mr-2",
  ) => {
    let connectorName = connector.connector_name
    let businessProfileRecoilVal =
      HyperswitchAtom.businessProfileFromIdAtomInterface->Recoil.useRecoilValueFromAtom
    let connector_Type = switch connectorType {
    | Some(connectorType) => connectorType
    | None => Processor
    }
    let vault_processor_id =
      businessProfileRecoilVal.external_vault_connector_details->Option.mapOr("", details =>
        details.vault_connector_id
      )
    <>
      <RenderIf condition={connectorName->isNonEmptyString}>
        <div className="flex items-center">
          <div className="flex items-center flex-nowrap break-all whitespace-nowrap mr-3">
            <GatewayIcon
              gateway={connectorName->String.toUpperCase} className={`${customIconStyle}`}
            />
            <div>
              {connectorName
              ->ConnectorUtils.getDisplayNameForConnector(~connectorType=connector_Type)
              ->React.string}
            </div>
          </div>
          <RenderIf condition={connector.id == vault_processor_id}>
            <div
              className={`border border-nd_gray-200 bg-nd_gray-50 px-2 py-2-px rounded-lg ${body.sm.semibold}`}>
              {"Default"->React.string}
            </div>
          </RenderIf>
        </div>
      </RenderIf>
      <RenderIf condition={connectorName->isEmptyString}> {"NA"->React.string} </RenderIf>
    </>
  }
}
