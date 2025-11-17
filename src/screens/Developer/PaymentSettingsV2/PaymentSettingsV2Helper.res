let maxAutoRetries = FormRenderer.makeFieldInfo(
  ~label="Max Auto Retries",
  ~name="max_auto_retries_enabled",
  ~placeholder="Enter number of max auto retries",
  ~customInput=InputFields.numericTextInput(~customStyle="border rounded-xl"),
  ~isRequired=true,
)
let webhookUrl = FormRenderer.makeFieldInfo(
  ~label="Webhook URL",
  ~name="webhook_details.webhook_url",
  ~placeholder="Enter Webhook URL",
  ~customInput=InputFields.textInput(~autoComplete="off", ~customStyle="rounded-xl"),
  ~isRequired=false,
  ~description="To activate this feature, your webhook URL needs manual whitelisting. Reach out to our team for assistance",
)
let returnUrl = FormRenderer.makeFieldInfo(
  ~label="Return URL",
  ~name="return_url",
  ~placeholder="Enter Return URL",
  ~customInput=InputFields.textInput(~autoComplete="off", ~customStyle="rounded-xl"),
  ~isRequired=false,
)
let threeDsRequestorUrl = FormRenderer.makeFieldInfo(
  ~label="3DS Requestor URL",
  ~name="authentication_connector_details.three_ds_requestor_url",
  ~placeholder="Enter 3DS Requestor URL",
  ~customInput=InputFields.textInput(~autoComplete="off", ~customStyle="rounded-xl"),
  ~isRequired=false,
)

let threeDsRequestoApprUrl = FormRenderer.makeFieldInfo(
  ~label="3DS Requestor App URL",
  ~name="authentication_connector_details.three_ds_requestor_app_url",
  ~placeholder="Enter 3DS Requestor App URL",
  ~customInput=InputFields.textInput(~autoComplete="off", ~customStyle="rounded-xl"),
  ~isRequired=false,
)
let authenticationConnectors = connectorList =>
  FormRenderer.makeFieldInfo(
    ~label="Authentication Connectors",
    ~name="authentication_connector_details.authentication_connectors",
    ~customInput=InputFields.multiSelectInput(
      ~options=connectorList->SelectBox.makeOptions,
      ~buttonText="Select Field",
      ~showSelectionAsChips=false,
      ~customButtonStyle="!rounded-lg",
      ~fixedDropDownDirection=BottomRight,
      ~dropdownClassName="!max-h-15-rem !overflow-auto",
    ),
    ~isRequired=false,
  )

let vaultConnectors = connectorList => {
  FormRenderer.makeFieldInfo(
    ~label="Vault Connectors",
    ~name="external_vault_connector_details.vault_connector_id",
    ~customInput=InputFields.selectInput(
      ~options=connectorList,
      ~buttonText="Select Field",
      ~customButtonStyle="!rounded-lg",
      ~fixedDropDownDirection=BottomRight,
      ~dropdownClassName="!max-h-15-rem !overflow-auto",
    ),
    ~isRequired=true,
  )
}

let customExternalVaultEnabled = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~placeholder as _,
  ~form: ReactFinalForm.formApi,
) => {
  let currentValue = switch input.value->JSON.Classify.classify {
  | String(str) => str === "enable"
  | _ => false
  }

  let handleChange = newValue => {
    let valueToSet = newValue ? "enable" : "skip"
    input.onChange(valueToSet->Identity.anyTypeToReactEvent)
    if !newValue {
      form.change("external_vault_connector_details", JSON.Encode.null)
    }
  }

  <BoolInput.BaseComponent
    isSelected={currentValue}
    setIsSelected={handleChange}
    isDisabled=false
    boolCustomClass="rounded-lg"
    toggleEnableColor="bg-nd_primary_blue-450"
  />
}
