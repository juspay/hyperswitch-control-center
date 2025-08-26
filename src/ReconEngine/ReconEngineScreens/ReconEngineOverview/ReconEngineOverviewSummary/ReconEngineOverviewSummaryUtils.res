open ReconEngineOverviewUtils

open ReconEngineOverviewTypes

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
        name: "Pending",
        data: [expectedCount->Int.toFloat],
        color: pendingColor,
      },
      {
        name: "Matched",
        data: [postedCount->Int.toFloat],
        color: matchedColor,
      },
    ],
    labelFormatter: StackedBarGraphUtils.stackedBarGraphLabelFormatter(~statType=Default),
  }
}

let calculateTotals = (data: array<accountType>) => {
  data->Array.reduce(Dict.make()->ReconEngineOverviewUtils.accountItemToObjMapper, (acc, item) => {
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
  let _ = setGraphDirection(graph, direction)

  edges->Array.forEach(edge => {
    let _ = setGraphEdge(graph, edge.source, edge.target)
  })

  nodes->Array.forEach(node => {
    let _ = setGraphNode(
      graph,
      node.id,
      {
        "width": 420.0,
        "height": 200.0,
      },
    )
  })

  let _ = layoutGraph(graph)

  let layoutedNodes = nodes->Array.map(node => {
    let position = getGraphNode(graph, node.id)
    let x = position["x"] -. 360.0 /. 2.0
    let y = position["y"] -. 200.0 /. 2.0

    {
      ...node,
      position: {"x": x, "y": y},
    }
  })

  (layoutedNodes, edges)
}

open ReconEngineOverviewSummaryTypes

let accountTransactionCountsToObjMapper = dict => {
  open LogicUtils
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
  open LogicUtils
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

// Function to generate status data using transaction amounts instead of account balances
let generateStatusDataWithTransactionAmounts = (transactionData: accountTransactionData) => {
  open LogicUtils

  let formatAmountWithCurrency = (balance: balanceType): string => {
    `${Math.abs(balance.value)->valueFormatter(Amount)} ${balance.currency}`
  }

  [
    {
      statusType: Reconciled,
      data: {
        \"in": formatAmountWithCurrency(transactionData.posted_confirmation_amount),
        out: formatAmountWithCurrency(transactionData.posted_transaction_amount),
        inTxns: `${transactionData.posted_confirmation_count->Int.toString} txns`,
        outTxns: `${transactionData.posted_transaction_count->Int.toString} txns`,
      },
    },
    {
      statusType: Pending,
      data: {
        \"in": formatAmountWithCurrency(transactionData.pending_confirmation_amount),
        out: formatAmountWithCurrency(transactionData.pending_transaction_amount),
        inTxns: `${transactionData.pending_confirmation_count->Int.toString} txns`,
        outTxns: `${transactionData.pending_transaction_count->Int.toString} txns`,
      },
    },
    {
      statusType: Mismatched,
      data: {
        \"in": formatAmountWithCurrency(transactionData.mismatched_confirmation_amount),
        out: formatAmountWithCurrency(transactionData.mismatched_transaction_amount),
        inTxns: `${transactionData.mismatched_confirmation_count->Int.toString} txns`,
        outTxns: `${transactionData.mismatched_transaction_count->Int.toString} txns`,
      },
    },
  ]
}

let getAccountData = (accountData: array<accountType>, accountId: string): accountType => {
  accountData
  ->Array.find(account => account.account_id === accountId)
  ->Option.getOr(Dict.make()->ReconEngineOverviewUtils.accountItemToObjMapper)
}

let generateNodesAndEdgesWithTransactionAmounts = (
  reconRulesList: array<reconRuleType>,
  accountsData: array<accountType>,
  accountTransactionData: Dict.t<accountTransactionData>,
  allTransactions: array<ReconEngineTransactionsTypes.transactionPayload>,
  ~selectedNodeId: option<string>,
  ~onNodeClick: option<string => unit>=?,
) => {
  let allAccountIds =
    reconRulesList
    ->Array.reduce([], (acc, rule) => {
      let sourceIds = rule.sources->Array.map(source => source.account_id)
      let targetIds = rule.targets->Array.map(target => target.account_id)
      Array.concat(Array.concat(acc, sourceIds), targetIds)
    })
    ->Array.filter(id => id !== "")
    ->Array.reduce([], (acc, id) => {
      acc->Array.includes(id) ? acc : Array.concat(acc, [id])
    })

  let nodes = allAccountIds->Array.mapWithIndex((accountId, index) => {
    let accountData = getAccountData(accountsData, accountId)
    let transactionData =
      accountTransactionData
      ->Dict.get(accountId)
      ->Option.getOr(Dict.make()->accountTransactionDataToObjMapper)

    let statusData = generateStatusDataWithTransactionAmounts(transactionData)
    let nodeId = `${accountId}-node`
    let isSelected = switch selectedNodeId {
    | Some(id) => id === nodeId
    | None => false
    }

    {
      id: nodeId,
      ReconEngineOverviewSummaryTypes.\"type": "reconNode",
      position: {"x": Int.toFloat(index * 100), "y": 0.0},
      data: {
        label: accountData.account_name,
        statusData,
        selected: isSelected,
        onNodeClick: switch onNodeClick {
        | Some(clickHandler) => Some(() => clickHandler(nodeId))
        | None => None
        },
      },
    }
  })

  let edges = reconRulesList->Array.reduce([], (acc, rule) => {
    let ruleEdges = rule.sources->Array.reduce([], (sourceAcc, source) => {
      let targetEdges = rule.targets->Array.map(
        target => {
          let ruleTransactions =
            allTransactions->Array.filter(transaction => transaction.rule.rule_id === rule.rule_id)

          let postedCount =
            ruleTransactions
            ->Array.filter(
              transaction =>
                transaction.transaction_status->ReconEngineTransactionsUtils.getTransactionTypeFromString ===
                  Posted,
            )
            ->Array.length

          let totalCount =
            ruleTransactions
            ->Array.filter(
              transaction =>
                transaction.transaction_status->ReconEngineTransactionsUtils.getTransactionTypeFromString !==
                  Archived,
            )
            ->Array.length

          let percentage = if totalCount > 0 {
            let percentageValue = postedCount->Int.toFloat /. totalCount->Int.toFloat *. 100.0
            `${percentageValue->LogicUtils.valueFormatter(Rate)} Reconciled`
          } else {
            "0% Reconciled"
          }

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
            \"type": "smoothstep",
            animated: isHighlighted,
            markerEnd: {"type": ReactFlow.markerTypeArrowClosed},
            label: percentage,
            style: isHighlighted
              ? {"stroke": "#3b82f6", "strokeWidth": 1.5}
              : {"stroke": "#6b7280", "strokeWidth": 1.5},
          }
        },
      )
      Array.concat(sourceAcc, targetEdges)
    })
    Array.concat(acc, ruleEdges)
  })
  getLayoutedElements(nodes, edges, "LR")
}

let processEntriesForTransactionCounts = (
  entries: array<ReconEngineTransactionsTypes.transactionEntryType>,
  transaction: ReconEngineTransactionsTypes.transactionPayload,
  accountTransactionCounts: Dict.t<accountTransactionCounts>,
  counterType: [#transaction | #confirmation],
) => {
  entries->Array.forEach(entry => {
    let accountId = entry.account.account_id
    switch accountTransactionCounts->Dict.get(accountId) {
    | Some(accountData) =>
      switch transaction.transaction_status->ReconEngineTransactionsUtils.getTransactionTypeFromString {
      | Posted =>
        let updatedData = switch counterType {
        | #transaction => {
            ...accountData,
            posted_transaction_count: accountData.posted_transaction_count + 1,
          }
        | #confirmation => {
            ...accountData,
            posted_confirmation_count: accountData.posted_confirmation_count + 1,
          }
        }
        accountTransactionCounts->Dict.set(accountId, updatedData)
      | Expected =>
        let updatedData = switch counterType {
        | #transaction => {
            ...accountData,
            pending_transaction_count: accountData.pending_transaction_count + 1,
          }
        | #confirmation => {
            ...accountData,
            pending_confirmation_count: accountData.pending_confirmation_count + 1,
          }
        }
        accountTransactionCounts->Dict.set(accountId, updatedData)
      | Mismatched =>
        let updatedData = switch counterType {
        | #transaction => {
            ...accountData,
            mismatched_transaction_count: accountData.mismatched_transaction_count + 1,
          }
        | #confirmation => {
            ...accountData,
            mismatched_confirmation_count: accountData.mismatched_confirmation_count + 1,
          }
        }
        accountTransactionCounts->Dict.set(accountId, updatedData)
      | _ => ()
      }
    | None => ()
    }
  })
}

