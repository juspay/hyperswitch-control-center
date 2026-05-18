open LogicUtils

let cleanNumericString = (rawValue, ~removeLeadingZeroes=false, ~precision=?) => {
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

@react.component
let make = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~placeholder,
  ~isDisabled=false,
  ~type_="text",
  ~inputMode="number",
  ~customStyle="",
  ~pattern=?,
  ~autoComplete=?,
  ~min=?,
  ~max=?,
  ~precision=?,
  ~maxLength=?,
  ~removeLeadingZeroes=false,
  ~shouldSubmitForm=true,
  ~widthMatchwithPlaceholderLength=None,
  ~leftIcon=?,
  ~rightIcon=?,
  ~iconOpacity=?,
  ~customPaddingClass=?,
  ~rightIconCustomStyle=?,
  ~leftIconCustomStyle=?,
  ~removeValidationCheck=?,
) => {
  let (localStrValue, setLocalStrValue) = React.useState(() => input.value)
  let inputRef = React.useRef(Nullable.null)
  React.useEffect(() => {
    switch widthMatchwithPlaceholderLength {
    | Some(length) =>
      switch inputRef.current->Nullable.toOption {
      | Some(elem) =>
        let size =
          elem
          ->Webapi.Dom.Element.getAttribute("placeholder")
          ->Option.mapOr(length, str => Math.Int.max(length, str->String.length))
          ->Int.toString

        elem->Webapi.Dom.Element.setAttribute("size", size)
      | None => ()
      }

    | None => ()
    }
    None
  }, (inputRef.current, input.name))
  let modifiedInput = React.useMemo(() => {
    {
      ...input,
      value: localStrValue,
      onChange: ev => {
        let value = ReactEvent.Form.target(ev)["value"]
        let strValue = getStringFromJson(value, "")
        let finalVal = strValue->cleanNumericString(~removeLeadingZeroes, ~precision?)
        setLocalStrValue(_ => finalVal->JSON.Encode.string)

        switch finalVal->Float.fromString {
        | Some(num) => input.onChange(num->Identity.anyTypeToReactEvent)
        | None =>
          if value->isEmptyString {
            input.onChange(JSON.Encode.null->Identity.anyTypeToReactEvent)
          }
        }
      },
    }
  }, (localStrValue, input))

  React.useEffect(() => {
    setLocalStrValue(prevLocalStr => {
      let numericPrevLocalValue =
        prevLocalStr
        ->JSON.Decode.string
        ->Option.flatMap(Float.fromString)
        ->Option.map(JSON.Encode.float)
        ->Option.getOr(JSON.Encode.null)
      if input.value === numericPrevLocalValue {
        prevLocalStr
      } else {
        input.value
      }
    })
    None
  }, [input.value])

  <TextInput
    input=modifiedInput
    customStyle
    placeholder
    isDisabled
    type_
    inputMode
    ?maxLength
    ?pattern
    ?autoComplete
    ?min
    ?max
    shouldSubmitForm
    widthMatchwithPlaceholderLength
    ?leftIcon
    ?rightIcon
    ?iconOpacity
    ?customPaddingClass
    ?rightIconCustomStyle
    ?leftIconCustomStyle
    ?removeValidationCheck
  />
}
