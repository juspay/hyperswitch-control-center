open LogicUtils

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
  attempts: array<payoutAttempts>,
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

let attemptsColumns = [
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
  | AttemptId => Table.makeHeaderInfo(~key="AttemptId", ~title="Attempt Id", ~showSort=false, ())
  | Status => Table.makeHeaderInfo(~key="Status", ~title="Status", ~showSort=false, ())
  | Amount => Table.makeHeaderInfo(~key="Amount", ~title="Amount", ~showSort=false, ())
  | Currency => Table.makeHeaderInfo(~key="Currency", ~title="Currency", ~showSort=false, ())
  | Connector => Table.makeHeaderInfo(~key="Connector", ~title="Connector", ~showSort=false, ())
  | ErrorCode => Table.makeHeaderInfo(~key="ErrorCode", ~title="Error Code", ~showSort=false, ())
  | Error_message =>
    Table.makeHeaderInfo(~key="Error_message", ~title="Error Message", ~showSort=false, ())
  | PaymentMethod =>
    Table.makeHeaderInfo(~key="PaymentMethod", ~title="Payment Method", ~showSort=false, ())
  | PayoutMethodType =>
    Table.makeHeaderInfo(~key="PayoutMethodType", ~title="Payout Method Type", ~showSort=false, ())
  | ConnectorTransactionId =>
    Table.makeHeaderInfo(
      ~key="ConnectorTransactionId",
      ~title="Connector Transaction Id",
      ~showSort=false,
      (),
    )
  | CancellationReason =>
    Table.makeHeaderInfo(
      ~key="CancellationReason",
      ~title="Cancellation Reason",
      ~showSort=false,
      (),
    )
  | UnifiedCode =>
    Table.makeHeaderInfo(~key="UnifiedCode", ~title="Unified Code", ~showSort=false, ())
  | UnifiedMessage =>
    Table.makeHeaderInfo(~key="UnifiedMessage", ~title="UnifiedM essage", ~showSort=false, ())
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
        LabelWhite
      | _ => LabelLightBlue
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

let useGetStatus = order => {
  let {globalUIConfig: {backgroundColor}} = React.useContext(ConfigContext.configContext)
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
    <div className={`${fixedCss} ${backgroundColor} bg-opacity-50`}>
      {orderStatusLabel->React.string}
    </div>
  | _ =>
    <div className={`${fixedCss} ${backgroundColor} bg-opacity-50`}>
      {orderStatusLabel->React.string}
    </div>
  }
}

