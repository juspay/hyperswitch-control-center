let domain = "payouts"

type payoutsObject = {
  payout_id: string,
  payout_attempt_id: string,
  payout_link_id: string,
  merchant_order_reference_id: string,
  connector_payout_id: string,
  status: string,
  amount: float,
  source_currency: string,
  destination_currency: string,
  payout_type: string,
  confirm: bool,
  attempt_count: int,
  is_eligible: bool,
  connector: string,
  payout_method_id: string,
  profile_id: string,
  merchant_id: string,
  organization_id: string,
  customer_id: string,
  recurring: bool,
  auto_fulfill: bool,
  priority: string,
  description: string,
  error_code: string,
  error_message: string,
  unified_code: string,
  unified_message: string,
  business_country: string,
  business_label: string,
  entity_type: string,
  created_at: float,
  last_modified_at: float,
  additional_payout_method_data: JSON.t,
  metadata: JSON.t,
}

type cols =
  | PayoutId
  | PayoutAttemptId
  | PayoutLinkId
  | MerchantOrderReferenceId
  | ConnectorPayoutId
  | Status
  | Amount
  | SourceCurrency
  | DestinationCurrency
  | PayoutType
  | Confirm
  | AttemptCount
  | IsEligible
  | Connector
  | PayoutMethodId
  | ProfileId
  | MerchantId
  | OrganizationId
  | CustomerId
  | Recurring
  | AutoFulfill
  | Priority
  | Description
  | ErrorCode
  | ErrorMessage
  | UnifiedCode
  | UnifiedMessage
  | BusinessCountry
  | BusinessLabel
  | EntityType
  | CreatedAt
  | LastModifiedAt
  | AdditionalPayoutMethodData
  | Metadata

let visibleColumns = [
  PayoutId,
  PayoutAttemptId,
  Amount,
  DestinationCurrency,
  Status,
  Connector,
  CreatedAt,
]

let colMapper = (col: cols) => {
  switch col {
  | PayoutId => "payout_id"
  | PayoutAttemptId => "payout_attempt_id"
  | PayoutLinkId => "payout_link_id"
  | MerchantOrderReferenceId => "merchant_order_reference_id"
  | ConnectorPayoutId => "connector_payout_id"
  | Status => "status"
  | Amount => "amount"
  | SourceCurrency => "source_currency"
  | DestinationCurrency => "destination_currency"
  | PayoutType => "payout_type"
  | Confirm => "confirm"
  | AttemptCount => "attempt_count"
  | IsEligible => "is_eligible"
  | Connector => "connector"
  | PayoutMethodId => "payout_method_id"
  | ProfileId => "profile_id"
  | MerchantId => "merchant_id"
  | OrganizationId => "organization_id"
  | CustomerId => "customer_id"
  | Recurring => "recurring"
  | AutoFulfill => "auto_fulfill"
  | Priority => "priority"
  | Description => "description"
  | ErrorCode => "error_code"
  | ErrorMessage => "error_message"
  | UnifiedCode => "unified_code"
  | UnifiedMessage => "unified_message"
  | BusinessCountry => "business_country"
  | BusinessLabel => "business_label"
  | EntityType => "entity_type"
  | CreatedAt => "created_at"
  | LastModifiedAt => "last_modified_at"
  | AdditionalPayoutMethodData => "additional_payout_method_data"
  | Metadata => "metadata"
  }
}

