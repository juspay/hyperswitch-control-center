open Typography
open ReconEngineTypes

let getFieldTypeLabel = (fieldType: fieldTypeVariant): string => {
  switch fieldType {
  | StringField(_) => "String"
  | NumberField(_) => "Number"
  | CurrencyField => "Currency"
  | MinorUnitField(_) => "Minor Unit"
  | DateTimeField => "DateTime"
  | BalanceDirectionField(_) => "Balance Direction"
  }
}

let getFieldTypeColor = (fieldType: fieldTypeVariant): string => {
  switch fieldType {
  | StringField(_) => "bg-blue-50 text-blue-700"
  | NumberField(_) => "bg-purple-50 text-purple-700"
  | CurrencyField => "bg-nd_green-50 text-nd_green-700"
  | MinorUnitField(_) => "bg-orange-50 text-orange-700"
  | DateTimeField => "bg-nd_yellow-50 text-nd_yellow-700"
  | BalanceDirectionField(_) => "bg-nd_red-50 text-nd_red-700"
  }
}

module FieldRow = {
  @react.component
  let make = (~identifier: string, ~fieldType: fieldTypeVariant, ~required: bool, ~description: string) => {
    let typeLabel = getFieldTypeLabel(fieldType)
    let typeColor = getFieldTypeColor(fieldType)

    <div
      className="flex flex-row items-center justify-between px-4 py-3 border-b border-nd_gray-100 last:border-b-0 hover:bg-nd_gray-25 transition-colors">
      <div className="flex flex-col gap-1 flex-1">
        <div className="flex flex-row items-center gap-2">
          <span className={`${body.md.semibold} text-nd_gray-800 font-mono`}>
            {identifier->React.string}
          </span>
          <RenderIf condition={required}>
            <span className={`${body.sm.semibold} text-nd_red-500`}> {"*"->React.string} </span>
          </RenderIf>
        </div>
        <RenderIf condition={description->LogicUtils.isNonEmptyString}>
          <span className={`${body.sm.medium} text-nd_gray-400`}>
            {description->React.string}
          </span>
        </RenderIf>
      </div>
      <div className="flex flex-row items-center gap-2">
        <span className={`px-2 py-0.5 rounded-md ${body.sm.semibold} ${typeColor}`}>
          {typeLabel->React.string}
        </span>
        <RenderIf condition={required}>
          <span
            className={`px-2 py-0.5 rounded-md ${body.sm.medium} bg-nd_red-50 text-nd_red-600`}>
            {"Required"->React.string}
          </span>
        </RenderIf>
      </div>
    </div>
  }
}

module MainFieldRow = {
  @react.component
  let make = (~field: mainFieldType) => {
    <div
      className="flex flex-row items-center justify-between px-4 py-3 border-b border-nd_gray-100 last:border-b-0 hover:bg-nd_gray-25 transition-colors">
      <div className="flex flex-row items-center gap-2">
        <span className={`${body.md.semibold} text-nd_gray-800 font-mono`}>
          {field.field_name->React.string}
        </span>
        <span className={`px-2 py-0.5 rounded-md ${body.sm.semibold} bg-nd_gray-100 text-nd_gray-600`}>
          {"System"->React.string}
        </span>
      </div>
      <span className={`${body.sm.medium} text-nd_gray-500 font-mono`}>
        {field.identifier->React.string}
      </span>
    </div>
  }
}

@react.component
let make = (~schemaData: schemaDataType) => {
  let mainFieldCount = schemaData.fields.main_fields->Array.length
  let metadataFieldCount = schemaData.fields.metadata_fields->Array.length
  let totalFields = mainFieldCount + metadataFieldCount

  <div className="border border-nd_gray-150 rounded-xl bg-white overflow-hidden mt-4">
    <div className="flex flex-row items-center justify-between px-4 py-3 bg-nd_gray-50 border-b border-nd_gray-150">
      <div className="flex flex-row items-center gap-2">
        <Icon name="nd-connectors" size=16 className="text-nd_gray-500" />
        <p className={`${body.md.semibold} text-nd_gray-700`}> {"Schema Fields"->React.string} </p>
      </div>
      <div className="flex flex-row items-center gap-3">
        <span className={`${body.sm.medium} text-nd_gray-500`}>
          {`${totalFields->Int.toString} fields`->React.string}
        </span>
        <span className={`px-2 py-0.5 rounded-md ${body.sm.medium} bg-nd_gray-100 text-nd_gray-600`}>
          {schemaData.processing_mode->React.string}
        </span>
      </div>
    </div>
    <RenderIf condition={mainFieldCount > 0}>
      <div className="px-4 py-2 bg-nd_gray-25 border-b border-nd_gray-100">
        <span className={`${body.sm.semibold} text-nd_gray-500 uppercase tracking-wider`}>
          {"System Fields"->React.string}
        </span>
      </div>
      {schemaData.fields.main_fields
      ->Array.map(field => {
        <MainFieldRow key={field.field_name} field />
      })
      ->React.array}
    </RenderIf>
    <RenderIf condition={metadataFieldCount > 0}>
      <div className="px-4 py-2 bg-nd_gray-25 border-b border-nd_gray-100">
        <span className={`${body.sm.semibold} text-nd_gray-500 uppercase tracking-wider`}>
          {"Metadata Fields"->React.string}
        </span>
      </div>
      {schemaData.fields.metadata_fields
      ->Array.map(field => {
        <FieldRow
          key={field.identifier}
          identifier={field.identifier}
          fieldType={field.field_type}
          required={field.required}
          description={field.description}
        />
      })
      ->React.array}
    </RenderIf>
  </div>
}
