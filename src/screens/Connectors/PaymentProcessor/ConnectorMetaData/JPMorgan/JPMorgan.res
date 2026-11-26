open LogicUtils
open Typography

@react.component
let make = (~connectorMetaDataFields) => {
  open ConnectorMetaDataUtils
  // Currencies come from the connector config, so new ones show up without code changes
  let merchantIdFields = getMetadataGroupFields(
    "merchant_id",
    connectorMetaDataFields
    ->getDictfromDict("merchant_id")
    ->JSON.Encode.object
    ->convertMapObjectToDict,
  )

  <div className="px-8 py-4">
    <div className="border border-nd_gray-200 rounded-xl overflow-hidden p-6 flex flex-col gap-4">
      <div className="flex flex-col gap-1">
        <p className={body.lg.semibold}> {"Merchant ID"->React.string} </p>
        <p className={`${body.md.medium} text-nd_gray-500`}>
          {"Enter the JPMorgan Merchant ID for at least one currency"->React.string}
        </p>
      </div>
      <hr />
      <div className="flex flex-col max-w-md">
        {merchantIdFields
        ->Array.map(field =>
          <FormRenderer.FieldRenderer
            key={field.name}
            labelClass="font-semibold !text-hyperswitch_black"
            field={connectorMetaDataValueInput(~connectorMetaDataFields=field)}
          />
        )
        ->React.array}
      </div>
    </div>
  </div>
}
