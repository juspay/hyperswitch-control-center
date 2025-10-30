open FeeEstimationTypes
open LogicUtils
let schemeFeesBreakdown: Dict.t<JSON.t> => array<schemeFee> = paymentDict => {
  paymentDict
  ->getArrayFromDict("estimate_scheme_breakdown", [])
  ->Array.map(schemeFeeJson => {
    let schemeFeeDict = schemeFeeJson->getDictFromJsonObject
    {
      feeName: schemeFeeDict->getString("fee_name", ""),
      feeLevel: schemeFeeDict->getString("fee_level", ""),
      fixedRate: schemeFeeDict->getFloat("fixed_rate", 0.0),
      variableRate: schemeFeeDict->getFloat("variable_rate", 0.0),
      cost: schemeFeeDict->getFloat("cost", 0.0),
    }
  })
}

let feeEstimateBreakdownMapper: JSON.t => breakdownItem = item => {
  let paymentDict = item->getDictFromJsonObject
  {
    paymentId: paymentDict->getString("payment_id", ""),
    merchantId: paymentDict->getString("merchant_id", ""),
    connector: paymentDict->getString("connector", ""),
    gross: paymentDict->getFloat("gross", 0.0),
    regionality: paymentDict->getString("regionality", ""),
    transactionCurrency: paymentDict->getString("transaction_currency", ""),
    fundingSource: paymentDict->getString("funding_source", ""),
    cardBrand: paymentDict->getString("card_brand", ""),
    cardVariant: paymentDict->getString("card_variant", ""),
    estimateInterchangeName: paymentDict->getString("estimate_interchange_name", ""),
    estimateInterchangeFixedRate: paymentDict->getFloat("estimate_interchange_fixed_rate", 0.0),
    estimateInterchangeVariableRate: paymentDict->getFloat(
      "estimate_interchange_variable_rate",
      0.0,
    ),
    estimateInterchangeCost: paymentDict->getFloat("estimate_interchange_cost", 0.0),
    estimateSchemeBreakdown: schemeFeesBreakdown(paymentDict),
    estimateSchemeTotalCost: paymentDict->getFloat("estimate_scheme_total_cost", 0.0),
    totalCost: paymentDict->getFloat("total_cost", 0.0),
  }
}

let feeEstimationMapper: Dict.t<JSON.t> => transactionViewfeeEstimate = dict => {
  let breakdown: array<FeeEstimationTypes.breakdownItem> = {
    let breakdownDict = dict->getArrayFromDict("breakdown", [])
    breakdownDict->Array.map(item => {
      feeEstimateBreakdownMapper(item)
    })
  }

  {
    totalRecords: dict->getInt("total_records", 0),
    breakdown,
  }
}

let fee_breakdown_based_on_geolocation: Dict.t<JSON.t> => array<feeBreakdownGeoLocation> = dict => {
  let feeBreakDownDict = dict->LogicUtils.getArrayFromDict("fee_breakdown_based_on_geolocation", [])
  let feeBreakdownGeoLocation: array<
    feeBreakdownGeoLocation,
  > = feeBreakDownDict->Array.map(value => {
    let schemeFeeDict = value->getDictFromJsonObject
    {
      region: schemeFeeDict->getString("region", ""),
      percentage: schemeFeeDict->getFloat("percentage", 0.0),
      fees: schemeFeeDict->getFloat("fees", 0.0),
    }
  })
  feeBreakdownGeoLocation
}
let regionBasedBreakdownMapper = overviewDict => {
  let regionBasedBreakdown: array<regionBasedBreakdownItem> =
    overviewDict
    ->LogicUtils.getArrayFromDict("region_based_breakdown", [])
    ->Array.map(value => {
      let regionDict = value->getDictFromJsonObject
      {
        fundingSource: regionDict->getString("funding_source", ""),
        transactionCount: regionDict->getInt("transaction_count", 0),
        totalCostIncurred: regionDict->getFloat("total_cost_incurred", 0.0),
        region: regionDict->getString("region", ""),
      }
    })
  regionBasedBreakdown
}

let overviewBreakdownItemMapper: JSON.t => overViewFeesBreakdown = item => {
  let overviewDict = item->getDictFromJsonObject
  {
    feeName: overviewDict->getString("fee_name", ""),
    totalCostIncurred: overviewDict->getFloat("total_cost_incurred", 0.0),
    transactionCurrency: overviewDict->getString("transaction_currency", ""),
    transactionCount: overviewDict->getInt("transaction_count", 0),
    feeType: overviewDict->getString("fee_type", ""),
    costContribution: overviewDict->getFloat("cost_contribution", 0.0),
    cardBrand: overviewDict->getString("card_brand", ""),
    regionValues: overviewDict->LogicUtils.getStrArray("region_values"),
    contributionPercentage: overviewDict->getFloat("cost_contribution", 0.0),
    regionBasedBreakdown: regionBasedBreakdownMapper(overviewDict),
  }
}

