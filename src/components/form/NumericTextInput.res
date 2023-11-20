external toReactFormEvent: 'a => ReactEvent.Form.t = "%identity"
let getFloat = strJson => strJson->Js.Json.decodeString->Belt.Option.flatMap(Belt.Float.fromString)

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
  let inputRef = React.useRef(Js.Nullable.null)
  React.useEffect2(() => {
    switch widthMatchwithPlaceholderLength {
    | Some(length) =>
      switch inputRef.current->Js.Nullable.toOption {
      | Some(elem) =>
        let size =
          elem
          ->Webapi.Dom.Element.getAttribute("placeholder")
          ->Belt.Option.mapWithDefault(length, str =>
            Js.Math.max_int(length, str->Js.String2.length)
          )
          ->Belt.Int.toString

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

        let strValue = value->Js.Json.decodeString->Belt.Option.getWithDefault("")

        let cleanedValue = switch strValue->Js.String2.match_(%re("/[\d\.]/g")) {
        | Some(strArr) =>
          let str =
            strArr
            ->Js.Array2.joinWith("")
            ->Js.String2.split(".")
            ->Js.Array2.slice(~start=0, ~end_=2)
          let result = if removeLeadingZeroes {
            str[0] =
              str[0]->Belt.Option.getWithDefault("")->Js.String2.replaceByRe(%re("/\b0+/g"), "")
            str[0] =
              str[0]->Belt.Option.getWithDefault("") === ""
                ? "0"
                : str[0]->Belt.Option.getWithDefault("")
            str->Js.Array2.joinWith(".")
          } else {
            str->Js.Array2.joinWith(".")
          }
          result
        | None => ""
        }
        let indexOfDec = cleanedValue->Js.String2.indexOf(".")
        let precisionCheckedVal = switch precision {
        | Some(val) =>
          if indexOfDec > 0 {
            cleanedValue->Js.String2.slice(~from=0, ~to_={indexOfDec + val + 1})
          } else {
            ""
          }
        | None => ""
        }

        let finalVal = precisionCheckedVal !== "" ? precisionCheckedVal : cleanedValue
        setLocalStrValue(_ => finalVal->Js.Json.string)

        switch finalVal->Js.Json.string->getFloat {
        | Some(num) => input.onChange(num->toReactFormEvent)
        | None =>
          if value === "" {
            input.onChange(Js.Json.null->toReactFormEvent)
          }
        }
      },
    }
  }, (localStrValue, input))

  React.useEffect1(() => {
    setLocalStrValue(prevLocalStr => {
      let numericPrevLocalValue =
        prevLocalStr
        ->Js.Json.decodeString
        ->Belt.Option.flatMap(Belt.Float.fromString)
        ->Belt.Option.map(Js.Json.number)
        ->Belt.Option.getWithDefault(Js.Json.null)
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
