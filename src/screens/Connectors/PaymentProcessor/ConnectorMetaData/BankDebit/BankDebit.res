module PMAuthProcessorInput = {
  @react.component
  let make = (
    ~options: array<SelectBox.dropdownOption>,
    ~fieldsArray: array<ReactFinalForm.fieldRenderProps>,
    ~paymentMethod: string,
    ~paymentMethodType: string,
    ~getPMConnectorId: ConnectorTypes.connectorTypes => string,
  ) => {
    open LogicUtils
    let (currentSelection, setCurrentSelection) = React.useState(_ => "")

    let enabledList = (
      fieldsArray->Array.get(0)->Option.getOr(ReactFinalForm.fakeFieldRenderProps)
    ).input

    let input: ReactFinalForm.fieldRenderPropsInput = {
      name: "string",
      onBlur: _ => (),
      onChange: ev => {
        let value = ev->Identity.formReactEventToString
        let getPaymentMethodsObject = connector => {
          open BankDebitTypes
          {
            payment_method: paymentMethod,
            payment_method_type: paymentMethodType,
            connector_name: connector,
            mca_id: getPMConnectorId(
              connector->ConnectorUtils.getConnectorNameTypeFromString(
                ~connectorType=PMAuthenticationProcessor,
              ),
            ),
          }
        }
        if value->isNonEmptyString {
          let paymentMethodsObject = value->getPaymentMethodsObject
          setCurrentSelection(_ => value)

          let existingPaymentMethodsArray =
            enabledList.value->getArrayDataFromJson(BankDebitUtils.itemToObjMapper)

          let newPaymentMethodsArray =
            existingPaymentMethodsArray->Array.filter(item =>
              item.payment_method_type !== paymentMethodType
            )

          newPaymentMethodsArray->Array.push(paymentMethodsObject)
          enabledList.onChange(newPaymentMethodsArray->Identity.anyTypeToReactEvent)
        }
      },
      onFocus: _ => (),
      value: currentSelection->JSON.Encode.string,
      checked: true,
    }
    <SelectBox.BaseDropdown
      allowMultiSelect=false
      buttonText="Select PM Authentication Processor"
      input
      options
      hideMultiSelectButtons=false
      showSelectionAsChips=true
      customButtonStyle="w-full"
      fullLength=true
      dropdownCustomWidth="w-full"
      dropdownClassName={`${options->PaymentMethodConfigUtils.dropdownClassName}`}
    />
  }
}

@react.component
let make = (~update, ~paymentMethod, ~paymentMethodType, ~setInitialValues, ~closeAccordionFn) => {
  open LogicUtils
  open BankDebitUtils
  let connectorsListPMAuth = ConnectorListInterface.useFilteredConnectorList(
    ~retainInList=PMAuthProcessor,
  )
  let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
    ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
  )

  let pmAuthConnectorOptions =
    connectorsListPMAuth->Array.map(item => item.connector_name)->removeDuplicate->dropdownOptions

  let getPMConnectorId = (connector: ConnectorTypes.connectorTypes) => {
    let connectorData = connectorsListPMAuth->Array.find(item => {
      item.connector_name == connector->ConnectorUtils.getConnectorNameString
    })
    switch connectorData {
    | Some(connectorData) => connectorData.id
    | None => ""
    }
  }

  let onSubmit = () => {
    closeAccordionFn()
    setInitialValues(_ => formState.values)
    update()
    Nullable.null->Promise.resolve
  }

  let renderValueInp = (options: array<SelectBox.dropdownOption>) => (
    fieldsArray: array<ReactFinalForm.fieldRenderProps>,
  ) => {
    <PMAuthProcessorInput options fieldsArray paymentMethod paymentMethodType getPMConnectorId />
  }

  let valueInput = (inputArg: PaymentMethodConfigTypes.valueInput) => {
    open FormRenderer
    makeMultiInputFieldInfoOld(
      ~label=`${inputArg.label}`,
      ~comboCustomInput=renderValueInp(inputArg.options),
      ~inputFields=[makeInputFieldInfo(~name=`${inputArg.name1}`), makeInputFieldInfo(~name=``)],
      (),
    )
  }

  <div className="flex flex-col gap-6 p-6">
    <FormRenderer.FieldRenderer
      field={valueInput({
        name1: `pm_auth_config.enabled_payment_methods`,
        name2: ``,
        label: `Select PM Authenticator (optional)`,
        options: pmAuthConnectorOptions,
      })}
      labelTextStyleClass="pt-2 pb-2 text-fs-13 text-jp-gray-900 dark:text-jp-gray-text_darktheme dark:text-opacity-50 ml-1 font-semibold"
    />
    <Button
      onClick={_ => {
        onSubmit()->ignore
      }}
      text="Proceed"
      buttonType={Primary}
      customButtonStyle="w-full"
      buttonSize={Small}
    />
  </div>
}
