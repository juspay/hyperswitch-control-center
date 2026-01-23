module PMAuthProcessorInput = {
  @react.component
  let make = (
    ~options: array<SelectBox.dropdownOption>,
    ~fieldsArray: array<ReactFinalForm.fieldRenderProps>,
    ~paymentMethod: string,
    ~paymentMethodType: string,
    ~getPMConnectorId: ConnectorTypes.connectorTypes => string,
    ~isMethodEnabled: bool,
  ) => {
    open LogicUtils
    open BankDebitUtils
    let enabledList = (
      fieldsArray->Array.get(0)->Option.getOr(ReactFinalForm.fakeFieldRenderProps)
    ).input

    let currentSelection = {
      let currentValues = enabledList.value->getArrayDataFromJson(itemToObjMapper)
      currentValues
      ->Array.find(item => item.payment_method_type === paymentMethodType)
      ->Option.mapOr("", item => item.connector_name)
    }

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

        let existingPaymentMethodsArray = enabledList.value->getArrayDataFromJson(itemToObjMapper)

        if value->isNonEmptyString {
          let paymentMethodsObject = value->getPaymentMethodsObject

          let filteredArray =
            existingPaymentMethodsArray->Array.filter(item =>
              item.payment_method_type !== paymentMethodType
            )

          let newPaymentMethodsArray = filteredArray->Array.concat([paymentMethodsObject])
          enabledList.onChange(newPaymentMethodsArray->Identity.anyTypeToReactEvent)
        } else {
          let newPaymentMethodsArray =
            existingPaymentMethodsArray->Array.filter(item =>
              item.payment_method_type !== paymentMethodType
            )

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
      disableSelect={!isMethodEnabled}
    />
  }
}

@react.component
let make = (
  ~paymentMethod,
  ~paymentMethodType,
  ~setInitialValues,
  ~closeAccordionFn,
  ~paymentMethodsEnabled,
) => {
  open LogicUtils
  open BankDebitUtils
  open Typography

  let connectorsListPMAuth = ConnectorListInterface.useFilteredConnectorList(
    ~retainInList=PMAuthProcessor,
  )
  let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
    ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
  )
  let form = ReactFinalForm.useForm()

  let isMethodEnabled = {
    let paymentObj = paymentMethodsEnabled->ConnectorUtils.getSelectedPaymentObj(paymentMethod)
    let stateProviders =
      paymentObj.provider->Option.getOr(
        []->JSON.Encode.array->ConnectorUtils.getPaymentMethodMapper,
      )
    stateProviders->Array.some(provider => provider.payment_method_type === paymentMethodType)
  }

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

  let onCancelClick = () => {
    let existingPaymentMethodValues =
      formState.values
      ->getDictFromJsonObject
      ->getDictfromDict("pm_auth_config")
      ->getArrayFromDict("enabled_payment_methods", [])
      ->JSON.Encode.array
      ->getArrayDataFromJson(itemToObjMapper)

    let newPaymentMethodValues =
      existingPaymentMethodValues->Array.filter(item =>
        item.payment_method_type !== paymentMethodType
      )

    form.change(
      "pm_auth_config.enabled_payment_methods",
      newPaymentMethodValues->Identity.genericTypeToJson,
    )
  }

  let closeModal = () => {
    onCancelClick()
    closeAccordionFn()
  }

  let onSubmit = () => {
    closeAccordionFn()
    setInitialValues(_ => formState.values)
    Nullable.null->Promise.resolve
  }

  let renderValueInp = (options: array<SelectBox.dropdownOption>) => (
    fieldsArray: array<ReactFinalForm.fieldRenderProps>,
  ) => {
    <PMAuthProcessorInput
      options fieldsArray paymentMethod paymentMethodType getPMConnectorId isMethodEnabled
    />
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

  <div className="flex flex-col gap-2 p-6">
    <FormRenderer.FieldRenderer
      field={valueInput({
        name1: `pm_auth_config.enabled_payment_methods`,
        name2: ``,
        label: `Select PM Authenticator (optional)`,
        options: pmAuthConnectorOptions,
      })}
      labelTextStyleClass="pt-2 pb-2 text-fs-13 text-jp-gray-900 dark:text-jp-gray-text_darktheme dark:text-opacity-50 ml-1 font-semibold"
    />
    <div className={`${body.sm.regular} text-nd_gray-700 opacity-50 ml-1`}>
      {"(Enable method to choose an authenticator)"->React.string}
    </div>
    <div className={`flex gap-2 justify-end mt-4`}>
      <Button
        text="Cancel" buttonType={Secondary} onClick={_ => closeModal()} customButtonStyle="w-full"
      />
      <Button
        onClick={_ => {
          onSubmit()->ignore
        }}
        text="Proceed"
        buttonType={Primary}
        buttonState={isMethodEnabled ? Button.Normal : Button.Disabled}
        customButtonStyle="w-full"
      />
    </div>
  </div>
}
