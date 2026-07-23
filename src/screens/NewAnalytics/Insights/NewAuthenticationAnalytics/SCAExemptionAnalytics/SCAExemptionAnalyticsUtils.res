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

let incrementCounter = (dict, key, count) => {
  dict->Dict.set(key, dict->getInt(key, 0) + count)
}

let scaExemptionResponseMapper = (sankeyDataArray: array<JSON.t>) => {
  let countersDict =
    [
      "total_3ds_payments",
      "exemption_requested",
      "exemption_not_requested",
      "exemption_accepted",
      "exemption_rejected",
      "accepted_frictionless",
      "rejected_frictionless",
      "rejected_challenge",
      "rejected_pending",
      "not_requested_frictionless",
      "not_requested_challenge",
      "not_requested_pending",
      "frictionless_auth_success",
      "frictionless_auth_failure",
      "frictionless_auth_pending",
      "challenge_auth_success",
      "challenge_auth_failure",
      "challenge_auth_pending",
    ]
    ->Array.map(key => (key, 0))
    ->Dict.fromArray

  sankeyDataArray->Array.forEach(item => {
    let itemDict = item->getDictFromJsonObject
    let count = itemDict->getInt("count", 0)
    let authStatus = itemDict->getString("authentication_status", "")
    let authenticationType = itemDict->getString("authentication_type", "")
    let exemptionRequested = itemDict->getOptionBool("exemption_requested")->Option.getOr(false)
    let exemptionAccepted =
      exemptionRequested && itemDict->getOptionBool("exemption_accepted")->Option.getOr(false)

    incrementCounter(countersDict, "total_3ds_payments", count)

    if exemptionRequested {
      incrementCounter(countersDict, "exemption_requested", count)
      if exemptionAccepted {
        incrementCounter(countersDict, "exemption_accepted", count)
      } else {
        incrementCounter(countersDict, "exemption_rejected", count)
      }
    } else {
      incrementCounter(countersDict, "exemption_not_requested", count)
    }

    // An approved exemption is always represented as a frictionless path.
    // For all other rows, pending is shown as its own path and completed
    // authentications use the authentication type returned by the API.
    let authenticationFlow = if exemptionAccepted {
      "frictionless"
    } else if authStatus == "pending" {
      "pending"
    } else {
      switch authenticationType {
      | "frictionless" => "frictionless"
      | _ => "challenge"
      }
    }

    let exemptionPath = if exemptionAccepted {
      "accepted"
    } else if exemptionRequested {
      "rejected"
    } else {
      "not_requested"
    }

    incrementCounter(countersDict, `${exemptionPath}_${authenticationFlow}`, count)

    switch authenticationFlow {
    | "frictionless" =>
      switch authStatus {
      | "success" => incrementCounter(countersDict, "frictionless_auth_success", count)
      | "failed" => incrementCounter(countersDict, "frictionless_auth_failure", count)
      | _ => incrementCounter(countersDict, "frictionless_auth_pending", count)
      }
    | "challenge" =>
      switch authStatus {
      | "success" => incrementCounter(countersDict, "challenge_auth_success", count)
      | "failed" => incrementCounter(countersDict, "challenge_auth_failure", count)
      | _ => incrementCounter(countersDict, "challenge_auth_pending", count)
      }
    | _ => ()
    }
  })

  let totalThreeDSPayments = countersDict->getInt("total_3ds_payments", 0)
  let exemptionRequested = countersDict->getInt("exemption_requested", 0)
  let exemptionNotRequested = countersDict->getInt("exemption_not_requested", 0)
  let exemptionAccepted = countersDict->getInt("exemption_accepted", 0)
  let exemptionRejected = countersDict->getInt("exemption_rejected", 0)
  let acceptedFrictionless = countersDict->getInt("accepted_frictionless", 0)
  let rejectedFrictionless = countersDict->getInt("rejected_frictionless", 0)
  let rejectedChallenge = countersDict->getInt("rejected_challenge", 0)
  let rejectedPending = countersDict->getInt("rejected_pending", 0)
  let notRequestedFrictionless = countersDict->getInt("not_requested_frictionless", 0)
  let notRequestedChallenge = countersDict->getInt("not_requested_challenge", 0)
  let notRequestedPending = countersDict->getInt("not_requested_pending", 0)
  let frictionlessAuthSuccess = countersDict->getInt("frictionless_auth_success", 0)
  let frictionlessAuthFailure = countersDict->getInt("frictionless_auth_failure", 0)
  let frictionlessAuthPending = countersDict->getInt("frictionless_auth_pending", 0)
  let challengeAuthSuccess = countersDict->getInt("challenge_auth_success", 0)
  let challengeAuthFailure = countersDict->getInt("challenge_auth_failure", 0)
  let challengeAuthPending = countersDict->getInt("challenge_auth_pending", 0)

  let frictionlessTotal =
    frictionlessAuthSuccess + frictionlessAuthFailure + frictionlessAuthPending
  let challengeTotal = challengeAuthSuccess + challengeAuthFailure + challengeAuthPending
  let pendingTotal = rejectedPending + notRequestedPending
  let authSuccess = frictionlessAuthSuccess + challengeAuthSuccess
  let authFailure =
    frictionlessAuthFailure +
    frictionlessAuthPending +
    challengeAuthFailure +
    challengeAuthPending +
    pendingTotal

  {
    totalThreeDSPayments,
    exemptionRequested,
    exemptionNotRequested,
    exemptionAccepted,
    exemptionRejected,
    acceptedFrictionless,
    rejectedFrictionless,
    rejectedChallenge,
    rejectedPending,
    notRequestedFrictionless,
    notRequestedChallenge,
    notRequestedPending,
    frictionlessTotal,
    challengeTotal,
    pendingTotal,
    frictionlessAuthSuccess,
    frictionlessAuthFailure,
    frictionlessAuthPending,
    challengeAuthSuccess,
    challengeAuthFailure,
    challengeAuthPending,
    authSuccess,
    authFailure,
  }
}

