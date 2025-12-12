let connectorsWithIntegrationSteps: array<ConnectorTypes.connectorTypes> = [
  Processors(ADYEN),
  Processors(CHECKOUT),
  Processors(STRIPE),
  Processors(PAYPAL),
]

module MultiConfigInp = {
  @react.component
  let make = (~label, ~fieldsArray: array<ReactFinalForm.fieldRenderProps>) => {
    let enabledList = (fieldsArray[0]->Option.getOr(ReactFinalForm.fakeFieldRenderProps)).input
    let valueField = (fieldsArray[1]->Option.getOr(ReactFinalForm.fakeFieldRenderProps)).input

    let input: ReactFinalForm.fieldRenderPropsInput = {
      name: "string",
      onBlur: _ => (),
      onChange: ev => {
        let value = ev->Identity.formReactEventToArrayOfString
        valueField.onChange(value->Identity.anyTypeToReactEvent)
        enabledList.onChange(value->Identity.anyTypeToReactEvent)
      },
      onFocus: _ => (),
      value: enabledList.value,
      checked: true,
    }
    <TextInput input placeholder={`Enter ${label->LogicUtils.snakeToTitle}`} />
  }
}

let renderValueInp = (~label) => (fieldsArray: array<ReactFinalForm.fieldRenderProps>) => {
  <MultiConfigInp fieldsArray label />
}

let multiValueInput = (~label, ~fieldName1, ~fieldName2) => {
  open FormRenderer
  makeMultiInputFieldInfoOld(
    ~label,
    ~comboCustomInput=renderValueInp(~label),
    ~inputFields=[
      makeInputFieldInfo(~name=`${fieldName1}`),
      makeInputFieldInfo(~name=`${fieldName2}`),
    ],
    (),
  )
}

module ErrorValidation = {
  @react.component
  let make = (~fieldName, ~validate) => {
    open LogicUtils
    let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
      ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
    )
    let appPrefix = LogicUtils.useUrlPrefix()
    let imageStyle = "w-4 h-4 my-auto border-gray-100"
    let errorDict = formState.values->validate->getDictFromJsonObject
    let {touched} = ReactFinalForm.useField(fieldName).meta
    let err = touched ? errorDict->Dict.get(fieldName) : None
    <RenderIf condition={err->Option.isSome}>
      <div
        className={`flex flex-row items-center text-orange-950 dark:text-orange-400 pt-2 text-base font-medium text-start ml-1`}>
        <div className="flex mr-2">
          <img className=imageStyle src={`${appPrefix}/icons/warning.svg`} alt="warning" />
        </div>
        {React.string(err->Option.getOr(""->JSON.Encode.string)->getStringFromJson(""))}
      </div>
    </RenderIf>
  }
}

module RenderConnectorInputFields = {
  open ConnectorTypes
  @react.component
  let make = (
    ~connector: connectorTypes,
    ~selectedConnector,
    ~details,
    ~name,
    ~keysToIgnore: array<string>=[],
    ~checkRequiredFields=?,
    ~getPlaceholder=?,
    ~isLabelNested=true,
    ~disabled=false,
    ~description="",
    ~labelTextStyleClass="",
    ~labelClass="font-semibold !text-hyperswitch_black",
  ) => {
    let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
    // open ConnectorUtils
    open LogicUtils
    let keys = details->Dict.keysToArray->Array.filter(ele => !Array.includes(keysToIgnore, ele))

    keys
    ->Array.mapWithIndex((field, i) => {
      let label = details->getString(field, "")

      let formName = isLabelNested ? `${name}.${field}` : name
      <RenderIf condition={label->isNonEmptyString} key={i->Int.toString}>
        <AddDataAttributes attributes=[("data-testid", label->titleToSnake->String.toLowerCase)]>
          <div key={label}>
            <FormRenderer.FieldRenderer
              labelClass
              labelTextStyleClass
              field={switch (connector, field) {
              | (Processors(PAYPAL), "key1") =>
                multiValueInput(
                  ~label,
                  ~fieldName1="connector_account_details.key1",
                  ~fieldName2="metadata.paypal_sdk.client_id",
                )
              | _ =>
                FormRenderer.makeFieldInfo(
                  ~label,
                  ~name=formName,
                  ~description,
                  ~toolTipPosition=Right,
                  ~customInput=InputFields.textInput(
                    ~isDisabled=disabled,
                    ~customStyle="border rounded-xl",
                  ),
                  ~placeholder=switch getPlaceholder {
                  | Some(fun) => fun(label)
                  | None => `Enter ${label->LogicUtils.snakeToTitle}`
                  },
                  ~isRequired=switch checkRequiredFields {
                  | Some(fun) => fun(connector, field)
                  | None => true
                  },
                )
              }}
            />
            <ErrorValidation
              fieldName=formName
              validate={ConnectorAuthKeyUtils.validate(
                ~selectedConnector,
                ~dict=details,
                ~fieldName=formName,
                ~isLiveMode={featureFlagDetails.isLiveMode},
              )}
            />
          </div>
        </AddDataAttributes>
      </RenderIf>
    })
    ->React.array
  }
}

