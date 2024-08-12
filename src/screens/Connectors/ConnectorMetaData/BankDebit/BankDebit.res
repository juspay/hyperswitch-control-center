module PmtConfigInp = {
  @react.component
  let make = (
    ~options: array<SelectBox.dropdownOption>,
    ~fieldsArray: array<ReactFinalForm.fieldRenderProps>,
    ~paymentMethod: string,
    ~paymentMethodType: string,
    ~getConnectorId: string => string,
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
            mca_id: getConnectorId(connector),
          }
        }
        if value->LogicUtils.isNonEmptyString {
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
      buttonText="Select Value"
      input
      options
      hideMultiSelectButtons=false
      showSelectionAsChips=true
      customButtonStyle="w-full"
      fullLength=true
      dropdownClassName={`${options->PaymentMethodConfigUtils.dropdownClassName}`}
    />
  }
}

@react.component
let make = (
  ~onCloseClickCustomFun,
  ~setShowWalletConfigurationModal,
  ~update,
  ~paymentMethod,
  ~paymentMethodType,
  ~setInitialValues,
) => {
  open LogicUtils
  open BankDebitUtils
  let connectorList = HyperswitchAtom.connectorListAtom->Recoil.useRecoilValueFromAtom
  let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
    ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
  )
  let form = ReactFinalForm.useForm()

  let connectorsListPMAuth =
    connectorList->ConnectorUtils.getProcessorsListFromJson(
      ~removeFromList=ConnectorTypes.PMAuthenticationProcessor,
    )
  let pmAuthConnectors =
    connectorsListPMAuth->Array.map(item => item.connector_name)->removeDuplicate

  let options = pmAuthConnectors->dropdownOptions

  let getConnectorId = connector => {
    let connectorData = connectorsListPMAuth->Array.find(item => {
      item.connector_name == connector
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
    onCloseClickCustomFun()
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
    <PmtConfigInp options fieldsArray paymentMethod paymentMethodType getConnectorId />
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

  <>
    <div className="p-4 border border-red-300">
      <FormRenderer.FieldRenderer
        field={valueInput({
          name1: `pm_auth_config.enabled_payment_methods`,
          name2: ``,
          label: `Select the open banking verification provider to verify the bank accounts`,
          options,
        })}
        labelTextStyleClass="pt-2 pb-2 text-fs-13 text-jp-gray-900 dark:text-jp-gray-text_darktheme dark:text-opacity-50 ml-1 font-semibold"
      />
      <div className={`flex gap-2 justify-end mt-4`}>
        <Button
          text="Cancel"
          buttonType={Secondary}
          onClick={_ev => {
            closeModal()->ignore
          }}
        />
        <Button
          onClick={_ev => {
            onSubmit()->ignore
          }}
          text="Proceed"
          buttonType={Primary}
        />
      </div>
      <FormValuesSpy />
    </div>
  </>
}
