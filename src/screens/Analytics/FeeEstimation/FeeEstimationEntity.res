open ConnectorTypes

type colType =
  | PaymentID
  | CardType
  | TransactionValue
  | CardBrand
  | TotalCostIncurred

type overviewColType =
  | FeeName
  | TotalCostIncurred
  | TotalTransactions
  | TypeOfFees
  | CostContribution

type feesBreakdown = FeeType | Rate | TotalCost

let defaultColumns = [PaymentID, CardType, TransactionValue, CardBrand, TotalCostIncurred]

let overviewDefaultColumns = [
  FeeName,
  TotalCostIncurred,
  TotalTransactions,
  TypeOfFees,
  CostContribution,
]

let getHeading = colType => {
  switch colType {
  | PaymentID => Table.makeHeaderInfo(~key="payment_ID", ~title="Payment ID")
  | CardType => Table.makeHeaderInfo(~key="card_type", ~title="Card Type")
  | TransactionValue => Table.makeHeaderInfo(~key="transaction_value", ~title="Transaction Value")
  | CardBrand => Table.makeHeaderInfo(~key="card_brand", ~title="Card Brand")
  | TotalCostIncurred =>
    Table.makeHeaderInfo(~key="total_cost_incurred", ~title="Total Cost Incurred")
  }
}

let getOverviewHeading = overviewColType => {
  switch overviewColType {
  | FeeName => Table.makeHeaderInfo(~key="fee_name", ~title="Fee Name")
  | TotalCostIncurred =>
    Table.makeHeaderInfo(~key="total_cost_incurred", ~title="Total Cost Incurred")
  | TotalTransactions =>
    Table.makeHeaderInfo(~key="total_transactions", ~title="Total Transactions")
  | TypeOfFees => Table.makeHeaderInfo(~key="type_of_fees", ~title="Type Of Fees")
  | CostContribution => Table.makeHeaderInfo(~key="cost_contribution", ~title="Cost Contribution")
  }
}

let getAllPaymentMethods = (paymentMethodsArray: array<paymentMethodEnabledTypeCommon>) => {
  let paymentMethods = paymentMethodsArray->Array.reduce([], (acc, item) => {
    acc->Array.concat([item.payment_method_type->LogicUtils.capitalizeString])
  })
  paymentMethods
}

let connectorStatusStyle = connectorStatus =>
  switch connectorStatus->String.toLowerCase {
  | "active" => "text-green-700"
  | _ => "text-grey-800 opacity-50"
  }

let getTableCell = () => {
  let getCell = (feeEstimationData: FeeEstimationTypes.breakdownItem, colType): Table.cell => {
    switch colType {
    | PaymentID =>
      Table.CustomCell(
        <div>
          <p className="text-sm text-nd_gray-600 font-medium">
            {feeEstimationData.paymentId->React.string}
          </p>
        </div>,
        "",
      )
    | CardType =>
      Label({
        title: feeEstimationData.fundingSource->LogicUtils.camelCaseToTitle,
        color: switch feeEstimationData.fundingSource {
        | "credit" => LabelOrange
        | _ => LabelBlue
        },
      })
    | TransactionValue =>
      Table.CustomCell(
        <p className="text-sm text-nd_gray-600 font-medium">
          {`${feeEstimationData.transactionCurrency} ${LogicUtils.valueFormatter(
              feeEstimationData.gross,
              Amount,
            )}`->React.string}
        </p>,
        "",
      )
    | CardBrand =>
      Table.CustomCell(
        <div className="flex items-center !justify-between gap-2">
          <GatewayIcon
            gateway={feeEstimationData.cardBrand->String.toUpperCase}
            className="w-6 h-6 p-1 px-0.5 rounded-md bg-nd_gray-25 border border-nd_br_gray-150"
          />
          <p className="text-sm font-medium text-nd_gray-600">
            {feeEstimationData.cardBrand->LogicUtils.camelCaseToTitle->React.string}
          </p>
        </div>,
        "",
      )
    | TotalCostIncurred =>
      Table.CustomCell(
        <p className="text-sm text-nd_gray-600 font-medium">
          {`${feeEstimationData.transactionCurrency} ${LogicUtils.valueFormatter(
              feeEstimationData.totalCost,
              Amount,
            )}`->React.string}
        </p>,
        "",
      )
    }
  }
  getCell
}

