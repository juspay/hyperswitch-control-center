open AdvancedRoutingUtils
open FormRenderer

module LogicalOps = {
  @react.component
  let make = (~id) => {
    let {globalUIConfig: {font: {textColor}}} = React.useContext(ThemeProvider.themeContext)
    let logicalOpsInput = ReactFinalForm.useField(`${id}.logical`).input

    React.useEffect(() => {
      if logicalOpsInput.value->LogicUtils.getStringFromJson("")->String.length === 0 {
        logicalOpsInput.onChange("AND"->Identity.stringToFormReactEvent)
      }
      None
    }, [])
    let onChange = str => logicalOpsInput.onChange(str->Identity.stringToFormReactEvent)

    <ButtonGroup wrapperClass="flex flex-row mr-2 ml-1">
      {["AND", "OR"]
      ->Array.mapWithIndex((text, i) => {
        let active = logicalOpsInput.value->LogicUtils.getStringFromJson("") === text
        <Button
          key={i->Int.toString}
          text
          onClick={_ => onChange(text)}
          textStyle={active ? `${textColor.primaryNormal}` : ""}
          textWeight={active ? "font-semibold" : "font-medium"}
          customButtonStyle={active ? "shadow-inner" : ""}
          buttonType={active ? SecondaryFilled : Secondary}
        />
      })
      ->React.array}
    </ButtonGroup>
  }
}

module OperatorInp = {
  @react.component
  let make = (~fieldsArray: array<ReactFinalForm.fieldRenderProps>, ~keyType) => {
    let defaultInput: ReactFinalForm.fieldRenderProps = {
      input: ReactFinalForm.makeInputRecord(""->JSON.Encode.string, _ => ()),
      meta: ReactFinalForm.makeCustomError(None),
    }
    let field = (fieldsArray->Array.get(0)->Option.getOr(defaultInput)).input
    let operator = (fieldsArray->Array.get(1)->Option.getOr(defaultInput)).input
    let valInp = (fieldsArray->Array.get(2)->Option.getOr(defaultInput)).input
    let (opVals, setOpVals) = React.useState(_ => [])

    let input: ReactFinalForm.fieldRenderPropsInput = {
      name: "string",
      onBlur: _ => (),
      onChange: ev => {
        let value = ev->Identity.formReactEventToString
        operator.onChange(value->Identity.anyTypeToReactEvent)
      },
      onFocus: _ => (),
      value: operator.value
      ->LogicUtils.getStringFromJson("")
      ->operatorMapper
      ->operatorTypeToStringMapper
      ->JSON.Encode.string,
      checked: true,
    }
    React.useEffect(() => {
      let operatorVals = switch keyType->variantTypeMapper {
      | Enum_variant => ["IS", "CONTAINS", "IS_NOT", "NOT_CONTAINS"]
      | Number => ["EQUAL TO", "GREATER THAN", "LESS THAN"]
      | Metadata_value => ["EQUAL TO"]
      | String_value => ["EQUAL TO", "NOT EQUAL_TO"]
      | _ => []
      }

      setOpVals(_ => operatorVals)

      if operator.value->JSON.Decode.string->Option.isNone {
        operator.onChange(operatorVals[0]->Identity.anyTypeToReactEvent)
      }
      None
    }, (field.value, valInp.value))
    let descriptionDict =
      [
        ("IS", "Includes only results that exactly match the filter value(s)."),
        ("CONTAINS", "Includes only results with any value for the filter property."),
        ("IS_NOT", "Includes results that does not match the filter value(s)."),
        ("NOT_CONTAINS", "Includes results except any value for the filter property."),
      ]->Dict.fromArray
    let disableSelect = field.value->JSON.Decode.string->Option.getOr("")->String.length === 0

    let operatorOptions = opVals->Array.map(opVal => {
      let obj: SelectBox.dropdownOption = {
        label: opVal,
        value: opVal,
      }

      switch descriptionDict->Dict.get(opVal) {
      | Some(description) => {...obj, description}
      | None => obj
      }
    })
    let textColorStyle = disableSelect ? "text-hyperswitch_red opacity-50" : "text-hyperswitch_red"
    <SelectBox.BaseDropdown
      allowMultiSelect=false
      buttonText="Select Operator"
      input
      options=operatorOptions
      hideMultiSelectButtons=true
      textStyle={`text-body ${textColorStyle}`}
      disableSelect
      customButtonStyle="!w-full"
    />
  }
}

