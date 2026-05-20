open ReactFinalForm
open LogicUtils

@react.component
let make = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~placeholder,
  ~isDisabled=false,
  ~customStyle="",
  ~precision=?,
  ~maxLength=?,
  ~removeLeadingZeroes=false,
  ~rightIcon=?,
  ~rightIconCustomStyle=?,
) => {
  let isBlendEnabled = BlendContext.useBlendEnabled()

  let cleanNumericString = rawValue => {
    let cleanedValue = switch rawValue->Js.String2.match_(%re("/[\d\.]/g")) {
    | Some(strArr) =>
      let parts =
        strArr
        ->Array.filterMap(x => x)
        ->Array.joinWith("")
        ->String.split(".")
        ->Array.slice(~start=0, ~end=2)
      if removeLeadingZeroes {
        let stripped = parts->getValueFromArray(0, "")->String.replaceRegExp(%re("/\b0+/g"), "")
        parts[0] = stripped->isEmptyString ? "0" : stripped
      }
      parts->Array.joinWith(".")
    | None => ""
    }
    let indexOfDec = cleanedValue->String.indexOf(".")
    let precisionCheckedVal = switch precision {
    | Some(val) =>
      indexOfDec > 0 ? cleanedValue->String.slice(~start=0, ~end={indexOfDec + val + 1}) : ""
    | None => ""
    }
    precisionCheckedVal->getNonEmptyString->Option.getOr(cleanedValue)
  }

  let blendValue = input.value->getOptionFloatFromJson->Option.mapOr(Nullable.null, Nullable.make)

  let blendOnChange = ev => {
    let strValue: string = ReactEvent.Form.target(ev)["value"]
    let finalVal = strValue->cleanNumericString

    switch finalVal->Float.fromString {
    | Some(num) => input.onChange(num->Identity.anyTypeToReactEvent)
    | None =>
      if strValue->isEmptyString {
        input.onChange(JSON.Encode.null->Identity.anyTypeToReactEvent)
      }
    }
  }

  <>
    <RenderIf condition=isBlendEnabled>
      <NumberInputBinding
        value=blendValue onChange=blendOnChange disabled=isDisabled placeholder ?maxLength
      />
    </RenderIf>
    <RenderIf condition={!isBlendEnabled}>
      <NumericTextInput
        input
        placeholder
        isDisabled
        customStyle
        ?precision
        ?maxLength
        removeLeadingZeroes
        ?rightIcon
        ?rightIconCustomStyle
      />
    </RenderIf>
  </>
}
