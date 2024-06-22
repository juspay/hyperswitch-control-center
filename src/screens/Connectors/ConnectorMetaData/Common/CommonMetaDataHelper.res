let textInput = (~field: CommonMetaDataTypes.inputField, ~formName) => {
  let {placeholder, label, required} = field
  FormRenderer.makeFieldInfo(
    ~label,
    ~name={formName},
    ~placeholder,
    ~customInput=InputFields.textInput(),
    ~isRequired=required,
    (),
  )
}

let selectInput = (~field: CommonMetaDataTypes.inputField, ~options, ~formName) => {
  let {label, required} = field
  FormRenderer.makeFieldInfo(
    ~label,
    ~isRequired=required,
    ~name={formName},
    ~customInput=(~input) =>
      InputFields.selectInput(
        ~input={
          ...input,
          onChange: event => {
            let value = event->Identity.formReactEventToString
            input.onChange(value->Identity.anyTypeToReactEvent)
          },
        },
        ~options={options},
        ~buttonText="Select Value",
        (),
      ),
    (),
  )
}

let multiSelectInput = (~field: CommonMetaDataTypes.inputField, ~formName) => {
  let {label, required, options} = field
  FormRenderer.makeFieldInfo(
    ~label,
    ~isRequired=required,
    ~name={formName},
    ~customInput=InputFields.selectInput(
      ~deselectDisable=true,
      ~fullLength=true,
      ~customStyle="max-h-48",
      ~customButtonStyle="pr-3",
      ~options={options->SelectBox.makeOptions},
      ~buttonText="Select Value",
      (),
    ),
    (),
  )
}

let toggleInput = (~field: CommonMetaDataTypes.inputField, ~formName) => {
  let {label} = field
  FormRenderer.makeFieldInfo(
    ~name={formName},
    ~label,
    ~customInput=InputFields.boolInput(~isDisabled=false, ~boolCustomClass="rounded-lg", ()),
    (),
  )
}

let radioInput = (
  ~field: CommonMetaDataTypes.inputField,
  ~formName,
  ~onItemChange: option<ReactEvent.Form.t => unit>=?,
  ~fill="",
  (),
) => {
  let {label, required, options} = field
  FormRenderer.makeFieldInfo(
    ~label,
    ~isRequired=required,
    ~name={formName},
    ~customInput=(~input) =>
      InputFields.radioInput(
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
        ~options=options->SelectBox.makeOptions,
        ~buttonText="",
        ~isHorizontal=true,
        ~customStyle="cursor-pointer gap-2",
        ~fill,
        (),
      ),
    (),
  )
}
