let metaDataInputKeysToIgnore = ["google_pay", "apple_pay", "zen_apple_pay"]

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
  (),
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
      ~options=options->Js.Array2.map(getCurrencyOption),
      ~buttonText="Select Currency",
      (),
    ),
    (),
  )

let inputField = (
  ~name,
  ~field,
  ~label,
  ~connector,
  ~getPlaceholder,
  ~checkRequiredFields,
  ~disabled,
  (),
) =>
  FormRenderer.makeFieldInfo(
    ~label,
    ~name,
    ~customInput=InputFields.textInput(~isDisabled=disabled, ()),
    ~placeholder=switch getPlaceholder {
    | Some(fun) => fun(connector, field, label)
    | None => `Enter ${label->LogicUtils.snakeToTitle}`
    },
    ~isRequired=switch checkRequiredFields {
    | Some(fun) => fun(connector, field)
    | None => true
    },
    (),
  )

module ErrorValidation = {
  @react.component
  let make = (~fieldName, ~validate) => {
    open LogicUtils
    let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
      ReactFinalForm.useFormSubscription(["values"])->Js.Nullable.return,
    )
    let appPrefix = LogicUtils.useUrlPrefix()
    let imageStyle = "w-4 h-4 my-auto border-gray-100"
    let errorDict = formState.values->validate->getDictFromJsonObject
    let {touched} = ReactFinalForm.useField(fieldName).meta
    let err = touched ? errorDict->Js.Dict.get(fieldName) : None
    <UIUtils.RenderIf condition={err->Belt.Option.isSome}>
      <div
        className={`flex flex-row items-center text-orange-950 dark:text-orange-400 pt-2 text-base font-medium text-start ml-1`}>
        <div className="flex mr-2">
          <img className=imageStyle src={`${appPrefix}/icons/warning.svg`} alt="warning" />
        </div>
        {React.string(err->Belt.Option.getWithDefault(""->Js.Json.string)->getStringFromJson(""))}
      </div>
    </UIUtils.RenderIf>
  }
}

module RenderConnectorInputFields = {
  open ConnectorTypes
  @react.component
  let make = (
    ~connector: connectorName,
    ~selectedConnector,
    ~details,
    ~name,
    ~keysToIgnore: array<string>=[],
    ~checkRequiredFields=?,
    ~getPlaceholder=?,
    ~isLabelNested=true,
    ~disabled=false,
  ) => {
    let featureFlagDetails =
      HyperswitchAtom.featureFlagAtom
      ->Recoil.useRecoilValueFromAtom
      ->LogicUtils.safeParse
      ->FeatureFlagUtils.featureFlagType
    open ConnectorUtils
    open LogicUtils
    let keys =
      details->Js.Dict.keys->Js.Array2.filter(ele => !Js.Array2.includes(keysToIgnore, ele))
    keys
    ->Array.mapWithIndex((field, index) => {
      let label = details->getString(field, "")
      let formName = isLabelNested ? `${name}.${field}` : name
      <UIUtils.RenderIf condition={label->Js.String2.length > 0}>
        <div key={index->string_of_int}>
          <FormRenderer.FieldRenderer
            labelClass="font-semibold !text-hyperswitch_black"
            field={switch (connector, field) {
            | (BRAINTREE, "merchant_config_currency") => currencyField(~name=formName, ())
            | _ =>
              inputField(
                ~name=formName,
                ~field,
                ~label,
                ~connector,
                ~checkRequiredFields,
                ~getPlaceholder,
                ~disabled,
                (),
              )
            }}
          />
          <ErrorValidation
            fieldName=formName
            validate={validate(
              ~selectedConnector,
              ~dict=details,
              ~fieldName=formName,
              ~isLiveMode={featureFlagDetails.testLiveMode},
            )}
          />
        </div>
      </UIUtils.RenderIf>
    })
    ->React.array
  }
}

module CurrencyAuthKey = {
  @react.component
  let make = (~dict, ~connector, ~selectedConnector: ConnectorTypes.integrationFields) => {
    open LogicUtils
    dict
    ->Js.Dict.keys
    ->Array.mapWithIndex((country, index) => {
      <Accordion
        key={index->string_of_int}
        initialExpandedArray={index == 0 ? [0] : []}
        accordion={[
          {
            title: country->snakeToTitle,
            renderContent: () => {
              <div className="grid gap-5">
                <RenderConnectorInputFields
                  details={dict->getDictfromDict(country)}
                  name={`connector_account_details.auth_key_map.${country}`}
                  connector
                  selectedConnector
                />
              </div>
            },
            renderContentOnTop: None,
          },
        ]}
        accordianTopContainerCss="border"
        accordianBottomContainerCss="p-5"
        contentExpandCss="px-10 pb-6 pt-3 !border-t-0"
        titleStyle="font-semibold text-bold text-md"
      />
    })
    ->React.array
  }
}

module ConnectorConfigurationFields = {
  open ConnectorTypes
  @react.component
  let make = (
    ~connectorAccountFields,
    ~connector: connectorName,
    ~selectedConnector: integrationFields,
    ~connectorMetaDataFields,
    ~connectorWebHookDetails,
    ~bodyType: string,
    ~isUpdateFlow=false,
    ~connectorLabelDetailField,
  ) => {
    open ConnectorUtils
    <div className="flex flex-col">
      {if bodyType->mapAuthType == #CurrencyAuthKey {
        let dict = connectorAccountFields->getAuthKeyMapFromConnectorAccountFields
        <CurrencyAuthKey dict connector selectedConnector />
      } else {
        <RenderConnectorInputFields
          details={connectorAccountFields}
          name={"connector_account_details"}
          getPlaceholder={getPlaceHolder}
          connector
          selectedConnector
        />
      }}
      <RenderConnectorInputFields
        details={connectorLabelDetailField}
        name={"connector_label"}
        keysToIgnore=metaDataInputKeysToIgnore
        checkRequiredFields={getMetaDataRequiredFields}
        connector
        selectedConnector
        isLabelNested=false
        disabled={isUpdateFlow ? true : false}
      />
      <RenderConnectorInputFields
        details={connectorMetaDataFields}
        name={"metadata"}
        keysToIgnore=metaDataInputKeysToIgnore
        checkRequiredFields={getMetaDataRequiredFields}
        connector
        selectedConnector
      />
      <RenderConnectorInputFields
        details={connectorWebHookDetails}
        name={"connector_webhook_details"}
        checkRequiredFields={getWebHookRequiredFields}
        connector
        selectedConnector
      />
    </div>
  }
}
