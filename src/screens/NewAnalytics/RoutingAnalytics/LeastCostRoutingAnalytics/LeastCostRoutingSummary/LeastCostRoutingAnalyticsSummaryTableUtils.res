open LogicUtils
open RoutingAnalyticsUtils
open LeastCostRoutingAnalyticsSummaryTableTypes

let sampleJson = {
  "queryData": [
    {
      "payment_success_rate": null,
      "payment_count": null,
      "payment_success_count": null,
      "payment_processed_amount": 0,
      "payment_processed_amount_in_usd": null,
      "payment_processed_count": null,
      "payment_processed_amount_without_smart_retries": 0,
      "payment_processed_amount_without_smart_retries_usd": null,
      "payment_processed_count_without_smart_retries": null,
      "avg_ticket_size": null,
      "payment_error_message": null,
      "retries_count": null,
      "retries_amount_processed": 0,
      "connector_success_rate": null,
      "payments_success_rate_distribution": null,
      "payments_success_rate_distribution_without_smart_retries": null,
      "payments_success_rate_distribution_with_only_retries": null,
      "payments_failure_rate_distribution": null,
      "payments_failure_rate_distribution_without_smart_retries": null,
      "payments_failure_rate_distribution_with_only_retries": null,
      "failure_reason_count": 0,
      "failure_reason_count_without_smart_retries": 0,
      "debit_routed_transaction_count": 60,
      "debit_routing_savings": 10000,
      "debit_routing_savings_in_usd": 10000,
      "signature_network": "Visa",
      "is_issuer_regulated": true,
      "currency": "USD",
      "status": null,
      "connector": null,
      "authentication_type": null,
      "payment_method": null,
      "payment_method_type": null,
      "client_source": null,
      "client_version": null,
      "profile_id": null,
      "card_network": "Star",
      "merchant_id": null,
      "card_last_4": null,
      "card_issuer": null,
      "error_reason": null,
      "routing_approach": null,
      "time_range": {
        "start_time": "2025-08-01T18:30:00.000Z",
        "end_time": "2025-09-30T09:22:00.000Z",
      },
      "time_bucket": "2025-08-01 18:30:00",
    },
    {
      "payment_success_rate": null,
      "payment_count": null,
      "payment_success_count": null,
      "payment_processed_amount": 0,
      "payment_processed_amount_in_usd": null,
      "payment_processed_count": null,
      "payment_processed_amount_without_smart_retries": 0,
      "payment_processed_amount_without_smart_retries_usd": null,
      "payment_processed_count_without_smart_retries": null,
      "avg_ticket_size": null,
      "payment_error_message": null,
      "retries_count": null,
      "retries_amount_processed": 0,
      "connector_success_rate": null,
      "payments_success_rate_distribution": null,
      "payments_success_rate_distribution_without_smart_retries": null,
      "payments_success_rate_distribution_with_only_retries": null,
      "payments_failure_rate_distribution": null,
      "payments_failure_rate_distribution_without_smart_retries": null,
      "payments_failure_rate_distribution_with_only_retries": null,
      "failure_reason_count": 0,
      "failure_reason_count_without_smart_retries": 0,
      "debit_routed_transaction_count": 30,
      "debit_routing_savings": 20000,
      "debit_routing_savings_in_usd": 20000,
      "signature_network": "Visa",
      "is_issuer_regulated": false,
      "currency": "USD",
      "status": null,
      "connector": null,
      "authentication_type": null,
      "payment_method": null,
      "payment_method_type": null,
      "client_source": null,
      "client_version": null,
      "profile_id": null,
      "card_network": "Star",
      "merchant_id": null,
      "card_last_4": null,
      "card_issuer": null,
      "error_reason": null,
      "routing_approach": null,
      "time_range": {
        "start_time": "2025-08-01T18:30:00.000Z",
        "end_time": "2025-09-30T09:22:00.000Z",
      },
      "time_bucket": "2025-08-01 18:30:00",
    },
    {
      "payment_success_rate": null,
      "payment_count": null,
      "payment_success_count": null,
      "payment_processed_amount": 0,
      "payment_processed_amount_in_usd": null,
      "payment_processed_count": null,
      "payment_processed_amount_without_smart_retries": 0,
      "payment_processed_amount_without_smart_retries_usd": null,
      "payment_processed_count_without_smart_retries": null,
      "avg_ticket_size": null,
      "payment_error_message": null,
      "retries_count": null,
      "retries_amount_processed": 0,
      "connector_success_rate": null,
      "payments_success_rate_distribution": null,
      "payments_success_rate_distribution_without_smart_retries": null,
      "payments_success_rate_distribution_with_only_retries": null,
      "payments_failure_rate_distribution": null,
      "payments_failure_rate_distribution_without_smart_retries": null,
      "payments_failure_rate_distribution_with_only_retries": null,
      "failure_reason_count": 0,
      "failure_reason_count_without_smart_retries": 0,
      "debit_routed_transaction_count": 60,
      "debit_routing_savings": 10000,
      "debit_routing_savings_in_usd": 12000,
      "signature_network": "Visa",
      "is_issuer_regulated": true,
      "currency": "EUR",
      "status": null,
      "connector": null,
      "authentication_type": null,
      "payment_method": null,
      "payment_method_type": null,
      "client_source": null,
      "client_version": null,
      "profile_id": null,
      "card_network": "Star",
      "merchant_id": null,
      "card_last_4": null,
      "card_issuer": null,
      "error_reason": null,
      "routing_approach": null,
      "time_range": {
        "start_time": "2025-08-01T18:30:00.000Z",
        "end_time": "2025-09-30T09:22:00.000Z",
      },
      "time_bucket": "2025-08-01 18:30:00",
    },
    {
      "payment_success_rate": null,
      "payment_count": null,
      "payment_success_count": null,
      "payment_processed_amount": 0,
      "payment_processed_amount_in_usd": null,
      "payment_processed_count": null,
      "payment_processed_amount_without_smart_retries": 0,
      "payment_processed_amount_without_smart_retries_usd": null,
      "payment_processed_count_without_smart_retries": null,
      "avg_ticket_size": null,
      "payment_error_message": null,
      "retries_count": null,
      "retries_amount_processed": 0,
      "connector_success_rate": null,
      "payments_success_rate_distribution": null,
      "payments_success_rate_distribution_without_smart_retries": null,
      "payments_success_rate_distribution_with_only_retries": null,
      "payments_failure_rate_distribution": null,
      "payments_failure_rate_distribution_without_smart_retries": null,
      "payments_failure_rate_distribution_with_only_retries": null,
      "failure_reason_count": 0,
      "failure_reason_count_without_smart_retries": 0,
      "debit_routed_transaction_count": 30,
      "debit_routing_savings": 20000,
      "debit_routing_savings_in_usd": 22000,
      "signature_network": "Visa",
      "is_issuer_regulated": false,
      "currency": "EUR",
      "status": null,
      "connector": null,
      "authentication_type": null,
      "payment_method": null,
      "payment_method_type": null,
      "client_source": null,
      "client_version": null,
      "profile_id": null,
      "card_network": "Star",
      "merchant_id": null,
      "card_last_4": null,
      "card_issuer": null,
      "error_reason": null,
      "routing_approach": null,
      "time_range": {
        "start_time": "2025-08-01T18:30:00.000Z",
        "end_time": "2025-09-30T09:22:00.000Z",
      },
      "time_bucket": "2025-08-01 18:30:00",
    },
    {
      "payment_success_rate": null,
      "payment_count": null,
      "payment_success_count": null,
      "payment_processed_amount": 0,
      "payment_processed_amount_in_usd": null,
      "payment_processed_count": null,
      "payment_processed_amount_without_smart_retries": 0,
      "payment_processed_amount_without_smart_retries_usd": null,
      "payment_processed_count_without_smart_retries": null,
      "avg_ticket_size": null,
      "payment_error_message": null,
      "retries_count": null,
      "retries_amount_processed": 0,
      "connector_success_rate": null,
      "payments_success_rate_distribution": null,
      "payments_success_rate_distribution_without_smart_retries": null,
      "payments_success_rate_distribution_with_only_retries": null,
      "payments_failure_rate_distribution": null,
      "payments_failure_rate_distribution_without_smart_retries": null,
      "payments_failure_rate_distribution_with_only_retries": null,
      "failure_reason_count": 0,
      "failure_reason_count_without_smart_retries": 0,
      "debit_routed_transaction_count": 60,
      "debit_routing_savings": 10000,
      "debit_routing_savings_in_usd": 10000,
      "signature_network": "Visa",
      "is_issuer_regulated": true,
      "currency": "USD",
      "status": null,
      "connector": null,
      "authentication_type": null,
      "payment_method": null,
      "payment_method_type": null,
      "client_source": null,
      "client_version": null,
      "profile_id": null,
      "card_network": "Accel",
      "merchant_id": null,
      "card_last_4": null,
      "card_issuer": null,
      "error_reason": null,
      "routing_approach": null,
      "time_range": {
        "start_time": "2025-08-01T18:30:00.000Z",
        "end_time": "2025-09-30T09:22:00.000Z",
      },
      "time_bucket": "2025-08-01 18:30:00",
    },
    {
      "payment_success_rate": null,
      "payment_count": null,
      "payment_success_count": null,
      "payment_processed_amount": 0,
      "payment_processed_amount_in_usd": null,
      "payment_processed_count": null,
      "payment_processed_amount_without_smart_retries": 0,
      "payment_processed_amount_without_smart_retries_usd": null,
      "payment_processed_count_without_smart_retries": null,
      "avg_ticket_size": null,
      "payment_error_message": null,
      "retries_count": null,
      "retries_amount_processed": 0,
      "connector_success_rate": null,
      "payments_success_rate_distribution": null,
      "payments_success_rate_distribution_without_smart_retries": null,
      "payments_success_rate_distribution_with_only_retries": null,
      "payments_failure_rate_distribution": null,
      "payments_failure_rate_distribution_without_smart_retries": null,
      "payments_failure_rate_distribution_with_only_retries": null,
      "failure_reason_count": 0,
      "failure_reason_count_without_smart_retries": 0,
      "debit_routed_transaction_count": 30,
      "debit_routing_savings": 20000,
      "debit_routing_savings_in_usd": 20000,
      "signature_network": "Visa",
      "is_issuer_regulated": false,
      "currency": "USD",
      "status": null,
      "connector": null,
      "authentication_type": null,
      "payment_method": null,
      "payment_method_type": null,
      "client_source": null,
      "client_version": null,
      "profile_id": null,
      "card_network": "Accel",
      "merchant_id": null,
      "card_last_4": null,
      "card_issuer": null,
      "error_reason": null,
      "routing_approach": null,
      "time_range": {
        "start_time": "2025-08-01T18:30:00.000Z",
        "end_time": "2025-09-30T09:22:00.000Z",
      },
      "time_bucket": "2025-08-01 18:30:00",
    },
    {
      "payment_success_rate": null,
      "payment_count": null,
      "payment_success_count": null,
      "payment_processed_amount": 0,
      "payment_processed_amount_in_usd": null,
      "payment_processed_count": null,
      "payment_processed_amount_without_smart_retries": 0,
      "payment_processed_amount_without_smart_retries_usd": null,
      "payment_processed_count_without_smart_retries": null,
      "avg_ticket_size": null,
      "payment_error_message": null,
      "retries_count": null,
      "retries_amount_processed": 0,
      "connector_success_rate": null,
      "payments_success_rate_distribution": null,
      "payments_success_rate_distribution_without_smart_retries": null,
      "payments_success_rate_distribution_with_only_retries": null,
      "payments_failure_rate_distribution": null,
      "payments_failure_rate_distribution_without_smart_retries": null,
      "payments_failure_rate_distribution_with_only_retries": null,
      "failure_reason_count": 0,
      "failure_reason_count_without_smart_retries": 0,
      "debit_routed_transaction_count": 60,
      "debit_routing_savings": 10000,
      "debit_routing_savings_in_usd": 12000,
      "signature_network": "Visa",
      "is_issuer_regulated": true,
      "currency": "EUR",
      "status": null,
      "connector": null,
      "authentication_type": null,
      "payment_method": null,
      "payment_method_type": null,
      "client_source": null,
      "client_version": null,
      "profile_id": null,
      "card_network": "Accel",
      "merchant_id": null,
      "card_last_4": null,
      "card_issuer": null,
      "error_reason": null,
      "routing_approach": null,
      "time_range": {
        "start_time": "2025-08-01T18:30:00.000Z",
        "end_time": "2025-09-30T09:22:00.000Z",
      },
      "time_bucket": "2025-08-01 18:30:00",
    },
  ],
  "metaData": [
    {
      "total_payment_processed_amount": 0,
      "total_payment_processed_amount_in_usd": null,
      "total_payment_processed_amount_without_smart_retries": 0,
      "total_payment_processed_amount_without_smart_retries_usd": null,
      "total_payment_processed_count": 0,
      "total_payment_processed_count_without_smart_retries": 0,
      "total_failure_reasons_count": 0,
      "total_failure_reasons_count_without_smart_retries": 0,
    },
  ],
}->Identity.genericTypeToJson

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