let getHeading = colType => {
  switch colType {
  | PayoutId => Table.makeHeaderInfo(~key="PayoutId", ~title="Payout Id", ~showSort=false, ())
  | MerchantId => Table.makeHeaderInfo(~key="MerchantId", ~title="Merchant Id", ~showSort=false, ())
  | Currency => Table.makeHeaderInfo(~key="Currency", ~title="Currency", ~showSort=false, ())
  | Connector => Table.makeHeaderInfo(~key="Connector", ~title="Connector", ~showSort=false, ())
  | Email => Table.makeHeaderInfo(~key="Email", ~title="Email", ~showSort=false, ())
  | Amount => Table.makeHeaderInfo(~key="Amount", ~title="Amount", ~showSort=false, ())
  | BusinessCountry =>
    Table.makeHeaderInfo(~key="BusinessCountry", ~title="Business Country", ~showSort=false, ())
  | ErrorMessage =>
    Table.makeHeaderInfo(~key="ErrorMessage", ~title="Error Message", ~showSort=false, ())
  | ProfileId => Table.makeHeaderInfo(~key="ProfileId", ~title="Profile Id", ~showSort=false, ())
  | Status =>
    Table.makeHeaderInfo(
      ~key="status",
      ~title="Payout Status",
      ~dataType=DropDown,
      ~showSort=false,
      (),
    )
  | CustomerId => Table.makeHeaderInfo(~key="CustomerId", ~title="Customer Id", ~showSort=false, ())
  | Created => Table.makeHeaderInfo(~key="Created", ~title="Created At", ~showSort=false, ())

  | PayoutType => Table.makeHeaderInfo(~key="PayoutType", ~title="Payout Type", ~showSort=false, ())
  | Billing => Table.makeHeaderInfo(~key="Billing", ~title="Billing", ~showSort=false, ())
  | AutoFulfill =>
    Table.makeHeaderInfo(~key="AutoFulfill", ~title="Auto Full fill", ~showSort=false, ())
  | Name => Table.makeHeaderInfo(~key="Name", ~title="Name", ~showSort=false, ())
  | Phone => Table.makeHeaderInfo(~key="Phone", ~title="Phone", ~showSort=false, ())
  | PhoneCountryCode =>
    Table.makeHeaderInfo(~key="PhoneCountryCode", ~title="Phone Country Code", ~showSort=false, ())
  | ClientSecret =>
    Table.makeHeaderInfo(~key="ClientSecret", ~title="Client Secret", ~showSort=false, ())
  | ReturnUrl => Table.makeHeaderInfo(~key="ReturnUrl", ~title="Return Url", ~showSort=false, ())
  | BusinessLabel =>
    Table.makeHeaderInfo(~key="BusinessLabel", ~title="Business Label", ~showSort=false, ())
  | Description =>
    Table.makeHeaderInfo(~key="Description", ~title="Description", ~showSort=false, ())
  | Entity_type =>
    Table.makeHeaderInfo(~key="Entity_type", ~title="Entity Type", ~showSort=false, ())
  | Recurring => Table.makeHeaderInfo(~key="Recurring", ~title="Recurring", ~showSort=false, ())
  | ErrorCode => Table.makeHeaderInfo(~key="ErrorCode", ~title="ErrorCode", ~showSort=false, ())
  | ConnectorTransactionId =>
    Table.makeHeaderInfo(
      ~key="ConnectorTransactionId",
      ~title="Connector Transaction ID",
      ~showSort=false,
      (),
    )

  | SendPriority =>
    Table.makeHeaderInfo(~key="SendPriority", ~title="Send Priority", ~showSort=false, ())
  }
}

let getCell = (payoutData, colType): Table.cell => {
  switch colType {
  | PayoutId => DisplayCopyCell(payoutData.payout_id)
  | MerchantId => DisplayCopyCell(payoutData.merchant_id)
  | Currency => Text(payoutData.currency)
  | Connector =>
    CustomCell(<HelperComponents.ConnectorCustomCell connectorName=payoutData.connector />, "")
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
        LabelWhite
      | _ => LabelLightBlue
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
        | _ => LabelOrange
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
  {
    payout_id: getString(dict, "payout_id", ""),
    merchant_id: getString(dict, "merchant_id", ""),
    amount: getFloat(dict, "amount", 0.0),
    currency: getString(dict, "currency", ""),
    connector: getString(dict, "connector", ""),
    payout_type: getString(dict, "payout_type", ""),
    billing: getString(dict, "billing", ""),
    customer_id: getString(dict, "customer_id", ""),
    auto_fulfill: getBool(dict, "auto_fulfill", false),
    email: getString(dict, "email", ""),
    name: getString(dict, "name", ""),
    phone: getString(dict, "phone", ""),
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
    attempts: dict->getArrayFromDict("attempts", [])->Array.map(itemToObjMapperAttempts),
  }
}

let getPayouts: JSON.t => array<payouts> = json => {
  getArrayDataFromJson(json, itemToObjMapper)
}

let payoutEntity = EntityType.makeEntity(
  ~uri="",
  ~getObjects=getPayouts,
  ~defaultColumns,
  ~allColumns,
  ~getHeading,
  ~getCell,
  ~dataKey="",
  ~getShowLink={
    payoutData => HSwitchGlobalVars.appendDashboardPath(~url=`/payouts/${payoutData.payout_id}`)
  },
  (),
)
