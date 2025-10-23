open ReconEngineOverviewUtils
open LogicUtils

let getSummaryStackedBarGraphData = (
  ~postedCount: int,
  ~mismatchedCount: int,
  ~expectedCount: int,
) => {
  {
    StackedBarGraphTypes.categories: ["Transactions"],
    data: [
      {
        name: "Mismatched",
        data: [mismatchedCount->Int.toFloat],
        color: mismatchedColor,
      },
      {
        name: "Expected",
        data: [expectedCount->Int.toFloat],
        color: expectedColor,
      },
      {
        name: "Posted",
        data: [postedCount->Int.toFloat],
        color: postedColor,
      },
    ],
    labelFormatter: StackedBarGraphUtils.stackedBarGraphLabelFormatter(~statType=Default),
  }
}

let calculateTotals = (data: array<ReconEngineTypes.accountType>) => {
  data->Array.reduce(Dict.make()->getOverviewAccountPayloadFromDict, (acc, item) => {
    {
      ...acc,
      posted_credits: {
        value: Math.abs(acc.posted_credits.value) +. Math.abs(item.posted_credits.value),
        currency: item.posted_credits.currency,
      },
      posted_debits: {
        value: Math.abs(acc.posted_debits.value) +. Math.abs(item.posted_debits.value),
        currency: item.posted_debits.currency,
      },
      pending_credits: {
        value: Math.abs(acc.pending_credits.value) +. Math.abs(item.pending_credits.value),
        currency: item.pending_credits.currency,
      },
      pending_debits: {
        value: Math.abs(acc.pending_debits.value) +. Math.abs(item.pending_debits.value),
        currency: item.pending_debits.currency,
      },
      expected_credits: {
        value: Math.abs(acc.expected_credits.value) +. Math.abs(item.expected_credits.value),
        currency: item.expected_credits.currency,
      },
      expected_debits: {
        value: Math.abs(acc.expected_debits.value) +. Math.abs(item.expected_debits.value),
        currency: item.expected_debits.currency,
      },
      mismatched_credits: {
        value: Math.abs(acc.mismatched_credits.value) +. Math.abs(item.mismatched_credits.value),
        currency: item.mismatched_credits.currency,
      },
      mismatched_debits: {
        value: Math.abs(acc.mismatched_debits.value) +. Math.abs(item.mismatched_debits.value),
        currency: item.mismatched_debits.currency,
      },
    }
  })
}

let getLayoutedElements = (
  nodes: array<ReconEngineOverviewSummaryTypes.nodeType>,
  edges: array<ReconEngineOverviewSummaryTypes.edgeType>,
  direction: string,
) => {
  open ReactFlow

  let graph = createDagreGraph()
  setGraphDirection(graph, direction)

  edges->Array.forEach(edge => {
    setGraphEdge(graph, edge.source, edge.target)
  })

  nodes->Array.forEach(node => {
    setGraphNode(
      graph,
      node.id,
      {
        width: 420.0,
        height: 200.0,
      },
    )
  })

  layoutGraph(graph)->ignore

  let layoutedNodes = nodes->Array.map(node => {
    let position = getGraphNode(graph, node.id)
    let x = position.x -. 360.0 /. 2.0
    let y = position.y -. 200.0 /. 2.0

    {
      ...node,
      position: {x, y},
    }
  })

  (layoutedNodes, edges)
}

open ReconEngineOverviewSummaryTypes

let accountTransactionCountsToObjMapper = dict => {
  {
    posted_confirmation_count: dict->getInt("posted_confirmation_count", 0),
    pending_confirmation_count: dict->getInt("pending_confirmation_count", 0),
    mismatched_confirmation_count: dict->getInt("mismatched_confirmation_count", 0),
    posted_transaction_count: dict->getInt("posted_transaction_count", 0),
    pending_transaction_count: dict->getInt("pending_transaction_count", 0),
    mismatched_transaction_count: dict->getInt("mismatched_transaction_count", 0),
  }
}

let accountTransactionDataToObjMapper = dict => {
  {
    posted_confirmation_count: dict->getInt("posted_confirmation_count", 0),
    pending_confirmation_count: dict->getInt("pending_confirmation_count", 0),
    mismatched_confirmation_count: dict->getInt("mismatched_confirmation_count", 0),
    posted_transaction_count: dict->getInt("posted_transaction_count", 0),
    pending_transaction_count: dict->getInt("pending_transaction_count", 0),
    mismatched_transaction_count: dict->getInt("mismatched_transaction_count", 0),
    posted_confirmation_amount: {value: 0.0, currency: "USD"},
    pending_confirmation_amount: {value: 0.0, currency: "USD"},
    mismatched_confirmation_amount: {value: 0.0, currency: "USD"},
    posted_transaction_amount: {value: 0.0, currency: "USD"},
    pending_transaction_amount: {value: 0.0, currency: "USD"},
    mismatched_transaction_amount: {value: 0.0, currency: "USD"},
  }
}

