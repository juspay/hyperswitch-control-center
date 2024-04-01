type paymentIntentObject = {
  payment_id: string,
  merchant_id: string,
  status: string,
  amount: float,
  currency: string,
  amount_captured: float,
  customer_id: string,
  description: string,
  return_url: string,
  connector_id: string,
  statement_descriptor_name: string,
  statement_descriptor_suffix: string,
  created_at: int,
  modified_at: int,
  last_synced: int,
  setup_future_usage: string,
  off_session: string,
  client_secret: string,
  active_attempt_id: string,
  business_country: string,
  business_label: string,
  attempt_count: int,
  sign_flag: int,
  timestamp: string,
}

type cols =
  | PaymentId
  | MerchantId
  | Status
  | Amount
  | Currency
  | AmountCaptured
  | CustomerId
  | Description
  | ReturnUrl
  | ConnectorId
  | StatementDescriptorName
  | StatementDescriptorSuffix
  | CreatedAt
  | ModifiedAt
  | LastSynced
  | SetupFutureUsage
  | OffSession
  | ClientSecret
  | ActiveAttemptId
  | BusinessCountry
  | BusinessLabel
  | AttemptCount
  | SignFlag
  | Timestamp

let visibleColumns = [
  PaymentId,
  MerchantId,
  Status,
  Amount,
  Currency,
  ActiveAttemptId,
  BusinessCountry,
  BusinessLabel,
  AttemptCount,
]

let colMapper = (col: cols) => {
  switch col {
  | PaymentId => "payment_id"
  | MerchantId => "merchant_id"
  | Status => "status"
  | Amount => "amount"
  | Currency => "currency"
  | AmountCaptured => "amount_captured"
  | CustomerId => "customer_id"
  | Description => "description"
  | ReturnUrl => "return_url"
  | ConnectorId => "connector_id"
  | StatementDescriptorName => "statement_descriptor_name"
  | StatementDescriptorSuffix => "statement_descriptor_suffix"
  | CreatedAt => "created_at"
  | ModifiedAt => "modified_at"
  | LastSynced => "last_synced"
  | SetupFutureUsage => "setup_future_usage"
  | OffSession => "off_session"
  | ClientSecret => "client_secret"
  | ActiveAttemptId => "active_attempt_id"
  | BusinessCountry => "business_country"
  | BusinessLabel => "business_label"
  | AttemptCount => "attempt_count"
  | SignFlag => "sign_flag"
  | Timestamp => "@timestamp"
  }
}

let tableItemToObjMapper: Dict.t<JSON.t> => paymentIntentObject = dict => {
  open LogicUtils

  {
    payment_id: dict->getString(PaymentId->colMapper, "NA"),
    merchant_id: dict->getString(MerchantId->colMapper, "NA"),
    status: dict->getString(Status->colMapper, "NA"),
    amount: dict->getFloat(Amount->colMapper, 0.0),
    currency: dict->getString(Currency->colMapper, "NA"),
    amount_captured: dict->getFloat(AmountCaptured->colMapper, 0.0),
    customer_id: dict->getString(CustomerId->colMapper, "NA"),
    description: dict->getString(Description->colMapper, "NA"),
    return_url: dict->getString(ReturnUrl->colMapper, "NA"),
    connector_id: dict->getString(ConnectorId->colMapper, "NA"),
    statement_descriptor_name: dict->getString(StatementDescriptorName->colMapper, "NA"),
    statement_descriptor_suffix: dict->getString(StatementDescriptorSuffix->colMapper, "NA"),
    created_at: dict->getInt(CreatedAt->colMapper, 0),
    modified_at: dict->getInt(ModifiedAt->colMapper, 0),
    last_synced: dict->getInt(LastSynced->colMapper, 0),
    setup_future_usage: dict->getString(SetupFutureUsage->colMapper, "NA"),
    off_session: dict->getString(OffSession->colMapper, "NA"),
    client_secret: dict->getString(ClientSecret->colMapper, "NA"),
    active_attempt_id: dict->getString(ActiveAttemptId->colMapper, "NA"),
    business_country: dict->getString(BusinessCountry->colMapper, "NA"),
    business_label: dict->getString(BusinessLabel->colMapper, "NA"),
    attempt_count: dict->getInt(AttemptCount->colMapper, 0),
    sign_flag: dict->getInt(SignFlag->colMapper, 0),
    timestamp: dict->getString(Timestamp->colMapper, "NA"),
  }
}

let getObjects: JSON.t => array<paymentIntentObject> = json => {
  open LogicUtils
  json
  ->LogicUtils.getArrayFromJson([])
  ->Array.map(item => {
    tableItemToObjMapper(item->getDictFromJsonObject)
  })
}

