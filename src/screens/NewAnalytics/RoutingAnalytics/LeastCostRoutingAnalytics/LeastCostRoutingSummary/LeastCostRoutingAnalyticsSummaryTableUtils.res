open LogicUtils
open RoutingAnalyticsUtils
open LeastCostRoutingAnalyticsSummaryTableTypes

let sumIsRegulatedTransactions = (records: array<JSON.t>) => {
  records->Array.reduce(0, (acc, record) => {
    let recordDict = record->getDictFromJsonObject
    let isIssuerRegulated = recordDict->getBool("is_issuer_regulated", false)
    let debitRoutedTransactionCount = recordDict->getInt("debit_routed_transaction_count", 0)

    if isIssuerRegulated {
      acc + debitRoutedTransactionCount
    } else {
      acc
    }
  })
}

let sumIsUnregulatedTransactions = (records: array<JSON.t>) => {
  records->Array.reduce(0, (acc, record) => {
    let recordDict = record->getDictFromJsonObject
    let isIssuerRegulated = recordDict->getBool("is_issuer_regulated", false)
    let debitRoutedTransactionCount = recordDict->getInt("debit_routed_transaction_count", 0)

    if !isIssuerRegulated {
      acc + debitRoutedTransactionCount
    } else {
      acc
    }
  })
}

let groupBySignatureAndCardNetwork = data => {
  data->Array.reduce(Dict.make(), (acc, item) => {
    let itemDict = item->getDictFromJsonObject
    let signatureNetwork = itemDict->getString("signature_network", "Unknown")
    let cardNetwork = itemDict->getString("card_network", "Unknown")
    let compositeKey = `${signatureNetwork}-${cardNetwork}`

    acc->Dict.set(
      compositeKey,
      [...acc->getArrayFromDict(compositeKey, []), item]->JSON.Encode.array,
    )
    acc
  })
}

let mapToTableData = data => {
  let queryData = data->getDictFromJsonObject->getArrayFromDict("queryData", [])

  let totalTransactions = sumIntField(queryData, "debit_routed_transaction_count")
  let groupedData = queryData->groupBySignatureAndCardNetwork

  groupedData
  ->Dict.toArray
  ->Array.map(((compositeKey, record)) => {
    let recordsJson = record->getArrayFromJson([])
    let signatureBrand = compositeKey->String.split("-")->getValueFromArray(0, "Unknown")
    let cardNetwork = compositeKey->String.split("-")->getValueFromArray(1, "Unknown")
    let transactionsForEachRow = recordsJson->sumIntField("debit_routed_transaction_count")

    let debitRoutingSavings = recordsJson->sumFloatField("debit_routing_savings_in_usd") /. 100.00
    let trafficPercentage = calculateTrafficPercentage(transactionsForEachRow, totalTransactions)

    let totalRegulatedTransactionForThisKey = recordsJson->sumIsRegulatedTransactions
    let totalUnregulatedTransactionForThisKey = recordsJson->sumIsUnregulatedTransactions
    let regulatedTransactionPercentage = calculateTrafficPercentage(
      totalRegulatedTransactionForThisKey,
      transactionsForEachRow,
    )
    let unregulatedTransactionsPercentage = calculateTrafficPercentage(
      totalUnregulatedTransactionForThisKey,
      transactionsForEachRow,
    )

    {
      signature_network: signatureBrand,
      card_network: cardNetwork,
      traffic_percentage: trafficPercentage,
      debit_routed_transaction_count: transactionsForEachRow,
      regulated_transaction_percentage: regulatedTransactionPercentage,
      unregulated_transaction_percentage: unregulatedTransactionsPercentage,
      debit_routing_savings: debitRoutingSavings,
    }
  })
}
