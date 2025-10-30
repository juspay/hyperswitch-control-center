type schemeFee = {
  feeName: string,
  feeLevel: string,
  fixedRate: float,
  variableRate: float,
  cost: float,
}

type breakdownItem = {
  paymentId: string,
  merchantId: string,
  connector: string,
  gross: float,
  regionality: string,
  transactionCurrency: string,
  fundingSource: string,
  cardBrand: string,
  cardVariant: string,
  estimateInterchangeName: string,
  estimateInterchangeFixedRate: float,
  estimateInterchangeVariableRate: float,
  estimateInterchangeCost: float,
  estimateSchemeBreakdown: array<schemeFee>,
  estimateSchemeTotalCost: float,
  totalCost: float,
}

type transactionViewfeeEstimate = {
  totalRecords: int,
  breakdown: array<breakdownItem>,
}

type feeBreakdownGeoLocation = {
  region: string,
  percentage: float,
  fees: float,
}

type regionBasedBreakdownItem = {
  fundingSource: string,
  region: string,
  transactionCount: int,
  totalCostIncurred: float,
}

type overViewFeesBreakdown = {
  feeName: string,
  totalCostIncurred: float,
  transactionCurrency: string,
  transactionCount: int,
  feeType: string,
  costContribution: float,
  cardBrand: string,
  contributionPercentage: float,
  regionValues: array<string>,
  regionBasedBreakdown: array<regionBasedBreakdownItem>,
}

type valuesBasedOnCardBrand = {
  cardBrand: string,
  totalCost: float,
  totalInterchangeCost: float,
  totalSchemeCost: float,
  noOfTxn: int,
  totalGrossAmt: float,
}

type overviewFeeEstimate = {
  totalCost: float,
  totalInterchangeCost: float,
  totalSchemeCost: float,
  currency: string,
  noOfTxn: int,
  totalGrossAmt: float,
  feeBreakdownBasedOnGeoLocation: array<feeBreakdownGeoLocation>,
  topValuesBasedOnCardBrand: array<valuesBasedOnCardBrand>,
  overviewBreakdown: array<overViewFeesBreakdown>,
  totalRecords: int,
}

type transactionTableEntity = {
  paymentId: string,
  totalPaymentValue: float,
  totalConstIncurred: float,
  cardBrand: string,
}

type breakdownCard = {
  title: string,
  value: float,
  currency: string,
}

type breakdownContribution = {
  cardBrand: string,
  currency: string,
  value: float,
}

type sidebarModalData = {
  title: string,
  value: string,
  icon: string,
}
