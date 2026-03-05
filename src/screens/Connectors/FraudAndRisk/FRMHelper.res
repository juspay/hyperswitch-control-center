let frmIntegFormFields = (~selectedFRMInfo: ConnectorTypes.integrationFields) => {
  open FRMUtils
  selectedFRMInfo.validate
  ->Option.getOr([])
  ->Array.mapWithIndex((field, index) => {
    let parse = field.encodeToBase64->Option.getOr(false) ? base64Parse : leadingSpaceStrParser
    let format = field.encodeToBase64->Option.getOr(false) ? Some(base64Format) : None
    <div key={index->Int.toString}>
      <FormRenderer.FieldRenderer
        labelClass="font-semibold !text-black"
        field={FormRenderer.makeFieldInfo(
          ~label=field.label->Option.getOr(""),
          ~name={field.name},
          ~placeholder=field.placeholder->Option.getOr(""),
          ~description=field.description->Option.getOr(""),
          ~isRequired=true,
          ~parse,
          ~format?,
        )}
      />
      <ConnectorAccountDetailsHelper.ErrorValidation
        fieldName={field.name} validate={values => FRMUtils.validate(~values, ~selectedFRMInfo)}
      />
    </div>
  })
  ->React.array
}

let customAuthTypeInput = (
  ~input as _: ReactFinalForm.fieldRenderPropsInput,
  ~placeholder as _,
  ~paymentMethodName,
  ~frmConfigInfo: ConnectorTypes.frm_config,
  ~frmConfigs,
  ~setConfigJson,
) => {
  let isEnabled =
    frmConfigInfo.payment_methods->Array.some(pm => pm.payment_method === paymentMethodName)
  let handleToggle = newValue => {
    if newValue {
      let newPM: ConnectorTypes.frm_payment_method = {
        payment_method: paymentMethodName,
        flow: FRMInfo.getFlowTypeNameString(PreAuth),
      }
      frmConfigInfo.payment_methods->Array.push(newPM)->ignore
    } else {
      frmConfigInfo.payment_methods =
        frmConfigInfo.payment_methods->Array.filter(pm => pm.payment_method !== paymentMethodName)
    }

    setConfigJson(frmConfigs->Identity.anyTypeToReactEvent)
  }

  <BoolInput.BaseComponent
    isSelected={isEnabled}
    setIsSelected={handleToggle}
    isDisabled=false
    boolCustomClass="rounded-xl"
    customToggleHeight="20px"
    customToggleWidth="36px"
    customInnerCircleHeight="10px"
    transformValue="20px"
    toggleEnableColor="bg-primary"
    toggleBorder="bg-primary"
  />
}
