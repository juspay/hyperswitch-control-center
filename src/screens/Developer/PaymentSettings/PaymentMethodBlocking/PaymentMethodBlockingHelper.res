open PaymentMethodBlockingTypes
open PaymentMethodBlockingUtils
open Typography
open LogicUtils

module IssuerTags = {
  @react.component
  let make = (~input: ReactFinalForm.fieldRenderPropsInput, ~catalogueState) => {
    let selectedValues = input.value->getStrArrayFromJson
    let hiddenCount = selectedValues->Array.length - maxIssuerTagsShown

    let removeIssuer = value =>
      input.onChange(
        selectedValues->Array.filter(item => item !== value)->Identity.arrofStringToReactEvent,
      )

    <div className="flex flex-wrap items-center gap-2">
      {selectedValues
      ->Array.slice(~start=0, ~end=maxIssuerTagsShown)
      ->Array.map(value =>
        <TagBinding
          key=value
          text={catalogueState->getIssuerLabel(value)}
          color=Neutral
          variant=Subtle
          shape=Squarical
          size=Sm
          rightSlot={<Icon
            name="cross-outline"
            size=10
            className="cursor-pointer"
            onClick={_ => removeIssuer(value)}
          />}
        />
      )
      ->React.array}
      <RenderIf condition={hiddenCount > 0}>
        <span className={`text-nd_gray-500 ${body.sm.medium}`}>
          {`+${hiddenCount->Int.toString} others`->React.string}
        </span>
      </RenderIf>
    </div>
  }
}

let getIssuersField = (~paymentMethod, ~catalogueState) =>
  FormRenderer.makeFieldInfo(
    ~label="Issuers",
    ~name=paymentMethod->getFieldName("issuers"),
    ~customInput=(~input, ~placeholder) =>
      <div className="flex flex-col gap-2">
        <IssuerTags input catalogueState />
        {InputFields.multiSelectInput(
          ~options=catalogueState->getIssuerOptions,
          ~buttonText="Select Issuers",
          ~showSelectAll=false,
          ~showSelectionAsChips=false,
          ~customButtonStyle="!rounded-lg",
          ~fixedDropDownDirection=BottomRight,
          ~searchable=true,
          ~searchInputPlaceHolder="Search issuers",
          ~enableVirtualization=true,
          ~virtualListItemHeight=40,
          ~maxMenuHeight=300,
        )(~input, ~placeholder)}
        <RenderIf condition={catalogueState == Failed}>
          <span className={`text-nd_gray-500 ${body.sm.medium}`}>
            {"Couldn't load the issuer list."->React.string}
          </span>
        </RenderIf>
      </div>,
  )

module BlockingConfigFields = {
  @react.component
  let make = (~paymentMethod, ~wasmOptions, ~catalogueState) => {
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
      <FormRenderer.FieldRenderer
        field={getIssuersField(~paymentMethod, ~catalogueState)}
        labelClass={`!${body.sm.medium} !text-nd_gray-700 !mb-1`}
      />
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
