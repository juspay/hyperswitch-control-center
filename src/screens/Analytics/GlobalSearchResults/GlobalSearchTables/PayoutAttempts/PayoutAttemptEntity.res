let domain = "payout_attempts"

type payoutAttemptObject = {
  payout_id: string,
  payout_attempt_id: string,
  merchant_order_reference_id: string,
  connector_payout_id: string,
  status: string,
  amount: float,
  currency: string,
  is_eligible: bool,
  connector: string,
  payout_method_id: string,
  profile_id: string,
  merchant_id: string,
  organization_id: string,
  customer_id: string,
  error_code: string,
  error_message: string,
  unified_code: string,
  unified_message: string,
  business_country: string,
  business_label: string,
  additional_payout_method_data: option<JSON.t>,
  created_at: string,
  last_modified_at: string,
}

type cols =
  | PayoutId
  | PayoutAttemptId
  | MerchantOrderReferenceId
  | ConnectorPayoutId
  | Status
  | Amount
  | Currency
  | IsEligible
  | Connector
  | PayoutMethodId
  | ProfileId
  | MerchantId
  | OrganizationId
  | CustomerId
  | ErrorCode
  | ErrorMessage
  | UnifiedCode
  | UnifiedMessage
  | BusinessCountry
  | BusinessLabel
  | AdditionalPayoutMethodData
  | CreatedAt
  | LastModifiedAt

let visibleColumns = [PayoutId, PayoutAttemptId, Status, Amount, Currency, Connector, CreatedAt]

let colMapper = (col: cols) => {
  switch col {
  | PayoutId => "payout_id"
  | PayoutAttemptId => "payout_attempt_id"
  | MerchantOrderReferenceId => "merchant_order_reference_id"
  | ConnectorPayoutId => "connector_payout_id"
  | Status => "status"
  | Amount => "amount"
  | Currency => "destination_currency"
  | IsEligible => "is_eligible"
  | Connector => "connector"
  | PayoutMethodId => "payout_method_id"
  | ProfileId => "profile_id"
  | MerchantId => "merchant_id"
  | OrganizationId => "organization_id"
  | CustomerId => "customer_id"
  | ErrorCode => "error_code"
  | ErrorMessage => "error_message"
  | UnifiedCode => "unified_code"
  | UnifiedMessage => "unified_message"
  | BusinessCountry => "business_country"
  | BusinessLabel => "business_label"
  | AdditionalPayoutMethodData => "additional_payout_method_data"
  | CreatedAt => "created_at"
  | LastModifiedAt => "last_modified_at"
  }
}

let tableItemToObjMapper: Dict.t<JSON.t> => payoutAttemptObject = dict => {
  open LogicUtils
  {
    payout_id: dict->getString(PayoutId->colMapper, "NA"),
    payout_attempt_id: dict->getString(PayoutAttemptId->colMapper, "NA"),
    merchant_order_reference_id: dict->getString(MerchantOrderReferenceId->colMapper, "NA"),
    connector_payout_id: dict->getString(ConnectorPayoutId->colMapper, "NA"),
    status: dict->getString(Status->colMapper, "NA"),
    amount: dict->getFloat(Amount->colMapper, 0.0),
    currency: dict->getString(Currency->colMapper, "NA"),
    is_eligible: dict->getBool(IsEligible->colMapper, false),
    connector: dict->getString(Connector->colMapper, "NA"),
    payout_method_id: dict->getString(PayoutMethodId->colMapper, "NA"),
    profile_id: dict->getString(ProfileId->colMapper, "NA"),
    merchant_id: dict->getString(MerchantId->colMapper, "NA"),
    organization_id: dict->getString(OrganizationId->colMapper, "NA"),
    customer_id: dict->getString(CustomerId->colMapper, "NA"),
    error_code: dict->getString(ErrorCode->colMapper, "NA"),
    error_message: dict->getString(ErrorMessage->colMapper, "NA"),
    unified_code: dict->getString(UnifiedCode->colMapper, "NA"),
    unified_message: dict->getString(UnifiedMessage->colMapper, "NA"),
    business_country: dict->getString(BusinessCountry->colMapper, "NA"),
    business_label: dict->getString(BusinessLabel->colMapper, "NA"),
    additional_payout_method_data: None,
    created_at: dict->getString(CreatedAt->colMapper, "NA"),
    last_modified_at: dict->getString(LastModifiedAt->colMapper, "NA"),
  }
}

