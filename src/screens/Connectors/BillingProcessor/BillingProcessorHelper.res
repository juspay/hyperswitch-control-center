open ConnectorTypes
open LogicUtils

module CustomConnectorCellWithDefaultIcon = {
  @react.component
  let make = (
    ~connector: connectorPayloadCommonType,
    ~connectorName,
    ~connectorType: option<connector>=?,
    ~customIconStyle="w-6 h-6 mr-2",
  ) => {
    open Typography
    let businessProfileRecoilVal =
      HyperswitchAtom.businessProfileFromIdAtomInterface->Recoil.useRecoilValueFromAtom
    let connector_Type = switch connectorType {
    | Some(connectorType) => connectorType
    | None => Processor
    }
    let billing_processor_id = businessProfileRecoilVal.billing_processor_id->Option.getOr("")
    <>
      <RenderIf condition={connectorName->isNonEmptyString}>
        <div className="flex items-center">
          <div className={`flex items-center flex-nowrap break-all whitespace-nowrap mr-3`}>
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

module ConnectButton = {
  @react.component
  let make = (~setShowModal) => {
    let dict = Dict.make()
    ["hasValidationErrors", "errors"]->Array.forEach(item => {
      Dict.set(dict, item, JSON.Encode.bool(true))
    })

    let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
      dict->JSON.Encode.object->Nullable.make,
    )

    let {hasValidationErrors, errors} = formState

    let errorsList = JsonFlattenUtils.flattenObject(errors, false)->Dict.toArray

    let button =
      <AddDataAttributes attributes=[("data-testid", "connector-submit-button")]>
        <Button
          text="Connect and Proceed"
          buttonType=Button.Primary
          buttonState={hasValidationErrors ? Button.Disabled : Button.Normal}
          onClick={_ => setShowModal(_ => true)}
        />
      </AddDataAttributes>

    let description =
      errorsList
      ->Array.map(entry => {
        let (key, jsonValue) = entry
        let value = getStringFromJson(jsonValue, "Error")
        `${key->snakeToTitle}: ${value}`
      })
      ->Array.joinWith("\n")

    <>
      <RenderIf condition={errorsList->Array.length === 0}> {button} </RenderIf>
      <RenderIf condition={errorsList->Array.length > 0}>
        <ToolTip
          description
          toolTipFor=button
          toolTipPosition=ToolTip.Top
          tooltipPositioning=#fixed
          tooltipWidthClass="w-auto"
          height="h-full"
          tooltipForWidthClass=""
        />
      </RenderIf>
    </>
  }
}
