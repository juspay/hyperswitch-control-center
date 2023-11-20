external inputAsString: ReactEvent.Form.t => string = "%identity"
external inputAsArray: ReactEvent.Form.t => array<Js.Json.t> = "%identity"
external stringToForm: string => ReactEvent.Form.t = "%identity"
external toReactForm: 'a => ReactEvent.Form.t = "%identity"

open LogicUtils

type fieldType = String | Array

type fieldInfo = {
  fieldName: string,
  fieldType: fieldType,
  customFunction?: (ReactFinalForm.fieldRenderPropsInput, string) => unit,
}

module BaseComponent = {
  @react.component
  let make = (
    ~input: ReactFinalForm.fieldRenderPropsInput,
    ~placeholder="Quick Search",
    ~isDisabled=false,
    ~type_="text",
    ~inputMode="text",
    ~autoComplete=?,
    ~autoFocus=false,
    ~leftIcon=?,
    ~inputStyle="",
    ~submitOnEnter=true,
    ~selectedMode,
    ~fieldType,
    ~setComboVal,
    ~comboVal,
    ~customSubmitFunction=?,
  ) => {
    let fieldInput = ReactFinalForm.useField(selectedMode).input
    let showPopUp = PopUpState.useShowPopUp()

    let input = {
      ...input,
      onChange: val => {
        fieldInput.onChange(
          switch fieldType {
          | String => val
          | Array =>
            val->inputAsString->Js.String2.split(",")->Js.Array2.filter(x => x !== "")->toReactForm
          },
        )
      },
    }

    let localInput = React.useMemo2((): ReactFinalForm.fieldRenderPropsInput => {
      {
        name: "--",
        onBlur: _ev => (),
        onChange: ev => {
          let value = {ev->ReactEvent.Form.target}["value"]
          if value->Js.String2.includes("<script>") || value->Js.String2.includes("</script>") {
            showPopUp({
              popUpType: (Warning, WithIcon),
              heading: `Script Tags are not allowed`,
              description: React.string(`Input cannot contain <script>, </script> tags`),
              handleConfirm: {text: "OK"},
            })
          }
          let val = value->Js.String2.replace("<script>", "")->Js.String2.replace("</script>", "")

          setComboVal(_ => val)
        },
        onFocus: _ev => (),
        value: {
          Js.Json.string(comboVal)
        },
        checked: false,
      }
    }, (comboVal, selectedMode))

    let handleKeyUp = React.useCallback1(ev => {
      if !submitOnEnter {
        let value = {ev->ReactEvent.Keyboard.target}["value"]->inputAsString->Js.String2.trim
        input.onChange(value->stringToForm)
      } else {
        let key = ev->ReactEvent.Keyboard.key
        let keyCode = ev->ReactEvent.Keyboard.keyCode
        if key === "Enter" || keyCode === 13 {
          let value = {ev->ReactEvent.Keyboard.target}["value"]->inputAsString->Js.String2.trim
          switch customSubmitFunction {
          | Some(fn) => fn(input, value)
          | None =>
            if value !== "" {
              input.onChange(value->stringToForm)
            }
          }
        }
      }
    }, [selectedMode])

    let onClick = (_: ReactEvent.Mouse.t) => {
      fieldInput.onChange(""->stringToForm)
      setComboVal(_ => "")
    }

    let rightIconVis =
      localInput.value == Js.Json.string("") ? React.null : <Icon name={"crossicon"} size=15 />

    <TextInput
      input=localInput
      placeholder
      isDisabled
      type_
      inputMode
      rightIcon=rightIconVis
      rightIconOnClick=onClick
      ?autoComplete
      ?leftIcon
      autoFocus
      inputStyle
      onKeyUp=handleKeyUp
      customStyle="!h-10"
    />
  }
}

@react.component
let make = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~placeholder,
  ~isDisabled=false,
  ~type_="text",
  ~inputMode="text",
  ~autoComplete=?,
  ~autoFocus=false,
  ~leftIcon=?,
  ~inputStyle="",
  ~submitOnEnter=true,
  ~fieldName,
  ~setFieldName,
  ~fields: array<fieldInfo>,
) => {
  let _ = placeholder
  let form = ReactFinalForm.useForm()

  let urlParam = RescriptReactRouter.useUrl().search
  let comboInputParam =
    urlParam
    ->Js.String2.split("&")
    ->Js.Array2.find(item => {
      let key = item->Js.String2.split("=")->Belt.Array.get(0)->Belt.Option.getWithDefault("")
      fields->Js.Array2.find(item => item.fieldName === key)->Belt.Option.isSome
    })
    ->Belt.Option.getWithDefault("")

  let keyValArr = Js.String2.split(comboInputParam, "=")
  let value = keyValArr->Belt.Array.get(1)->Belt.Option.getWithDefault("")
  let key = keyValArr->Belt.Array.get(0)->Belt.Option.getWithDefault("")
  let value = if value->Js.String2.startsWith("[") && value->Js.String2.endsWith("]") {
    value->Js.String2.slice(~from=1, ~to_=-1)
  } else {
    value
  }

  let (comboVal, setComboVal) = React.useState(_ => value)

  let (selectedMode, setSelectedMode) = React.useState(_ => key !== "" ? key : fieldName)
  React.useEffect1(_ => {
    setFieldName(_ => selectedMode)
    None
  }, [selectedMode])

  React.useEffect1(() => {
    if key !== selectedMode && key !== "" {
      setSelectedMode(_ => key)
    }
    None
  }, [key])

  React.useEffect1(() => {
    if value !== comboVal {
      setComboVal(_ => value)
    }
    None
  }, [value])

  let idsSearchOptions: array<SelectBox.dropdownOption> = fields->Js.Array2.map(item => {
    let obj: SelectBox.dropdownOption = {
      label: item.fieldName->camelCaseToTitle,
      value: item.fieldName,
    }
    obj
  })

  let selectedField = fields->Js.Array2.find(item => item.fieldName === selectedMode)
  let currentFieldType =
    selectedField
    ->Belt.Option.flatMap(item => Some(item.fieldType))
    ->Belt.Option.getWithDefault(String)
  let customSubmitFunction = selectedField->Belt.Option.flatMap(item => item.customFunction)
  let newCalculationRuleFieldInput = React.useMemo1((): ReactFinalForm.fieldRenderPropsInput => {
    {
      name: "--",
      onBlur: _ev => (),
      onChange: ev => {
        setComboVal(_ => "")
        let value = ev->inputAsString
        form.change(selectedMode, Js.Json.null)
        setSelectedMode(_ => value)
      },
      onFocus: _ev => (),
      value: Js.Json.string(selectedMode),
      checked: false,
    }
  }, [selectedMode])
  <ButtonGroup>
    <SelectBox
      buttonText={newCalculationRuleFieldInput.value->Js.String.make}
      options=idsSearchOptions
      input=newCalculationRuleFieldInput
      deselectDisable=true
    />
    <BaseComponent
      input
      placeholder={selectedMode->camelCaseToTitle}
      isDisabled
      type_
      inputMode
      ?autoComplete
      autoFocus
      ?leftIcon
      inputStyle
      submitOnEnter
      selectedMode
      fieldType=currentFieldType
      setComboVal
      comboVal
      ?customSubmitFunction
    />
  </ButtonGroup>
}