let processAllTransactions = (
  reconRulesList: array<reconRuleType>,
  allTransactions: array<ReconEngineTransactionsTypes.transactionPayload>,
) => {
  try {
    let accountTransactionCounts = Dict.make()

    let allAccountIds =
      reconRulesList
      ->Array.reduce([], (acc, rule) => {
        let sourceIds = rule.sources->Array.map(source => source.account_id)
        let targetIds = rule.targets->Array.map(target => target.account_id)
        Array.concat(Array.concat(acc, sourceIds), targetIds)
      })
      ->Array.reduce([], (acc, id) => {
        acc->Array.includes(id) ? acc : Array.concat(acc, [id])
      })

    allAccountIds->Array.forEach(accountId => {
      accountTransactionCounts->Dict.set(
        accountId,
        Dict.make()->accountTransactionCountsToObjMapper,
      )
    })

    allTransactions->Array.forEach((
      transaction: ReconEngineTransactionsTypes.transactionPayload,
    ) => {
      let creditEntries = transaction.entries->Array.filter(entry => entry.entry_type === "credit")
      let debitEntries = transaction.entries->Array.filter(entry => entry.entry_type === "debit")

      processEntriesForTransactionCounts(
        creditEntries,
        transaction,
        accountTransactionCounts,
        #transaction,
      )
      processEntriesForTransactionCounts(
        debitEntries,
        transaction,
        accountTransactionCounts,
        #confirmation,
      )
    })

    accountTransactionCounts
  } catch {
  | _ => Dict.make()
  }
}

