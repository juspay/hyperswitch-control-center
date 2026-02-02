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

let scaExemptionResponseMapper = (sankeyDataArray: array<JSON.t>) => {
  let countersDict =
    [
      "total_3ds_payments",
      "exemption_requested",
      "exemption_not_requested",
      "exemption_accepted",
      "exemption_rejected",
      "not_requested_3ds_completed",
      "not_requested_3ds_incomplete",
      "rejected_3ds_completed",
      "rejected_3ds_incomplete",
      "accepted_auth_success",
      "accepted_auth_failure",
      "challenge_auth_success",
      "challenge_auth_failure",
      "challenge_incomplete_auth_failure",
    ]
    ->Array.map(key => (key, 0))
    ->Dict.fromArray

  sankeyDataArray->Array.forEach(item => {
    let itemDict = item->getDictFromJsonObject
    let count = itemDict->getInt("count", 0)
    let authStatus = itemDict->getString("authentication_status", "")
    let exemptionRequestedValue = itemDict->getOptionBool("exemption_requested")
    let exemptionAcceptedValue = itemDict->getOptionBool("exemption_accepted")

    countersDict->Dict.set(
      "total_3ds_payments",
      countersDict->getInt("total_3ds_payments", 0) + count,
    )

    let isExemptionRequested = exemptionRequestedValue->Option.getOr(false)

    let isExemptionAccepted = switch (exemptionRequestedValue, exemptionAcceptedValue) {
    | (Some(true), Some(true)) => true
    | _ => false
    }

    if isExemptionRequested {
      countersDict->Dict.set(
        "exemption_requested",
        countersDict->getInt("exemption_requested", 0) + count,
      )
    } else {
      countersDict->Dict.set(
        "exemption_not_requested",
        countersDict->getInt("exemption_not_requested", 0) + count,
      )
    }

    if isExemptionRequested && isExemptionAccepted {
      countersDict->Dict.set(
        "exemption_accepted",
        countersDict->getInt("exemption_accepted", 0) + count,
      )
    } else if isExemptionRequested {
      countersDict->Dict.set(
        "exemption_rejected",
        countersDict->getInt("exemption_rejected", 0) + count,
      )
    }

    let exemptionPath = if isExemptionRequested && isExemptionAccepted {
      "exemptionAcceptedPath"
    } else if isExemptionRequested {
      "exemptionRejectedPath"
    } else {
      "exemptionNotRequestedPath"
    }

    // route counts
    switch authStatus {
    | "success" =>
      switch exemptionPath {
      | "exemptionAcceptedPath" =>
        countersDict->Dict.set(
          "accepted_auth_success",
          countersDict->getInt("accepted_auth_success", 0) + count,
        )
      | "exemptionRejectedPath" =>
        countersDict->Dict.set(
          "rejected_3ds_completed",
          countersDict->getInt("rejected_3ds_completed", 0) + count,
        )
        countersDict->Dict.set(
          "challenge_auth_success",
          countersDict->getInt("challenge_auth_success", 0) + count,
        )
      | "exemptionNotRequestedPath" =>
        countersDict->Dict.set(
          "not_requested_3ds_completed",
          countersDict->getInt("not_requested_3ds_completed", 0) + count,
        )
        countersDict->Dict.set(
          "challenge_auth_success",
          countersDict->getInt("challenge_auth_success", 0) + count,
        )
      | _ => ()
      }

    | "failed" =>
      switch exemptionPath {
      | "exemptionAcceptedPath" =>
        countersDict->Dict.set(
          "accepted_auth_failure",
          countersDict->getInt("accepted_auth_failure", 0) + count,
        )
      | "exemptionRejectedPath" =>
        countersDict->Dict.set(
          "rejected_3ds_completed",
          countersDict->getInt("rejected_3ds_completed", 0) + count,
        )
        countersDict->Dict.set(
          "challenge_auth_failure",
          countersDict->getInt("challenge_auth_failure", 0) + count,
        )
      | "exemptionNotRequestedPath" =>
        countersDict->Dict.set(
          "not_requested_3ds_completed",
          countersDict->getInt("not_requested_3ds_completed", 0) + count,
        )
        countersDict->Dict.set(
          "challenge_auth_failure",
          countersDict->getInt("challenge_auth_failure", 0) + count,
        )
      | _ => ()
      }

    | "pending" => {
        switch exemptionPath {
        | "exemptionRejectedPath" =>
          countersDict->Dict.set(
            "rejected_3ds_incomplete",
            countersDict->getInt("rejected_3ds_incomplete", 0) + count,
          )
        | "exemptionNotRequestedPath" =>
          countersDict->Dict.set(
            "not_requested_3ds_incomplete",
            countersDict->getInt("not_requested_3ds_incomplete", 0) + count,
          )
        | _ => ()
        }

        countersDict->Dict.set(
          "challenge_incomplete_auth_failure",
          countersDict->getInt("challenge_incomplete_auth_failure", 0) + count,
        )
      }
    | _ =>
      switch exemptionPath {
      | "exemptionRejectedPath" =>
        countersDict->Dict.set(
          "rejected_3ds_incomplete",
          countersDict->getInt("rejected_3ds_incomplete", 0) + count,
        )
      | "exemptionNotRequestedPath" =>
        countersDict->Dict.set(
          "not_requested_3ds_incomplete",
          countersDict->getInt("not_requested_3ds_incomplete", 0) + count,
        )
      | _ => ()
      }
    }
  })
  let totalThreeDSPayments = countersDict->getInt("total_3ds_payments", 0)
  let exemptionRequested = countersDict->getInt("exemption_requested", 0)
  let exemptionNotRequested = countersDict->getInt("exemption_not_requested", 0)
  let exemptionAccepted = countersDict->getInt("exemption_accepted", 0)
  let exemptionRejected = countersDict->getInt("exemption_rejected", 0)

  let notRequested3dsCompleted = countersDict->getInt("not_requested_3ds_completed", 0)
  let notRequested3dsIncomplete = countersDict->getInt("not_requested_3ds_incomplete", 0)
  let rejected3dsCompleted = countersDict->getInt("rejected_3ds_completed", 0)
  let rejected3dsIncomplete = countersDict->getInt("rejected_3ds_incomplete", 0)

  let acceptedAuthSuccess = countersDict->getInt("accepted_auth_success", 0)
  let acceptedAuthFailure = countersDict->getInt("accepted_auth_failure", 0)

  let challengeAuthSuccess = countersDict->getInt("challenge_auth_success", 0)
  let challengeAuthFailure = countersDict->getInt("challenge_auth_failure", 0)
  let challengeIncompleteAuthFailure = countersDict->getInt("challenge_incomplete_auth_failure", 0)

  let threeDSCompleted = notRequested3dsCompleted + rejected3dsCompleted
  let threeDSIncomplete = notRequested3dsIncomplete + rejected3dsIncomplete

  let authSuccess = acceptedAuthSuccess + challengeAuthSuccess
  let authFailure = acceptedAuthFailure + challengeAuthFailure + challengeIncompleteAuthFailure

  {
    totalThreeDSPayments,
    exemptionRequested,
    exemptionNotRequested,
    exemptionAccepted,
    exemptionRejected,
    threeDSCompleted,
    threeDSIncomplete,
    authSuccess,
    authFailure,
    notRequested3dsCompleted,
    notRequested3dsIncomplete,
    rejected3dsCompleted,
    rejected3dsIncomplete,
    acceptedAuthSuccess,
    acceptedAuthFailure,
    challengeAuthSuccess,
    challengeAuthFailure,
    challengeIncompleteAuthFailure,
  }
}