let generateStatusDataWithTransactionAmounts = (transactionData: accountTransactionData) => {
  let formatAmountWithCurrency = (balance: ReconEngineTypes.balanceType): string => {
    `${Math.abs(balance.value)->valueFormatter(Amount)} ${balance.currency}`
  }

  [
    {
      statusType: Reconciled,
      data: {
        inAmount: formatAmountWithCurrency(transactionData.posted_confirmation_amount),
        outAmount: formatAmountWithCurrency(transactionData.posted_transaction_amount),
        inTxns: `${transactionData.posted_confirmation_count->Int.toString} txns`,
        outTxns: `${transactionData.posted_transaction_count->Int.toString} txns`,
      },
    },
    {
      statusType: Pending,
      data: {
        inAmount: formatAmountWithCurrency(transactionData.pending_confirmation_amount),
        outAmount: formatAmountWithCurrency(transactionData.pending_transaction_amount),
        inTxns: `${transactionData.pending_confirmation_count->Int.toString} txns`,
        outTxns: `${transactionData.pending_transaction_count->Int.toString} txns`,
      },
    },
    {
      statusType: Mismatched,
      data: {
        inAmount: formatAmountWithCurrency(transactionData.mismatched_confirmation_amount),
        outAmount: formatAmountWithCurrency(transactionData.mismatched_transaction_amount),
        inTxns: `${transactionData.mismatched_confirmation_count->Int.toString} txns`,
        outTxns: `${transactionData.mismatched_transaction_count->Int.toString} txns`,
      },
    },
  ]
}

let getAccountData = (
  accountData: array<ReconEngineTypes.accountType>,
  accountId: string,
): ReconEngineTypes.accountType => {
  accountData
  ->Array.find(account => account.account_id === accountId)
  ->Option.getOr(Dict.make()->getOverviewAccountPayloadFromDict)
}

let getAllAccountIds = (reconRulesList: array<ReconEngineTypes.reconRuleType>) => {
  reconRulesList
  ->Array.flatMap(rule =>
    Array.concat(
      rule.sources->Array.map(source => source.account_id),
      rule.targets->Array.map(target => target.account_id),
    )
  )
  ->getUniqueArray
}

let summarizeTransactions = (ruleTransactions: array<ReconEngineTypes.transactionType>): (
  int,
  int,
) => {
  ruleTransactions->Array.reduce((0, 0), (
    (postedCount, totalCount),
    t: ReconEngineTypes.transactionType,
  ) => {
    switch t.transaction_status {
    | Posted => (postedCount + 1, totalCount + 1)
    | Archived => (postedCount, totalCount)
    | _ => (postedCount, totalCount + 1)
    }
  })
}

let getPercentageLabel = (~postedCount, ~totalCount) =>
  if totalCount > 0 {
    let percentageValue = postedCount->Int.toFloat /. totalCount->Int.toFloat *. 100.0
    `${percentageValue->LogicUtils.valueFormatter(Rate)} Reconciled`
  } else {
    "0% Reconciled"
  }
let makeEdge = (
  ~source: ReconEngineTypes.reconRuleAccountRefType,
  ~target: ReconEngineTypes.reconRuleAccountRefType,
  ~ruleTransactions,
  ~selectedNodeId,
) => {
  let (postedCount, totalCount) = summarizeTransactions(ruleTransactions)
  let label = getPercentageLabel(~postedCount, ~totalCount)
  let sourceNodeId = `${source.account_id}-node`
  let targetNodeId = `${target.account_id}-node`
  let isHighlighted = switch selectedNodeId {
  | Some(id) => id === sourceNodeId || id === targetNodeId
  | None => false
  }
  {
    id: `${source.account_id}-to-${target.account_id}`,
    ReconEngineOverviewSummaryTypes.source: sourceNodeId,
    target: targetNodeId,
    edgeType: "smoothstep",
    animated: isHighlighted,
    markerEnd: {edgeMarkerType: ReactFlow.markerTypeArrowClosed},
    label,
    style: isHighlighted
      ? {stroke: highlightStrokeColor, strokeWidth: 1.5}
      : {stroke: normalStrokeColor, strokeWidth: 1.5},
  }
}
let getEdges = (
  ~reconRulesList: array<ReconEngineTypes.reconRuleType>,
  ~allTransactions: array<ReconEngineTypes.transactionType>,
  ~selectedNodeId,
) =>
  reconRulesList->Array.flatMap(rule =>
    rule.sources->Array.flatMap(source =>
      rule.targets->Array.map(
        target => {
          let ruleTransactions = allTransactions->Array.filter(t => t.rule.rule_id === rule.rule_id)
          makeEdge(~source, ~target, ~ruleTransactions, ~selectedNodeId)
        },
      )
    )
  )