module CashToCodeSelectBox = {
  open ConnectorTypes
  @react.component
  let make = (
    ~opts: array<string>,
    ~dict,
    ~selectedCashToCodeMthd: cashToCodeMthd,
    ~connector,
    ~selectedConnector,
  ) => {
    open LogicUtils
    open Typography
    let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
      ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
    )

    let isSelected = (country): bool => {
      let formValues =
        formState.values
        ->getDictFromJsonObject
        ->getDictfromDict("connector_account_details")
        ->getDictfromDict("auth_key_map")
        ->getDictfromDict(country)

      let wasmValues =
        dict
        ->getDictfromDict(country)
        ->getDictfromDict((selectedCashToCodeMthd: cashToCodeMthd :> string)->String.toLowerCase)
        ->Dict.keysToArray

      wasmValues
      ->Array.find(ele => formValues->getString(ele, "")->String.length <= 0)
      ->Option.isNone
    }

    let accordionItems = opts->Array.map(country => {
      let countryTitle = country->snakeToTitle
      let isCountrySelected = country->isSelected
      let accordionItem: Accordion.accordion = {
        title: "",
        renderContentOnTop: Some(
          () =>
            <div className="flex items-center gap-3 w-full">
              <CheckBoxIcon isSelected=isCountrySelected stopPropagationNeeded=true />
              <span
                className={`${body.sm.semibold} text-nd-gray-600 dark:text-jp-gray-text_darktheme`}>
                {countryTitle->React.string}
              </span>
            </div>,
        ),
        renderContent: (~currentAccordianState as _, ~closeAccordionFn as _) =>
          <div className="p-4 pt-2">
            <RenderConnectorInputFields
              details={dict
              ->getDictfromDict(country)
              ->getDictfromDict(
                (selectedCashToCodeMthd: cashToCodeMthd :> string)->String.toLowerCase,
              )}
              name={`connector_account_details.auth_key_map.${country}`}
              connector
              selectedConnector
            />
          </div>,
      }
      accordionItem
    })

    <div className="w-full">
      <Accordion
        accordion=accordionItems
        accordianTopContainerCss="mt-4 rounded-lg"
        accordianBottomContainerCss="p-4"
        contentExpandCss="px-0 py-0"
        titleStyle={`${body.sm.semibold} text-nd-gray-600 dark:text-jp-gray-text_darktheme hover:text-jp-gray-800 dark:hover:text-opacity-100`}
        accordionHeaderTextClass="flex-1"
        gapClass="space-y-3"
        arrowPosition=Right
      />
    </div>
  }
}

module CashToCodeMethods = {
  open ConnectorTypes
  @react.component
  let make = (~connectorAccountFields, ~selectedConnector, ~connector) => {
    open ConnectorUtils
    let dict = connectorAccountFields->getAuthKeyMapFromConnectorAccountFields
    let (selectedCashToCodeMthd, setCashToCodeMthd) = React.useState(_ => #Classic)
    let tabs = [#Classic, #Evoucher]

    let tabList: array<Tabs.tab> = tabs->Array.map(tab => {
      let tab: Tabs.tab = {
        title: (tab: cashToCodeMthd :> string),
        renderContent: () =>
          <CashToCodeSelectBox
            opts={dict->Dict.keysToArray}
            dict={dict}
            selectedCashToCodeMthd
            connector
            selectedConnector
          />,
      }
      tab
    })
    <Tabs
      tabs=tabList
      disableIndicationArrow=true
      showBorder=false
      includeMargin=false
      lightThemeColor="black"
      defaultClasses="font-ibm-plex w-max flex flex-auto flex-row items-center justify-center px-6 font-semibold text-body"
      onTitleClick={tabIndex => {
        setCashToCodeMthd(_ => tabs->LogicUtils.getValueFromArray(tabIndex, #Classic))
      }}
    />
  }
}

module ConnectorConfigurationFields = {
  open ConnectorTypes
  @react.component
  let make = (
    ~connectorAccountFields,
    ~connector: connectorTypes,
    ~selectedConnector: integrationFields,
    ~isUpdateFlow=false,
    ~showVertically=true,
  ) => {
    <div
      className={`grid ${showVertically
          ? "grid-cols-1"
          : "grid-cols-2"} max-w-3xl gap-x-6 gap-y-3 `}>
      {switch connector {
      | Processors(CASHTOCODE) =>
        <CashToCodeMethods connectorAccountFields connector selectedConnector />

      | _ =>
        <RenderConnectorInputFields
          details={connectorAccountFields}
          name={"connector_account_details"}
          getPlaceholder={ConnectorUtils.getPlaceHolder}
          connector
          selectedConnector
        />
      }}
    </div>
  }
}