let getObjects: JSON.t => array<payoutAttemptObject> = json => {
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
  | PayoutId => Table.makeHeaderInfo(~key, ~title="Payout ID", ~dataType=TextType)
  | PayoutAttemptId => Table.makeHeaderInfo(~key, ~title="Payout Attempt ID", ~dataType=TextType)
  | MerchantOrderReferenceId =>
    Table.makeHeaderInfo(~key, ~title="Merchant Order Reference ID", ~dataType=TextType)
  | ConnectorPayoutId =>
    Table.makeHeaderInfo(~key, ~title="Connector Payout ID", ~dataType=TextType)
  | Status => Table.makeHeaderInfo(~key, ~title="Status", ~dataType=TextType)
  | Amount => Table.makeHeaderInfo(~key, ~title="Amount", ~dataType=TextType)
  | Currency => Table.makeHeaderInfo(~key, ~title="Currency", ~dataType=TextType)
  | IsEligible => Table.makeHeaderInfo(~key, ~title="Is Eligible", ~dataType=TextType)
  | Connector => Table.makeHeaderInfo(~key, ~title="Connector", ~dataType=TextType)
  | PayoutMethodId => Table.makeHeaderInfo(~key, ~title="Payout Method ID", ~dataType=TextType)
  | ProfileId => Table.makeHeaderInfo(~key, ~title="Profile ID", ~dataType=TextType)
  | MerchantId => Table.makeHeaderInfo(~key, ~title="Merchant ID", ~dataType=TextType)
  | OrganizationId => Table.makeHeaderInfo(~key, ~title="Organization ID", ~dataType=TextType)
  | CustomerId => Table.makeHeaderInfo(~key, ~title="Customer ID", ~dataType=TextType)
  | ErrorCode => Table.makeHeaderInfo(~key, ~title="Error Code", ~dataType=TextType)
  | ErrorMessage => Table.makeHeaderInfo(~key, ~title="Error Message", ~dataType=TextType)
  | UnifiedCode => Table.makeHeaderInfo(~key, ~title="Unified Code", ~dataType=TextType)
  | UnifiedMessage => Table.makeHeaderInfo(~key, ~title="Unified Message", ~dataType=TextType)
  | BusinessCountry => Table.makeHeaderInfo(~key, ~title="Business Country", ~dataType=TextType)
  | BusinessLabel => Table.makeHeaderInfo(~key, ~title="Business Label", ~dataType=TextType)
  | AdditionalPayoutMethodData =>
    Table.makeHeaderInfo(~key, ~title="Additional Payout Method Data", ~dataType=TextType)
  | CreatedAt => Table.makeHeaderInfo(~key, ~title="Created At", ~dataType=TextType)
  | LastModifiedAt => Table.makeHeaderInfo(~key, ~title="Last Modified At", ~dataType=TextType)
  }
}

let getCell = (payoutAttemptObj, colType): Table.cell => {
  let payoutStatus = payoutAttemptObj.status->HSwitchOrderUtils.statusVariantMapper
  let conversionFactor = CurrencyUtils.getCurrencyConversionFactor(payoutAttemptObj.currency)

  switch colType {
  | PayoutId =>
    CustomCell(
      <HSwitchOrderUtils.CopyLinkTableCell
        url={`/payouts/${payoutAttemptObj.payout_id}/${payoutAttemptObj.profile_id}/${payoutAttemptObj.merchant_id}/${payoutAttemptObj.organization_id}`}
        displayValue={payoutAttemptObj.payout_id}
        copyValue={Some(payoutAttemptObj.payout_id)}
      />,
      "",
    )
  | PayoutAttemptId => Text(payoutAttemptObj.payout_attempt_id)
  | MerchantOrderReferenceId => Text(payoutAttemptObj.merchant_order_reference_id)
  | ConnectorPayoutId => Text(payoutAttemptObj.connector_payout_id)
  | Status =>
    Label({
      title: payoutAttemptObj.status->String.toUpperCase,
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
        amount={(payoutAttemptObj.amount /. conversionFactor)->Float.toString}
        currency={payoutAttemptObj.currency}
      />,
      "",
    )
  | Currency => Text(payoutAttemptObj.currency)
  | IsEligible => Text(payoutAttemptObj.is_eligible->LogicUtils.getStringFromBool)
  | Connector => Text(payoutAttemptObj.connector)
  | PayoutMethodId => Text(payoutAttemptObj.payout_method_id)
  | ProfileId => Text(payoutAttemptObj.profile_id)
  | MerchantId => Text(payoutAttemptObj.merchant_id)
  | OrganizationId => Text(payoutAttemptObj.organization_id)
  | CustomerId => Text(payoutAttemptObj.customer_id)
  | ErrorCode => Text(payoutAttemptObj.error_code)
  | ErrorMessage => Text(payoutAttemptObj.error_message)
  | UnifiedCode => Text(payoutAttemptObj.unified_code)
  | UnifiedMessage => Text(payoutAttemptObj.unified_message)
  | BusinessCountry => Text(payoutAttemptObj.business_country)
  | BusinessLabel => Text(payoutAttemptObj.business_label)
  | AdditionalPayoutMethodData => Text("N/A")
  | CreatedAt => Date(payoutAttemptObj.created_at)
  | LastModifiedAt => Text(payoutAttemptObj.last_modified_at)
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
    payoutAttempt =>
      GlobalVars.appendDashboardPath(
        ~url=`/payouts/${payoutAttempt.payout_id}/${payoutAttempt.profile_id}/${payoutAttempt.merchant_id}/${payoutAttempt.organization_id}`,
      )
  },
)