let scaExemptionMapper = (
  ~params: InsightsTypes.getObjects<scaExemption>,
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

  let notRequested3dsCompleted = data.notRequested3dsCompleted
  let notRequested3dsIncomplete = data.notRequested3dsIncomplete
  let rejected3dsCompleted = data.rejected3dsCompleted
  let rejected3dsIncomplete = data.rejected3dsIncomplete

  let acceptedAuthSuccess = data.acceptedAuthSuccess
  let acceptedAuthFailure = data.acceptedAuthFailure
  let challengeAuthSuccess = data.challengeAuthSuccess
  let challengeAuthFailure = data.challengeAuthFailure
  let challengeIncompleteAuthFailure = data.challengeIncompleteAuthFailure

  let valueDict =
    [
      ("Total 3DS Payment Request", totalThreeDSPayments),
      ("Exempt Req", exemptionRequested),
      ("No Exempt Req", exemptionNotRequested),
      ("Exempt Accept", exemptionAccepted),
      ("Exempt Reject", exemptionRejected),
      ("No Exempt 3DS Done", notRequested3dsCompleted),
      ("No Exempt 3DS Pending", notRequested3dsIncomplete),
      ("Rejected 3DS Done", rejected3dsCompleted),
      ("Rejected 3DS Pending", rejected3dsIncomplete),
      ("Exempted Success", acceptedAuthSuccess),
      ("Exempted Failure", acceptedAuthFailure),
      ("Challenge Success", challengeAuthSuccess),
      ("Challenge Failure", challengeAuthFailure),
      ("Challenge Pending", challengeIncompleteAuthFailure),
      ("3DS Done", threeDSCompleted),
      ("3DS Pending", threeDSIncomplete),
      ("Authentication Success", authSuccess),
      ("Authentication Failure", authFailure),
    ]
    ->Array.filter(((_, v)) => v > 0)
    ->PaymentsLifeCycleUtils.transformData

  let sankeyNodes = [
    {
      id: "Total 3DS Payment Request",
      dataLabels: {align: "left", x: -140, name: totalThreeDSPayments},
      column: 0,
    },
    {
      id: "Exempt Req",
      dataLabels: {align: "left", x: 20, name: exemptionRequested},
      column: 1,
    },
    {
      id: "No Exempt Req",
      dataLabels: {align: "left", x: 20, name: exemptionNotRequested},
      column: 1,
    },
    {
      id: "Exempt Accept",
      dataLabels: {align: "left", x: 20, name: exemptionAccepted},
      column: 2,
    },
    {
      id: "Exempt Reject",
      dataLabels: {align: "left", x: 20, name: exemptionRejected},
      column: 2,
    },
    {
      id: "No Exempt 3DS Done",
      dataLabels: {align: "left", x: 20, name: notRequested3dsCompleted},
      column: 2,
    },
    {
      id: "No Exempt 3DS Pending",
      dataLabels: {align: "left", x: 20, name: notRequested3dsIncomplete},
      column: 2,
    },
    {
      id: "Rejected 3DS Done",
      dataLabels: {align: "left", x: 20, name: rejected3dsCompleted},
      column: 3,
    },
    {
      id: "Rejected 3DS Pending",
      dataLabels: {align: "left", x: 20, name: rejected3dsIncomplete},
      column: 3,
    },
    {
      id: "3DS Done",
      dataLabels: {align: "left", x: 20, name: threeDSCompleted},
      column: 4,
    },
    {
      id: "3DS Pending",
      dataLabels: {align: "left", x: 20, name: threeDSIncomplete},
      column: 4,
    },
    {
      id: "Exempted Success",
      dataLabels: {align: "left", x: 20, name: acceptedAuthSuccess},
      column: 5,
    },
    {
      id: "Exempted Failure",
      dataLabels: {align: "left", x: 20, name: acceptedAuthFailure},
      column: 5,
    },
    {
      id: "Challenge Success",
      dataLabels: {align: "left", x: 20, name: challengeAuthSuccess},
      column: 5,
    },
    {
      id: "Challenge Failure",
      dataLabels: {align: "left", x: 20, name: challengeAuthFailure},
      column: 5,
    },
    {
      id: "Challenge Pending",
      dataLabels: {align: "left", x: 20, name: challengeIncompleteAuthFailure},
      column: 5,
    },
    {
      id: "Authentication Success",
      dataLabels: {align: "right", x: 155, name: authSuccess},
      column: 6,
    },
    {
      id: "Authentication Failure",
      dataLabels: {align: "right", x: 145, name: authFailure},
      column: 6,
    },
  ]

  let exemptionRequestedVal = valueDict->getInt("Exempt Req", 0)
  let exemptionNotRequestedVal = valueDict->getInt("No Exempt Req", 0)
  let exemptionAcceptedVal = valueDict->getInt("Exempt Accept", 0)
  let exemptionRejectedVal = valueDict->getInt("Exempt Reject", 0)

  let notRequested3dsCompletedVal = valueDict->getInt("No Exempt 3DS Done", 0)
  let notRequested3dsIncompleteVal = valueDict->getInt("No Exempt 3DS Pending", 0)

  let rejected3dsCompletedVal = valueDict->getInt("Rejected 3DS Done", 0)
  let rejected3dsIncompleteVal = valueDict->getInt("Rejected 3DS Pending", 0)

  let acceptedAuthSuccessVal = valueDict->getInt("Exempted Success", 0)
  let acceptedAuthFailureVal = valueDict->getInt("Exempted Failure", 0)

  let challengeAuthSuccessVal = valueDict->getInt("Challenge Success", 0)
  let challengeAuthFailureVal = valueDict->getInt("Challenge Failure", 0)
  let challengeIncompleteAuthFailureVal = valueDict->getInt("Challenge Pending", 0)

  let processedData = [
    ("Total 3DS Payment Request", "Exempt Req", exemptionRequestedVal, sankeyBlueFlow),
    ("Exempt Req", "Exempt Accept", exemptionAcceptedVal, sankeyBlueFlow),
    ("Exempt Accept", "Exempted Success", acceptedAuthSuccessVal, sankeyGreenFlow),
    ("Exempt Accept", "Exempted Failure", acceptedAuthFailureVal, sankeyRedFlow),
    ("Exempt Req", "Exempt Reject", exemptionRejectedVal, sankeyYellowFlow),
    ("Exempt Reject", "Rejected 3DS Done", rejected3dsCompletedVal, sankeyBlueFlow),
    ("Exempt Reject", "Rejected 3DS Pending", rejected3dsIncompleteVal, sankeyRedFlow),
    ("Total 3DS Payment Request", "No Exempt Req", exemptionNotRequestedVal, sankeyBlueFlow),
    ("No Exempt Req", "No Exempt 3DS Done", notRequested3dsCompletedVal, sankeyBlueFlow),
    ("No Exempt Req", "No Exempt 3DS Pending", notRequested3dsIncompleteVal, sankeyRedFlow),
    ("Rejected 3DS Done", "3DS Done", rejected3dsCompletedVal, sankeyBlueFlow),
    ("Rejected 3DS Pending", "3DS Pending", rejected3dsIncompleteVal, sankeyRedFlow),
    ("No Exempt 3DS Done", "3DS Done", notRequested3dsCompletedVal, sankeyBlueFlow),
    ("No Exempt 3DS Pending", "3DS Pending", notRequested3dsIncompleteVal, sankeyRedFlow),
    ("3DS Done", "Challenge Success", challengeAuthSuccessVal, sankeyGreenFlow),
    ("3DS Done", "Challenge Failure", challengeAuthFailureVal, sankeyRedFlow),
    ("3DS Pending", "Challenge Pending", challengeIncompleteAuthFailureVal, sankeyRedFlow),
    ("Exempted Success", "Authentication Success", acceptedAuthSuccessVal, sankeyGreenFlow),
    ("Challenge Success", "Authentication Success", challengeAuthSuccessVal, sankeyGreenFlow),
    ("Exempted Failure", "Authentication Failure", acceptedAuthFailureVal, sankeyRedFlow),
    ("Challenge Failure", "Authentication Failure", challengeAuthFailureVal, sankeyRedFlow),
    (
      "Challenge Pending",
      "Authentication Failure",
      challengeIncompleteAuthFailureVal,
      sankeyRedFlow,
    ),
  ]

  let title = {text: ""}

  let colors = [
    sankeyBlueNode, // Total 3DS Payment Request
    sankeyBlueNode, // Exempt Req
    sankeyBlueNode, // Exempt Accept
    sankeyGreenNode, // Exempted Success
    sankeyRedNode, // Exempted Failure
    sankeyYellowNode, // Exempt Reject
    sankeyBlueNode, // Rejected 3DS Done
    sankeyRedNode, // Rejected 3DS Pending
    sankeyBlueNode, // No Exempt Req
    sankeyBlueNode, // No Exempt 3DS Done
    sankeyRedNode, // No Exempt 3DS Pending
    sankeyBlueNode, // 3DS Done
    sankeyRedNode, // 3DS Pending
    sankeyGreenNode, // Challenge Success
    sankeyRedNode, // Challenge Failure
    sankeyRedNode, // Challenge Pending
    sankeyGreenNode, // Authentication Success
    sankeyRedNode, // Authentication Failure
  ]

  {data: processedData, nodes: sankeyNodes, title, colors}
}