let getOverviewTableCell = () => {
  let getCell = (
    feeEstimationData: FeeEstimationTypes.overViewFeesBreakdown,
    colType: overviewColType,
  ): Table.cell => {
    switch colType {
    | FeeName =>
      Table.CustomCell(
        <div>
          <p className="text-sm text-nd_gray-600 font-medium">
            {feeEstimationData.feeName->React.string}
          </p>
        </div>,
        "",
      )
    | TotalTransactions =>
      Table.CustomCell(
        <Table.TableCell
          cell={CustomCell(
            <div>
              <p className="text-sm text-nd_gray-600 font-medium">
                {LogicUtils.valueFormatter(
                  feeEstimationData.transactionCount->Int.toFloat,
                  Amount,
                )->React.string}
              </p>
            </div>,
            "",
          )}
          textAlign=Table.Left
          labelMargin="!py-0"
        />,
        "",
      )
    | TotalCostIncurred =>
      Table.CustomCell(
        <p className="text-sm text-nd_gray-600 font-medium">
          {`${feeEstimationData.transactionCurrency} ${LogicUtils.valueFormatter(
              feeEstimationData.totalCostIncurred,
              Amount,
            )}`->React.string}
        </p>,
        "",
      )
    | TypeOfFees =>
      Table.CustomCell(
        <Table.TableCell
          cell={Label({
            title: feeEstimationData.feeType->LogicUtils.camelCaseToTitle,
            color: switch feeEstimationData.feeType->String.toLocaleLowerCase {
            | "interchange" => LabelOrange
            | _ => LabelBlue
            },
          })}
          textAlign=Table.Left
          labelMargin="!py-0"
        />,
        "",
      )
    | CostContribution =>
      Table.CustomCell(
        <p className="text-sm text-nd_gray-600 font-medium">
          {`${LogicUtils.valueFormatter(feeEstimationData.costContribution, Rate)}`->React.string}
        </p>,
        "",
      )
    }
  }
  getCell
}

let feeEstimationEntity = (~authorization: CommonAuthTypes.authorization, ~sendMixpanelEvent) => {
  EntityType.makeEntity(
    ~uri=``,
    ~getObjects=_ => [],
    ~defaultColumns,
    ~getHeading,
    ~getCell=getTableCell(),
    ~dataKey="",
  )
}

let feeOverviewEstimationEntity = (
  ~authorization: CommonAuthTypes.authorization,
  ~sendMixpanelEvent,
) => {
  EntityType.makeEntity(
    ~uri=``,
    ~getObjects=_ => [],
    ~defaultColumns=overviewDefaultColumns,
    ~getHeading=getOverviewHeading,
    ~getCell=getOverviewTableCell(),
    ~dataKey="",
  )
}

let getConnectorObjectFromListViaId = (
  connectorList: array<ConnectorTypes.connectorPayloadCommonType>,
  mca_id: string,
  ~version: UserInfoTypes.version,
) => {
  let interface = switch version {
  | V1 => ConnectorListInterface.connectorInterfaceV1
  | V2 => ConnectorListInterface.connectorInterfaceV2
  }
  connectorList
  ->Array.find(ele => {ele.id == mca_id})
  ->Option.getOr(ConnectorListInterface.mapDictToConnectorPayload(interface, Dict.make())) //interface
}

let getFeeBreakdownHeading = (feesBreakdownData: feesBreakdown) => {
  switch feesBreakdownData {
  | FeeType => Table.makeHeaderInfo(~key="amount", ~title="Fee type")
  | Rate => Table.makeHeaderInfo(~key="created", ~title="Charged Rate/per txn")
  | TotalCost => Table.makeHeaderInfo(~key="currency", ~title="Total cost")
  }
}

let getFeeBreakdownCell = (
  refunds: FeeEstimationTypes.schemeFee,
  feeBreakdownColType: feesBreakdown,
): Table.cell => {
  switch feeBreakdownColType {
  | FeeType =>
    let feeName = refunds.feeName->LogicUtils.snakeToTitle
    if refunds.feeName->String.includes("interchange") {
      CustomCell(<p className="!cursor-not-allowed"> {`${feeName}`->React.string} </p>, "")
    } else {
      Text(feeName)
    }
  | Rate =>
    CustomCell(
      <div>
        <p>
          {`${refunds.variableRate->Float.toString} % ${refunds.cost->Float.toString}`->React.string}
        </p>
      </div>,
      "",
    )
  | TotalCost => Text(refunds.cost->Float.toString)
  }
}

let feesBreakdownColumns: array<feesBreakdown> = [FeeType, Rate, TotalCost]
