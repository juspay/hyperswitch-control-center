open PaymentMethodBlockingTypes
open PaymentMethodBlockingUtils
open FormRenderer
open Typography

module BlockingConfigFields = {
  @react.component
  let make = (~paymentMethod, ~wasmOptions) => {
    let multiSelect = (~key, ~label, ~buttonText, ~options) =>
      makeFieldInfo(
        ~label,
        ~name=paymentMethod->getFieldName(key),
        ~customInput=InputFields.multiSelectInput(
          ~options,
          ~buttonText,
          ~showSelectionAsChips=false,
          ~customButtonStyle="!rounded-lg",
          ~fixedDropDownDirection=BottomRight,
          ~searchable=true,
        ),
      )

    let toggle = (field: toggleField) =>
      makeFieldInfo(
        ~label=field.label,
        ~name=paymentMethod->getFieldName(field.key),
        ~description=field.description,
        ~customInput=InputFields.switchInput(
          ~isDisabled=false,
          ~boolCustomClass="rounded-lg",
          ~toggleBorder="border-nd_primary_blue-450",
          ~toggleEnableColor="bg-nd_primary_blue-450",
        ),
      )

    let selectFields = [
      multiSelect(
        ~key="issuing_country",
        ~label="Issuing Country",
        ~buttonText="Select Countries",
        ~options=wasmOptions.issuingCountry,
      ),
      multiSelect(
        ~key="card_types",
        ~label="Card Types",
        ~buttonText="Select Card Types",
        ~options=wasmOptions.cardTypes,
      ),
      multiSelect(
        ~key="card_networks",
        ~label="Card Networks",
        ~buttonText="Select Card Networks",
        ~options=wasmOptions.cardNetworks,
      ),
      multiSelect(
        ~key="funding_sources",
        ~label="Funding Sources",
        ~buttonText="Select Funding Sources",
        ~options=wasmOptions.fundingSources,
      ),
      multiSelect(
        ~key="card_segment_types",
        ~label="Card Segment Types",
        ~buttonText="Select Segment Types",
        ~options=wasmOptions.cardSegmentTypes,
      ),
      multiSelect(
        ~key="card_subtypes",
        ~label="Card Subtypes",
        ~buttonText="Select Card Subtypes",
        ~options=wasmOptions.cardSubtypes,
      ),
    ]

    <div className="flex flex-col gap-6 p-6">
      <div className="grid grid-cols-1 laptop:grid-cols-2 gap-x-6 gap-y-5">
        {selectFields
        ->Array.mapWithIndex((field, index) =>
          <FieldRenderer
            key={index->Int.toString}
            field
            labelClass={`!${body.sm.medium} !text-nd_gray-700 !mb-1`}
          />
        )
        ->React.array}
      </div>
      <div className="flex flex-col gap-1 border-t border-nd_gray-150 pt-4">
        {toggleFields
        ->Array.mapWithIndex((field, index) =>
          <FieldRenderer
            key={index->Int.toString}
            field={field->toggle}
            labelClass={`!${body.sm.medium} !text-nd_gray-700`}
            fieldWrapperClass="w-full flex justify-between items-center gap-6 py-2"
          />
        )
        ->React.array}
      </div>
    </div>
  }
}
