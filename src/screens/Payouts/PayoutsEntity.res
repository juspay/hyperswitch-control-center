open LogicUtils

let concatValueOfGivenKeysOfDict = (dict, keys) => {
  Array.reduceWithIndex(keys, "", (acc, key, i) => {
    let val = dict->getString(key, "")
    let delimiter = if val->isNonEmptyString {
      if key !== "first_name" {
        i + 1 == keys->Array.length ? "." : ", "
      } else {
        " "
      }
    } else {
      ""
    }
    String.concat(acc, `${val}${delimiter}`)
  })
}

type payoutAttempts = {
  attempt_id: string,
  status: string,
  amount: float,
  currency: string,
  connector: string,
  error_code: string,
  error_message: string,
  payment_method: string,
  payout_method_type: string,
  connector_transaction_id: string,
  cancellation_reason: string,
  unified_code: string,
  unified_message: string,
}

type payouts = {
  payout_id: string,
  merchant_id: string,
  amount: float,
  currency: string,
  connector: string,
  payout_type: string,
  billing: string,
  billingEmail: string,
  billingPhone: string,
  customer_id: string,
  auto_fulfill: bool,
  email: string,
  name: string,
  phone: string,
  phone_country_code: string,
  client_secret: string,
  return_url: string,
  business_country: string,
  business_label: string,
  description: string,
  entity_type: string,
  recurring: bool,
  status: string,
  error_message: string,
  error_code: string,
  profile_id: string,
  created: string,
  connector_transaction_id: string,
  priority: string,
  payout_method_data: option<JSON.t>,
  attempts: array<payoutAttempts>,
  metadata: Dict.t<JSON.t>,
}

type payoutsAttemptColType =
  | AttemptId
  | Status
  | Amount
  | Currency
  | Connector
  | ErrorCode
  | Error_message
  | PaymentMethod
  | PayoutMethodType
  | ConnectorTransactionId
  | CancellationReason
  | UnifiedCode
  | UnifiedMessage

let attemptsColumns = [AttemptId, Status, Amount, Currency, Connector]

let attemptDetailsField = [
  AttemptId,
  Status,
  Amount,
  Currency,
  Connector,
  ErrorCode,
  Error_message,
  PaymentMethod,
  PayoutMethodType,
  ConnectorTransactionId,
  CancellationReason,
  UnifiedCode,
  UnifiedMessage,
]

type status =
  | Succeeded
  | Failed
  | Cancelled
  | Processing
  | RequiresCustomerAction
  | RequiresPaymentMethod
  | RequiresConfirmation
  | PartiallyCaptured
  | None

let statusVariantMapper: string => status = statusLabel =>
  switch statusLabel {
  | "failed" => Failed
  | "pending" => Processing
  | "success" => Succeeded
  | "requires_fulfillment"
  | "requires_creation"
  | _ =>
    None
  }

type priority =
  | Instant
  | Fast
  | Regular
  | Wire
  | CrossBorder
  | Internal
  | None

let priorityVariantMapper: string => priority = priorityLabel =>
  switch priorityLabel {
  | "instant" => Instant
  | "fast" => Fast
  | "regular" => Regular
  | "wire" => Wire
  | "crossBorder" => CrossBorder
  | "internal" => Internal
  | _ => None
  }