let getHeading = colType => {
  let key = colType->colMapper
  switch colType {
  | PaymentId =>
    Table.makeHeaderInfo(~key, ~title="Payment Id", ~dataType=TextType, ~showSort=false, ())
  | MerchantId =>
    Table.makeHeaderInfo(~key, ~title="Merchant Id", ~dataType=TextType, ~showSort=false, ())
  | Status => Table.makeHeaderInfo(~key, ~title="Status", ~dataType=TextType, ~showSort=false, ())
  | Amount => Table.makeHeaderInfo(~key, ~title="Amount", ~dataType=TextType, ~showSort=false, ())
  | Currency =>
    Table.makeHeaderInfo(~key, ~title="Currency", ~dataType=TextType, ~showSort=false, ())
  | AmountCaptured =>
    Table.makeHeaderInfo(~key, ~title="Amount Captured", ~dataType=TextType, ~showSort=false, ())
  | CustomerId =>
    Table.makeHeaderInfo(~key, ~title="Customer Id", ~dataType=TextType, ~showSort=false, ())
  | Description =>
    Table.makeHeaderInfo(~key, ~title="Description", ~dataType=TextType, ~showSort=false, ())
  | ReturnUrl =>
    Table.makeHeaderInfo(~key, ~title="Return Url", ~dataType=TextType, ~showSort=false, ())
  | ConnectorId =>
    Table.makeHeaderInfo(~key, ~title="Connector Id", ~dataType=TextType, ~showSort=false, ())
  | StatementDescriptorName =>
    Table.makeHeaderInfo(
      ~key,
      ~title="Statement Descriptor Name",
      ~dataType=TextType,
      ~showSort=false,
      (),
    )
  | StatementDescriptorSuffix =>
    Table.makeHeaderInfo(
      ~key,
      ~title="Statement Descriptor Suffix",
      ~dataType=TextType,
      ~showSort=false,
      (),
    )
  | CreatedAt =>
    Table.makeHeaderInfo(~key, ~title="Created At", ~dataType=TextType, ~showSort=false, ())
  | ModifiedAt =>
    Table.makeHeaderInfo(~key, ~title="Modified At", ~dataType=TextType, ~showSort=false, ())
  | LastSynced =>
    Table.makeHeaderInfo(~key, ~title="Last Synced", ~dataType=TextType, ~showSort=false, ())
  | SetupFutureUsage =>
    Table.makeHeaderInfo(~key, ~title="Setup Future Usage", ~dataType=TextType, ~showSort=false, ())
  | OffSession =>
    Table.makeHeaderInfo(~key, ~title="Off Session", ~dataType=TextType, ~showSort=false, ())
  | ClientSecret =>
    Table.makeHeaderInfo(~key, ~title="Client Secret", ~dataType=TextType, ~showSort=false, ())
  | ActiveAttemptId =>
    Table.makeHeaderInfo(~key, ~title="Active Attempt Id", ~dataType=TextType, ~showSort=false, ())
  | BusinessCountry =>
    Table.makeHeaderInfo(~key, ~title="Business Country", ~dataType=TextType, ~showSort=false, ())
  | BusinessLabel =>
    Table.makeHeaderInfo(~key, ~title="Business Label", ~dataType=TextType, ~showSort=false, ())
  | AttemptCount =>
    Table.makeHeaderInfo(~key, ~title="Attempt Count", ~dataType=TextType, ~showSort=false, ())
  | SignFlag =>
    Table.makeHeaderInfo(~key, ~title="Sign Flag", ~dataType=TextType, ~showSort=false, ())
  | Timestamp =>
    Table.makeHeaderInfo(~key, ~title="Time Stamp", ~dataType=TextType, ~showSort=false, ())
  }
}

let getCell = (paymentObj, colType): Table.cell => {
  let orderStatus = paymentObj.status->HSwitchOrderUtils.statusVariantMapper

  switch colType {
  | PaymentId => Text(paymentObj.payment_id)
  | MerchantId => Text(paymentObj.merchant_id)
  | Status =>
    Label({
      title: paymentObj.status->String.toUpperCase,
      color: switch orderStatus {
      | Succeeded
      | PartiallyCaptured =>
        LabelGreen
      | Failed
      | Cancelled =>
        LabelRed
      | Processing
      | RequiresCustomerAction
      | RequiresConfirmation
      | RequiresPaymentMethod =>
        LabelLightBlue
      | _ => LabelLightBlue
      },
    })
  | Amount =>
    CustomCell(
      <OrderEntity.CurrencyCell
        amount={(paymentObj.amount /. 100.0)->Float.toString} currency={paymentObj.currency}
      />,
      "",
    )
  | Currency => Text(paymentObj.currency)
  | AmountCaptured =>
    CustomCell(
      <OrderEntity.CurrencyCell
        amount={(paymentObj.amount_captured /. 100.0)->Float.toString}
        currency={paymentObj.currency}
      />,
      "",
    )
  | CustomerId => Text(paymentObj.customer_id)
  | Description => Text(paymentObj.description)
  | ReturnUrl => Text(paymentObj.return_url)
  | ConnectorId => Text(paymentObj.connector_id)
  | StatementDescriptorName => Text(paymentObj.statement_descriptor_name)
  | StatementDescriptorSuffix => Text(paymentObj.statement_descriptor_suffix)
  | CreatedAt => Text(paymentObj.created_at->Int.toString)
  | ModifiedAt => Text(paymentObj.modified_at->Int.toString)
  | LastSynced => Text(paymentObj.last_synced->Int.toString)
  | SetupFutureUsage => Text(paymentObj.setup_future_usage)
  | OffSession => Text(paymentObj.off_session)
  | ClientSecret => Text(paymentObj.client_secret)
  | ActiveAttemptId => Text(paymentObj.active_attempt_id)
  | BusinessCountry => Text(paymentObj.business_country)
  | BusinessLabel => Text(paymentObj.business_label)
  | AttemptCount => Text(paymentObj.attempt_count->Int.toString)
  | SignFlag => Text(paymentObj.sign_flag->Int.toString)
  | Timestamp => Text(paymentObj.timestamp)
  }
}

let tableEntity = EntityType.makeEntity(
  ~uri=``,
  ~getObjects,
  ~dataKey="queryData",
  ~defaultColumns=visibleColumns,
  ~requiredSearchFieldsList=[],
  ~allColumns=visibleColumns,
  ~getCell,
  ~getHeading,
  ~getShowLink={order => `/payments/${order.payment_id}`},
  (),
)