let tableItemToObjMapper: Dict.t<JSON.t> => payoutsObject = dict => {
  open LogicUtils
  {
    payout_id: dict->getString(PayoutId->colMapper, "NA"),
    payout_attempt_id: dict->getString(PayoutAttemptId->colMapper, "NA"),
    payout_link_id: dict->getString(PayoutLinkId->colMapper, "NA"),
    merchant_order_reference_id: dict->getString(MerchantOrderReferenceId->colMapper, "NA"),
    connector_payout_id: dict->getString(ConnectorPayoutId->colMapper, "NA"),
    status: dict->getString(Status->colMapper, "NA"),
    amount: dict->getFloat(Amount->colMapper, 0.0),
    source_currency: dict->getString(SourceCurrency->colMapper, "NA"),
    destination_currency: dict->getString(DestinationCurrency->colMapper, "NA"),
    payout_type: dict->getString(PayoutType->colMapper, "NA"),
    confirm: dict->getBool(Confirm->colMapper, false),
    attempt_count: dict->getInt(AttemptCount->colMapper, 0),
    is_eligible: dict->getBool(IsEligible->colMapper, false),
    connector: dict->getString(Connector->colMapper, "NA"),
    payout_method_id: dict->getString(PayoutMethodId->colMapper, "NA"),
    profile_id: dict->getString(ProfileId->colMapper, "NA"),
    merchant_id: dict->getString(MerchantId->colMapper, "NA"),
    organization_id: dict->getString(OrganizationId->colMapper, "NA"),
    customer_id: dict->getString(CustomerId->colMapper, "NA"),
    recurring: dict->getBool(Recurring->colMapper, false),
    auto_fulfill: dict->getBool(AutoFulfill->colMapper, false),
    priority: dict->getString(Priority->colMapper, "NA"),
    description: dict->getString(Description->colMapper, "NA"),
    error_code: dict->getString(ErrorCode->colMapper, "NA"),
    error_message: dict->getString(ErrorMessage->colMapper, "NA"),
    unified_code: dict->getString(UnifiedCode->colMapper, "NA"),
    unified_message: dict->getString(UnifiedMessage->colMapper, "NA"),
    business_country: dict->getString(BusinessCountry->colMapper, "NA"),
    business_label: dict->getString(BusinessLabel->colMapper, "NA"),
    entity_type: dict->getString(EntityType->colMapper, "NA"),
    created_at: dict->getFloat(CreatedAt->colMapper, 0.0),
    last_modified_at: dict->getFloat(LastModifiedAt->colMapper, 0.0),
    additional_payout_method_data: dict->getJsonObjectFromDict(
      AdditionalPayoutMethodData->colMapper,
    ),
    metadata: dict->getJsonObjectFromDict(Metadata->colMapper),
  }
}

let getObjects: JSON.t => array<payoutsObject> = json => {
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
  | PayoutId => Table.makeHeaderInfo(~key, ~title="Payout Id", ~dataType=TextType)
  | PayoutAttemptId => Table.makeHeaderInfo(~key, ~title="Payout Attempt Id", ~dataType=TextType)
  | PayoutLinkId => Table.makeHeaderInfo(~key, ~title="Payout Link Id", ~dataType=TextType)
  | MerchantOrderReferenceId =>
    Table.makeHeaderInfo(~key, ~title="Merchant Order Reference Id", ~dataType=TextType)
  | ConnectorPayoutId =>
    Table.makeHeaderInfo(~key, ~title="Connector Payout Id", ~dataType=TextType)
  | Status => Table.makeHeaderInfo(~key, ~title="Status", ~dataType=TextType)
  | Amount => Table.makeHeaderInfo(~key, ~title="Amount", ~dataType=TextType)
  | SourceCurrency => Table.makeHeaderInfo(~key, ~title="Source Currency", ~dataType=TextType)
  | DestinationCurrency =>
    Table.makeHeaderInfo(~key, ~title="Destination Currency", ~dataType=TextType)
  | PayoutType => Table.makeHeaderInfo(~key, ~title="Payout Type", ~dataType=TextType)
  | Confirm => Table.makeHeaderInfo(~key, ~title="Confirm", ~dataType=TextType)
  | AttemptCount => Table.makeHeaderInfo(~key, ~title="Attempt Count", ~dataType=TextType)
  | IsEligible => Table.makeHeaderInfo(~key, ~title="Is Eligible", ~dataType=TextType)
  | Connector => Table.makeHeaderInfo(~key, ~title="Connector", ~dataType=TextType)
  | PayoutMethodId => Table.makeHeaderInfo(~key, ~title="Payout Method Id", ~dataType=TextType)
  | ProfileId => Table.makeHeaderInfo(~key, ~title="Profile Id", ~dataType=TextType)
  | MerchantId => Table.makeHeaderInfo(~key, ~title="Merchant Id", ~dataType=TextType)
  | OrganizationId => Table.makeHeaderInfo(~key, ~title="Organization Id", ~dataType=TextType)
  | CustomerId => Table.makeHeaderInfo(~key, ~title="Customer Id", ~dataType=TextType)
  | Recurring => Table.makeHeaderInfo(~key, ~title="Recurring", ~dataType=TextType)
  | AutoFulfill => Table.makeHeaderInfo(~key, ~title="Auto Fulfill", ~dataType=TextType)
  | Priority => Table.makeHeaderInfo(~key, ~title="Priority", ~dataType=TextType)
  | Description => Table.makeHeaderInfo(~key, ~title="Description", ~dataType=TextType)
  | ErrorCode => Table.makeHeaderInfo(~key, ~title="Error Code", ~dataType=TextType)
  | ErrorMessage => Table.makeHeaderInfo(~key, ~title="Error Message", ~dataType=TextType)
  | UnifiedCode => Table.makeHeaderInfo(~key, ~title="Unified Code", ~dataType=TextType)
  | UnifiedMessage => Table.makeHeaderInfo(~key, ~title="Unified Message", ~dataType=TextType)
  | BusinessCountry => Table.makeHeaderInfo(~key, ~title="Business Country", ~dataType=TextType)
  | BusinessLabel => Table.makeHeaderInfo(~key, ~title="Business Label", ~dataType=TextType)
  | EntityType => Table.makeHeaderInfo(~key, ~title="Entity Type", ~dataType=TextType)
  | CreatedAt => Table.makeHeaderInfo(~key, ~title="Created At", ~dataType=TextType)
  | LastModifiedAt => Table.makeHeaderInfo(~key, ~title="Last Modified At", ~dataType=TextType)
  | AdditionalPayoutMethodData =>
    Table.makeHeaderInfo(~key, ~title="Additional Payout Method Data", ~dataType=TextType)
  | Metadata => Table.makeHeaderInfo(~key, ~title="Metadata", ~dataType=TextType)
  }
}

