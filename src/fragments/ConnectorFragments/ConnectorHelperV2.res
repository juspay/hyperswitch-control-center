let textInput = (~field: CommonConnectorTypes.inputField, ~formName, ~customStyle=?) => {
  let {placeholder, label, required} = field
  let customStyle = {
    switch customStyle {
    | Some(val) => val
    | None => ""
    }
  }
  FormRenderer.makeFieldInfo(
    ~label,
    ~name={formName},
    ~placeholder,
    ~customInput=InputFields.textInput(~customStyle),
    ~isRequired=required,
  )
}

let selectInput = (
  ~field: CommonConnectorTypes.inputField,
  ~formName,
  ~opt=None,
  ~onItemChange: option<ReactEvent.Form.t => unit>=?,
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
    ),
  )

module InfoField = {
  @react.component
  let make = (~label, ~str, ~customElementStyle="") => {
    <div className={`flex flex-col justify-center gap-0.5-rem ${customElementStyle} `}>
      <h2 className="flex-[1] text-nd_gray-400 "> {label->React.string} </h2>
      <h3 className="flex-[3]  overflow-scroll whitespace-nowrap"> {str->React.string} </h3>
    </div>
  }
}
module CredsInfoField = {
  @react.component
  let make = (
    ~authKeys,
    ~connectorAccountFields,
    ~customContainerStyle=?,
    ~customElementStyle="",
  ) => {
    open LogicUtils
    let customContainerCss = {
      switch customContainerStyle {
      | Some(val) => val
      | None => "flex flex-col gap-4"
      }
    }
    let dict = authKeys->Identity.genericTypeToDictOfJson
    <div className=customContainerCss>
      {dict
      ->Dict.keysToArray
      ->Array.filter(ele => ele !== "auth_type")
      ->Array.mapWithIndex((field, index) => {
        let value = dict->getString(field, "")
        let label = connectorAccountFields->getString(field, "")
        <InfoField key={index->Int.toString} label str=value customElementStyle />
      })
      ->React.array}
    </div>
  }
}
module CashtoCodeCredsInfo = {
  @react.component
  let make = (~authKeys: ConnectorTypes.currencyAuthKey) => {
    open LogicUtils
    let dict = authKeys.auth_key_map->Identity.genericTypeToDictOfJson
    dict
    ->Dict.keysToArray
    ->Array.map(ele => {
      let data = dict->getDictfromDict(ele)
      let keys = data->Dict.keysToArray

      {
        <>
          <InfoField label="Currency" str=ele />
          {keys
          ->Array.map(ele => {
            let value = data->getString(ele, "")
            <InfoField label={ele->snakeToTitle} str=value />
          })
          ->React.array}
        </>
      }
    })
    ->React.array
  }
}
module PreviewCreds = {
  @react.component
  let make = (
    ~connectorAccountFields,
    ~connectorInfo: ConnectorTypes.connectorPayloadV2,
    ~customContainerStyle=?,
    ~customElementStyle=?,
  ) => {
    switch connectorInfo.connector_account_details {
    | HeaderKey(authKeys) =>
      <CredsInfoField authKeys connectorAccountFields ?customContainerStyle ?customElementStyle />
    | BodyKey(bodyKey) =>
      <CredsInfoField
        authKeys=bodyKey connectorAccountFields ?customContainerStyle ?customElementStyle
      />
    | SignatureKey(signatureKey) =>
      <CredsInfoField
        authKeys=signatureKey connectorAccountFields ?customContainerStyle ?customElementStyle
      />
    | MultiAuthKey(multiAuthKey) =>
      <CredsInfoField
        authKeys=multiAuthKey connectorAccountFields ?customContainerStyle ?customElementStyle
      />
    | CertificateAuth(certificateAuth) =>
      <CredsInfoField
        authKeys=certificateAuth connectorAccountFields ?customContainerStyle ?customElementStyle
      />
    | CurrencyAuthKey(currencyAuthKey) => <CashtoCodeCredsInfo authKeys=currencyAuthKey />
    | NoKey(_)
    | UnKnownAuthType(_) => React.null
    }
  }
}

let connectorMetaDataValueInput = (~connectorMetaDataFields: CommonConnectorTypes.inputField) => {
  let {\"type", name} = connectorMetaDataFields

  let formName = `metadata.${name}`

  {
    switch (\"type", name) {
    | (Select, "merchant_config_currency") => currencyField(~name=formName)
    | (Text, _) => textInput(~field={connectorMetaDataFields}, ~formName, ~customStyle="rounded-xl")
    | (Select, _) => selectInput(~field={connectorMetaDataFields}, ~formName)
    | (Toggle, _) => toggleInput(~field={connectorMetaDataFields}, ~formName)
    | (MultiSelect, _) => multiSelectInput(~field={connectorMetaDataFields}, ~formName)
    | _ => textInput(~field={connectorMetaDataFields}, ~formName)
    }
  }
}

module ProcessorStatus = {
  @react.component
  let make = (~connectorInfo: ConnectorTypes.connectorPayloadV2) => {
    let form = ReactFinalForm.useForm()
    let updateConnectorStatus = (isSelected: bool) => {
      form.change("disabled", !isSelected->Identity.genericTypeToJson)
      form.submit()->ignore
    }
    <BoolInput.BaseComponent
      isSelected={!connectorInfo.disabled}
      setIsSelected={isSelected => updateConnectorStatus(isSelected)}
      isDisabled=false
      boolCustomClass="rounded-lg"
    />
  }
}
module DisableConnector = {
  @react.component
  let make = (~isConnectorDisabled, ~disableConnector) => {
    let showPopUp = PopUpState.useShowPopUp()

    let showConfirmationPopUp = _ => {
      showPopUp({
        popUpType: (Warning, WithIcon),
        heading: "Confirm Action ? ",
        description: `You are about to ${isConnectorDisabled
            ? "Enable"
            : "Disable"->String.toLowerCase} this connector. This might impact your desired routing configurations. Please confirm to proceed.`->React.string,
        handleConfirm: {
          text: "Confirm",
          onClick: _ => disableConnector()->ignore,
        },
        handleCancel: {text: "Cancel"},
      })
    }

    <Button
      text={isConnectorDisabled ? "Enable Processor" : "Disable Processor"}
      onClick={_ => showConfirmationPopUp()}
    />
  }
}