module ValueInp = {
  @react.component
  let make = (~fieldsArray: array<ReactFinalForm.fieldRenderProps>, ~variantValues, ~keyType) => {
    let valueField = (fieldsArray[1]->Option.getOr(ReactFinalForm.fakeFieldRenderProps)).input
    let opField = (fieldsArray[2]->Option.getOr(ReactFinalForm.fakeFieldRenderProps)).input
    let typeField = (fieldsArray[3]->Option.getOr(ReactFinalForm.fakeFieldRenderProps)).input

    React.useEffect(() => {
      typeField.onChange(
        if keyType->variantTypeMapper === Metadata_value {
          "metadata_variant"
        } else if keyType->variantTypeMapper === String_value {
          "str_value"
        } else {
          switch opField.value->LogicUtils.getStringFromJson("")->operatorMapper {
          | IS
          | IS_NOT => "enum_variant"
          | CONTAINS
          | NOT_CONTAINS => "enum_variant_array"
          | _ => "number"
          }
        }->Identity.anyTypeToReactEvent,
      )
      None
    }, [valueField.value])

    let input: ReactFinalForm.fieldRenderPropsInput = {
      name: "string",
      onBlur: _ => (),
      onChange: ev => {
        let value = ev->Identity.formReactEventToArrayOfString
        valueField.onChange(value->Identity.anyTypeToReactEvent)
      },
      onFocus: _ => (),
      value: valueField.value,
      checked: true,
    }

    switch opField.value->LogicUtils.getStringFromJson("")->operatorMapper {
    | CONTAINS | NOT_CONTAINS =>
      <SelectBox.BaseDropdown
        allowMultiSelect=true
        buttonText="Select Value"
        input
        options={variantValues->SelectBox.makeOptions}
        hideMultiSelectButtons=true
        showSelectionAsChips={false}
        maxHeight="max-h-full sm:max-h-64"
        customButtonStyle="!w-full"
      />
    | IS | IS_NOT => {
        let val = valueField.value->LogicUtils.getStringFromJson("")
        <SelectBox.BaseDropdown
          allowMultiSelect=false
          buttonText={val->String.length === 0 ? "Select Value" : val}
          input
          options={variantValues->SelectBox.makeOptions}
          hideMultiSelectButtons=true
          fixedDropDownDirection=SelectBox.TopRight
          customButtonStyle="!w-full"
        />
      }
    | EQUAL_TO =>
      switch keyType->variantTypeMapper {
      | String_value | Metadata_value => <TextInput input placeholder="Enter value" />
      | _ => <NumericTextInput placeholder={"Enter value"} input />
      }

    | NOT_EQUAL_TO => <TextInput input placeholder="Enter value" />
    | LESS_THAN | GREATER_THAN => <NumericTextInput placeholder={"Enter value"} input />

    | _ => React.null
    }
  }
}

module MetadataInp = {
  @react.component
  let make = (~fieldsArray: array<ReactFinalForm.fieldRenderProps>, ~keyType) => {
    let valueField = (fieldsArray[2]->Option.getOr(ReactFinalForm.fakeFieldRenderProps)).input

    let textInput: ReactFinalForm.fieldRenderPropsInput = {
      name: "string",
      onBlur: _ => {
        let value = valueField.value
        let val = value->LogicUtils.getStringFromJson("")
        let valSplit = String.split(val, ",")
        let arrStr = valSplit->Array.map(item => {
          String.trim(item)
        })
        let finalVal = Array.joinWith(arrStr, ",")->JSON.Encode.string

        valueField.onChange(finalVal->Identity.anyTypeToReactEvent)
      },
      onChange: ev => {
        let target = ReactEvent.Form.target(ev)
        let value = target["value"]
        valueField.onChange(value->Identity.anyTypeToReactEvent)
      },
      onFocus: _ => (),
      value: valueField.value,
      checked: true,
    }
    <RenderIf condition={keyType->variantTypeMapper === Metadata_value}>
      <TextInput placeholder={"Enter Key"} input=textInput />
    </RenderIf>
  }
}

