open SankeyGraphTypes
open LogicUtils
open SCAExemptionAnalyticsTypes

let sankeyGreenNode = "#69AF7D"
let sankeyGreenFlow = "#B1D6B5"
let sankeyRedNode = "#F57F6C"
let sankeyRedFlow = "#FDD4CD"
let sankeyBlueNode = "#6AA1F2"
let sankeyBlueFlow = "#BCD7FA"
let sankeyYellowNode = "#D99530"
let sankeyYellowFlow = "#F5D9A8"

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
    let exemptionRequestedValue = itemDict->getOptionBool("exemption_requested")
    let exemptionAcceptedValue = itemDict->getOptionBool("exemption_accepted")

    // Total 3DS
    countersDict->Dict.set(
      "total_3ds_payments",
      countersDict->getInt("total_3ds_payments", 0) + count,
    )

    // Exemption requested
    switch exemptionRequestedValue {
    | Some(true) =>
      countersDict->Dict.set(
        "exemption_requested",
        countersDict->getInt("exemption_requested", 0) + count,
      )
    | Some(false) | None =>
      countersDict->Dict.set(
        "exemption_not_requested",
        countersDict->getInt("exemption_not_requested", 0) + count,
      )
    }

    // Exemption accepted/rejected (only if requested)
    switch (exemptionRequestedValue, exemptionAcceptedValue) {
    | (Some(true), Some(true)) =>
      countersDict->Dict.set(
        "exemption_accepted",
        countersDict->getInt("exemption_accepted", 0) + count,
      )
    | (Some(true), Some(false)) =>
      countersDict->Dict.set(
        "exemption_rejected",
        countersDict->getInt("exemption_rejected", 0) + count,
      )
    | _ => ()
    }

    switch authStatus {
    | "success" => {
        countersDict->Dict.set("auth_success", countersDict->getInt("auth_success", 0) + count)

        // Count 3DS completed unless exemption accepted (no challenge)
        switch (exemptionRequestedValue, exemptionAcceptedValue) {
        | (Some(true), Some(true)) => () // skip challenge
        | _ =>
          countersDict->Dict.set("3ds_completed", countersDict->getInt("3ds_completed", 0) + count)
        }
      }

    | "failed" => {
        countersDict->Dict.set("auth_failure", countersDict->getInt("auth_failure", 0) + count)

        // Count 3DS completed unless exemption accepted (no challenge)
        switch (exemptionRequestedValue, exemptionAcceptedValue) {
        | (Some(true), Some(true)) => () // skip challenge
        | _ =>
          countersDict->Dict.set("3ds_completed", countersDict->getInt("3ds_completed", 0) + count)
        }
      }

    | "pending" =>
      countersDict->Dict.set("3ds_incomplete", countersDict->getInt("3ds_incomplete", 0) + count)
    | _ =>
      countersDict->Dict.set("3ds_incomplete", countersDict->getInt("3ds_incomplete", 0) + count)
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
        x: -140,
        name: totalThreeDSPayments,
      },
      column: 0,
    },
    {
      id: "Exemption Requested",
      dataLabels: {
        align: "left",
        x: 25,
        name: exemptionRequested,
      },
      column: 1,
    },
    {
      id: "Exemption not Requested",
      dataLabels: {
        align: "left",
        x: 25,
        name: exemptionNotRequested,
      },
      column: 1,
    },
    {
      id: "Exemption Accepted",
      dataLabels: {
        align: "left",
        x: 25,
        name: exemptionAccepted,
      },
      column: 2,
    },
    {
      id: "Exemption not Accepted",
      dataLabels: {
        align: "left",
        x: 25,
        name: exemptionRejected,
      },
      column: 2,
    },
    {
      id: "3DS Completed",
      dataLabels: {
        align: "left",
        x: 25,
        name: threeDSCompleted,
      },
      column: 3,
    },
    {
      id: "3DS not Completed",
      dataLabels: {
        align: "left",
        x: 25,
        name: threeDSIncomplete,
      },
      column: 3,
      offset: 270,
    },
    {
      id: "Authentication Success",
      dataLabels: {
        align: "right",
        x: 155,
        name: authSuccess,
      },
      column: 4,
    },
    {
      id: "Authentication Failure",
      dataLabels: {
        align: "right",
        x: 145,
        name: authFailure,
      },
      column: 4,
    },
  ]

  let exemptionRequestedVal = valueDict->getInt("Exemption Requested", 0)
  let exemptionNotRequestedVal = valueDict->getInt("Exemption not Requested", 0)
  let exemptionAcceptedVal = valueDict->getInt("Exemption Accepted", 0)
  let exemptionRejectedVal = valueDict->getInt("Exemption not Accepted", 0)
  let threeDSCompletedVal = valueDict->getInt("3DS Completed", 0)
  let threeDSIncompleteVal = valueDict->getInt("3DS not Completed", 0)
  let authSuccessVal = valueDict->getInt("Authentication Success", 0)
  let authFailureVal = valueDict->getInt("Authentication Failure", 0)

  // Create sankey flow data
  let processedData = [
    ("Total 3DS Payment Request", "Exemption Requested", exemptionRequestedVal, sankeyBlueFlow),
    (
      "Total 3DS Payment Request",
      "Exemption not Requested",
      exemptionNotRequestedVal,
      sankeyBlueFlow,
    ),
    ("Exemption Requested", "Exemption Accepted", exemptionAcceptedVal, sankeyBlueFlow),
    ("Exemption Requested", "Exemption not Accepted", exemptionRejectedVal, sankeyYellowFlow),
    ("Exemption not Requested", "3DS Completed", threeDSCompletedVal, sankeyBlueFlow),
    ("Exemption not Requested", "3DS not Completed", threeDSIncompleteVal, sankeyRedFlow),
    ("Exemption not Accepted", "3DS Completed", threeDSCompletedVal, sankeyYellowFlow),
    ("Exemption Accepted", "Authentication Success", authSuccessVal, sankeyGreenFlow),
    ("Exemption Accepted", "Authentication Failure", authFailureVal, sankeyRedFlow),
    ("3DS Completed", "Authentication Success", authSuccessVal, sankeyGreenFlow),
    ("3DS Completed", "Authentication Failure", authFailureVal, sankeyRedFlow),
    ("3DS not Completed", "Authentication Failure", authFailureVal, sankeyRedFlow),
  ]->Array.filter(item => {
    let (_, _, value, _) = item
    value > 0
  })

  let title = {
    text: "",
  }

  let colors = [
    sankeyBlueNode, // "Total 3DS Payment Request"
    sankeyBlueNode, // "Exemption Requested"
    sankeyBlueNode, // "Exemption not Requested"
    sankeyBlueNode, // "Exemption Accepted"
    sankeyYellowNode, // "Exemption not Accepted"
    sankeyBlueNode, // "3DS Completed"
    sankeyRedNode, // "3DS not Completed"
    sankeyGreenNode, // "Authentication Success"
    sankeyRedNode, // "Authentication Failure"
  ]

  {data: processedData, nodes: sankeyNodes, title, colors}
}
