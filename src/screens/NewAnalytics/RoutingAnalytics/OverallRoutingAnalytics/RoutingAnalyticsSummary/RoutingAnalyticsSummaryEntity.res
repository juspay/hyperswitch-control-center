open RoutingAnalyticsSummaryTypes
open LogicUtils
open CurrencyFormatUtils

let summaryMainColumns = [
  RoutingLogic,
  TrafficPercentage,
  NoOfPayments,
  AuthorizationRate,
  ProcessedAmount,
]
let connectorCols = [
  ConnectorName,
  TrafficPercentage,
  NoOfPayments,
  AuthorizationRate,
  ProcessedAmount,
]

let getSummaryMainHeading = colType => {
  switch colType {
  | RoutingLogic => Table.makeHeaderInfo(~key="routing_logic", ~title="Routing Logic")
  | TrafficPercentage =>
    Table.makeHeaderInfo(~key="traffic_percentage", ~title="Traffic Percentage (%)")
  | NoOfPayments => Table.makeHeaderInfo(~key="no_of_payments", ~title="No. of Payments")
  | AuthorizationRate =>
    Table.makeHeaderInfo(~key="authorization_rate", ~title="Authorization Rate (%)")
  | ProcessedAmount => Table.makeHeaderInfo(~key="processed_amount", ~title="Processed Amount ($)")
  }
}
let getConnectorHeading = colType => {
  switch colType {
  | ConnectorName => Table.makeHeaderInfo(~key="connector_name", ~title="Connector Name")
  | TrafficPercentage =>
    Table.makeHeaderInfo(~key="traffic_percentage", ~title="Traffic Percentage(%)")
  | NoOfPayments => Table.makeHeaderInfo(~key="no_of_payments", ~title="No. of Payments")
  | AuthorizationRate =>
    Table.makeHeaderInfo(~key="authorization_rate", ~title="Authorization Rate(%)")
  | ProcessedAmount => Table.makeHeaderInfo(~key="processed_amount", ~title="Processed Amount")
  }
}

let getSummaryMainCell = (summaryMain, colType): Table.cell => {
  let usaNumberAbbreviation = labelValue => {
    shortNum(~labelValue, ~numberFormat=getDefaultNumberFormat())
  }
  switch colType {
  | RoutingLogic => Text(summaryMain.routing_logic->snakeToTitle)
  | TrafficPercentage => Numeric(summaryMain.traffic_percentage, usaNumberAbbreviation)
  | NoOfPayments => Text(summaryMain.no_of_payments->string_of_int)
  | AuthorizationRate => Numeric(summaryMain.authorization_rate, usaNumberAbbreviation)
  | ProcessedAmount => Numeric(summaryMain.processed_amount, usaNumberAbbreviation)
  }
}

let getConnectorCell = (connector, colType): Table.cell => {
  let usaNumberAbbreviation = labelValue => {
    shortNum(~labelValue, ~numberFormat=getDefaultNumberFormat())
  }
  switch colType {
  | ConnectorName =>
    CustomCell(
      <HelperComponents.ConnectorCustomCell
        connectorName=connector.connector_name
        connectorType={ConnectorUtils.connectorTypeFromConnectorName(connector.connector_name)}
        customIconStyle="w-4 h-4 mx-3"
      />,
      "",
    )
  | TrafficPercentage => Numeric(connector.traffic_percentage, usaNumberAbbreviation)
  | NoOfPayments => Text(connector.no_of_payments->string_of_int)
  | AuthorizationRate => Numeric(connector.authorization_rate, usaNumberAbbreviation)
  | ProcessedAmount => Numeric(connector.processed_amount, usaNumberAbbreviation)
  }
}

let connectorEntity = () =>
  EntityType.makeEntity(
    ~uri=``,
    ~defaultColumns={connectorCols},
    ~allColumns={connectorCols},
    ~getHeading=getConnectorHeading,
    ~getObjects=_ => [],
    ~getCell=getConnectorCell,
    ~dataKey="",
  )
