@react.component
let make = (~connectorMetaDataFields) => {
  open ConnectorMetaDataUtils

  <>
    {connectorMetaDataFields
    ->getMetadataInputFields
    ->Array.mapWithIndex((fields, index) => {
      <div key={index->Int.toString}>
        <FormRenderer.FieldRenderer
          labelClass="font-semibold !text-hyperswitch_black"
          field={connectorMetaDataValueInput(~connectorMetaDataFields={fields})}
        />
      </div>
    })
    ->React.array}
  </>
}