let getSigandLocalLookup = data => {
  data
  ->groupBySignatureAndCardNetwork
  ->Dict.toArray
  ->Array.reduce(Dict.make(), (acc, (sigAndLocalKey, records)) => {
    let recordsJson = records->getArrayFromJson([])
    let totalTransactionsForCompositeKey =
      recordsJson->sumFloatField("debit_routed_transaction_count")
    let regulatedTrasnactions = recordsJson->sumIsRegulatedTransactions
    let unregulatedTransactions = recordsJson->sumIsUnregulatedTransactions
    let routingData =
      [
        ("totalTransactionForCompositeKey", totalTransactionsForCompositeKey->JSON.Encode.float),
        ("regulatedTransactions", regulatedTrasnactions->JSON.Encode.int),
        ("unregulatedTransactions", unregulatedTransactions->JSON.Encode.int),
      ]->getJsonFromArrayOfJson

    acc->Dict.set(sigAndLocalKey, routingData)
    acc
  })
}
// let mapToTableData = data => {
//   let queryData = data->getDictFromJsonObject->getArrayFromDict("queryData", [])

//   let totalTransactions = sumIntField(queryData, "debit_routed_transaction_count")
//   let signatureandLocallookup = getSigandLocalLookup(queryData)
//   Js.log2("signatureandLocallookup>>", signatureandLocallookup)
//   let groupedData = queryData->groupBySignatureAndCardNetwork
//   Js.log2("groupedData>>", groupedData)

