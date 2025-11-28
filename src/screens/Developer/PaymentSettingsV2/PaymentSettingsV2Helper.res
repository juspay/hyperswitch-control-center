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
