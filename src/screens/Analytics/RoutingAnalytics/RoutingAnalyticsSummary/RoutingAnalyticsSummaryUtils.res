open RoutingAnalyticsSummaryTypes
open LogicUtils

let groupByRoutingApproach = (queryData: array<JSON.t>) => {
  let routingGroupsDict = queryData->Array.reduce(Dict.make(), (acc, item: JSON.t) => {
    let routingApproach = item->getDictFromJsonObject->getString("routing_approach", "Unknown")
    let existing = acc->getArrayFromDict(routingApproach, [])
    let concatedArray = Array.concat(existing, [item])
    acc->Dict.set(routingApproach, concatedArray->JSON.Encode.array)
    acc
  })
  routingGroupsDict
}

let mapToTableData = (~responseConnector, ~responseRouting): array<summaryMain> => {
  let queryData = responseConnector->getDictFromJsonObject->getArrayFromDict("queryData", [])
  let queryDataRouting = responseRouting->getDictFromJsonObject->getArrayFromDict("queryData", [])

  let totalPayments = queryData->Array.reduce(0, (acc, item) => {
    acc + item->getDictFromJsonObject->getInt("payment_count", 0)
  })

  let routingGroupsRoutingApproachDict = groupByRoutingApproach(queryDataRouting)

  let routingDataLookup =
    routingGroupsRoutingApproachDict
    ->Dict.toArray
    ->Array.reduce(Dict.make(), (acc, (routingApproach, records)) => {
      let recordsJson = records->getArrayFromJson([])
      let authrate = recordsJson->Array.reduce(0.0, (acc, record) => {
        let dict = record->getDictFromJsonObject
        acc +. dict->getFloat("payment_success_rate", 0.0)
      })
      let processedAmount = recordsJson->Array.reduce(0.0, (acc, record) => {
        let dict = record->getDictFromJsonObject
        acc +. dict->getFloat("payment_processed_amount", 0.0)
      })
      let routingData =
        [
          ("authRate", authrate->JSON.Encode.float),
          ("processedAmount", processedAmount->JSON.Encode.float),
        ]->getJsonFromArrayOfJson

      acc->Dict.set(routingApproach, routingData)
      acc
    })

  let routingGroupsDict = groupByRoutingApproach(queryData)

  routingGroupsDict
  ->Dict.toArray
  ->Array.map(((routingApproach, records)) => {
    let recordsJson = records->getArrayFromJson([])
    let totalPaymentsForRouting = recordsJson->Array.reduce(0, (acc, record) => {
      let dict = record->getDictFromJsonObject
      acc + dict->getInt("payment_count", 0)
    })

    let trafficPercentage =
      totalPayments > 0
        ? Int.toFloat(totalPaymentsForRouting) /. Int.toFloat(totalPayments) *. 100.0
        : 0.0

    let routingData = routingDataLookup->getDictfromDict(routingApproach)
    let authorizationRate = routingData->getFloat("authRate", 0.0)
    let processedAmount = routingData->getFloat("processedAmount", 0.0)

    let connectorGroupsDict = recordsJson->Array.reduce(Dict.make(), (acc, item) => {
      let connectorName = item->getDictFromJsonObject->getString("connector", "Unknown")
      let existing = acc->getArrayFromDict(connectorName, [])
      let concatedArray = Array.concat(existing, [item])
      acc->Dict.set(connectorName, concatedArray->JSON.Encode.array)
      acc
    })

    let connectors =
      connectorGroupsDict
      ->Dict.toArray
      ->Array.map(((connectorName, connectorRecords)) => {
        let connectorRecordsJson = connectorRecords->getArrayFromJson([])
        let connectorPayments = connectorRecordsJson->Array.reduce(
          0,
          (acc, record) => {
            let dict = record->getDictFromJsonObject
            acc + dict->getInt("payment_count", 0)
          },
        )

        let connectorProcessedAmount = connectorRecordsJson->Array.reduce(
          0.0,
          (acc, record) => {
            let dict = record->getDictFromJsonObject
            acc +. dict->getFloat("payment_processed_amount", 0.0)
          },
        )

        let connectorSuccessRate = connectorRecordsJson->Array.reduce(
          0.0,
          (acc, record) => {
            let dict = record->getDictFromJsonObject
            let successRate = dict->getFloat("payment_success_rate", 0.0)
            acc +. successRate
          },
        )

        let connectorTrafficPercentage =
          totalPaymentsForRouting > 0
            ? Int.toFloat(connectorPayments) /. Int.toFloat(totalPaymentsForRouting) *. 100.0
            : 0.0

        {
          connector_name: connectorName,
          traffic_percentage: connectorTrafficPercentage,
          no_of_payments: connectorPayments,
          authorization_rate: connectorSuccessRate,
          processed_amount: connectorProcessedAmount,
        }
      })

    {
      routing_logic: routingApproach,
      traffic_percentage: trafficPercentage,
      no_of_payments: totalPaymentsForRouting,
      authorization_rate: authorizationRate,
      processed_amount: processedAmount,
      connectors,
    }
  })
}