let renderOperatorInp = keyType => (fieldsArray: array<ReactFinalForm.fieldRenderProps>) => {
  <OperatorInp fieldsArray keyType />
}
let renderValueInp = (keyType: string, variantValues) => (
  fieldsArray: array<ReactFinalForm.fieldRenderProps>,
) => {
  <ValueInp fieldsArray variantValues keyType />
}

let renderMetaInput = keyType => (fieldsArray: array<ReactFinalForm.fieldRenderProps>) => {
  <MetadataInp fieldsArray keyType />
}

let operatorInput = (id, keyType) => {
  makeMultiInputFieldInfoOld(
    ~label="",
    ~comboCustomInput=renderOperatorInp(keyType),
    ~inputFields=[
      makeInputFieldInfo(~name=`${id}.lhs`),
      makeInputFieldInfo(~name=`${id}.comparison`),
      makeInputFieldInfo(~name=`${id}.value.value`),
    ],
    (),
  )
}

let valueInput = (id, variantValues, keyType) => {
  let valuePath = if keyType->variantTypeMapper === Metadata_value {
    `value.value.value`
  } else {
    `value.value`
  }
  makeMultiInputFieldInfoOld(
    ~label="",
    ~comboCustomInput=renderValueInp(keyType, variantValues),
    ~inputFields=[
      makeInputFieldInfo(~name=`${id}.lhs`),
      makeInputFieldInfo(~name=`${id}.${valuePath}`),
      makeInputFieldInfo(~name=`${id}.comparison`),
      makeInputFieldInfo(~name=`${id}.value.type`),
    ],
    (),
  )
}
let metaInput = (id, keyType) =>
  makeMultiInputFieldInfoOld(
    ~label="",
    ~comboCustomInput=renderMetaInput(keyType),
    ~inputFields=[
      makeInputFieldInfo(~name=`${id}.value`),
      makeInputFieldInfo(~name=`${id}.operator`),
      makeInputFieldInfo(~name=`${id}.value.value.key`),
    ],
    (),
  )

module FieldInp = {
  @react.component
  let make = (~methodKeys, ~prefix, ~onChangeMethod) => {
    let url = RescriptReactRouter.useUrl()
    let field = ReactFinalForm.useField(`${prefix}.lhs`).input
    let op = ReactFinalForm.useField(`${prefix}.comparison`).input
    let val = ReactFinalForm.useField(`${prefix}.value.value`).input

    let convertedValue = React.useMemo(() => {
      let keyDescriptionMapper = switch url->RoutingUtils.urlToVariantMapper {
      | PayoutRouting => Window.getPayoutDescriptionCategory()->Identity.jsonToAnyType
      | _ => Window.getDescriptionCategory()->Identity.jsonToAnyType
      }
      keyDescriptionMapper->LogicUtils.convertMapObjectToDict
    }, [])

    let options = React.useMemo(() =>
      convertedValue
      ->Dict.keysToArray
      ->Array.reduce([], (acc, ele) => {
        open LogicUtils
        convertedValue
        ->getArrayFromDict(ele, [])
        ->Array.forEach(
          value => {
            let dictValue = value->LogicUtils.getDictFromJsonObject
            let kindValue = dictValue->getString("kind", "")
            if methodKeys->Array.includes(kindValue) {
              let generatedSelectBoxOptionType: SelectBox.dropdownOption = {
                label: kindValue,
                value: kindValue,
                description: dictValue->getString("description", ""),
                optGroup: ele,
              }
              acc->Array.push(generatedSelectBoxOptionType)->ignore
            }
          },
        )
        acc
      })
    , [])

    let input: ReactFinalForm.fieldRenderPropsInput = {
      name: "string",
      onBlur: _ => (),
      onChange: ev => {
        let value = ev->Identity.formReactEventToString
        onChangeMethod(value)
        field.onChange(value->Identity.anyTypeToReactEvent)
        op.onChange(""->Identity.anyTypeToReactEvent)
        val.onChange(""->Identity.anyTypeToReactEvent)
      },
      onFocus: _ => (),
      value: field.value,
      checked: true,
    }

    <SelectBox.BaseDropdown
      allowMultiSelect=false
      buttonText="Select Field"
      input
      options
      hideMultiSelectButtons=true
      customButtonStyle="!w-full"
    />
  }
}

