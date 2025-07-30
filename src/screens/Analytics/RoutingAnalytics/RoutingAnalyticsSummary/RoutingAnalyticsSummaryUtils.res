open RoutingAnalyticsSummaryTypes
open LogicUtils

let groupByField = (data: array<JSON.t>, fieldName: string) => {
  data->Array.reduce(Dict.make(), (acc, item: JSON.t) => {
    let fieldValue = item->getDictFromJsonObject->getString(fieldName, "Unknown")
    let existing = acc->getArrayFromDict(fieldValue, [])
    let concatedArray = Array.concat(existing, [item])
    acc->Dict.set(fieldValue, concatedArray->JSON.Encode.array)
    acc
  })
}

let sumIntField = (records: array<JSON.t>, fieldName: string) => {
  records->Array.reduce(0, (acc, record) => {
    acc + record->getDictFromJsonObject->getInt(fieldName, 0)
  })
}

let sumFloatField = (records: array<JSON.t>, fieldName: string) => {
  records->Array.reduce(0.0, (acc, record) => {
    acc +. record->getDictFromJsonObject->getFloat(fieldName, 0.0)
  })
}

let calculateTrafficPercentage = (part: int, total: int) => {
  total > 0 ? Int.toFloat(part) /. Int.toFloat(total) *. 100.0 : 0.0
}

let mapToTableData = (~responseConnector, ~responseRouting) => {
  let queryData = responseConnector->getDictFromJsonObject->getArrayFromDict("queryData", [])
  let queryDataRouting = responseRouting->getDictFromJsonObject->getArrayFromDict("queryData", [])

  let totalPayments = sumIntField(queryData, "payment_count")

  let routingGroupsRoutingApproachDict = groupByField(queryDataRouting, "routing_approach")

  let routingDataLookup =
    routingGroupsRoutingApproachDict
    ->Dict.toArray
    ->Array.reduce(Dict.make(), (acc, (routingApproach, records)) => {
      let recordsJson = records->getArrayFromJson([])
      let authrate = sumFloatField(recordsJson, "payment_success_rate")
      let processedAmount = sumFloatField(recordsJson, "payment_processed_amount")
      let routingData =
        [
          ("authRate", authrate->JSON.Encode.float),
          ("processedAmount", processedAmount->JSON.Encode.float),
        ]->getJsonFromArrayOfJson

      acc->Dict.set(routingApproach, routingData)
      acc
    })

  let routingGroupsDict = groupByField(queryData, "routing_approach")

  routingGroupsDict
  ->Dict.toArray
  ->Array.map(((routingApproach, records)) => {
    let recordsJson = records->getArrayFromJson([])
    let totalPaymentsForRouting = sumIntField(recordsJson, "payment_count")
    let trafficPercentage = calculateTrafficPercentage(totalPaymentsForRouting, totalPayments)
    let routingData = routingDataLookup->getDictfromDict(routingApproach)
    let authorizationRate = routingData->getFloat("authRate", 0.0)
    let processedAmount = routingData->getFloat("processedAmount", 0.0)

    let connectorGroupsDict = groupByField(recordsJson, "connector")

    let connectors =
      connectorGroupsDict
      ->Dict.toArray
      ->Array.map(((connectorName, connectorRecords)) => {
        let connectorRecordsJson = connectorRecords->getArrayFromJson([])
        let connectorPayments = sumIntField(connectorRecordsJson, "payment_count")

        let connectorProcessedAmount = sumFloatField(
          connectorRecordsJson,
          "payment_processed_amount",
        )

        let connectorSuccessRate = sumFloatField(connectorRecordsJson, "payment_success_rate")

        let connectorTrafficPercentage = calculateTrafficPercentage(
          connectorPayments,
          totalPaymentsForRouting,
        )

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
