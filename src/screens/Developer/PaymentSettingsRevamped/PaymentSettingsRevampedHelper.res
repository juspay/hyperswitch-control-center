open PaymentSettingsRevampedUtils

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
  ~description="To activate this feature, your webhook URL needs to be manually added to the allowlist. Please reach out to our team for assistance.",
)
let domainName = isDisabled =>
  FormRenderer.makeFieldInfo(
    ~label="Domain Name",
    ~name="payment_link_config.domain_name",
    ~placeholder="Enter Domain Name",
    ~customInput=InputFields.textInput(~autoComplete="off", ~isDisabled, ~customStyle="rounded-xl"),
    ~description="This domain name will be used to generate payment links.",
  )

let allowedDomains = isDisabled =>
  FormRenderer.makeFieldInfo(
    ~label="Allowed Domain",
    ~name="payment_link_config.allowed_domains",
    ~placeholder="Enter Allowed Domain",
    ~customInput=InputFields.textInput(~autoComplete="off", ~isDisabled, ~customStyle="rounded-xl"),
    ~description="The allowed domains will be able to embed payment links.",
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

let vault_token_selector_list = [
  "card_number",
  "card_cvc",
  "card_expiry_year",
  "card_expiry_month",
  "network_token",
  "network_token_cryptogram",
  "network_token_expiry_month",
  "network_token_expiry_year",
]

let vaultTokenSelectorDropdownOptions = vault_token_selector_list->Array.map((
  item
): SelectBox.dropdownOption => {
  {
    label: item->LogicUtils.snakeToTitle,
    value: item,
  }
})

let vaultTokenList = {
  open LogicUtils

  FormRenderer.makeFieldInfo(
    ~label="Vault Token ",
    ~name="external_vault_connector_details.vault_token_selector",
    ~customInput=InputFields.multiSelectInput(
      ~showSelectionAsChips=false,
      ~options=vaultTokenSelectorDropdownOptions,
      ~buttonText="Select Field",
      ~customButtonStyle="!rounded-lg",
      ~fixedDropDownDirection=BottomRight,
      ~dropdownClassName="!max-h-15-rem !overflow-auto",
      ~buttonSize=Button.Large,
    ),
    ~parse=(~value, ~name as _) => {
      let parsedValue =
        value
        ->getArrayFromJson([])
        ->Array.map(item => {
          [("token_type", item)]->getJsonFromArrayOfJson
        })

      parsedValue->JSON.Encode.array
    },
    ~format=(~value, ~name as _) => {
      let formattedValue =
        value
        ->getArrayFromJson([])
        ->Array.map(item =>
          item->getDictFromJsonObject->getString("token_type", "")->JSON.Encode.string
        )
      formattedValue->JSON.Encode.array
    },
  )
}

let webhookVersion = FormRenderer.makeFieldInfo(
  ~label="Webhook Version",
  ~name="webhook_details.webhook_version",
  ~placeholder="Enter Webhook Version",
  ~customInput=InputFields.textInput(~autoComplete="off", ~customStyle="rounded-xl"),
  ~isRequired=false,
)

let webhookUsername = FormRenderer.makeFieldInfo(
  ~label="Webhook Username",
  ~name="webhook_details.webhook_username",
  ~placeholder="Enter Webhook Username",
  ~customInput=InputFields.textInput(~autoComplete="off", ~customStyle="rounded-xl"),
  ~isRequired=false,
)

let webhookPassword = FormRenderer.makeFieldInfo(
  ~label="Webhook Password",
  ~name="webhook_details.webhook_password",
  ~placeholder="Enter Webhook Password",
  ~customInput=InputFields.textInput(~autoComplete="off", ~customStyle="rounded-xl"),
  ~isRequired=false,
)

let paymentStatusOptions = [
  "succeeded",
  "failed",
  "cancelled",
  "cancelled_post_capture",
  "processing",
  "partially_captured_and_processing",
  "requires_customer_action",
  "requires_merchant_action",
  "requires_capture",
  "partially_captured",
  "partially_captured_and_capturable",
  "partially_authorized_and_requires_capture",
  "conflicted",
  "expired",
]

let refundStatusOptions = ["failure", "success"]

let payoutStatusOptions = [
  "success",
  "failed",
  "cancelled",
  "initiated",
  "expired",
  "reversed",
]

let makeDropdownOptions = options =>
  options->Array.map((item): SelectBox.dropdownOption => {
    {
      label: item->LogicUtils.snakeToTitle,
      value: item,
    }
  })

let paymentStatusesEnabled = FormRenderer.makeFieldInfo(
  ~label="Payment Statuses",
  ~name="webhook_details.payment_statuses_enabled",
  ~customInput=InputFields.multiSelectInput(
    ~options=paymentStatusOptions->makeDropdownOptions,
    ~buttonText="Select Payment Statuses",
    ~showSelectionAsChips=false,
    ~customButtonStyle="!rounded-lg",
    ~fixedDropDownDirection=BottomRight,
    ~dropdownClassName="!max-h-15-rem !overflow-auto",
  ),
  ~isRequired=false,
)

let refundStatusesEnabled = FormRenderer.makeFieldInfo(
  ~label="Refund Statuses",
  ~name="webhook_details.refund_statuses_enabled",
  ~customInput=InputFields.multiSelectInput(
    ~options=refundStatusOptions->makeDropdownOptions,
    ~buttonText="Select Refund Statuses",
    ~showSelectionAsChips=false,
    ~customButtonStyle="!rounded-lg",
    ~fixedDropDownDirection=BottomRight,
    ~dropdownClassName="!max-h-15-rem !overflow-auto",
  ),
  ~isRequired=false,
)

let payoutStatusesEnabled = FormRenderer.makeFieldInfo(
  ~label="Payout Statuses",
  ~name="webhook_details.payout_statuses_enabled",
  ~customInput=InputFields.multiSelectInput(
    ~options=payoutStatusOptions->makeDropdownOptions,
    ~buttonText="Select Payout Statuses",
    ~showSelectionAsChips=false,
    ~customButtonStyle="!rounded-lg",
    ~dropdownClassName="!max-h-15-rem !overflow-auto",
  ),
  ~isRequired=false,
)

let customExternalVaultEnabled = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~placeholder as _,
  ~form: ReactFinalForm.formApi,
) => {
  let currentValue = switch input.value->JSON.Classify.classify {
  | String(str) =>
    str
    ->vaultStatusFromString
    ->Option.mapOr(false, isVaultEnabled)
  | _ => false
  }

  let handleChange = newValue => {
    let valueToSet = newValue->vaultStatusStringFromBool
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