//   let test =
//     groupedData
//     ->Dict.toArray
//     ->Array.map(((compositeKey, record)) => {
//       let recordsJson = record->getArrayFromJson([])
//       let signatureBrand = compositeKey->String.split("-")->getValueFromArray(0, "Unknown")
//       let cardNetwork = compositeKey->String.split("-")->getValueFromArray(1, "Unknown")
//       let sigandLocaldata = signatureandLocallookup->getDictfromDict(compositeKey)
//       let transactionsFOrEachRow = recordsJson->sumIntField("debit_routed_transaction_count")
//       let totalTransactionsForCompositeKey =
//         sigandLocaldata->getInt("totalTransactionForCompositeKey", 0)
//       // let totakTransactionForKey = recordsJson->sumIntField("debit_routed_transaction_count")

//       let debitRoutingSavings = recordsJson->sumFloatField("debit_routing_savings_in_usd") /. 100.00
//       let trafficPercentage = calculateTrafficPercentage(
//         totalTransactionsForCompositeKey,
//         totalTransactions,
//       )

//       let totalTransactionsForThisKey =
//         sigandLocaldata->getInt("totalTransactionForCompositeKey", 0)
//       let totalRegulatedTransactionForThisKey = sigandLocaldata->getInt("regulatedTransactions", 0)
//       let totalUnregulatedTransactionForThisKey =
//         sigandLocaldata->getInt("unregulatedTransactions", 0)
//       let regulatedTransactionPercentage = calculateTrafficPercentage(
//         totalRegulatedTransactionForThisKey,
//         totalTransactionsForThisKey,
//       )
//       let unregulatedTransactionsPercentage = calculateTrafficPercentage(
//         totalUnregulatedTransactionForThisKey,
//         totalTransactionsForThisKey,
//       )