let scaExemptionMapper = (
  ~params: InsightsTypes.getObjects<scaExemption>,
): SankeyGraphTypes.sankeyPayload => {
  let {data} = params
  let frictionlessFailed = data.frictionlessAuthFailure + data.frictionlessAuthPending
  let challengeFailed = data.challengeAuthFailure + data.challengeAuthPending

  let processedData = [
    ("Total 3DS Requests", "Exemption Requested", data.exemptionRequested, sankeyBlueFlow),
    ("Total 3DS Requests", "No Exemption Requested", data.exemptionNotRequested, sankeyBlueFlow),
    ("Exemption Requested", "Exemption Approved", data.exemptionAccepted, sankeyGreenFlow),
    ("Exemption Requested", "Exemption Rejected", data.exemptionRejected, sankeyYellowFlow),
    ("Exemption Approved", "Frictionless", data.acceptedFrictionless, sankeyGreenFlow),
    ("Exemption Rejected", "Frictionless", data.rejectedFrictionless, sankeyBlueFlow),
    ("Exemption Rejected", "Challenge", data.rejectedChallenge, sankeyBlueFlow),
    ("Exemption Rejected", "Pending", data.rejectedPending, sankeyYellowFlow),
    ("No Exemption Requested", "Frictionless", data.notRequestedFrictionless, sankeyBlueFlow),
    ("No Exemption Requested", "Challenge", data.notRequestedChallenge, sankeyBlueFlow),
    ("No Exemption Requested", "Pending", data.notRequestedPending, sankeyYellowFlow),
    ("Frictionless", "Authentication Successful", data.frictionlessAuthSuccess, sankeyGreenFlow),
    ("Frictionless", "Frictionless Failed", frictionlessFailed, sankeyRedFlow),
    ("Challenge", "Authentication Successful", data.challengeAuthSuccess, sankeyGreenFlow),
    ("Challenge", "Challenge Failed", challengeFailed, sankeyRedFlow),
    ("Pending", "Authentication Failed", data.pendingTotal, sankeyRedFlow),
    ("Frictionless Failed", "Authentication Failed", frictionlessFailed, sankeyRedFlow),
    ("Challenge Failed", "Authentication Failed", challengeFailed, sankeyRedFlow),
  ]

  let sankeyNodes = [
    {
      id: "Total 3DS Requests",
      color: sankeyBlueNode,
      dataLabels: {align: "left", x: -120, name: data.totalThreeDSPayments},
      column: 0,
    },
    {
      id: "Exemption Requested",
      color: sankeyBlueNode,
      dataLabels: {align: "left", x: 20, name: data.exemptionRequested},
      column: 1,
    },
    {
      id: "No Exemption Requested",
      color: sankeyBlueNode,
      dataLabels: {align: "left", x: 20, name: data.exemptionNotRequested},
      column: 1,
    },
    {
      id: "Exemption Approved",
      color: sankeyGreenNode,
      dataLabels: {align: "left", x: 20, name: data.exemptionAccepted},
      column: 2,
    },
    {
      id: "Exemption Rejected",
      color: sankeyYellowNode,
      dataLabels: {align: "left", x: 20, name: data.exemptionRejected},
      column: 2,
    },
    {
      id: "Frictionless",
      color: sankeyGreenNode,
      dataLabels: {align: "left", x: 20, name: data.frictionlessTotal},
      column: 3,
    },
    {
      id: "Challenge",
      color: sankeyBlueNode,
      dataLabels: {align: "left", x: 20, name: data.challengeTotal},
      column: 3,
    },
    {
      id: "Pending",
      color: sankeyYellowNode,
      dataLabels: {align: "left", x: 20, name: data.pendingTotal},
      column: 3,
    },
    {
      id: "Frictionless Failed",
      color: sankeyRedNode,
      dataLabels: {align: "left", x: 20, name: frictionlessFailed},
      column: 4,
    },
    {
      id: "Challenge Failed",
      color: sankeyRedNode,
      dataLabels: {align: "left", x: 20, name: challengeFailed},
      column: 4,
    },
    {
      id: "Authentication Successful",
      color: sankeyGreenNode,
      dataLabels: {align: "right", x: 170, name: data.authSuccess},
      column: 5,
    },
    {
      id: "Authentication Failed",
      color: sankeyRedNode,
      dataLabels: {align: "right", x: 155, name: data.authFailure},
      column: 5,
    },
  ]

  let title = {text: ""}
  let colors = [
    sankeyBlueNode, // Total 3DS Requests
    sankeyBlueNode, // Exemption Requested
    sankeyBlueNode, // No Exemption Requested
    sankeyGreenNode, // Exemption Approved
    sankeyYellowNode, // Exemption Rejected
    sankeyGreenNode, // Frictionless
    sankeyBlueNode, // Challenge
    sankeyYellowNode, // Pending
    sankeyRedNode, // Frictionless Failed
    sankeyRedNode, // Challenge Failed
    sankeyGreenNode, // Authentication Successful
    sankeyRedNode, // Authentication Failed
  ]

  {data: processedData, nodes: sankeyNodes, title, colors}
}