let getTransactionsData = (
  accountTransactionData: Dict.t<accountTransactionData>,
  accountId: string,
): accountTransactionData => {
  accountTransactionData
  ->getvalFromDict(accountId)
  ->Option.getOr(Dict.make()->accountTransactionDataToObjMapper)
}

let generateNodesAndEdgesWithTransactionAmounts = (
  reconRulesList: array<ReconEngineTypes.reconRuleType>,
  accountsData: array<ReconEngineTypes.accountType>,
  accountTransactionData: Dict.t<accountTransactionData>,
  allTransactions: array<ReconEngineTypes.transactionType>,
  ~selectedNodeId: option<string>,
  ~onNodeClick: option<string => unit>=?,
) => {
  let allAccountIds = getAllAccountIds(reconRulesList)

  let nodes = allAccountIds->Array.mapWithIndex((accountId, index) => {
    let accountData = getAccountData(accountsData, accountId)
    let transactionData = getTransactionsData(accountTransactionData, accountId)

    let statusData = generateStatusDataWithTransactionAmounts(transactionData)
    let accountType = accountData.account_type
    let nodeId = `${accountId}-node`
    let isSelected = switch selectedNodeId {
    | Some(id) => id === nodeId
    | None => false
    }

    {
      id: nodeId,
      ReconEngineOverviewSummaryTypes.nodeType: "reconNode",
      position: {x: Int.toFloat(index * 100), y: 0.0},
      data: {
        label: accountData.account_name,
        accountType,
        statusData,
        selected: isSelected,
        onNodeClick: switch onNodeClick {
        | Some(clickHandler) => Some(() => clickHandler(nodeId))
        | None => None
        },
      },
    }
  })

  let edges = getEdges(~reconRulesList, ~allTransactions, ~selectedNodeId)

  getLayoutedElements(nodes, edges, "LR")
}

let processAllTransactionsWithAmounts = (
  reconRulesList: array<ReconEngineTypes.reconRuleType>,
  allTransactions: array<ReconEngineTypes.transactionType>,
) => {
  let accountTransactionData = Dict.make()

  let allAccountIds = getAllAccountIds(reconRulesList)

  allAccountIds->Array.forEach(accountId => {
    accountTransactionData->Dict.set(accountId, Dict.make()->accountTransactionDataToObjMapper)
  })

  allTransactions->Array.forEach((transaction: ReconEngineTypes.transactionType) => {
    let creditEntries = transaction.entries->Array.filter(entry => entry.entry_type === Credit)
    let debitEntries = transaction.entries->Array.filter(entry => entry.entry_type === Debit)

    debitEntries->Array.forEach(entry => {
      let accountId = entry.account.account_id
      switch accountTransactionData->getvalFromDict(accountId) {
      | Some(accountData) =>
        let updatedData = switch transaction.transaction_status {
        | Posted => {
            ...accountData,
            posted_confirmation_count: accountData.posted_confirmation_count + 1,
            posted_confirmation_amount: {
              value: accountData.posted_confirmation_amount.value +. transaction.debit_amount.value,
              currency: transaction.debit_amount.currency,
            },
          }
        | Expected => {
            ...accountData,
            pending_confirmation_count: accountData.pending_confirmation_count + 1,
            pending_confirmation_amount: {
              value: accountData.pending_confirmation_amount.value +.
              transaction.debit_amount.value,
              currency: transaction.debit_amount.currency,
            },
          }
        | Mismatched => {
            ...accountData,
            mismatched_confirmation_count: accountData.mismatched_confirmation_count + 1,
            mismatched_confirmation_amount: {
              value: accountData.mismatched_confirmation_amount.value +.
              transaction.debit_amount.value,
              currency: transaction.debit_amount.currency,
            },
          }
        | _ => accountData
        }
        accountTransactionData->Dict.set(accountId, updatedData)
      | None => ()
      }
    })

    creditEntries->Array.forEach(entry => {
      let accountId = entry.account.account_id
      switch accountTransactionData->getvalFromDict(accountId) {
      | Some(accountData) =>
        let updatedData = switch transaction.transaction_status {
        | Posted => {
            ...accountData,
            posted_transaction_count: accountData.posted_transaction_count + 1,
            posted_transaction_amount: {
              value: accountData.posted_transaction_amount.value +. transaction.credit_amount.value,
              currency: transaction.credit_amount.currency,
            },
          }
        | Expected => {
            ...accountData,
            pending_transaction_count: accountData.pending_transaction_count + 1,
            pending_transaction_amount: {
              value: accountData.pending_transaction_amount.value +.
              transaction.credit_amount.value,
              currency: transaction.credit_amount.currency,
            },
          }
        | Mismatched => {
            ...accountData,
            mismatched_transaction_count: accountData.mismatched_transaction_count + 1,
            mismatched_transaction_amount: {
              value: accountData.mismatched_transaction_amount.value +.
              transaction.credit_amount.value,
              currency: transaction.credit_amount.currency,
            },
          }
        | _ => accountData
        }
        accountTransactionData->Dict.set(accountId, updatedData)
      | None => ()
      }
    })
  })

  accountTransactionData
}