//       {
//         signature_network: signatureBrand,
//         card_network: cardNetwork,
//         traffic_percentage: trafficPercentage,
//         debit_routed_transaction_count: transactionsFOrEachRow,
//         regulated_transaction_percentage: regulatedTransactionPercentage,
//         unregulated_transaction_percentage: unregulatedTransactionsPercentage,
//         debit_routing_savings: debitRoutingSavings,
//       }
//     })
//   Js.log2("test>>", test)
//   test
// }
let mapToTableData = data => {
  let queryData = sampleJson->getDictFromJsonObject->getArrayFromDict("queryData", [])

  let totalTransactions = sumIntField(queryData, "debit_routed_transaction_count")
  let signatureandLocallookup = getSigandLocalLookup(queryData)
  Js.log2("signatureandLocallookup>>", signatureandLocallookup)
  let groupedData = queryData->groupBySignatureAndCardNetwork
  Js.log2("groupedData>>", groupedData)

  let test =
    groupedData
    ->Dict.toArray
    ->Array.map(((compositeKey, record)) => {
      let recordsJson = record->getArrayFromJson([])
      let signatureBrand = compositeKey->String.split("-")->getValueFromArray(0, "Unknown")
      let cardNetwork = compositeKey->String.split("-")->getValueFromArray(1, "Unknown")
      // let sigandLocaldata = signatureandLocallookup->getDictfromDict(compositeKey)
      let transactionsFOrEachRow = recordsJson->sumIntField("debit_routed_transaction_count")
      // let totalTransactionsForCompositeKey =
      //   sigandLocaldata->getInt("totalTransactionForCompositeKey", 0)

      let debitRoutingSavings = recordsJson->sumFloatField("debit_routing_savings_in_usd") /. 100.00
      let trafficPercentage = calculateTrafficPercentage(transactionsFOrEachRow, totalTransactions)

      // let totalTransactionsForThisKey =
      //   sigandLocaldata->getInt("totalTransactionForCompositeKey", 0)
      // let totalRegulatedTransactionForThisKey = sigandLocaldata->getInt("regulatedTransactions", 0)
      let totalRegulatedTransactionForThisKey = recordsJson->sumIsRegulatedTransactions
      let totalUnregulatedTransactionForThisKey = recordsJson->sumIsUnregulatedTransactions
      // let totalUnregulatedTransactionForThisKey =
      //   sigandLocaldata->getInt("unregulatedTransactions", 0)
      let regulatedTransactionPercentage = calculateTrafficPercentage(
        totalRegulatedTransactionForThisKey,
        transactionsFOrEachRow,
      )
      let unregulatedTransactionsPercentage = calculateTrafficPercentage(
        totalUnregulatedTransactionForThisKey,
        transactionsFOrEachRow,
      )

      {
        signature_network: signatureBrand,
        card_network: cardNetwork,
        traffic_percentage: trafficPercentage,
        debit_routed_transaction_count: transactionsFOrEachRow,
        regulated_transaction_percentage: regulatedTransactionPercentage,
        unregulated_transaction_percentage: unregulatedTransactionsPercentage,
        debit_routing_savings: debitRoutingSavings,
      }
    })
  Js.log2("test>>", test)
  test
}
