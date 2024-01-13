let listChoices: array<PayPalFlowTypes.choiceDetailsType> = [
  {
    displayText: "No, I don't",
    choiceDescription: "Don't worry, easily create & activate your PayPal account in minutes.",
    variantType: Automatic,
  },
  {
    displayText: "Yes, I have",
    choiceDescription: "Simply login to your PayPal account and leave the rest to us. Or enter credentials manually.",
    variantType: Manual,
  },
]

let getPageDetailsForAutomatic: PayPalFlowTypes.setupAccountStatus => PayPalFlowTypes.errorPageInfoType = setupAccountStatus => {
  switch setupAccountStatus {
  | Payments_not_receivable => {
      headerText: "You currently cannot receive payments due to restriction on your PayPal account",
      subText: "An email has been sent to you explaining the issue. Please reach out to PayPal Customer Support for more information.",
      refreshStatusText: "Issue Resolved?",
    }
  | Ppcp_custom_denied => {
      headerText: "Your application has been denied by PayPal",
      subText: "PayPal denied your application to use Advanced Credit and Debit Card Payments.",
      refreshStatusText: "Try again?",
    }
  | More_permissions_needed => {
      headerText: "PayPal requires you to grant all permissions",
      subText: "You need to grant all the permissions to create and receive payments. Please click on the Signup to PayPal button and grant the permissions.",
      buttonText: "Complete Signing up",
      refreshStatusText: "Already granted all permissions?",
    }

  | Email_not_verified => {
      headerText: "Your email is yet to be confirmed!",
      subText: "Please confirm your email address on https://www.paypal.com/businessprofile/settings in order to receive payments.",
      refreshStatusText: "Email already confirmed?",
    }
  | _ => {
      headerText: "",
      subText: "",
    }
  }
}

let stringToVariantMapper = strValue => {
  open PayPalFlowTypes
  switch strValue {
  | "account_not_found" => Account_not_found
  | "payments_not_receivables" => Payments_not_receivable
  | "ppcp_custom_denied" => Ppcp_custom_denied
  | "more_permissions_needed" => More_permissions_needed
  | "email_not_verified" => Email_not_verified
  | "connector_integrated" => Connector_integrated
  | _ => Account_not_found
  }
}

let handleConnectorIntegrated = (
  ~dictValue,
  ~setInitialValues,
  ~connector,
  ~handleStateToNextPage,
) => {
  open LogicUtils

  let values = dictValue->getJsonObjectFromDict("connector_integrated")
  let bodyTypeValue =
    dictValue
    ->getDictfromDict("connector_integrated")
    ->getDictfromDict("connector_account_details")
    ->getString("auth_type", "")
  let body = ConnectorUtils.generateInitialValuesDict(
    ~values,
    ~connector,
    ~bodyType=bodyTypeValue,
    ~isPayoutFlow=false,
    (),
  )
  setInitialValues(_ => body)
  handleStateToNextPage()->ignore
}

let handleObjectResponse = (
  ~dict,
  ~setSetupAccountStatus,
  ~setInitialValues,
  ~connector,
  ~handleStateToNextPage,
) => {
  let dictkey = dict->Dict.keysToArray->LogicUtils.getValueFromArray(0, "")

  switch dictkey->stringToVariantMapper {
  | Ppcp_custom_denied => setSetupAccountStatus(._ => dictkey->stringToVariantMapper)
  | Connector_integrated =>
    handleConnectorIntegrated(
      ~dictValue=dict,
      ~setInitialValues,
      ~connector,
      ~handleStateToNextPage,
    )
  | _ => setSetupAccountStatus(._ => dictkey->stringToVariantMapper)
  }
}

let getBodyType = (isUpdateFlow, configuartionType, setupAccountStatus) => {
  open PayPalFlowTypes
  switch (isUpdateFlow, setupAccountStatus) {
  | (false, _) | (true, Account_not_found) => "TemporaryAuth"
  | (true, _) =>
    switch configuartionType {
    | Manual => "BodyKey"
    | Automatic | NotSelected => "SignatureKey"
    }
  }
}

let generateConnectorPayloadPayPal = (
  ~profileId,
  ~connectorId,
  ~connector,
  ~isUpdateFlow,
  ~configuartionType,
  ~setupAccountStatus,
  ~connectorLabel,
) => {
  open ConnectorUtils
  let initialValues =
    [
      ("profile_id", profileId->Js.Json.string),
      ("connector_name", connector->String.toLowerCase->Js.Json.string),
      ("connector_type", "payment_processor"->Js.Json.string),
      ("disabled", true->Js.Json.boolean),
      ("test_mode", true->Js.Json.boolean),
      ("status", "inactive"->Js.Json.string),
      ("connector_label", connectorLabel->Js.Json.string),
    ]->LogicUtils.getJsonFromArrayOfJson

  generateInitialValuesDict(
    ~values={initialValues},
    ~connector,
    ~bodyType=getBodyType(isUpdateFlow, configuartionType, setupAccountStatus),
    ~isPayoutFlow=false,
    (),
  )->ignoreFields(connectorId, connectorIgnoredField)
}
