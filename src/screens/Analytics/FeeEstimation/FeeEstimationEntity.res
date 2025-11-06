open ConnectorTypes
open Typography
open LogicUtils
open FeeEstimationTypes
open CurrencyFormatUtils

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

let allTransactionViewColumns = [
  PaymentID,
  CardType,
  TransactionValue,
  CardBrand,
  TotalCostIncurred,
]

let feeEstimationTransactionViewMapDefaultCols = Recoil.atom(
  "feeEstimationTransactionViewMapDefaultCols",
  defaultColumns,
)

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
  | CostContribution =>
    Table.makeHeaderInfo(~key="cost_contribution", ~title="Cost Contribution", ~showSort=true)
  }
}

let getAllPaymentMethods = (paymentMethodsArray: array<paymentMethodEnabledTypeCommon>) => {
  paymentMethodsArray->Array.reduce([], (acc, item) => {
    acc->Array.concat([item.payment_method_type->capitalizeString])
  })
}

let getTableCell = () => {
  let getCell = (feeEstimationData: breakdownItem, colType): Table.cell => {
    switch colType {
    | PaymentID =>
      Table.CustomCell(
        <div>
          <p className={`${body.md.medium} text-nd_gray-600`}>
            {feeEstimationData.paymentId->String.slice(~start=0, ~end=20)->React.string}
          </p>
        </div>,
        "",
      )
    | CardType =>
      Label({
        title: feeEstimationData.fundingSource->camelCaseToTitle,
        color: switch feeEstimationData.fundingSource {
        | "credit" => LabelOrange
        | _ => LabelBlue
        },
      })
    | TransactionValue =>
      Table.CustomCell(
        <p className={`${body.md.medium} text-nd_gray-600`}>
          {`${feeEstimationData.transactionCurrency} ${valueFormatter(
              feeEstimationData.gross,
              Amount,
            )}`->React.string}
        </p>,
        "",
      )
    | CardBrand =>
      Table.CustomCell(
        <div className="flex items-center gap-2">
          <GatewayIcon
            gateway={feeEstimationData.cardBrand->String.toUpperCase}
            className="w-6 h-6 p-1 px-0.5 rounded-md bg-nd_gray-25 border border-nd_br_gray-150"
          />
          <p className={`${body.md.medium} text-nd_gray-600`}>
            {feeEstimationData.cardBrand->camelCaseToTitle->React.string}
          </p>
        </div>,
        "",
      )
    | TotalCostIncurred =>
      Table.CustomCell(
        <p className={`${body.md.medium} text-nd_gray-600`}>
          {`${feeEstimationData.transactionCurrency} ${valueFormatter(
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

let getOverviewTableCell = (
  feeEstimationData: overViewFeesBreakdown,
  colType: overviewColType,
): Table.cell => {
  switch colType {
  | FeeName =>
    Table.CustomCell(
      <div>
        <p className={`${body.md.medium} text-nd_gray-600 font-medium`}>
          {feeEstimationData.feeName->camelCaseToTitle->React.string}
        </p>
      </div>,
      "",
    )
  | TotalTransactions =>
    Table.CustomCell(
      <Table.TableCell
        cell={CustomCell(
          <div>
            <p className={`${body.md.medium} text-nd_gray-600`}>
              {valueFormatter(
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
      <p className={`${body.md.medium} text-nd_gray-600`}>
        {`${feeEstimationData.transactionCurrency} ${valueFormatter(
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
          title: feeEstimationData.feeType->camelCaseToTitle,
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
      <p className={`${body.md.medium} text-nd_gray-600`}>
        {`${valueFormatter(feeEstimationData.costContribution, Rate)}`->React.string}
      </p>,
      "",
    )
  }
}

let feeEstimationEntity = () => {
  EntityType.makeEntity(
    ~uri=``,
    ~getObjects=_ => [],
    ~defaultColumns,
    ~getHeading,
    ~allColumns=allTransactionViewColumns,
    ~getCell=getTableCell(),
    ~dataKey="",
  )
}

let feeOverviewEstimationEntity = () => {
  EntityType.makeEntity(
    ~uri=``,
    ~getObjects=_ => [],
    ~defaultColumns=overviewDefaultColumns,
    ~getHeading=getOverviewHeading,
    ~getCell=getOverviewTableCell,
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
  ->Option.getOr(ConnectorListInterface.mapDictToConnectorPayload(interface, Dict.make()))
}

let getFeeBreakdownHeading = (feesBreakdownData: feesBreakdown) => {
  switch feesBreakdownData {
  | FeeType => Table.makeHeaderInfo(~key="amount", ~title="Fee type")
  | Rate => Table.makeHeaderInfo(~key="created", ~title="Charged Rate/per txn")
  | TotalCost => Table.makeHeaderInfo(~key="currency", ~title="Total cost")
  }
}

let getFeeBreakdownCell = (refunds: schemeFee, feeBreakdownColType: feesBreakdown): Table.cell => {
  switch feeBreakdownColType {
  | FeeType =>
    let feeName = refunds.feeName->snakeToTitle
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
