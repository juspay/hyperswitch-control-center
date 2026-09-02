open PaymentMethodBlockingUtils
open Typography

module BlockingConfigFields = {
  @react.component
  let make = (~paymentMethod, ~wasmOptions) => {
    <div className="flex flex-col gap-6 p-6">
      <div className="grid grid-cols-1 laptop:grid-cols-2 gap-x-6 gap-y-5">
        {getSelectFields(~paymentMethod, ~wasmOptions)
        ->Array.mapWithIndex((field, index) =>
          <FormRenderer.FieldRenderer
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
          <FormRenderer.FieldRenderer
            key={index->Int.toString}
            field={getToggleField(~paymentMethod, ~field)}
            labelClass={`!${body.sm.medium} !text-nd_gray-700`}
            fieldWrapperClass="w-full flex justify-between items-center gap-6 py-2"
          />
        )
        ->React.array}
      </div>
    </div>
  }
}