let getAttemptHeading = colType => {
  switch colType {
  | AttemptId =>
    Table.makeHeaderInfo(
      ~key="AttemptId",
      ~title="Attempt Id",
      ~description="You can validate the information shown here by cross checking the payout attempt identifier (Attempt ID) in your payout processor portal.",
    )
  | Status => Table.makeHeaderInfo(~key="Status", ~title="Status")
  | Amount => Table.makeHeaderInfo(~key="Amount", ~title="Amount")
  | Currency => Table.makeHeaderInfo(~key="Currency", ~title="Currency")
  | Connector => Table.makeHeaderInfo(~key="Connector", ~title="Connector")
  | ErrorCode => Table.makeHeaderInfo(~key="ErrorCode", ~title="Error Code")
  | Error_message => Table.makeHeaderInfo(~key="Error_message", ~title="Error Message")
  | PaymentMethod => Table.makeHeaderInfo(~key="PaymentMethod", ~title="Payment Method")
  | PayoutMethodType => Table.makeHeaderInfo(~key="PayoutMethodType", ~title="Payout Method Type")
  | ConnectorTransactionId =>
    Table.makeHeaderInfo(~key="ConnectorTransactionId", ~title="Connector Transaction Id")
  | CancellationReason =>
    Table.makeHeaderInfo(~key="CancellationReason", ~title="Cancellation Reason")
  | UnifiedCode => Table.makeHeaderInfo(~key="UnifiedCode", ~title="Unified Code")
  | UnifiedMessage => Table.makeHeaderInfo(~key="UnifiedMessage", ~title="Unified Message")
  }
}

let getAttemptCell = (attemptData, colType): Table.cell => {
  switch colType {
  | AttemptId => DisplayCopyCell(attemptData.attempt_id)
  | Status =>
    Label({
      title: attemptData.status->String.toUpperCase,
      color: switch attemptData.status->statusVariantMapper {
      | Succeeded => LabelGreen
      | Failed => LabelRed
      | Processing => LabelOrange
      | Cancelled => LabelRed
      | RequiresCustomerAction
      | RequiresConfirmation
      | RequiresPaymentMethod =>
        LabelBlue
      | _ => LabelLightGray
      },
    })
  | Amount =>
    CustomCell(
      <OrderEntity.CurrencyCell
        amount={(attemptData.amount /. 100.0)->Float.toString} currency={attemptData.currency}
      />,
      "",
    )
  | Currency => Text(attemptData.currency)
  | Connector =>
    CustomCell(<HelperComponents.ConnectorCustomCell connectorName=attemptData.connector />, "")
  | ErrorCode => Text(attemptData.error_code)
  | Error_message => Text(attemptData.error_message)
  | PaymentMethod => Text(attemptData.payment_method)
  | PayoutMethodType => Text(attemptData.payout_method_type)
  | ConnectorTransactionId => DisplayCopyCell(attemptData.connector_transaction_id)
  | CancellationReason => Text(attemptData.cancellation_reason)
  | UnifiedCode => Text(attemptData.unified_code)
  | UnifiedMessage => Text(attemptData.unified_message)
  }
}

type payoutsColType =
  | PayoutId
  | MerchantId
  | Amount
  | Currency
  | Connector
  | PayoutType
  | Billing
  | CustomerId
  | AutoFulfill
  | Email
  | Name
  | Phone
  | PhoneCountryCode
  | ClientSecret
  | ReturnUrl
  | BusinessCountry
  | BusinessLabel
  | Description
  | Entity_type
  | Recurring
  | Status
  | ErrorMessage
  | ErrorCode
  | ProfileId
  | Created
  | ConnectorTransactionId
  | SendPriority

let defaultColumns = [PayoutId, Connector, Amount, Status, ConnectorTransactionId, Created]
let allColumns = [
  PayoutId,
  MerchantId,
  Amount,
  Currency,
  Connector,
  PayoutType,
  SendPriority,
  Billing,
  CustomerId,
  AutoFulfill,
  Email,
  Name,
  Phone,
  PhoneCountryCode,
  ClientSecret,
  ReturnUrl,
  BusinessCountry,
  BusinessLabel,
  Description,
  Entity_type,
  Recurring,
  Status,
  ErrorMessage,
  ErrorCode,
  ProfileId,
  Created,
  ConnectorTransactionId,
]
type summaryColType =
  | Created
  | AmountReceived
  | PayoutId
  | Currency
  | ClientSecret
  | ConnectorTransactionID
  | ErrorMessage

