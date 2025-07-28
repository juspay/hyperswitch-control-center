open RoutingAnalyticsSummaryTypes
open LogicUtils

let groupByRoutingApproach = (queryData: array<JSON.t>) => {
  let routingGroupsDict = Dict.make()
  queryData->Array.forEach(item => {
    let dict = item->getDictFromJsonObject
    let routingApproach = dict->getString("routing_approach", "Unknown")
    let existing = routingGroupsDict->Dict.get(routingApproach)->Option.getOr([])
    routingGroupsDict->Dict.set(routingApproach, [item, ...existing])
  })
  routingGroupsDict
}

let mapToTableData = (~responseConnector, ~responseRouting): array<summaryMain> => {
  let queryData = responseConnector->getDictFromJsonObject->getArrayFromDict("queryData", [])
  let queryDataRouting = responseRouting->getDictFromJsonObject->getArrayFromDict("queryData", [])

  let totalPayments = queryData->Array.reduce(0, (acc, item) => {
    let dict = item->getDictFromJsonObject
    acc + dict->getInt("payment_count", 0)
  })

  let routingGroupsRoutingApproachDict = groupByRoutingApproach(queryDataRouting)

  let routingDataLookup = Dict.make()

  routingGroupsRoutingApproachDict
  ->Dict.toArray
  ->Array.forEach(((routingApproach, records)) => {
    let authrate = records->Array.reduce(0.0, (acc, record) => {
      let dict = record->getDictFromJsonObject
      acc +. dict->getFloat("payment_success_rate", 0.0)
    })
    let processedAmount = records->Array.reduce(0.0, (acc, record) => {
      let dict = record->getDictFromJsonObject
      acc +. dict->getFloat("payment_processed_amount", 0.0)
    })
    let routingData = Dict.make()
    routingData->Dict.set("authRate", authrate)
    routingData->Dict.set("processedAmount", processedAmount)

    routingDataLookup->Dict.set(routingApproach, routingData)
  })

  let routingGroupsDict = groupByRoutingApproach(queryData)

  routingGroupsDict
  ->Dict.toArray
  ->Array.map(((routingApproach, records)) => {
    let totalPaymentsForRouting = records->Array.reduce(0, (acc, record) => {
      let dict = record->getDictFromJsonObject
      acc + dict->getInt("payment_count", 0)
    })

    let trafficPercentage =
      totalPayments > 0
        ? Int.toFloat(totalPaymentsForRouting) /. Int.toFloat(totalPayments) *. 100.0
        : 0.0

    let routingData = routingDataLookup->Dict.get(routingApproach)->Option.getOr(Dict.make())
    let authorizationRate = routingData->getFloat("authRate", 0.0)
    let processedAmount = routingData->getFloat("processedAmount", 0.0)

    let connectorGroupsDict = Dict.make()
    records->Array.forEach(item => {
      let dict = item->getDictFromJsonObject
      let connectorName = dict->getString("connector", "Unknown")
      let existing = connectorGroupsDict->Dict.get(connectorName)->Option.getOr([])
      connectorGroupsDict->Dict.set(connectorName, [item, ...existing])
    })

    let connectors =
      connectorGroupsDict
      ->Dict.toArray
      ->Array.map(((connectorName, connectorRecords)) => {
        let connectorPayments = connectorRecords->Array.reduce(
          0,
          (acc, record) => {
            let dict = record->getDictFromJsonObject
            acc + dict->getInt("payment_count", 0)
          },
        )

        let connectorProcessedAmount = connectorRecords->Array.reduce(
          0.0,
          (acc, record) => {
            let dict = record->getDictFromJsonObject
            acc +. dict->getFloat("payment_processed_amount", 0.0)
          },
        )

        let connectorSuccessRate = connectorRecords->Array.reduce(
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

let processRoutingAnalyticsSummaryResponse = (~dataConnector: JSON.t, ~dataRouting: JSON.t): array<
  summaryMain,
> => {
  let responseConnector = dataConnector
  let responseRouting = dataRouting
  mapToTableData(~responseConnector, ~responseRouting)
}
