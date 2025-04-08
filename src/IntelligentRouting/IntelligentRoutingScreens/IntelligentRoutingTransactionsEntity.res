open LogicUtils
open IntelligentRoutingTypes

type cols =
  | PaymentID
  | PaymentMethodType
  | TxnAmount
  | Status
  | CardNetwork
  | ActualGateway
  | SuggestedGateway
  | SuccessRateUplift
  | CreatedAt

let defaultColumns = [
  PaymentID,
  PaymentMethodType,
  CardNetwork,
  TxnAmount,
  Status,
  ActualGateway,
  SuggestedGateway,
  SuccessRateUplift,
  CreatedAt,
]

let getHeading = colType => {
  switch colType {
  | PaymentID => Table.makeHeaderInfo(~key="txn_no", ~title="Payment ID")
  | PaymentMethodType =>
    Table.makeHeaderInfo(~key="payment_method_type", ~title="Payment Method Type")
  | CardNetwork => Table.makeHeaderInfo(~key="card_network", ~title="Card Network")
  | TxnAmount => Table.makeHeaderInfo(~key="tax_amount", ~title="Txn Amount ($)")
  | Status => Table.makeHeaderInfo(~key="payment_status", ~title="Status")
  | ActualGateway => Table.makeHeaderInfo(~key="payment_gateway", ~title="Actual Gateway")
  | SuggestedGateway => Table.makeHeaderInfo(~key="model_connector", ~title="Suggested Gateway")
  | SuccessRateUplift => Table.makeHeaderInfo(~key="suggested_uplift", ~title="Auth Rate Uplift")
  | CreatedAt => Table.makeHeaderInfo(~key="last_updated", ~title="Timestamp")
  }
}

module CurrencyCell = {
  @react.component
  let make = (~amount, ~currency) => {
    <p className="whitespace-nowrap"> {`${amount} ${currency}`->React.string} </p>
  }
}

module UpliftCell = {
  @react.component
  let make = (~uplift: float) => {
    let upliftClass = uplift > 0.0 ? "text-green-500" : ""
    let icon = uplift > 0.0 ? "nd-arrow-up-no-underline" : ""

    let upliftAmount = uplift > 0.0 ? uplift->Float.toString : "-"

    <div className={`flex gap-1 ${upliftClass}`}>
      <Icon name={icon} size=10 />
      <p> {upliftAmount->React.string} </p>
      <RenderIf condition={uplift > 0.0}>
        <Icon name="percent" size=10 />
      </RenderIf>
    </div>
  }
}

let getCell = (~transactionsData: transactionObj, colType): Table.cell => {
  switch colType {
  | PaymentID =>
    CustomCell(
      <HelperComponents.EllipsisText displayValue={transactionsData.payment_attempt_id} />,
      "",
    )
  | PaymentMethodType => Text(transactionsData.payment_method_type->LogicUtils.getTitle)
  | CardNetwork => Text(transactionsData.card_network)
  | TxnAmount => Text(transactionsData.amount->Float.toString)
  | Status =>
    Label({
      title: transactionsData.payment_status ? "Success" : "Failed",
      color: transactionsData.payment_status ? LabelGreen : LabelRed,
    })
  | ActualGateway => Text(transactionsData.payment_gateway)
  | SuggestedGateway => Text(transactionsData.model_connector)
  | SuccessRateUplift => CustomCell(<UpliftCell uplift=transactionsData.suggested_uplift />, "")
  | CreatedAt => DateWithCustomDateStyle(transactionsData.created_at, "MMM DD, YYYY hh:mm:ss A")
  }
}

let itemToObjectMapper = dict => {
  {
    txn_no: dict->getInt("txn_no", 0),
    payment_intent_id: dict->getString("payment_intent_id", ""),
    payment_attempt_id: dict->getString("payment_attempt_id", ""),
    amount: dict->getFloat("amount", 0.0),
    payment_gateway: dict->getString("payment_gateway", ""),
    payment_status: dict->getBool("payment_status", false),
    card_network: dict->getString("card_network", ""),
    payment_method_type: dict->getString("payment_method_type", ""),
    order_currency: dict->getString("order_currency", ""),
    model_connector: dict->getString("model_connector", ""),
    suggested_uplift: dict->getFloat("suggested_uplift", 0.0),
    created_at: dict->getString("created_at", ""),
  }
}

let getTransactionsData: JSON.t => array<transactionObj> = json => {
  let dict = json->getDictFromJsonObject
  let simulatorOutcome = dict->getArrayFromDict("simulation_outcome_of_each_txn", [])
  getArrayDataFromJson(simulatorOutcome->JSON.Encode.array, itemToObjectMapper)
}

let transactionDetailsEntity = () => {
  EntityType.makeEntity(
    ~uri=``,
    ~getObjects=getTransactionsData,
    ~defaultColumns,
    ~getHeading,
    ~getCell=(transactionDetails, cols) => getCell(~transactionsData=transactionDetails, cols),
    ~dataKey="",
  )
}
