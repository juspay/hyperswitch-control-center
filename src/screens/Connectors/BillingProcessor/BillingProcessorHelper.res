module CustomCellWithDefaultIcon = {
  @react.component
  let make = (
    ~connector: ConnectorTypes.connectorPayloadCommonType,
    ~connectorName,
    ~connectorType: option<ConnectorTypes.connector>=?,
    ~customIconStyle="w-6 h-6 mr-2",
  ) => {
    let businessProfileRecoilVal =
      HyperswitchAtom.businessProfileFromIdAtom->Recoil.useRecoilValueFromAtom
    let connector_Type = switch connectorType {
    | Some(connectorType) => connectorType
    | None => ConnectorTypes.Processor
    }
    let billing_processor_id = switch businessProfileRecoilVal.billing_processor_id {
    | Some(id) => id
    | None => ""
    }

    if connectorName->LogicUtils.isNonEmptyString {
      <div className="flex gap-2 items-center">
        <div className={`flex items-center flex-nowrap break-all whitespace-nowrap mr-6`}>
          <GatewayIcon
            gateway={connectorName->String.toUpperCase} className={`${customIconStyle}`}
          />
          <div>
            {connectorName
            ->ConnectorUtils.getDisplayNameForConnector(~connectorType=connector_Type)
            ->React.string}
          </div>
        </div>
        <RenderIf condition={connector.id == billing_processor_id}>
          <TableUtils.LabelCell labelColor={LabelLightGray} text="Default" />
        </RenderIf>
      </div>
    } else {
      "NA"->React.string
    }
  }
}
