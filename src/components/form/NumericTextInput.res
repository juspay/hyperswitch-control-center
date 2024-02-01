let getFloat = strJson => strJson->JSON.Decode.string->Option.flatMap(Float.fromString)

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
  React.useEffect2(() => {
    switch widthMatchwithPlaceholderLength {
    | Some(length) =>
      switch inputRef.current->Nullable.toOption {
      | Some(elem) =>
        let size =
          elem
          ->Webapi.Dom.Element.getAttribute("placeholder")
          ->Option.mapOr(length, str => Js.Math.max_int(length, str->String.length))
          ->Int.toString

        elem->Webapi.Dom.Element.setAttribute("size", size)
      | None => ()
      }

    | None => ()
    }
    None
  }, (inputRef.current, input.name))
  let modifiedInput = React.useMemo2(() => {
    {
      ...input,
      value: localStrValue,
      onChange: ev => {
        let value = ReactEvent.Form.target(ev)["value"]

        let strValue = value->JSON.Decode.string->Option.getOr("")

        let cleanedValue = switch strValue->Js.String2.match_(%re("/[\d\.]/g")) {
        | Some(strArr) =>
          let str =
            strArr->Array.joinWithUnsafe("")->String.split(".")->Array.slice(~start=0, ~end=2)
          let result = if removeLeadingZeroes {
            str[0] = str[0]->Option.getOr("")->String.replaceRegExp(%re("/\b0+/g"), "")
            str[0] = str[0]->Option.getOr("") === "" ? "0" : str[0]->Option.getOr("")
            str->Array.joinWith(".")
          } else {
            str->Array.joinWith(".")
          }
          result
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

        let finalVal = precisionCheckedVal !== "" ? precisionCheckedVal : cleanedValue
        setLocalStrValue(_ => finalVal->JSON.Encode.string)

        switch finalVal->JSON.Encode.string->getFloat {
        | Some(num) => input.onChange(num->Identity.anyTypeToReactEvent)
        | None =>
          if value === "" {
            input.onChange(JSON.Encode.null->Identity.anyTypeToReactEvent)
          }
        }
      },
    }
  }, (localStrValue, input))

  React.useEffect1(() => {
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
