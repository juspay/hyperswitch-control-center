@react.component
let make = (~connectorMetaDataFields) => {
  open LogicUtils
  open ConnectorMetaDataUtils

  let keys =
    connectorMetaDataFields
    ->Dict.keysToArray
    ->Array.filter(ele => !Array.includes(metaDataInputKeysToIgnore, ele))
  <>
    {keys
    ->Array.mapWithIndex((field, index) => {
      let fields =
        connectorMetaDataFields
        ->getDictfromDict(field)
        ->JSON.Encode.object
        ->convertMapObjectToDict
        ->CommonMetaDataUtils.inputFieldMapper
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
