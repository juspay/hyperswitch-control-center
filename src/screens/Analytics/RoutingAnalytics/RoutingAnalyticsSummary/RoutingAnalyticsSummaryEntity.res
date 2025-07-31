open RoutingAnalyticsSummaryTypes
open RoutingAnalyticsSummaryHelper
open LogicUtils

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
    Table.makeHeaderInfo(~key="traffic_percentage", ~title="Traffic Percentage")
  | NoOfPayments => Table.makeHeaderInfo(~key="no_of_payments", ~title="No. of Payments")
  | AuthorizationRate =>
    Table.makeHeaderInfo(~key="authorization_rate", ~title="Authorization Rate")
  | ProcessedAmount => Table.makeHeaderInfo(~key="processed_amount", ~title="Processed Amount")
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
  | TrafficPercentage =>
    CustomCell(
      <CustomNumeric
        num=summaryMain.traffic_percentage
        mapper=usaNumberAbbreviation
        // customStyling="ml-54-px 2xl:ml-[30px]"
        customStyling=""
      />,
      "",
    )
  | NoOfPayments =>
    CustomCell(
      <div className=""> {`${summaryMain.no_of_payments->string_of_int}`->React.string} </div>,
      "",
    )
  | AuthorizationRate =>
    CustomCell(
      <CustomNumeric
        num=summaryMain.authorization_rate
        mapper=usaNumberAbbreviation
        // customStyling="ml-8 2xl:ml-8"
        customStyling=""
      />,
      "",
    )
  | ProcessedAmount =>
    CustomCell(
      <CustomNumeric
        num=summaryMain.processed_amount
        mapper=usaNumberAbbreviation
        // customStyling="ml-4 2xl:ml-6"
        customStyling=""
      />,
      "",
    )
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
        // customStyle="!pl-6"
        // customStyle="!pl-6"
        customIconStyle="w-4 h-4 mr-2"
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