module RuleFieldBase = {
  @react.component
  let make = (
    ~isFirst,
    ~id,
    ~isExpanded,
    ~onClick,
    ~wasm,
    ~isFrom3ds,
    ~isFromSurcharge,
    ~isFrom3DsExemptions,
  ) => {
    let url = RescriptReactRouter.useUrl()
    let (hover, setHover) = React.useState(_ => false)
    let (keyType, setKeyType) = React.useState(_ => "")
    let (variantValues, setVariantValues) = React.useState(_ => [])
    let field = ReactFinalForm.useField(`${id}.lhs`).input

    let setKeyTypeAndVariants = (wasm, value) => {
      let keyType = getWasmKeyType(wasm, value)
      let keyVariant = keyType->variantTypeMapper
      if keyVariant !== Number || keyVariant !== Metadata_value {
        let variantValues = switch url->RoutingUtils.urlToVariantMapper {
        | PayoutRouting => getWasmPayoutVariantValues(wasm, value)
        | _ => getWasmVariantValues(wasm, value)
        }
        setVariantValues(_ => variantValues)
      }
      setKeyType(_ => keyType)
    }

    let onChangeMethod = value => {
      setKeyTypeAndVariants(wasm, value)
    }

    let methodKeys = React.useMemo(() => {
      let value = field.value->LogicUtils.getStringFromJson("")
      if value->LogicUtils.isNonEmptyString {
        setKeyTypeAndVariants(wasm, value)
      }
      if isFrom3ds {
        Window.getThreeDsKeys()
      } else if isFrom3DsExemptions {
        Window.getThreeDsDecisionRuleKeys()
      } else if isFromSurcharge {
        Window.getSurchargeKeys()
      } else {
        switch url->RoutingUtils.urlToVariantMapper {
        | PayoutRouting => Window.getAllPayoutKeys()
        | _ => Window.getAllKeys()
        }
      }
    }, [field.value])

    <RenderIf condition={methodKeys->Array.length > 0}>
      {if isExpanded {
        <div
          className={`flex flex-wrap items-center px-1 ${hover
              ? "rounded-md bg-white dark:bg-black shadow"
              : ""}`}>
          <RenderIf condition={!isFirst}>
            <LogicalOps id />
          </RenderIf>
          <div className="-mt-5 p-1">
            <FieldWrapper label="">
              <FieldInp methodKeys prefix=id onChangeMethod />
            </FieldWrapper>
          </div>
          <div className="-mt-5">
            <FieldRenderer field={metaInput(id, keyType)} />
          </div>
          <div className="-mt-5">
            <FieldRenderer field={operatorInput(id, keyType)} />
          </div>
          <div className="-mt-5">
            <FieldRenderer field={valueInput(id, variantValues, keyType)} />
          </div>
          <RenderIf condition={!isFirst}>
            <div
              onClick
              onMouseEnter={_ => setHover(_ => true)}
              onMouseLeave={_ => setHover(_ => false)}
              className="flex items-center cursor-pointer rounded-full  border border-jp-gray-500 dark:border-jp-gray-960 bg-red-400 hover:shadow focus:outline-none p-2">
              <Icon size=10 className="text-gray-50 font-semibold" name="close" />
            </div>
          </RenderIf>
        </div>
      } else {
        <MakeRuleFieldComponent.CompressedView isFirst id keyType />
      }}
    </RenderIf>
  }
}

