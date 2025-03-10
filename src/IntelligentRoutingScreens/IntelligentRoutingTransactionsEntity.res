open LogicUtils
open IntelligentRoutingTypes

type cols =
  | PaymentID
  | PaymentMethodType
  | CardNetwork
  | TaxAmount
  | Status
  | ActualGateway
  | SuggestedGateway
  | SuccessRateUplift
  | LastUpdated

let defaultColumns = [
  PaymentID,
  PaymentMethodType,
  CardNetwork,
  TaxAmount,
  Status,
  ActualGateway,
  SuggestedGateway,
  SuccessRateUplift,
  LastUpdated,
]
let getHeading = colType => {
  switch colType {
  | PaymentID => Table.makeHeaderInfo(~key="txn_no", ~title="Payment ID")
  | PaymentMethodType =>
    Table.makeHeaderInfo(~key="payment_method_type", ~title="Payment Method Type")
  | CardNetwork => Table.makeHeaderInfo(~key="card_network", ~title="Card Network")
  | TaxAmount => Table.makeHeaderInfo(~key="tax_amount", ~title="Tax Amount")
  | Status => Table.makeHeaderInfo(~key="payment_status", ~title="Status")
  | ActualGateway => Table.makeHeaderInfo(~key="payment_gateway", ~title="Actual Gateway")
  | SuggestedGateway => Table.makeHeaderInfo(~key="model_connector", ~title="Suggested Gateway")
  | SuccessRateUplift => Table.makeHeaderInfo(~key="suggested_uplift", ~title="Success Rate Uplift")
  | LastUpdated => Table.makeHeaderInfo(~key="last_updated", ~title="Last Updated")
  }
}

let getCell = (~transactionsData: transactionDetails, colType): Table.cell => {
  switch colType {
  | PaymentID => Text(transactionsData.order_id)
  | PaymentMethodType => Text(transactionsData.payment_method_type)
  | CardNetwork => Text(transactionsData.payment_gateway)
  | TaxAmount => Text(transactionsData.amount->Float.toString)
  | Status =>
    transactionsData.payment_status
      ? Label({
          title: "Success"->String.toUpperCase,
          color: LabelGreen,
        })
      : Label({
          title: "Failed"->String.toUpperCase,
          color: LabelRed,
        })
  | ActualGateway =>
    CustomCell(
      <HelperComponents.ConnectorCustomCell connectorName=transactionsData.payment_gateway />,
      "",
    )
  | SuggestedGateway =>
    CustomCell(
      <HelperComponents.ConnectorCustomCell connectorName=transactionsData.model_connector />,
      "",
    )
  | SuccessRateUplift =>
    CustomCell(
      <div className="flex gap-1 text-green-500">
        <Icon name="nd-arrow-up-no-underline" size=10 />
        <p> {transactionsData.suggested_uplift->Float.toString->React.string} </p>
        <Icon name="percent" size=10 />
      </div>,
      "",
    )
  | LastUpdated => Text("Feb25,2025_04:15PMIST")
  }
}

let itemToObjectMapper = dict => {
  {
    txn_no: dict->getInt("txn_no", 0),
    order_id: dict->getString("order_id", ""),
    juspay_txn_id: dict->getString("juspay_txn_id", ""),
    amount: dict->getFloat("amount", 0.0),
    payment_gateway: dict->getString("payment_gateway", ""),
    payment_status: dict->getBool("payment_status", false),
    payment_method_type: dict->getString("payment_method_type", ""),
    order_currency: dict->getString("order_currency", ""),
    model_connector: dict->getString("model_connector", ""),
    suggested_uplift: dict->getFloat("suggested_uplift", 0.0),
  }
}

let getTransactionsData: JSON.t => array<transactionDetails> = json => {
  getArrayDataFromJson(json, itemToObjectMapper)
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