let overviewBreakdownMapper: Dict.t<JSON.t> => array<overViewFeesBreakdown> = dict => {
  let overviewBreakdownDict = dict->LogicUtils.getArrayFromDict("breakdown", [])
  let overviewBreakdown: array<overViewFeesBreakdown> = overviewBreakdownDict->Array.map(value => {
    overviewBreakdownItemMapper(value)
  })
  overviewBreakdown
}

let valuesBasedOnCardBrandMapper: Dict.t<JSON.t> => array<valuesBasedOnCardBrand> = dict => {
  let valuesBasedOnCardBrandDict =
    dict->LogicUtils.getArrayFromDict("top_values_based_on_brand", [])
  let valuesBasedOnCardBrand: array<
    valuesBasedOnCardBrand,
  > = valuesBasedOnCardBrandDict->Array.map(value => {
    let cardBrandDict = value->getDictFromJsonObject
    {
      cardBrand: cardBrandDict->getString("card_brand", ""),
      totalCost: cardBrandDict->getFloat("total_cost", 0.0),
      totalInterchangeCost: cardBrandDict->getFloat("total_interchange_cost", 0.0),
      totalSchemeCost: cardBrandDict->getFloat("total_scheme_cost", 0.0),
      noOfTxn: cardBrandDict->getInt("no_of_txn", 0),
      totalGrossAmt: cardBrandDict->getFloat("total_gross_amt", 0.0),
    }
  })
  valuesBasedOnCardBrand
}

let overviewDataMapper: Dict.t<JSON.t> => overviewFeeEstimate = dict => {
  {
    totalCost: dict->getFloat("total_cost", 0.0),
    totalInterchangeCost: dict->getFloat("total_interchange_cost", 0.0),
    totalSchemeCost: dict->getFloat("total_scheme_cost", 0.0),
    currency: dict->getString("currency", ""),
    noOfTxn: dict->getInt("no_of_txn", 0),
    totalGrossAmt: dict->getFloat("total_gross_amt", 0.0),
    feeBreakdownBasedOnGeoLocation: fee_breakdown_based_on_geolocation(dict),
    topValuesBasedOnCardBrand: valuesBasedOnCardBrandMapper(dict),
    overviewBreakdown: overviewBreakdownMapper(dict),
    totalRecords: dict->getInt("total_records", 10),
  }
}

let getTotalCostIncurredGraphOptions = (totalIncurredCost, isMiniLaptopView) => {
  StackedBarGraphUtils.getStackedBarGraphOptions(
    {
      categories: ["Total Orders"],
      data: [
        {
          name: "Interchanged Based Fee",
          data: [totalIncurredCost.totalInterchangeCost],
          color: "#8BC2F3",
        },
        {
          name: "Scheme Based Fee",
          data: [totalIncurredCost.totalSchemeCost],
          color: "#7CC5BF",
        },
      ],
      labelFormatter: StackedBarGraphUtils.stackedBarGraphLabelFormatter(~statType=Amount),
    },
    ~yMax=Math.Int.max(totalIncurredCost.totalCost->Math.ceil->Int.fromFloat, 1),
    ~labelItemDistance={isMiniLaptopView ? 45 : 90},
  )
}

let getTotalCostIncurredGraphTickInterval = maxFeeValue => {
  let exp = Math.floor(Math.log10(maxFeeValue))
  Math.pow(10.0, ~exp=exp -. 1.0) *. if maxFeeValue /. Math.pow(10.0, ~exp) < 1.5 {
    1.0
  } else if maxFeeValue /. Math.pow(10.0, ~exp) < 3.0 {
    2.0
  } else if maxFeeValue /. Math.pow(10.0, ~exp) < 7.0 {
    5.0
  } else {
    10.0
  }
}

let calculateCardBreakdownData = (
  cardBreakdownData: array<valuesBasedOnCardBrand>,
  currency: string,
) => {
  let (
    totalGrossAmt,
    totalCost,
    totalSchemeCost,
    totalInterchangeCost,
  ) = cardBreakdownData->Array.reduce((0.0, 0.0, 0.0, 0.0), (
    (grossAcc, costAcc, schemeAcc, interchangeAcc),
    item,
  ) => {
    (
      grossAcc +. item.totalGrossAmt,
      costAcc +. item.totalCost,
      schemeAcc +. item.totalSchemeCost,
      interchangeAcc +. item.totalInterchangeCost,
    )
  })

  [
    {
      title: "Total Sales",
      value: totalGrossAmt,
      currency,
    },
    {
      title: "Total Cost Incurred",
      value: totalCost,
      currency,
    },
    {
      title: "Total Scheme Based Fee",
      value: totalSchemeCost,
      currency,
    },
    {
      title: "Total Interchange Based Fee",
      value: totalInterchangeCost,
      currency,
    },
  ]
}
