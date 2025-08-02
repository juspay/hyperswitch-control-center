open RoutingAnalyticsSummaryTypes
open LogicUtils

let groupByField = (data, fieldName) => {
  data->Array.reduce(Dict.make(), (acc, item) => {
    let fieldValue = item->getDictFromJsonObject->getString(fieldName, "Unknown")
    acc->Dict.set(fieldValue, [...acc->getArrayFromDict(fieldValue, []), item]->JSON.Encode.array)
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

let getConnectorsData = (records, totalPaymentsForRouting) => {
  let connectorGroupsDict = records->groupByField("connector")

  connectorGroupsDict
  ->Dict.toArray
  ->Array.map(((connectorName, connectorRecords)) => {
    let connectorRecordsJson = connectorRecords->getArrayFromJson([])
    let connectorPayments = connectorRecordsJson->sumIntField("payment_count")
    let connectorProcessedAmount =
      connectorRecordsJson->sumFloatField("payment_processed_amount_in_usd") /. 100.00
    let connectorSuccessRate = connectorRecordsJson->sumFloatField("payment_success_rate")

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
}

let getRoutingDataLookup = queryDataRouting => {
  let routingGroupsRoutingApproachDict = queryDataRouting->groupByField("routing_approach")

  routingGroupsRoutingApproachDict
  ->Dict.toArray
  ->Array.reduce(Dict.make(), (acc, (routingApproach, records)) => {
    let recordsJson = records->getArrayFromJson([])
    let authRate = recordsJson->sumFloatField("payment_success_rate")
    let processedAmount = recordsJson->sumFloatField("payment_processed_amount_in_usd") /. 100.00

    let routingData =
      [
        ("authRate", authRate->JSON.Encode.float),
        ("processedAmount", processedAmount->JSON.Encode.float),
      ]->getJsonFromArrayOfJson

    acc->Dict.set(routingApproach, routingData)
    acc
  })
}

let mapToTableData = (~responseConnector, ~responseRouting) => {
  let queryData = responseConnector->getDictFromJsonObject->getArrayFromDict("queryData", [])
  let queryDataRouting = responseRouting->getDictFromJsonObject->getArrayFromDict("queryData", [])
  let routingDataLookup = getRoutingDataLookup(queryDataRouting)
  let totalPayments = sumIntField(queryData, "payment_count")

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

    let connectors = getConnectorsData(recordsJson, totalPaymentsForRouting)

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