type aboutPayoutColType =
  | Connector
  | ProfileId
  | ProfileName
  | PayoutMethodType
  | PayoutMethod
  | CardBrand
  | ConnectorLabel
  | AuthenticationType
  | CaptureMethod
  | CardNetwork

type otherDetailsColType =
  | CustomerId
  | Name
  | Email
  | Phone
  | PhoneCountryCode
  | Description
  | BillingEmail
  | BillingPhone
  | BillingAddress
  | FirstName
  | LastName
  | PayoutMethodEmail
  | PayoutMethodAddress
  | AutoFulfill
  | Recurring
  | EntityType
  | BusinessCountry
  | BusinessLabel
  | ReturnUrl
  | ClientSecret
  | Priority
  | ErrorCode
  | MerchantId

let useGetStatus = order => {
  let {globalUIConfig: {primaryColor}} = React.useContext(ThemeProvider.themeContext)
  let orderStatusLabel = order.status->String.toUpperCase
  let fixedCss = "text-sm text-white font-bold p-1.5 rounded-lg"
  switch order.status->statusVariantMapper {
  | Succeeded =>
    <div className={`${fixedCss} bg-hyperswitch_green dark:bg-opacity-50`}>
      {orderStatusLabel->React.string}
    </div>
  | Failed
  | Cancelled =>
    <div className={`${fixedCss} bg-red-960 dark:bg-opacity-50`}>
      {orderStatusLabel->React.string}
    </div>
  | Processing
  | RequiresCustomerAction
  | RequiresPaymentMethod =>
    <div className={`${fixedCss} ${primaryColor} bg-opacity-50`}>
      {orderStatusLabel->React.string}
    </div>
  | _ =>
    <div className={`${fixedCss} ${primaryColor} bg-opacity-50`}>
      {orderStatusLabel->React.string}
    </div>
  }
}

let getHeading = (colType: payoutsColType) => {
  switch colType {
  | PayoutId => Table.makeHeaderInfo(~key="PayoutId", ~title="Payout Id")
  | MerchantId => Table.makeHeaderInfo(~key="MerchantId", ~title="Merchant Id")
  | Currency => Table.makeHeaderInfo(~key="Currency", ~title="Currency")
  | Connector => Table.makeHeaderInfo(~key="Connector", ~title="Connector")
  | Email => Table.makeHeaderInfo(~key="Email", ~title="Email")
  | Amount => Table.makeHeaderInfo(~key="Amount", ~title="Amount")
  | BusinessCountry => Table.makeHeaderInfo(~key="BusinessCountry", ~title="Business Country")
  | ErrorMessage => Table.makeHeaderInfo(~key="ErrorMessage", ~title="Error Message")
  | ProfileId => Table.makeHeaderInfo(~key="ProfileId", ~title="Profile Id")
  | Status => Table.makeHeaderInfo(~key="status", ~title="Payout Status", ~dataType=DropDown)
  | CustomerId => Table.makeHeaderInfo(~key="CustomerId", ~title="Customer Id")
  | Created => Table.makeHeaderInfo(~key="Created", ~title="Created At")
  | PayoutType => Table.makeHeaderInfo(~key="PayoutType", ~title="Payout Type")
  | Billing => Table.makeHeaderInfo(~key="Billing", ~title="Billing")
  | AutoFulfill => Table.makeHeaderInfo(~key="AutoFulfill", ~title="Auto Full fill")
  | Name => Table.makeHeaderInfo(~key="Name", ~title="Name")
  | Phone => Table.makeHeaderInfo(~key="Phone", ~title="Phone")
  | PhoneCountryCode => Table.makeHeaderInfo(~key="PhoneCountryCode", ~title="Phone Country Code")
  | ClientSecret => Table.makeHeaderInfo(~key="ClientSecret", ~title="Client Secret")
  | ReturnUrl => Table.makeHeaderInfo(~key="ReturnUrl", ~title="Return Url")
  | BusinessLabel => Table.makeHeaderInfo(~key="BusinessLabel", ~title="Business Label")
  | Description => Table.makeHeaderInfo(~key="Description", ~title="Description")
  | Entity_type => Table.makeHeaderInfo(~key="Entity_type", ~title="Entity Type")
  | Recurring => Table.makeHeaderInfo(~key="Recurring", ~title="Recurring")
  | ErrorCode => Table.makeHeaderInfo(~key="ErrorCode", ~title="ErrorCode")
  | ConnectorTransactionId =>
    Table.makeHeaderInfo(~key="ConnectorTransactionId", ~title="Connector Transaction ID")
  | SendPriority => Table.makeHeaderInfo(~key="SendPriority", ~title="Send Priority")
  }
}