let getHeaderText = (amountType: amountType, currency: string) => {
  switch amountType {
  | Reconciled => `Reconciled Amount (${currency})`
  | Pending => `Pending Amount (${currency})`
  | Mismatched => `Mismatched Amount (${currency})`
  }
}

let getAmountPair = (amountType: amountType, data: ReconEngineTypes.accountType) => {
  switch amountType {
  | Reconciled => (data.posted_debits, data.posted_credits)
  | Pending => (data.pending_debits, data.pending_credits)
  | Mismatched => (data.mismatched_debits, data.mismatched_credits)
  }
}

let convertTransactionDataToAccountData = (
  accountsData: array<ReconEngineTypes.accountType>,
  accountTransactionData: Dict.t<accountTransactionData>,
) => {
  accountsData->Array.map(account => {
    let transactionData = getTransactionsData(accountTransactionData, account.account_id)

    {
      ...account,
      posted_debits: transactionData.posted_confirmation_amount,
      posted_credits: transactionData.posted_transaction_amount,
      pending_debits: transactionData.pending_confirmation_amount,
      pending_credits: transactionData.pending_transaction_amount,
      mismatched_debits: transactionData.mismatched_confirmation_amount,
      mismatched_credits: transactionData.mismatched_transaction_amount,
      expected_debits: transactionData.pending_confirmation_amount,
      expected_credits: transactionData.pending_transaction_amount,
    }
  })
}

let calculateTotalsFromTransactionAmounts = (
  accountTransactionData: Dict.t<accountTransactionData>,
) => {
  let allTransactionData = accountTransactionData->Dict.valuesToArray

  allTransactionData->Array.reduce(Dict.make()->accountTransactionDataToObjMapper, (acc, item) => {
    {
      posted_confirmation_amount: {
        value: Math.abs(acc.posted_confirmation_amount.value) +.
        Math.abs(item.posted_confirmation_amount.value),
        currency: item.posted_confirmation_amount.currency,
      },
      posted_transaction_amount: {
        value: Math.abs(acc.posted_transaction_amount.value) +.
        Math.abs(item.posted_transaction_amount.value),
        currency: item.posted_transaction_amount.currency,
      },
      pending_confirmation_amount: {
        value: Math.abs(acc.pending_confirmation_amount.value) +.
        Math.abs(item.pending_confirmation_amount.value),
        currency: item.pending_confirmation_amount.currency,
      },
      pending_transaction_amount: {
        value: Math.abs(acc.pending_transaction_amount.value) +.
        Math.abs(item.pending_transaction_amount.value),
        currency: item.pending_transaction_amount.currency,
      },
      mismatched_confirmation_amount: {
        value: Math.abs(acc.mismatched_confirmation_amount.value) +.
        Math.abs(item.mismatched_confirmation_amount.value),
        currency: item.mismatched_confirmation_amount.currency,
      },
      mismatched_transaction_amount: {
        value: Math.abs(acc.mismatched_transaction_amount.value) +.
        Math.abs(item.mismatched_transaction_amount.value),
        currency: item.mismatched_transaction_amount.currency,
      },
      posted_confirmation_count: acc.posted_confirmation_count + item.posted_confirmation_count,
      pending_confirmation_count: acc.pending_confirmation_count + item.pending_confirmation_count,
      mismatched_confirmation_count: acc.mismatched_confirmation_count +
      item.mismatched_confirmation_count,
      posted_transaction_count: acc.posted_transaction_count + item.posted_transaction_count,
      pending_transaction_count: acc.pending_transaction_count + item.pending_transaction_count,
      mismatched_transaction_count: acc.mismatched_transaction_count +
      item.mismatched_transaction_count,
    }
  })
}

let getStatusIcon = (statusType: amountType) => {
  switch statusType {
  | Reconciled => ("nd-check-circle-outline", "text-green-500")
  | Pending => ("nd-hour-glass-outline", "text-yellow-500")
  | Mismatched => ("nd-alert-triangle-outline", "text-red-500")
  }
}

let allAmountTypes = [Reconciled, Pending, Mismatched]
let allSubHeaderTypes = [Debit, Credit]
