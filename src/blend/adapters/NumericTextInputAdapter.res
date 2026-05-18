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
      let parts = strArr->Array.joinWithUnsafe("")->String.split(".")->Array.slice(~start=0, ~end=2)
      if removeLeadingZeroes {
        parts[0] = parts[0]->Option.getOr("")->String.replaceRegExp(%re("/\b0+/g"), "")
        parts[0] = parts[0]->Option.getOr("")->isEmptyString ? "0" : parts[0]->Option.getOr("")
      }
      parts->Array.joinWith(".")
    | None => ""
    }
    let indexOfDec = cleanedValue->String.indexOf(".")
    let precisionCheckedVal = switch precision {
    | Some(val) =>
      if indexOfDec > 0 {
        cleanedValue->String.slice(~start=0, ~end={indexOfDec + val + 1})
      } else {
        ""
      }
    | None => ""
    }
    precisionCheckedVal->isNonEmptyString ? precisionCheckedVal : cleanedValue
  }

  let blendValue =
    input.value->JSON.Decode.float->Option.mapOr(Nullable.null, f => Nullable.make(f))

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