let getCell = (payoutData, colType: payoutsColType, merchantId, orgId): Table.cell => {
  switch colType {
  | PayoutId =>
    CustomCell(
      <HSwitchOrderUtils.CopyLinkTableCell
        url={`/payouts/${payoutData.payout_id}/${payoutData.profile_id}/${merchantId}/${orgId}`}
        displayValue={payoutData.payout_id}
        copyValue={Some(payoutData.payout_id)}
      />,
      "",
    )
  | MerchantId => DisplayCopyCell(payoutData.merchant_id)
  | Currency => Text(payoutData.currency)
  | Connector =>
    CustomCell(
      <HelperComponents.ConnectorCustomCell
        connectorName=payoutData.connector connectorType={PayoutProcessor}
      />,
      "",
    )
  | Email => Text(payoutData.email)
  | Amount =>
    CustomCell(
      <OrderEntity.CurrencyCell
        amount={(payoutData.amount /. 100.0)->Float.toString} currency={payoutData.currency}
      />,
      "",
    )
  | BusinessCountry => Text(payoutData.business_country)
  | ErrorMessage => Text(payoutData.error_message)
  | ProfileId => DisplayCopyCell(payoutData.profile_id)
  | Status =>
    Label({
      title: payoutData.status->String.toUpperCase,
      color: switch payoutData.status->statusVariantMapper {
      | Succeeded => LabelGreen
      | Failed => LabelRed
      | Processing => LabelOrange
      | Cancelled => LabelRed
      | RequiresCustomerAction
      | RequiresConfirmation
      | RequiresPaymentMethod =>
        LabelBlue
      | _ => LabelLightGray
      },
    })
  | CustomerId => DisplayCopyCell(payoutData.customer_id)
  | Created => Date(payoutData.created)
  | PayoutType => Text(payoutData.payout_type)
  | Billing => Text(payoutData.billing)
  | AutoFulfill => Text(payoutData.auto_fulfill->getStringFromBool)
  | Name => Text(payoutData.name)
  | Phone => Text(payoutData.phone)
  | PhoneCountryCode => Text(payoutData.phone_country_code)
  | ClientSecret => Text(payoutData.client_secret)
  | ReturnUrl => Text(payoutData.return_url)
  | BusinessLabel => Text(payoutData.business_label)
  | Description => Text(payoutData.description)
  | Entity_type => Text(payoutData.entity_type)
  | Recurring => Text(payoutData.recurring->getStringFromBool)
  | ErrorCode => Text(payoutData.error_code)
  | ConnectorTransactionId => DisplayCopyCell(payoutData.connector_transaction_id)
  | SendPriority =>
    switch payoutData.priority->priorityVariantMapper {
    | None => Text(payoutData.priority)
    | priorityVariants =>
      Label({
        title: payoutData.priority->String.toUpperCase,
        color: switch priorityVariants {
        | Instant => LabelBlue
        | _ => LabelLightGray
        },
      })
    }
  }
}

