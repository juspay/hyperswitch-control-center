open SankeyGraphTypes
open LogicUtils
open SCAExemptionAnalyticsTypes

let scaExemptionResponseMapper = (json: JSON.t) => {
  let sankeyDataArray = json->getArrayFromJson([])

  // Initialize counters dictionary with meaningful names
  let countersDict =
    [
      "total_3ds_payments",
      "exemption_requested",
      "exemption_not_requested",
      "exemption_accepted",
      "exemption_rejected",
      "3ds_completed",
      "3ds_incomplete",
      "auth_success",
      "auth_failure",
    ]
    ->Array.map(item => (item, 0))
    ->Dict.fromArray

  // Process each item in the sankey data
  sankeyDataArray->Array.forEach(item => {
    let itemDict = item->getDictFromJsonObject
    let count = itemDict->getInt("count", 0)
    let authStatus = itemDict->getString("authentication_status", "")

    switch authStatus {
    | "Total 3DS Payment Request" => countersDict->Dict.set("total_3ds_payments", count)
    | "Exemption Requested" => countersDict->Dict.set("exemption_requested", count)
    | "Exemption not Requested" => countersDict->Dict.set("exemption_not_requested", count)
    | "Exemption Accepted" => countersDict->Dict.set("exemption_accepted", count)
    | "Exemption not Accepted" => countersDict->Dict.set("exemption_rejected", count)
    | "3DS Completed" => countersDict->Dict.set("3ds_completed", count)
    | "3DS not Completed" => countersDict->Dict.set("3ds_incomplete", count)
    | "Authentication Success" => countersDict->Dict.set("auth_success", count)
    | "Authentication Failure" => countersDict->Dict.set("auth_failure", count)
    | _ => ()
    }
  })

  {
    totalThreeDSPayments: countersDict->getInt("total_3ds_payments", 0),
    exemptionRequested: countersDict->getInt("exemption_requested", 0),
    exemptionNotRequested: countersDict->getInt("exemption_not_requested", 0),
    exemptionAccepted: countersDict->getInt("exemption_accepted", 0),
    exemptionRejected: countersDict->getInt("exemption_rejected", 0),
    threeDSCompleted: countersDict->getInt("3ds_completed", 0),
    threeDSIncomplete: countersDict->getInt("3ds_incomplete", 0),
    authSuccess: countersDict->getInt("auth_success", 0),
    authFailure: countersDict->getInt("auth_failure", 0),
  }
}

let transformData = (data: array<(string, int)>) => {
  let data = data->Array.map(item => {
    let (key, value) = item
    (key, value->Int.toFloat)
  })
  let arr = data->Array.map(item => {
    let (_, value) = item
    value
  })
  let minVal = arr->Math.minMany
  let maxVal = arr->Math.maxMany
  let total = arr->Array.reduce(0.0, (sum, count) => {
    sum +. count
  })
  // Normalize Each Element
  let updatedData = data->Array.map(item => {
    let (key, count) = item
    let num = count -. minVal
    let dinom = maxVal -. minVal
    let normalizedValue = maxVal != minVal ? num /. dinom : 1.0

    (key, normalizedValue)
  })
  // Map to Target Range
  let updatedData = updatedData->Array.map(item => {
    let (key, count) = item
    let scaledValue = count *. (100.0 -. 10.0) +. 10.0
    (key, scaledValue)
  })
  // Adjust to Sum 100
  let updatedData = updatedData->Array.map(item => {
    let (key, count) = item
    let mul = 100.0 /. total
    let finalValue = count *. mul
    (key, finalValue)
  })
  // Round to Integers
  let updatedData = updatedData->Array.map(item => {
    let (key, count) = item
    let finalValue = (count *. 100.0)->Float.toInt
    (key, finalValue)
  })

  updatedData->Dict.fromArray
}

