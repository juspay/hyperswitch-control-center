@react.component
let make = (~connectorMetaDataFields, ~selectedConnector) => {
  open ConnectorMetaDataUtils
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

  <>
    {connectorMetaDataFields
    ->getMetadataInputFields
    ->Array.mapWithIndex((fields, index) => {
      let formName = connectorMetaDataNameMapper(fields.name)
      <div key={index->Int.toString}>
        <FormRenderer.FieldRenderer
          labelClass="font-semibold !text-hyperswitch_black"
          field={connectorMetaDataValueInput(~connectorMetaDataFields={fields})}
        />
        <ConnectorAuthKeysHelper.ErrorValidation
          fieldName=formName
          validate={ConnectorUtils.validate(
            ~selectedConnector,
            ~dict=Dict.make(),
            ~fieldName=formName,
            ~isLiveMode=featureFlagDetails.isLiveMode,
          )}
        />
      </div>
    })
    ->React.array}
  </>
}