let getCell = (payoutObj: payoutsObject, colType): Table.cell => {
  let payoutStatus = payoutObj.status->HSwitchOrderUtils.statusVariantMapper
  let conversionFactor = CurrencyUtils.getCurrencyConversionFactor(payoutObj.destination_currency)

  switch colType {
  | PayoutId =>
    CustomCell(
      <HSwitchOrderUtils.CopyLinkTableCell
        url={`/payouts/${payoutObj.payout_id}/${payoutObj.profile_id}/${payoutObj.merchant_id}/${payoutObj.organization_id}`}
        displayValue={payoutObj.payout_id}
        copyValue={Some(payoutObj.payout_id)}
      />,
      payoutObj.payout_id,
    )
  | PayoutAttemptId => Text(payoutObj.payout_attempt_id)
  | PayoutLinkId => Text(payoutObj.payout_link_id)
  | MerchantOrderReferenceId => Text(payoutObj.merchant_order_reference_id)
  | ConnectorPayoutId => Text(payoutObj.connector_payout_id)
  | Status =>
    Label({
      title: payoutObj.status->String.toUpperCase,
      color: switch payoutStatus {
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
        LabelBlue
      | _ => LabelLightGray
      },
    })
  | Amount =>
    CustomCell(
      <OrderEntity.CurrencyCell
        amount={(payoutObj.amount /. conversionFactor)->Float.toString}
        currency={payoutObj.destination_currency}
      />,
      (payoutObj.amount /. conversionFactor)->Float.toString,
    )
  | SourceCurrency => Text(payoutObj.source_currency)
  | DestinationCurrency => Text(payoutObj.destination_currency)
  | PayoutType => Text(payoutObj.payout_type)
  | Confirm => Text(payoutObj.confirm->LogicUtils.getStringFromBool)
  | AttemptCount => Text(payoutObj.attempt_count->Int.toString)
  | IsEligible => Text(payoutObj.is_eligible->LogicUtils.getStringFromBool)
  | Connector => Text(payoutObj.connector)
  | PayoutMethodId => Text(payoutObj.payout_method_id)
  | ProfileId => Text(payoutObj.profile_id)
  | MerchantId => Text(payoutObj.merchant_id)
  | OrganizationId => Text(payoutObj.organization_id)
  | CustomerId => Text(payoutObj.customer_id)
  | Recurring => Text(payoutObj.recurring->LogicUtils.getStringFromBool)
  | AutoFulfill => Text(payoutObj.auto_fulfill->LogicUtils.getStringFromBool)
  | Priority => Text(payoutObj.priority)
  | Description => Text(payoutObj.description)
  | ErrorCode => Text(payoutObj.error_code)
  | ErrorMessage => Text(payoutObj.error_message)
  | UnifiedCode => Text(payoutObj.unified_code)
  | UnifiedMessage => Text(payoutObj.unified_message)
  | BusinessCountry => Text(payoutObj.business_country)
  | BusinessLabel => Text(payoutObj.business_label)
  | EntityType => Text(payoutObj.entity_type)
  | CreatedAt => Date(payoutObj.created_at->DateTimeUtils.unixToISOString)
  | LastModifiedAt => Date(payoutObj.last_modified_at->DateTimeUtils.unixToISOString)
  | AdditionalPayoutMethodData => Text(payoutObj.additional_payout_method_data->JSON.stringify)

  | Metadata => Text(payoutObj.metadata->JSON.stringify)
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
  ~getShowLink={
    payout =>
      GlobalVars.appendDashboardPath(
        ~url=`/payouts/${payout.payout_id}/${payout.profile_id}/${payout.merchant_id}/${payout.organization_id}`,
      )
  },
)

let getColFromKey = (key: string): option<cols> => {
  switch key {
  | "payout_id" => Some(PayoutId)
  | "payout_attempt_id" => Some(PayoutAttemptId)
  | "connector_payout_id" => Some(ConnectorPayoutId)
  | "status" => Some(Status)
  | "amount" => Some(Amount)
  | "source_currency" => Some(SourceCurrency)
  | "destination_currency" => Some(DestinationCurrency)
  | "payout_type" => Some(PayoutType)
  | "attempt_count" => Some(AttemptCount)
  | "is_eligible" => Some(IsEligible)
  | "connector" => Some(Connector)
  | "payout_method_id" => Some(PayoutMethodId)
  | "profile_id" => Some(ProfileId)
  | "merchant_id" => Some(MerchantId)
  | "organization_id" => Some(OrganizationId)
  | "customer_id" => Some(CustomerId)
  | "recurring" => Some(Recurring)
  | "auto_fulfill" => Some(AutoFulfill)
  | "priority" => Some(Priority)
  | "description" => Some(Description)
  | "error_code" => Some(ErrorCode)
  | "error_message" => Some(ErrorMessage)
  | "business_country" => Some(BusinessCountry)
  | "business_label" => Some(BusinessLabel)
  | "entity_type" => Some(EntityType)
  | "created_at" => Some(CreatedAt)
  | "last_modified_at" => Some(LastModifiedAt)
  | "metadata" => Some(Metadata)
  | _ => None
  }
}

let allColumns = [
  PayoutId,
  PayoutAttemptId,
  ConnectorPayoutId,
  Status,
  Amount,
  SourceCurrency,
  DestinationCurrency,
  PayoutType,
  AttemptCount,
  IsEligible,
  Connector,
  PayoutMethodId,
  ProfileId,
  MerchantId,
  OrganizationId,
  CustomerId,
  Recurring,
  AutoFulfill,
  Priority,
  Description,
  ErrorCode,
  ErrorMessage,
  BusinessCountry,
  BusinessLabel,
  EntityType,
  CreatedAt,
  LastModifiedAt,
  Metadata,
]

let csvHeaders = allColumns->Array.map(col => {
  let {key, title} = col->getHeading
  (key, title)
})

let itemToCSVMapping = (obj: payoutsObject): JSON.t => {
  allColumns
  ->Array.reduce(Dict.make(), (dict, col) => {
    let {key} = col->getHeading
    let value = obj->getCell(col)->TableUtils.getTableCellValue
    dict->Dict.set(key, value->JSON.Encode.string)
    dict
  })
  ->JSON.Encode.object
}
