let textInput = (~field: CommonConnectorTypes.inputField, ~formName) => {
  let {placeholder, label, required} = field
  FormRenderer.makeFieldInfo(
    ~label,
    ~name={formName},
    ~placeholder,
    ~customInput=InputFields.textInput(),
    ~isRequired=required,
  )
}

let numberInput = (~field: CommonConnectorTypes.inputField, ~formName) => {
  let {placeholder, label, required} = field
  FormRenderer.makeFieldInfo(
    ~label,
    ~name={formName},
    ~placeholder,
    ~customInput=InputFields.numericTextInput(),
    ~isRequired=required,
  )
}

let selectInput = (
  ~field: CommonConnectorTypes.inputField,
  ~formName,
  ~opt=None,
  ~onItemChange: option<ReactEvent.Form.t => unit>=?,
  ~fixedDropDownDirection=SelectBox.BottomRight,
) => {
  let {label, required} = field
  let options = switch opt {
  | Some(value) => value
  | None => field.options->SelectBox.makeOptions
  }

  FormRenderer.makeFieldInfo(~label={label}, ~isRequired=required, ~name={formName}, ~customInput=(
    ~input,
    ~placeholder as _,
  ) =>
    InputFields.selectInput(
      ~customStyle="max-h-48",
      ~options={options},
      ~buttonText="Select Value",
      ~dropdownCustomWidth="",
      ~fixedDropDownDirection,
    )(
      ~input={
        ...input,
        onChange: event => {
          let _ = switch onItemChange {
          | Some(func) => func(event)
          | _ => ()
          }
          input.onChange(event)
        },
      },
      ~placeholder="",
    )
  )
}

let multiSelectInput = (~field: CommonConnectorTypes.inputField, ~formName) => {
  let {label, required, options} = field
  FormRenderer.makeFieldInfo(
    ~label,
    ~isRequired=required,
    ~name={formName},
    ~customInput=InputFields.multiSelectInput(
      ~showSelectionAsChips=false,
      ~customStyle="max-h-48",
      ~customButtonStyle="pr-3",
      ~options={options->SelectBox.makeOptions},
      ~buttonText="Select Value",
    ),
  )
}

let toggleInput = (~field: CommonConnectorTypes.inputField, ~formName) => {
  let {label} = field
  FormRenderer.makeFieldInfo(
    ~name={formName},
    ~label,
    ~customInput=InputFields.boolInput(~isDisabled=false, ~boolCustomClass="rounded-lg"),
  )
}

let radioInput = (
  ~field: CommonConnectorTypes.inputField,
  ~formName,
  ~onItemChange: option<ReactEvent.Form.t => unit>=?,
  ~fill="",
  (),
) => {
  let {label, required, options} = field

  FormRenderer.makeFieldInfo(~label={label}, ~isRequired=required, ~name={formName}, ~customInput=(
    ~input,
    ~placeholder as _,
  ) =>
    InputFields.radioInput(
      ~customStyle="cursor-pointer gap-2",
      ~isHorizontal=false,
      ~options=options->SelectBox.makeOptions,
      ~buttonText="",
      ~fill,
    )(
      ~input={
        ...input,
        onChange: event => {
          let _ = switch onItemChange {
          | Some(func) => func(event)
          | _ => ()
          }
          input.onChange(event)
        },
      },
      ~placeholder="",
    )
  )
}

let getCurrencyOption: CurrencyUtils.currencyCode => SelectBox.dropdownOption = currencyType => {
  open CurrencyUtils
  {
    label: currencyType->getCurrencyCodeStringFromVariant,
    value: currencyType->getCurrencyCodeStringFromVariant,
  }
}

let currencyField = (
  ~name,
  ~options=CurrencyUtils.currencyList,
  ~disableSelect=false,
  ~toolTipText="",
) =>
  FormRenderer.makeFieldInfo(
    ~label="Currency",
    ~isRequired=true,
    ~name,
    ~description=toolTipText,
    ~customInput=InputFields.selectInput(
      ~deselectDisable=true,
      ~disableSelect,
      ~customStyle="max-h-48",
      ~options=options->Array.map(getCurrencyOption),
      ~buttonText="Select Currency",
      ~fixedDropDownDirection=TopLeft,
      ~dropdownCustomWidth="",
    ),
  )
