open RoutingAnalyticsSummaryTypes
open LogicUtils
module CustomNumeric = {
  @react.component
  let make = (~num: float, ~mapper, ~customStyling) => {
    <div className={customStyling}> {React.string(num->mapper)} </div>
  }
}

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

let getSummaryMainHeading = (colType: summaryColType) => {
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
let getConnectorHeading = (colType: connectorColType) => {
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

let getSummaryMainCell = (summaryMain: summaryMain, colType: summaryColType): Table.cell => {
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
        customStyling="ml-8 2xl:ml-4"
      />,
      "",
    )
  | NoOfPayments =>
    CustomCell(
      <div className="ml-8 2xl:ml-2">
        {`${summaryMain.no_of_payments->string_of_int}`->React.string}
      </div>,
      "",
    )
  | AuthorizationRate =>
    CustomCell(
      <CustomNumeric
        num=summaryMain.authorization_rate
        mapper=usaNumberAbbreviation
        customStyling="ml-7 2xl:ml-6"
      />,
      "",
    )
  | ProcessedAmount =>
    CustomCell(
      <CustomNumeric
        num=summaryMain.processed_amount mapper=usaNumberAbbreviation customStyling="ml-7 2xl:ml-6"
      />,
      "",
    )
  }
}

let getConnectorCell = (connector: connectorDetails, colType: connectorColType): Table.cell => {
  let usaNumberAbbreviation = labelValue => {
    shortNum(~labelValue, ~numberFormat=getDefaultNumberFormat())
  }
  switch colType {
  | ConnectorName =>
    CustomCell(
      <HelperComponents.ConnectorCustomCell
        connectorName=connector.connector_name
        connectorType={ConnectorUtils.connectorTypeFromConnectorName(connector.connector_name)}
        customWidth="w-9-rem 2xl:w-15-rem"
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
    ~getObjects={
      _ => []
    },
    ~getCell=getConnectorCell,
    ~dataKey="",
  )
