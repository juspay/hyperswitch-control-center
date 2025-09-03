open LogicUtils
open RoutingAnalyticsUtils

let sumTransactions = (records: array<JSON.t>, ~forRegulated) => {
  records->Array.reduce(0, (acc, record) => {
    let recordDict = record->getDictFromJsonObject
    let debitRoutedTransactionCount = recordDict->getInt("debit_routed_transaction_count", 0)
    let isIssuerRegulated = recordDict->getBool("is_issuer_regulated", false)
    if forRegulated {
      acc + if isIssuerRegulated {
        debitRoutedTransactionCount
      } else {
        0
      }
    } else {
      acc + if !isIssuerRegulated {
        debitRoutedTransactionCount
      } else {
        0
      }
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
let createTableRow = (
  compositeKey,
  record,
  totalTransactions,
): LeastCostRoutingAnalyticsSummaryTableTypes.summaryMain => {
  let recordsJson = record->getArrayFromJson([])
  let signatureBrand = compositeKey->String.split("-")->getValueFromArray(0, "Unknown")
  let cardNetwork = compositeKey->String.split("-")->getValueFromArray(1, "Unknown")
  let transactionsForEachRow = recordsJson->sumIntField("debit_routed_transaction_count")

  let debitRoutingSavings = recordsJson->sumFloatField("debit_routing_savings_in_usd") /. 100.00
  let trafficPercentage = calculateTrafficPercentage(transactionsForEachRow, totalTransactions)

  let totalRegulatedTransactionForThisKey = recordsJson->sumTransactions(~forRegulated=true)
  let totalUnregulatedTransactionForThisKey = recordsJson->sumTransactions(~forRegulated=false)

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
}

let mapToTableData = data => {
  let queryData = data->getDictFromJsonObject->getArrayFromDict("queryData", [])

  let totalTransactions = sumIntField(queryData, "debit_routed_transaction_count")

  queryData
  ->groupBySignatureAndCardNetwork
  ->Dict.toArray
  ->Array.map(((compositeKey, record)) => {
    let rowData = createTableRow(compositeKey, record, totalTransactions)
    rowData
  })
}
