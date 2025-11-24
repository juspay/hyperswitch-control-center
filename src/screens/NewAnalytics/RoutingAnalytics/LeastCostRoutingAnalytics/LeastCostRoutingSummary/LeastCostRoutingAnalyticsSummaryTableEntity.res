open CurrencyFormatUtils

let summaryCols: array<LeastCostRoutingAnalyticsSummaryTableTypes.summaryColType> = [
  SignatureBrand,
  CardNetwork,
  TrafficPercentage,
  DebitRoutedTransactionCount,
  RegulatedTransactionPercentage,
  UnregulatedTransactionPercentage,
  DebitRoutingSavings,
]

let getSummaryMainHeading = (
  colType: LeastCostRoutingAnalyticsSummaryTableTypes.summaryColType,
) => {
  switch colType {
  | SignatureBrand => Table.makeHeaderInfo(~key="signature_brand", ~title="Signature Brand")
  | CardNetwork => Table.makeHeaderInfo(~key="card_network", ~title="Card Network")
  | TrafficPercentage =>
    Table.makeHeaderInfo(~key="traffic_percentage", ~title="Traffic Percentage (%)")
  | DebitRoutedTransactionCount =>
    Table.makeHeaderInfo(
      ~key="debit_routed_transaction_count",
      ~title="Debit Routed Transaction Count",
    )
  | RegulatedTransactionPercentage =>
    Table.makeHeaderInfo(
      ~key="regulated_transaction_percentage",
      ~title="Regulated Transaction Percentage (%)",
    )
  | UnregulatedTransactionPercentage =>
    Table.makeHeaderInfo(
      ~key="unregulated_transaction_percentage",
      ~title="Unregulated Transaction Percentage (%)",
    )
  | DebitRoutingSavings =>
    Table.makeHeaderInfo(~key="debit_routing_savings", ~title="Debit Routing Savings ($)")
  }
}

let getSummaryMainCell = (
  summaryMain: LeastCostRoutingAnalyticsSummaryTableTypes.summaryMain,
  colType: LeastCostRoutingAnalyticsSummaryTableTypes.summaryColType,
): Table.cell => {
  let usaNumberAbbreviation = labelValue => {
    shortNum(~labelValue, ~numberFormat=getDefaultNumberFormat())
  }
  switch colType {
  | SignatureBrand =>
    CustomCell(
      LeastCostRoutingAnalyticsSummaryTableHelper.paymentMethodCell(summaryMain.signature_network),
      "",
    )
  | CardNetwork =>
    CustomCell(
      LeastCostRoutingAnalyticsSummaryTableHelper.paymentMethodCell(summaryMain.card_network),
      "",
    )
  | TrafficPercentage => Numeric(summaryMain.traffic_percentage, usaNumberAbbreviation)
  | DebitRoutedTransactionCount => Text(summaryMain.debit_routed_transaction_count->string_of_int)
  | RegulatedTransactionPercentage =>
    Numeric(summaryMain.regulated_transaction_percentage, usaNumberAbbreviation)
  | UnregulatedTransactionPercentage =>
    Numeric(summaryMain.unregulated_transaction_percentage, usaNumberAbbreviation)
  | DebitRoutingSavings => Numeric(summaryMain.debit_routing_savings, usaNumberAbbreviation)
  }
}

let summaryEntity = () => {
  EntityType.makeEntity(
    ~uri=``,
    ~defaultColumns={summaryCols},
    ~allColumns={summaryCols},
    ~getHeading=getSummaryMainHeading,
    ~getObjects=_ => [],
    ~getCell=getSummaryMainCell,
    ~dataKey="",
  )
}