let itemToObjMapperAttempts = json => {
  let dict = json->getDictFromJsonObject
  {
    attempt_id: getString(dict, "attempt_id", ""),
    status: getString(dict, "status", ""),
    amount: getFloat(dict, "amount", 0.0),
    currency: getString(dict, "currency", ""),
    connector: getString(dict, "connector", ""),
    error_code: getString(dict, "error_code", ""),
    error_message: getString(dict, "error_message", ""),
    payment_method: getString(dict, "payment_method", ""),
    payout_method_type: getString(dict, "payout_method_type", ""),
    connector_transaction_id: getString(dict, "connector_transaction_id", ""),
    cancellation_reason: getString(dict, "cancellation_reason", ""),
    unified_code: getString(dict, "unified_code", ""),
    unified_message: getString(dict, "unified_message", ""),
  }
}

let itemToObjMapper = dict => {
  let addressKeys = ["line1", "line2", "line3", "city", "state", "country", "zip"]

  let getPhoneNumberString = (phone, ~phoneKey="number", ~codeKey="country_code") => {
    `${phone->getString(codeKey, "")} ${phone->getString(phoneKey, "NA")}`
  }

  {
    payout_id: getString(dict, "payout_id", ""),
    merchant_id: getString(dict, "merchant_id", ""),
    amount: getFloat(dict, "amount", 0.0),
    currency: getString(dict, "currency", ""),
    connector: getString(dict, "connector", ""),
    payout_type: getString(dict, "payout_type", ""),
    billing: dict
    ->getDictfromDict("billing")
    ->getDictfromDict("address")
    ->concatValueOfGivenKeysOfDict(addressKeys),
    billingEmail: dict->getDictfromDict("billing")->getString("email", ""),
    billingPhone: dict
    ->getDictfromDict("billing")
    ->getDictfromDict("phone")
    ->getPhoneNumberString,
    customer_id: getString(dict, "customer_id", ""),
    auto_fulfill: getBool(dict, "auto_fulfill", false),
    email: getString(dict, "email", ""),
    name: getString(dict, "name", ""),
    phone: dict
    ->getDictfromDict("customer")
    ->getPhoneNumberString(~phoneKey="phone", ~codeKey="phone_country_code"),
    phone_country_code: getString(dict, "phone_country_code", ""),
    client_secret: getString(dict, "client_secret", ""),
    return_url: getString(dict, "return_url", ""),
    business_country: getString(dict, "business_country", ""),
    business_label: getString(dict, "business_label", ""),
    description: getString(dict, "description", ""),
    entity_type: getString(dict, "entity_type", ""),
    recurring: getBool(dict, "recurring", false),
    status: getString(dict, "status", ""),
    error_message: getString(dict, "error_message", ""),
    error_code: getString(dict, "error_code", ""),
    profile_id: getString(dict, "profile_id", ""),
    created: getString(dict, "created", ""),
    connector_transaction_id: getString(dict, "connector_transaction_id", ""),
    priority: getString(dict, "priority", ""),
    payout_method_data: {
      let payoutMethodData = dict->LogicUtils.getvalFromDict("payout_method_data")
      switch payoutMethodData {
      | Some(data) => data->LogicUtils.isNullJson ? None : Some(data)
      | None => None
      }
    },
    attempts: dict->getArrayFromDict("attempts", [])->Array.map(itemToObjMapperAttempts),
    metadata: dict->getDictfromDict("metadata"),
  }
}

let getPayouts: JSON.t => array<payouts> = json => {
  getArrayDataFromJson(json, itemToObjMapper)
}

let payoutEntity = (merchantId, orgId) =>
  EntityType.makeEntity(
    ~uri="",
    ~getObjects=getPayouts,
    ~defaultColumns,
    ~allColumns,
    ~getHeading,
    ~getCell=(payout, payoutColsType) => getCell(payout, payoutColsType, merchantId, orgId),
    ~dataKey="",
    ~getShowLink={
      payoutData =>
        GlobalVars.appendDashboardPath(
          ~url=`/payouts/${payoutData.payout_id}/${payoutData.profile_id}/${merchantId}/${orgId}`,
        )
    },
  )