module MakeRuleField = {
  @react.component
  let make = (~id, ~isExpanded, ~wasm, ~isFrom3ds, ~isFromSurcharge, ~isFrom3DsExemptions) => {
    let ruleJsonPath = `${id}.statements`
    let conditionsInput = ReactFinalForm.useField(ruleJsonPath).input
    let fields = conditionsInput.value->JSON.Decode.array->Option.getOr([])
    let plusBtnEnabled = true
    //fields->Array.every(validateConditionJson)
    let onPlusClick = _ => {
      if plusBtnEnabled {
        let toAdd = Dict.make()
        conditionsInput.onChange(
          Array.concat(
            fields,
            [toAdd->JSON.Encode.object],
          )->Identity.arrayOfGenericTypeToFormReactEvent,
        )
      }
    }

    let onCrossClick = index => {
      conditionsInput.onChange(
        fields
        ->Array.filterWithIndex((_, i) => index !== i)
        ->Identity.arrayOfGenericTypeToFormReactEvent,
      )
    }

    <div className="flex flex-wrap items-center">
      {Array.mapWithIndex(fields, (_, i) =>
        <RuleFieldBase
          key={i->Int.toString}
          onClick={_ => onCrossClick(i)}
          isFirst={i === 0}
          id={`${ruleJsonPath}[${i->Int.toString}]`}
          isExpanded
          wasm
          isFrom3ds
          isFromSurcharge
          isFrom3DsExemptions
        />
      )->React.array}
      {if isExpanded {
        <div
          onClick={onPlusClick}
          className={`focus:outline-none p-2 ml-8 mt-2 md:mt-0 flex items-center bg-white dark:bg-jp-gray-darkgray_background 
           rounded-full border border-jp-gray-500 dark:border-jp-gray-960 
           text-jp-gray-900 dark:text-jp-gray-text_darktheme   
          ${plusBtnEnabled
              ? "cursor-pointer text-opacity-75 dark:text-opacity-50 
                hover:text-opacity-100 dark:hover:text-opacity-75 hover:shadow"
              : "cursor-not-allowed text-opacity-50 dark:text-opacity-50"}`}>
          <Icon size=14 name="plus" />
        </div>
      } else {
        <Icon size=14 name="arrow-right" className="ml-4" />
      }}
    </div>
  }
}

let configurationNameInput = makeFieldInfo(
  ~label="Configuration Name",
  ~name="name",
  ~isRequired=true,
  ~placeholder="Enter Configuration Name",
  ~customInput=InputFields.textInput(~autoFocus=true),
)
let descriptionInput = makeFieldInfo(
  ~label="Description",
  ~name="description",
  ~isRequired=true,
  ~placeholder="Add a description for your configuration",
  ~customInput=InputFields.multiLineTextInput(
    ~isDisabled=false,
    ~rows=Some(3),
    ~cols=None,
    ~customClass="text-sm",
  ),
)

module ConfigureRuleButton = {
  @react.component
  let make = (~setShowModal, ~isConfigButtonEnabled) => {
    let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
      ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
    )

    <Button
      text={"Configure Rule"}
      buttonType=Primary
      buttonState={!formState.hasValidationErrors && isConfigButtonEnabled ? Normal : Disabled}
      onClick={_ => {
        setShowModal(_ => true)
      }}
      customButtonStyle="w-1/5"
    />
  }
}

module SaveAndActivateButton = {
  @react.component
  let make = (
    ~onSubmit: (JSON.t, 'a) => promise<Nullable.t<JSON.t>>,
    ~handleActivateConfiguration,
  ) => {
    let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
      ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
    )

    let handleSaveAndActivate = async _ => {
      try {
        let onSubmitResponse = await onSubmit(formState.values, false)
        let currentActivatedFromJson =
          onSubmitResponse->LogicUtils.getValFromNullableValue(JSON.Encode.null)
        let currentActivatedId =
          currentActivatedFromJson->LogicUtils.getDictFromJsonObject->LogicUtils.getString("id", "")
        let _ = await handleActivateConfiguration(Some(currentActivatedId))
      } catch {
      | Exn.Error(e) =>
        let _err = Exn.message(e)->Option.getOr("Failed to save and activate configuration!")
      }
    }
    <Button
      text={"Save and Activate Rule"}
      buttonType={Primary}
      buttonSize=Button.Small
      onClick={_ => {
        handleSaveAndActivate()->ignore
      }}
      customButtonStyle="w-1/5"
    />
  }
}