let processAllTransactionsWithAmounts = (
  reconRulesList: array<reconRuleType>,
  allTransactions: array<ReconEngineTransactionsTypes.transactionPayload>,
) => {
  try {
    let accountTransactionData = Dict.make()

    let allAccountIds =
      reconRulesList
      ->Array.reduce([], (acc, rule) => {
        let sourceIds = rule.sources->Array.map(source => source.account_id)
        let targetIds = rule.targets->Array.map(target => target.account_id)
        Array.concat(Array.concat(acc, sourceIds), targetIds)
      })
      ->Array.reduce([], (acc, id) => {
        acc->Array.includes(id) ? acc : Array.concat(acc, [id])
      })

    allAccountIds->Array.forEach(accountId => {
      accountTransactionData->Dict.set(accountId, Dict.make()->accountTransactionDataToObjMapper)
    })

    allTransactions->Array.forEach((
      transaction: ReconEngineTransactionsTypes.transactionPayload,
    ) => {
      let creditEntries = transaction.entries->Array.filter(entry => entry.entry_type === "credit")
      let debitEntries = transaction.entries->Array.filter(entry => entry.entry_type === "debit")

      let transactionStatus =
        transaction.transaction_status->ReconEngineTransactionsUtils.getTransactionTypeFromString

      debitEntries->Array.forEach(entry => {
        let accountId = entry.account.account_id
        switch accountTransactionData->Dict.get(accountId) {
        | Some(accountData) =>
          let updatedData = switch transactionStatus {
          | Posted => {
              ...accountData,
              posted_confirmation_count: accountData.posted_confirmation_count + 1,
              posted_confirmation_amount: {
                value: accountData.posted_confirmation_amount.value +.
                transaction.debit_amount.value,
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

      // Process credit entries (transactions/out-flow)
      creditEntries->Array.forEach(entry => {
        let accountId = entry.account.account_id
        switch accountTransactionData->Dict.get(accountId) {
        | Some(accountData) =>
          let updatedData = switch transactionStatus {
          | Posted => {
              ...accountData,
              posted_transaction_count: accountData.posted_transaction_count + 1,
              posted_transaction_amount: {
                value: accountData.posted_transaction_amount.value +.
                transaction.credit_amount.value,
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
  } catch {
  | _ => Dict.make()
  }
}

let getHeaderText = (amountType: amountType, currency: string) => {
  switch amountType {
  | Reconciled => `Reconciled Amount (${currency})`
  | Pending => `Pending Amount (${currency})`
  | Mismatched => `Mismatched Amount (${currency})`
  }
}

let getAmountPair = (amountType: amountType, data: accountType) => {
  switch amountType {
  | Reconciled => (data.posted_debits, data.posted_credits)
  | Pending => (data.pending_debits, data.pending_credits)
  | Mismatched => (data.mismatched_debits, data.mismatched_credits)
  }
}

let convertTransactionDataToAccountData = (
  accountsData: array<accountType>,
  accountTransactionData: Dict.t<accountTransactionData>,
) => {
  accountsData->Array.map(account => {
    let transactionData =
      accountTransactionData
      ->Dict.get(account.account_id)
      ->Option.getOr(Dict.make()->accountTransactionDataToObjMapper)

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
  | Reconciled => "nd-check-circle-outline"
  | Pending => "nd-hour-glass-outline"
  | Mismatched => "nd-alert-triangle-outline"
  }
}

let getStatusText = (statusType: amountType) => {
  switch statusType {
  | Reconciled => "Reconciled"
  | Pending => "Pending"
  | Mismatched => "Mismatch"
  }
}

let allAmountTypes = [Reconciled, Pending, Mismatched]
let allSubHeaderTypes = [In, Out]
