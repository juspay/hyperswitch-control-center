let getFloat = strJson => strJson->JSON.Decode.string->Option.flatMap(val => val->Float.fromString)

@react.component
let make = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~placeholder,
  ~isDisabled=false,
  ~inputMode="number",
  ~customStyle="",
  ~precision=?,
  ~maxLength=?,
  ~removeLeadingZeroes=false,
  ~leftIcon=?,
  ~rightIcon=?,
  ~customPaddingClass=?,
  ~rightIconCustomStyle=?,
  ~leftIconCustomStyle=?,
) => {
  let isBlendEnabled = BlendContext.useBlendEnabled()

  if isBlendEnabled {
    let blendValue =
      input.value->JSON.Decode.float->Option.mapOr(Nullable.null, f => Nullable.make(f))

    let blendOnChange = ev => {
      let strValue: string = ReactEvent.Form.target(ev)["value"]

      let cleanedValue = switch strValue->Js.String2.match_(%re("/[\d\.]/g")) {
      | Some(strArr) =>
        let str = strArr->Array.joinWithUnsafe("")->String.split(".")->Array.slice(~start=0, ~end=2)
        if removeLeadingZeroes {
          str[0] = str[0]->Option.getOr("")->String.replaceRegExp(%re("/\b0+/g"), "")
          str[0] =
            str[0]->Option.getOr("")->LogicUtils.isEmptyString ? "0" : str[0]->Option.getOr("")
          str->Array.joinWith(".")
        } else {
          str->Array.joinWith(".")
        }
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

      let finalVal =
        precisionCheckedVal->LogicUtils.isNonEmptyString ? precisionCheckedVal : cleanedValue

      switch finalVal->Float.fromString {
      | Some(num) => input.onChange(num->Identity.anyTypeToReactEvent)
      | None =>
        if strValue->LogicUtils.isEmptyString {
          input.onChange(JSON.Encode.null->Identity.anyTypeToReactEvent)
        }
      }
    }

    <NumberInputBinding
      value=blendValue onChange=blendOnChange disabled=isDisabled placeholder ?maxLength
    />
  } else {
    <NumericTextInput
      input
      placeholder
      isDisabled
      inputMode
      customStyle
      ?precision
      ?maxLength
      removeLeadingZeroes
      ?leftIcon
      ?rightIcon
      ?customPaddingClass
      ?rightIconCustomStyle
      ?leftIconCustomStyle
    />
  }
}
