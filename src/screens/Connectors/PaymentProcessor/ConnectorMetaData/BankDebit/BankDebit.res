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
let make = (
  ~setShowWalletConfigurationModal,
  ~update,
  ~paymentMethod,
  ~paymentMethodType,
  ~setInitialValues,
) => {
  open LogicUtils
  open BankDebitUtils
  let connectorsListPMAuth = ConnectorInterface.useConnectorArrayMapper(
    ~interface=ConnectorInterface.connectorInterfaceV1,
    ~retainInList=PMAuthProcessor,
  )
  let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
    ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
  )
  let form = ReactFinalForm.useForm()

  let pmAuthConnectorOptions =
    connectorsListPMAuth->Array.map(item => item.connector_name)->removeDuplicate->dropdownOptions

  let getPMConnectorId = (connector: ConnectorTypes.connectorTypes) => {
    let connectorData = connectorsListPMAuth->Array.find(item => {
      item.connector_name == connector->ConnectorUtils.getConnectorNameString
    })
    switch connectorData {
    | Some(connectorData) => connectorData.merchant_connector_id
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
    update()
    onCancelClick()
    setShowWalletConfigurationModal(_ => false)
  }

  let onSubmit = () => {
    setShowWalletConfigurationModal(_ => false)
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
      ~isRequired=true,
      (),
    )
  }

  <div className="p-4">
    <FormRenderer.FieldRenderer
      field={valueInput({
        name1: `pm_auth_config.enabled_payment_methods`,
        name2: ``,
        label: `Select the open banking verification provider to verify the bank accounts`,
        options: pmAuthConnectorOptions,
      })}
      labelTextStyleClass="pt-2 pb-2 text-fs-13 text-jp-gray-900 dark:text-jp-gray-text_darktheme dark:text-opacity-50 ml-1 font-semibold"
    />
    <div className={`flex gap-2 justify-end mt-4`}>
      <Button text="Cancel" buttonType={Secondary} onClick={_ => closeModal()} />
      <Button
        onClick={_ => {
          onSubmit()->ignore
        }}
        text="Proceed"
        buttonType={Primary}
        buttonState={validateSelectedPMAuth(formState.values, paymentMethodType)}
      />
    </div>
    <FormValuesSpy />
  </div>
}
