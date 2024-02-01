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
  | Account_not_found => {
      headerText: "No account found for this email",
      subText: "No account found for this email.",
    }
  | Payments_not_receivable => {
      headerText: "You currently cannot receive payments due to restriction on your PayPal account",
      subText: "An email has been sent to you explaining the issue. Please reach out to PayPal Customer Support for more information.",
    }
  | Ppcp_custom_denied => {
      headerText: "Your application has been denied by PayPal",
      subText: "PayPal denied your application to use Advanced Credit and Debit Card Payments.",
    }
  | More_permissions_needed => {
      headerText: "PayPal requires you to grant all permissions",
      subText: "You need to grant all the permissions to create and receive payments. Please click on the Signup to PayPal button and grant the permissions.",
      buttonText: "Complete Signing up",
    }

  | Email_not_verified => {
      headerText: "Your email is yet to be confirmed!",
      subText: "Please confirm your email address on https://www.paypal.com/businessprofile/settings in order to receive payments.",
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

let handleObjectResponse = (~dict, ~setInitialValues, ~connector, ~handleStateToNextPage) => {
  open LogicUtils
  let values = dict->getJsonObjectFromDict("connector_integrated")
  let bodyTypeValue =
    values
    ->getDictFromJsonObject
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
  handleStateToNextPage()
}

let getBodyType = (isUpdateFlow, configuartionType) => {
  open PayPalFlowTypes
  isUpdateFlow
    ? switch configuartionType {
      | Manual => "BodyKey"
      | Automatic | NotSelected => "SignatureKey"
      }
    : "TemporaryAuth"
}

let generateConnectorPayloadPayPal = (
  ~profileId,
  ~connectorId,
  ~connector,
  ~bodyType,
  ~connectorLabel,
  ~disabled,
  ~status,
) => {
  open ConnectorUtils
  let initialValues =
    [
      ("profile_id", profileId->JSON.Encode.string),
      ("connector_name", connector->String.toLowerCase->JSON.Encode.string),
      ("connector_type", "payment_processor"->JSON.Encode.string),
      ("disabled", disabled->JSON.Encode.bool),
      ("test_mode", true->JSON.Encode.bool),
      ("status", status->JSON.Encode.string),
      ("connector_label", connectorLabel->JSON.Encode.string),
    ]->LogicUtils.getJsonFromArrayOfJson

  generateInitialValuesDict(
    ~values={initialValues},
    ~connector,
    ~bodyType,
    ~isPayoutFlow=false,
    (),
  )->ignoreFields(connectorId, connectorIgnoredField)
}

let generatePayPalBody = (~returnUrl=None, ~connectorId, ~profileId=None, ()) => {
  switch returnUrl {
  | Some(returnURL) =>
    [
      ("connector", "paypal"->JSON.Encode.string),
      ("return_url", returnURL->JSON.Encode.string),
      ("connector_id", connectorId->JSON.Encode.string),
    ]->LogicUtils.getJsonFromArrayOfJson
  | _ =>
    [
      ("connector", "paypal"->JSON.Encode.string),
      ("connector_id", connectorId->JSON.Encode.string),
      ("profile_id", profileId->Option.getOr("")->JSON.Encode.string),
    ]->LogicUtils.getJsonFromArrayOfJson
  }
}

let conditionForIntegrationSteps: array<PayPalFlowTypes.setupAccountStatus> = [
  Account_not_found,
  Redirecting_to_paypal,
]

let useDeleteTrackingDetails = () => {
  open APIUtils
  let updateDetails = useUpdateMethod(~showErrorToast=false, ())

  async (connectorId, connector) => {
    try {
      let url = `${getURL(~entityName=PAYPAL_ONBOARDING, ~methodType=Post, ())}/reset_tracking_id`
      let body =
        [
          ("connector_id", connectorId->JSON.Encode.string),
          ("connector", connector->JSON.Encode.string),
        ]->LogicUtils.getJsonFromArrayOfJson
      let _ = await updateDetails(url, body, Post, ())
    } catch {
    | Js.Exn.Error(e) => {
        let err = Js.Exn.message(e)->Option.getOr("Failed to update!")
        Js.Exn.raiseError(err)
      }
    }
  }
}

let useDeleteConnectorAccountDetails = () => {
  open LogicUtils
  open APIUtils
  let updateDetails = useUpdateMethod(~showErrorToast=false, ())

  async (initialValues, connectorId, connector, isUpdateFlow, disabled, status) => {
    try {
      let dictOfJson = initialValues->getDictFromJsonObject
      let profileIdValue = dictOfJson->getString("profile_id", "")
      let body = generateConnectorPayloadPayPal(
        ~profileId=profileIdValue,
        ~connectorId,
        ~connector,
        ~bodyType="TemporaryAuth",
        ~connectorLabel={
          dictOfJson->getString("connector_label", "")
        },
        ~disabled,
        ~status,
      )
      let url = getURL(
        ~entityName=CONNECTOR,
        ~methodType=Post,
        ~id=isUpdateFlow ? Some(connectorId) : None,
        (),
      )
      let res = await updateDetails(url, body, Post, ())
      res
    } catch {
    | Js.Exn.Error(e) => {
        let err = Js.Exn.message(e)->Option.getOr("Failed to Fetch!")
        Js.Exn.raiseError(err)
      }
    }
  }
}

let getAuthTypeFromConnectorDetails = json => {
  open LogicUtils
  json
  ->getDictFromJsonObject
  ->getDictfromDict("connector_account_details")
  ->getString("auth_type", "")
  ->String.toLowerCase
  ->ConnectorUtils.mapAuthType
}

let payPalPageState = async (
  ~setScreenState: (PageLoaderWrapper.viewType => PageLoaderWrapper.viewType) => unit,
  ~url: RescriptReactRouter.url,
  ~setSetupAccountStatus,
  ~getPayPalStatus,
  ~setCurrentStep,
  ~isUpdateFlow,
) => {
  open LogicUtils
  try {
    let isSimplifiedPayPalFlow =
      url.search
      ->getDictFromUrlSearchParams
      ->Dict.get("is_simplified_paypal")
      ->Option.getOr("false")
      ->getBoolFromString(false)
    let isRedirectedFromPaypalModal =
      url.search
      ->getDictFromUrlSearchParams
      ->Dict.get("is_back")
      ->Option.getOr("false")
      ->getBoolFromString(false)

    setSetupAccountStatus(._ => PayPalFlowTypes.Connect_paypal_landing)
    if isRedirectedFromPaypalModal {
      await getPayPalStatus()
    } else if isUpdateFlow && !(isSimplifiedPayPalFlow && isRedirectedFromPaypalModal) {
      setCurrentStep(_ => ConnectorTypes.Preview)
      setScreenState(_ => Success)
    } else {
      setCurrentStep(_ => ConnectorTypes.AutomaticFlow)
      setScreenState(_ => Success)
    }
  } catch {
  | Js.Exn.Error(e) => {
      let err = Js.Exn.message(e)->Option.getOr("Something went wrong")
      setScreenState(_ => Error(err))
    }
  | _ => setScreenState(_ => Error("Something went wrong"))
  }
}