let scaExemptionMapper = (
  ~params: NewAuthenticationAnalyticsTypes.getObjects<scaExemption>,
): SankeyGraphTypes.sankeyPayload => {
  open InsightsUtils
  let {data} = params

  // Extract values from the data record
  let totalThreeDSPayments = data.totalThreeDSPayments
  let exemptionRequested = data.exemptionRequested
  let exemptionNotRequested = data.exemptionNotRequested
  let exemptionAccepted = data.exemptionAccepted
  let exemptionRejected = data.exemptionRejected
  let threeDSCompleted = data.threeDSCompleted
  let threeDSIncomplete = data.threeDSIncomplete
  let authSuccess = data.authSuccess
  let authFailure = data.authFailure

  // Create value dictionary for filtering
  let valueDict =
    [
      ("Total 3DS Payment Request", totalThreeDSPayments),
      ("Exemption Requested", exemptionRequested),
      ("Exemption not Requested", exemptionNotRequested),
      ("Exemption Accepted", exemptionAccepted),
      ("Exemption not Accepted", exemptionRejected),
      ("3DS Completed", threeDSCompleted),
      ("3DS not Completed", threeDSIncomplete),
      ("Authentication Success", authSuccess),
      ("Authentication Failure", authFailure),
    ]
    ->Array.filter(item => {
      let (_, value) = item
      value > 0
    })
    ->transformData

  // Create sankey nodes using authentication_status names
  let sankeyNodes = [
    {
      id: "Total 3DS Payment Request",
      dataLabels: {
        align: "left",
        x: -130,
        name: totalThreeDSPayments,
      },
    },
    {
      id: "Exemption Requested",
      dataLabels: {
        align: "left",
        x: 20,
        name: exemptionRequested,
      },
    },
    {
      id: "Exemption not Requested",
      dataLabels: {
        align: "left",
        x: 20,
        name: exemptionNotRequested,
      },
    },
    {
      id: "Exemption Accepted",
      dataLabels: {
        align: "left",
        x: 20,
        name: exemptionAccepted,
      },
    },
    {
      id: "Exemption not Accepted",
      dataLabels: {
        align: "left",
        x: 20,
        name: exemptionRejected,
      },
    },
    {
      id: "3DS Completed",
      dataLabels: {
        align: "left",
        x: 20,
        name: threeDSCompleted,
      },
    },
    {
      id: "3DS not Completed",
      dataLabels: {
        align: "left",
        x: 20,
        name: threeDSIncomplete,
      },
    },
    {
      id: "Authentication Success",
      dataLabels: {
        align: "right",
        x: 183,
        name: authSuccess,
      },
    },
    {
      id: "Authentication Failure",
      dataLabels: {
        align: "right",
        x: 183,
        name: authFailure,
      },
    },
  ]

  // Get values from transformed dictionary
  let exemptionRequested = valueDict->getInt("Exemption Requested", 0)
  let exemptionNotRequested = valueDict->getInt("Exemption not Requested", 0)
  let exemptionAccepted = valueDict->getInt("Exemption Accepted", 0)
  let exemptionRejected = valueDict->getInt("Exemption not Accepted", 0)
  let threeDSCompleted = valueDict->getInt("3DS Completed", 0)
  let threeDSIncomplete = valueDict->getInt("3DS not Completed", 0)
  let authSuccess = valueDict->getInt("Authentication Success", 0)
  let authFailure = valueDict->getInt("Authentication Failure", 0)

  // Create sankey flow data
  let processedData = [
    ("Total 3DS Payment Request", "Exemption Requested", exemptionRequested, sankyBlue),
    ("Total 3DS Payment Request", "Exemption not Requested", exemptionNotRequested, sankyRed),
    ("Exemption Requested", "Exemption Accepted", exemptionAccepted, sankyBlue),
    ("Exemption Requested", "Exemption not Accepted", exemptionRejected, sankyRed),
    ("Exemption not Requested", "3DS Completed", threeDSCompleted, sankyBlue),
    ("Exemption not Accepted", "3DS Completed", threeDSCompleted, sankyBlue),
    ("Exemption not Requested", "3DS not Completed", threeDSIncomplete, sankyRed),
    ("Exemption Accepted", "Authentication Success", authSuccess, sankyBlue),
    ("Exemption Accepted", "Authentication Failure", authFailure, sankyRed),
    ("3DS Completed", "Authentication Success", authSuccess, sankyBlue),
    ("3DS not Completed", "Authentication Failure", authFailure, sankyRed),
    ("3DS Completed", "Authentication Failure", authFailure, sankyRed),
  ]->Array.filter(item => {
    let (_, _, value, _) = item
    value > 0
  })

  let title = {
    text: "",
  }

  let colors = [
    sankyLightBlue, // "Total 3DS Payment Request"
    sankyLightBlue, // "Exemption Requested"
    sankyLightRed, // "Exemption not Requested"
    sankyLightBlue, // "Exemption Accepted"
    sankyLightRed, // "Exemption not Accepted"
    sankyLightBlue, // "3DS Completed"
    sankyLightRed, // "3DS not Completed"
    sankyLightBlue, // "Authentication Success"
    sankyLightRed, // "Authentication Failure"
  ]

  {data: processedData, nodes: sankeyNodes, title, colors}
}