module CurrencyCell = {
  @react.component
  let make = (~amount, ~currency) => {
    <p className="whitespace-nowrap"> {`${amount} ${currency}`->React.string} </p>
  }
}
let getCellForSummary = (order, summaryColType): Table.cell => {
  switch summaryColType {
  | Created => Date(order.created)
  | AmountReceived =>
    CustomCell(
      <CurrencyCell amount={(order.amount /. 100.0)->Float.toString} currency={order.currency} />,
      "",
    )

  | PayoutId => DisplayCopyCell(order.payout_id)
  | Currency => Text(order.currency)

  | ClientSecret => Text(order.client_secret)
  | ErrorMessage => Text(order.error_message)
  | ConnectorTransactionID =>
    CustomCell(
      <HelperComponents.CopyTextCustomComp
        customTextCss="w-36 truncate whitespace-nowrap"
        displayValue=Some(order.connector_transaction_id)
      />,
      "",
    )
  }
}

let getHeadingForSummary = summaryColType => {
  switch summaryColType {
  | Created => Table.makeHeaderInfo(~key="created", ~title="Created")
  | AmountReceived =>
    Table.makeHeaderInfo(
      ~key="amount_received",
      ~title="Amount Received",
      ~description="Amount processed by the payout processor for this payout.",
    )
  | PayoutId => Table.makeHeaderInfo(~key="payout_id", ~title="Payout ID")
  | Currency => Table.makeHeaderInfo(~key="currency", ~title="Currency")
  | ClientSecret => Table.makeHeaderInfo(~key="client_secret", ~title="Client Secret")
  | ConnectorTransactionID =>
    Table.makeHeaderInfo(~key="connector_transaction_id", ~title="Connector Transaction ID")
  | ErrorMessage => Table.makeHeaderInfo(~key="error_message", ~title="Error Message")
  }
}

let getHeadingForAboutPayment = aboutPaymentColType => {
  switch aboutPaymentColType {
  | Connector => Table.makeHeaderInfo(~key="connector", ~title="Preferred connector")
  | ProfileId => Table.makeHeaderInfo(~key="profile_id", ~title="Profile Id")
  | ProfileName => Table.makeHeaderInfo(~key="profile_name", ~title="Profile Name")
  | CardBrand => Table.makeHeaderInfo(~key="card_brand", ~title="Card Brand")
  | ConnectorLabel => Table.makeHeaderInfo(~key="connector_label", ~title="Connector Label")
  | PayoutMethod => Table.makeHeaderInfo(~key="payout_method", ~title="Payout Method")
  | PayoutMethodType => Table.makeHeaderInfo(~key="payout_method_type", ~title="Payout Method Type")
  | AuthenticationType => Table.makeHeaderInfo(~key="authentication_type", ~title="Auth Type")
  | CaptureMethod => Table.makeHeaderInfo(~key="capture_method", ~title="Capture Method")
  | CardNetwork => Table.makeHeaderInfo(~key="card_network", ~title="Card Network")
  }
}

