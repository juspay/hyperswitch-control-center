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
  gmvPercentage: float,
  regionValues: array<string>,
  regionBasedBreakdown: array<regionBasedBreakdownItem>,
}

type overviewFeeEstimate = {
  totalCost: float,
  totalInterchangeCost: float,
  totalSchemeCost: float,
  noOfTxn: int,
  totalGrossAmt: float,
  feeBreakdownBasedOnGeoLocation: array<feeBreakdownGeoLocation>,
  overviewBreakdown: array<overViewFeesBreakdown>,
}

type transactionTableEntity = {
  paymentId: string,
  totalPaymentValue: float,
  totalConstIncurred: float,
  cardBrand: string,
}