let getHeadingForOtherDetails = otherDetailsColType => {
  switch otherDetailsColType {
  | CustomerId => Table.makeHeaderInfo(~key="customer_id", ~title="Customer ID")
  | Name => Table.makeHeaderInfo(~key="name", ~title="Name")
  | Email => Table.makeHeaderInfo(~key="email", ~title="Email")
  | Phone => Table.makeHeaderInfo(~key="phone", ~title="Phone")
  | PhoneCountryCode => Table.makeHeaderInfo(~key="phone_country_code", ~title="Phone Country Code")
  | Description => Table.makeHeaderInfo(~key="description", ~title="Description")
  | BillingEmail => Table.makeHeaderInfo(~key="billing_email", ~title="Billing Email")
  | BillingPhone => Table.makeHeaderInfo(~key="billing_phone", ~title="Billing Phone")
  | BillingAddress => Table.makeHeaderInfo(~key="billing_address", ~title="Billing Address")
  | FirstName => Table.makeHeaderInfo(~key="first_name", ~title="First Name")
  | LastName => Table.makeHeaderInfo(~key="last_name", ~title="Last Name")
  | PayoutMethodEmail =>
    Table.makeHeaderInfo(~key="Payout_method_email", ~title="Payout Method Email")
  | PayoutMethodAddress =>
    Table.makeHeaderInfo(~key="Payout_method_address", ~title="Payout Method Address")
  | AutoFulfill => Table.makeHeaderInfo(~key="auto_fulfill", ~title="Auto Fulfill")
  | Recurring => Table.makeHeaderInfo(~key="recurring", ~title="Recurring")
  | EntityType => Table.makeHeaderInfo(~key="entity_type", ~title="Entity Type")
  | BusinessCountry => Table.makeHeaderInfo(~key="business_country", ~title="Business Country")
  | BusinessLabel => Table.makeHeaderInfo(~key="business_label", ~title="Business Label")
  | ReturnUrl => Table.makeHeaderInfo(~key="return_url", ~title="Return URL")
  | ClientSecret => Table.makeHeaderInfo(~key="client_secret", ~title="Client Secret")
  | Priority => Table.makeHeaderInfo(~key="priority", ~title="Priority")
  | ErrorCode => Table.makeHeaderInfo(~key="error_code", ~title="Error Code")
  | MerchantId => Table.makeHeaderInfo(~key="merchant_id", ~title="Merchant ID")
  }
}

let getCellForAboutPayment = (payoutData, aboutPaymentColType): Table.cell => {
  switch aboutPaymentColType {
  | Connector =>
    CustomCell(<HelperComponents.ConnectorCustomCell connectorName=payoutData.connector />, "")
  | ProfileId => DisplayCopyCell(payoutData.profile_id)
  | ProfileName => Text("")
  | PayoutMethod => Text(payoutData.payout_type)
  | PayoutMethodType => Text(payoutData.payout_type)
  | CardBrand => Text("")
  | ConnectorLabel => Text(payoutData.connector)
  | AuthenticationType => Text("")
  | CaptureMethod => Text("")
  | CardNetwork => Text("")
  }
}

let getCellForOtherDetails = (payoutData, otherDetailsColType): Table.cell => {
  let splittedName = payoutData.name->String.split(" ")
  switch otherDetailsColType {
  | CustomerId => DisplayCopyCell(payoutData.customer_id)
  | Name => Text(payoutData.name)
  | Email => Text(payoutData.email)
  | Phone => Text(payoutData.phone)
  | PhoneCountryCode => Text(payoutData.phone_country_code)
  | Description => Text(payoutData.description)
  | BillingEmail => Text(payoutData.billingEmail)
  | BillingPhone => Text(payoutData.billingPhone)
  | BillingAddress => Text(payoutData.billing)
  | FirstName => Text(splittedName->Array.get(0)->Option.getOr(""))
  | LastName => Text(splittedName->Array.get(splittedName->Array.length - 1)->Option.getOr(""))
  | PayoutMethodEmail => Text(payoutData.email)
  | PayoutMethodAddress => Text(payoutData.billing)
  | AutoFulfill => Text(payoutData.auto_fulfill->getStringFromBool)
  | Recurring => Text(payoutData.recurring->getStringFromBool)
  | EntityType => Text(payoutData.entity_type)
  | BusinessCountry => Text(payoutData.business_country)
  | BusinessLabel => Text(payoutData.business_label)
  | ReturnUrl => Text(payoutData.return_url)
  | ClientSecret => Text(payoutData.client_secret)
  | Priority => Text(payoutData.priority)
  | ErrorCode => Text(payoutData.error_code)
  | MerchantId => DisplayCopyCell(payoutData.merchant_id)
  }
}
