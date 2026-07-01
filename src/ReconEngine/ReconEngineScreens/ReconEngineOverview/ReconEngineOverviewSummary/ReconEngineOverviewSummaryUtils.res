open ReconEngineOverviewUtils
open LogicUtils
open CurrencyFormatUtils
open ReconEngineTypes

let matchedColor = "#52A87A"
let exceptionColor = "#D95F5F"
let expectedColor = "#4A90E2"
let missingColor = "#D4A032"
let matchRateColor = "#8B72CC"

let roundCurrency = (value: float, currency: string): float => {
  let precision = CurrencyUtils.getAmountPrecisionDigits(currency)
  let factor = Math.pow(10.0, ~exp=precision->Int.toFloat)
  Math.round(value *. factor) /. factor
}

let calculateTotals = (data: array<accountType>) => {
  data->Array.reduce(Dict.make()->getOverviewAccountPayloadFromDict, (acc, item) => {
    {
      ...acc,
      matched_credits: {
        value: Math.abs(acc.matched_credits.value) +. Math.abs(item.matched_credits.value),
        currency: item.matched_credits.currency,
      },
      matched_debits: {
        value: Math.abs(acc.matched_debits.value) +. Math.abs(item.matched_debits.value),
        currency: item.matched_debits.currency,
      },
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
    matched_confirmation_count: dict->getInt("matched_confirmation_count", 0),
    pending_confirmation_count: dict->getInt("pending_confirmation_count", 0),
    mismatched_confirmation_count: dict->getInt("mismatched_confirmation_count", 0),
    matched_transaction_count: dict->getInt("matched_transaction_count", 0),
    pending_transaction_count: dict->getInt("pending_transaction_count", 0),
    mismatched_transaction_count: dict->getInt("mismatched_transaction_count", 0),
  }
}

let accountTransactionDataToObjMapper = dict => {
  {
    matched_confirmation_count: dict->getInt("matched_confirmation_count", 0),
    pending_confirmation_count: dict->getInt("pending_confirmation_count", 0),
    mismatched_confirmation_count: dict->getInt("mismatched_confirmation_count", 0),
    matched_transaction_count: dict->getInt("matched_transaction_count", 0),
    pending_transaction_count: dict->getInt("pending_transaction_count", 0),
    mismatched_transaction_count: dict->getInt("mismatched_transaction_count", 0),
    matched_confirmation_amount: {value: 0.0, currency: "USD"},
    pending_confirmation_amount: {value: 0.0, currency: "USD"},
    mismatched_confirmation_amount: {value: 0.0, currency: "USD"},
    matched_transaction_amount: {value: 0.0, currency: "USD"},
    pending_transaction_amount: {value: 0.0, currency: "USD"},
    mismatched_transaction_amount: {value: 0.0, currency: "USD"},
  }
}

let generateStatusDataWithTransactionAmounts = (transactionData: accountTransactionData) => {
  let formatAmountWithCurrency = (balance: balanceType): string => {
    `${Math.abs(balance.value)->valueFormatter(Amount)} ${balance.currency}`
  }

  [
    {
      statusType: MatchedAmount,
      reconStatusData: {
        inAmount: formatAmountWithCurrency(transactionData.matched_confirmation_amount),
        outAmount: formatAmountWithCurrency(transactionData.matched_transaction_amount),
        inTxns: `${transactionData.matched_confirmation_count->Int.toString} txns`,
        outTxns: `${transactionData.matched_transaction_count->Int.toString} txns`,
      },
    },
    {
      statusType: PendingAmount,
      reconStatusData: {
        inAmount: formatAmountWithCurrency(transactionData.pending_confirmation_amount),
        outAmount: formatAmountWithCurrency(transactionData.pending_transaction_amount),
        inTxns: `${transactionData.pending_confirmation_count->Int.toString} txns`,
        outTxns: `${transactionData.pending_transaction_count->Int.toString} txns`,
      },
    },
    {
      statusType: MismatchedAmount,
      reconStatusData: {
        inAmount: formatAmountWithCurrency(transactionData.mismatched_confirmation_amount),
        outAmount: formatAmountWithCurrency(transactionData.mismatched_transaction_amount),
        inTxns: `${transactionData.mismatched_confirmation_count->Int.toString} txns`,
        outTxns: `${transactionData.mismatched_transaction_count->Int.toString} txns`,
      },
    },
  ]
}

let getAccountData = (accountData: array<accountType>, accountId: string): accountType => {
  accountData
  ->Array.find(account => account.account_id === accountId)
  ->Option.getOr(Dict.make()->getOverviewAccountPayloadFromDict)
}

let getAllAccountIds = (reconRulesList: array<ReconEngineRulesTypes.rulePayload>) => {
  reconRulesList
  ->Array.flatMap(rule =>
    switch rule.strategy {
    | OneToOne(oneToOne) =>
      switch oneToOne {
      | SingleSingle(data) => [data.source_account.account_id, data.target_account.account_id]
      | SingleMany(data) => [data.source_account.account_id, data.target_account.account_id]
      | ManySingle(data) => [data.source_account.account_id, data.target_account.account_id]
      | ManyMany(data) => [data.source_account.account_id, data.target_account.account_id]
      | UnknownOneToOneStrategy => []
      }
    | OneToMany(oneToMany) =>
      switch oneToMany {
      | SingleSingle(data) => {
          let targetAccountIds = switch data.target_accounts {
          | Percentage({targets})
          | Fixed({targets}) =>
            targets->Array.map(((target, _)) => target.account_id)
          | UnknownTargetsType => []
          }
          [data.source_account.account_id, ...targetAccountIds]
        }
      | UnknownOneToManyStrategy => []
      }
    | UnknownReconStrategy => []
    }
  )
  ->getUniqueArray
}

let summarizeTransactions = (ruleTransactions: array<transactionType>): (int, int) => {
  ruleTransactions->Array.reduce((0, 0), ((matchedCount, totalCount), t: transactionType) => {
    switch t.transaction_status {
    | Matched(Force)
    | Matched(Manual)
    | Matched(Auto)
    | Posted(Manual)
    | Matched(WithTolerance) => (matchedCount + 1, totalCount + 1)
    | PartiallyReconciled
    | Missing
    | DataMismatch
    | Expected
    | OverAmount(Expected)
    | UnderAmount(Expected)
    | OverAmount(Mismatch)
    | UnderAmount(Mismatch)
    | SplitMismatch
    | CurrencyMismatch => (matchedCount, totalCount + 1)
    | Archived
    | Void
    | UnknownDomainTransactionStatus
    | Matched(UnknownDomainTransactionMatchedStatus)
    | Posted(UnknownDomainTransactionPostedStatus)
    | OverAmount(UnknownDomainTransactionAmountMismatchStatus)
    | UnderAmount(UnknownDomainTransactionAmountMismatchStatus) => (matchedCount, totalCount)
    }
  })
}

let getPercentageLabel = (~matchedCount, ~totalCount) =>
  if totalCount > 0 {
    let percentageValue = matchedCount->Int.toFloat /. totalCount->Int.toFloat *. 100.0
    `${percentageValue->valueFormatter(Rate)} Matched`
  } else {
    "0% Matched"
  }

let getCompactRuleType = (strategy: ReconEngineRulesTypes.reconStrategyType) => {
  open ReconEngineRulesTypes
  switch strategy {
  | OneToOne(SingleSingle(_)) => "Direct Match"
  | OneToOne(SingleMany(_)) => "Split Match"
  | OneToOne(ManySingle(_)) => "Lumpsum Match"
  | OneToOne(ManyMany(_)) => "Batch Match"
  | OneToMany(SingleSingle(_)) => "Consolidated Match"
  | UnknownReconStrategy
  | OneToOne(UnknownOneToOneStrategy)
  | OneToMany(UnknownOneToManyStrategy) => "Unknown"
  }
}

let makeEdge = (
  ~rule: ReconEngineRulesTypes.rulePayload,
  ~sourceAccountId: string,
  ~targetAccountId: string,
  ~ruleTransactions,
  ~selectedNodeId,
) => {
  let (matchedCount, totalCount) = summarizeTransactions(ruleTransactions)
  let percentageLabel = getPercentageLabel(~matchedCount, ~totalCount)
  let sourceNodeId = `${sourceAccountId}-node`
  let targetNodeId = `${targetAccountId}-node`
  let isHighlighted = Some(sourceNodeId) == selectedNodeId || Some(targetNodeId) == selectedNodeId
  {
    id: `${sourceAccountId}-to-${targetAccountId}`,
    ReconEngineOverviewSummaryTypes.source: sourceNodeId,
    target: targetNodeId,
    edgeType: "reconEdge",
    animated: isHighlighted,
    markerEnd: {edgeMarkerType: ReactFlow.markerTypeArrowClosed},
    data: {
      ruleType: getCompactRuleType(rule.strategy),
      percentageLabel,
    },
    style: isHighlighted
      ? {stroke: highlightStrokeColor, strokeWidth: 2.0}
      : {stroke: normalStrokeColor, strokeWidth: 2.0},
  }
}
let getEdges = (
  ~reconRulesList: array<ReconEngineRulesTypes.rulePayload>,
  ~allTransactions: array<transactionType>,
  ~selectedNodeId,
) =>
  reconRulesList->Array.flatMap(rule => {
    let ruleTransactions = allTransactions->Array.filter(t => t.rule.rule_id === rule.rule_id)
    switch rule.strategy {
    | OneToOne(oneToOne) =>
      switch oneToOne {
      | SingleSingle(data) => [
          makeEdge(
            ~rule,
            ~sourceAccountId=data.source_account.account_id,
            ~targetAccountId=data.target_account.account_id,
            ~ruleTransactions,
            ~selectedNodeId,
          ),
        ]
      | SingleMany(data) => [
          makeEdge(
            ~rule,
            ~sourceAccountId=data.source_account.account_id,
            ~targetAccountId=data.target_account.account_id,
            ~ruleTransactions,
            ~selectedNodeId,
          ),
        ]
      | ManySingle(data) => [
          makeEdge(
            ~rule,
            ~sourceAccountId=data.source_account.account_id,
            ~targetAccountId=data.target_account.account_id,
            ~ruleTransactions,
            ~selectedNodeId,
          ),
        ]
      | ManyMany(data) => [
          makeEdge(
            ~rule,
            ~sourceAccountId=data.source_account.account_id,
            ~targetAccountId=data.target_account.account_id,
            ~ruleTransactions,
            ~selectedNodeId,
          ),
        ]
      | UnknownOneToOneStrategy => []
      }
    | OneToMany(oneToMany) =>
      switch oneToMany {
      | SingleSingle(data) => {
          let targetAccounts = switch data.target_accounts {
          | Percentage({targets})
          | Fixed({targets}) => targets
          | UnknownTargetsType => []
          }
          targetAccounts->Array.map(((target, _)) =>
            makeEdge(
              ~rule,
              ~sourceAccountId=data.source_account.account_id,
              ~targetAccountId=target.account_id,
              ~ruleTransactions,
              ~selectedNodeId,
            )
          )
        }
      | UnknownOneToManyStrategy => []
      }
    | UnknownReconStrategy => []
    }
  })

let getTransactionsData = (
  accountTransactionData: Dict.t<accountTransactionData>,
  accountId: string,
): accountTransactionData => {
  accountTransactionData->getValueFromDict(
    accountId,
    Dict.make()->accountTransactionDataToObjMapper,
  )
}

let generateNodesAndEdgesWithTransactionAmounts = (
  reconRulesList: array<ReconEngineRulesTypes.rulePayload>,
  accountsData: array<accountType>,
  accountTransactionData: Dict.t<accountTransactionData>,
  allTransactions: array<transactionType>,
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

let calculateMetrics = (
  accountId: string,
  transactions: array<transactionType>,
  entryType: entryDirectionType,
) => {
  let matchingEntries =
    transactions->Array.flatMap(transaction =>
      transaction.entries->Array.filter(entry =>
        entry.account.account_id === accountId && entry.entry_type === entryType
      )
    )
  let amount = matchingEntries->Array.reduce(0.0, (sum, entry) => sum +. entry.amount.value)
  let count =
    transactions
    ->Array.filter(t =>
      t.entries->Array.some(e => e.account.account_id === accountId && e.entry_type === entryType)
    )
    ->Array.length
  (count, amount)
}

let makeAmountData = (amount, currency): balanceType => {
  {
    value: roundCurrency(amount, currency),
    currency,
  }
}

let processAllTransactionsWithAmounts = (
  reconRulesList: array<ReconEngineRulesTypes.rulePayload>,
  allTransactions: array<transactionType>,
  accountsData: array<accountType>,
) => {
  let accountTransactionData = Dict.make()
  let allAccountIds = getAllAccountIds(reconRulesList)

  allAccountIds->Array.forEach(accountId => {
    accountTransactionData->Dict.set(accountId, Dict.make()->accountTransactionDataToObjMapper)
  })

  let processStatusMetrics = (accountId, transactions) => {
    let (confirmationCount, debitAmount) = calculateMetrics(accountId, transactions, Debit)
    let (transactionCount, creditAmount) = calculateMetrics(accountId, transactions, Credit)
    (confirmationCount, debitAmount, transactionCount, creditAmount)
  }

  allAccountIds->Array.forEach(accountId => {
    let accountTransactions = allTransactions->Array.filter(transaction => {
      transaction.entries->Array.some(entry => entry.account.account_id === accountId)
    })

    let matchedTransactions = accountTransactions->Array.filter(t =>
      switch t.transaction_status {
      | Matched(Force)
      | Matched(Manual)
      | Matched(Auto)
      | Posted(Manual)
      | Matched(WithTolerance) => true
      | OverAmount(Expected)
      | UnderAmount(Expected)
      | Expected
      | Missing
      | PartiallyReconciled
      | OverAmount(Mismatch)
      | UnderAmount(Mismatch)
      | DataMismatch
      | Archived
      | Void
      | SplitMismatch
      | CurrencyMismatch
      | Matched(UnknownDomainTransactionMatchedStatus)
      | Posted(UnknownDomainTransactionPostedStatus)
      | OverAmount(UnknownDomainTransactionAmountMismatchStatus)
      | UnderAmount(UnknownDomainTransactionAmountMismatchStatus)
      | UnknownDomainTransactionStatus => false
      }
    )

    let pendingTransactions = accountTransactions->Array.filter(t =>
      switch t.transaction_status {
      | Expected
      | Missing
      | PartiallyReconciled
      | OverAmount(Expected)
      | UnderAmount(Expected) => true
      | DataMismatch
      | OverAmount(Mismatch)
      | UnderAmount(Mismatch)
      | SplitMismatch
      | CurrencyMismatch
      | Matched(Force)
      | Matched(Manual)
      | Matched(Auto)
      | Matched(WithTolerance)
      | Posted(Manual)
      | Archived
      | Void
      | Matched(UnknownDomainTransactionMatchedStatus)
      | Posted(UnknownDomainTransactionPostedStatus)
      | OverAmount(UnknownDomainTransactionAmountMismatchStatus)
      | UnderAmount(UnknownDomainTransactionAmountMismatchStatus)
      | UnknownDomainTransactionStatus => false
      }
    )
    let mismatchedTransactions = accountTransactions->Array.filter(t =>
      switch t.transaction_status {
      | OverAmount(Mismatch)
      | UnderAmount(Mismatch)
      | DataMismatch
      | CurrencyMismatch
      | SplitMismatch => true
      | OverAmount(Expected)
      | UnderAmount(Expected)
      | Expected
      | Missing
      | PartiallyReconciled
      | Matched(Force)
      | Matched(Manual)
      | Matched(Auto)
      | Matched(WithTolerance)
      | Posted(Manual)
      | Archived
      | Void
      | Matched(UnknownDomainTransactionMatchedStatus)
      | Posted(UnknownDomainTransactionPostedStatus)
      | OverAmount(UnknownDomainTransactionAmountMismatchStatus)
      | UnderAmount(UnknownDomainTransactionAmountMismatchStatus)
      | UnknownDomainTransactionStatus => false
      }
    )

    let (
      matchedConfirmationCount,
      matchedDebitAmount,
      matchedTransactionCount,
      matchedCreditAmount,
    ) = processStatusMetrics(accountId, matchedTransactions)

    let (
      pendingConfirmationCount,
      pendingDebitAmount,
      pendingTransactionCount,
      pendingCreditAmount,
    ) = processStatusMetrics(accountId, pendingTransactions)

    let (
      mismatchedConfirmationCount,
      mismatchedDebitAmount,
      mismatchedTransactionCount,
      mismatchedCreditAmount,
    ) = processStatusMetrics(accountId, mismatchedTransactions)

    let currency = getAccountData(accountsData, accountId).currency

    let updatedData = {
      matched_confirmation_count: matchedConfirmationCount,
      matched_confirmation_amount: makeAmountData(matchedDebitAmount, currency),
      pending_confirmation_count: pendingConfirmationCount,
      pending_confirmation_amount: makeAmountData(pendingDebitAmount, currency),
      mismatched_confirmation_count: mismatchedConfirmationCount,
      mismatched_confirmation_amount: makeAmountData(mismatchedDebitAmount, currency),
      matched_transaction_count: matchedTransactionCount,
      matched_transaction_amount: makeAmountData(matchedCreditAmount, currency),
      pending_transaction_count: pendingTransactionCount,
      pending_transaction_amount: makeAmountData(pendingCreditAmount, currency),
      mismatched_transaction_count: mismatchedTransactionCount,
      mismatched_transaction_amount: makeAmountData(mismatchedCreditAmount, currency),
    }
    accountTransactionData->Dict.set(accountId, updatedData)
  })

  accountTransactionData
}

let getHeaderText = (amountType: amountType, currency: string) => {
  switch amountType {
  | MatchedAmount => `Matched Amount (${currency})`
  | PendingAmount => `Pending Amount (${currency})`
  | MismatchedAmount => `Mismatched Amount (${currency})`
  }
}

let getAmountPair = (amountType: amountType, data: accountType) => {
  switch amountType {
  | MatchedAmount => (data.matched_debits, data.matched_credits)
  | PendingAmount => (data.pending_debits, data.pending_credits)
  | MismatchedAmount => (data.mismatched_debits, data.mismatched_credits)
  }
}

let convertTransactionDataToAccountData = (
  accountsData: array<accountType>,
  accountTransactionData: Dict.t<accountTransactionData>,
) => {
  accountsData->Array.map(account => {
    let transactionData = getTransactionsData(accountTransactionData, account.account_id)

    {
      ...account,
      matched_debits: transactionData.matched_confirmation_amount,
      matched_credits: transactionData.matched_transaction_amount,
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
      matched_confirmation_amount: {
        value: Math.abs(acc.matched_confirmation_amount.value) +.
        Math.abs(item.matched_confirmation_amount.value),
        currency: item.matched_confirmation_amount.currency,
      },
      matched_transaction_amount: {
        value: Math.abs(acc.matched_transaction_amount.value) +.
        Math.abs(item.matched_transaction_amount.value),
        currency: item.matched_transaction_amount.currency,
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
      matched_confirmation_count: acc.matched_confirmation_count + item.matched_confirmation_count,
      pending_confirmation_count: acc.pending_confirmation_count + item.pending_confirmation_count,
      mismatched_confirmation_count: acc.mismatched_confirmation_count +
      item.mismatched_confirmation_count,
      matched_transaction_count: acc.matched_transaction_count + item.matched_transaction_count,
      pending_transaction_count: acc.pending_transaction_count + item.pending_transaction_count,
      mismatched_transaction_count: acc.mismatched_transaction_count +
      item.mismatched_transaction_count,
    }
  })
}

let getStatusIcon = (statusType: amountType) => {
  switch statusType {
  | MatchedAmount => ("nd-check-circle-outline", "text-nd_green-600")
  | PendingAmount => ("nd-hour-glass-outline", "text-nd_yellow-600")
  | MismatchedAmount => ("nd-alert-triangle-outline", "text-nd_red-500")
  }
}

let allAmountTypes = [MatchedAmount, PendingAmount, MismatchedAmount]
let allSubHeaderTypes = [DebitAmount, CreditAmount]

let getSourceAndAllTargetAccountIds = (ruleDetails: ReconEngineRulesTypes.rulePayload) => {
  switch ruleDetails.strategy {
  | OneToOne(oneToOne) =>
    switch oneToOne {
    | SingleSingle(data) => (data.source_account.account_id, [data.target_account.account_id])
    | SingleMany(data) => (data.source_account.account_id, [data.target_account.account_id])
    | ManySingle(data) => (data.source_account.account_id, [data.target_account.account_id])
    | ManyMany(data) => (data.source_account.account_id, [data.target_account.account_id])
    | UnknownOneToOneStrategy => ("", [])
    }
  | OneToMany(oneToMany) =>
    switch oneToMany {
    | SingleSingle(data) => {
        let targetIds = switch data.target_accounts {
        | Percentage({targets})
        | Fixed({targets}) =>
          targets->Array.map(((target, _)) => target.account_id)
        | UnknownTargetsType => []
        }
        (data.source_account.account_id, targetIds)
      }
    | UnknownOneToManyStrategy => ("", [])
    }
  | UnknownReconStrategy => ("", [])
  }
}

let getTotalCount = (~overviewRules: array<overviewRulesResponse>) =>
  overviewRules->Array.reduce(0, (acc, rule) => {
    let totalCount = rule.status_breakdown->Array.reduce(0, (statusAcc, status) => {
      switch status.status {
      | Archived | Void => statusAcc
      | _ => statusAcc + status.count
      }
    })

    acc + totalCount
  })

let getMatchedCount = (~overviewRules: array<overviewRulesResponse>) => {
  overviewRules->Array.reduce(0, (acc, rule) => {
    let matchedCount = rule.status_breakdown->Array.reduce(0, (statusAcc, status) => {
      switch status.status {
      | Matched(Auto)
      | Matched(Force)
      | Matched(WithTolerance)
      | Matched(Manual)
      | Posted(Manual) =>
        statusAcc + status.count
      | CurrencyMismatch
      | SplitMismatch
      | OverAmount(Expected)
      | Expected
      | Missing
      | OverAmount(Mismatch)
      | UnderAmount(Expected)
      | UnderAmount(Mismatch)
      | DataMismatch
      | PartiallyReconciled
      | Void
      | Archived
      | UnknownDomainTransactionStatus
      | Matched(UnknownDomainTransactionMatchedStatus)
      | Posted(UnknownDomainTransactionPostedStatus)
      | OverAmount(UnknownDomainTransactionAmountMismatchStatus)
      | UnderAmount(UnknownDomainTransactionAmountMismatchStatus) => statusAcc
      }
    })

    acc + matchedCount
  })
}

let getOpenExceptions = (
  ~overviewRules: array<overviewRulesResponse>,
  ~processingEntries: array<processingEntryType>,
) => {
  let txnExceptions = overviewRules->Array.reduce(0, (acc, rule) => {
    let exceptionCount = rule.status_breakdown->Array.reduce(0, (statusAcc, status) => {
      switch status.status {
      | OverAmount(Expected)
      | UnderAmount(Expected)
      | OverAmount(Mismatch)
      | UnderAmount(Mismatch)
      | DataMismatch
      | CurrencyMismatch
      | SplitMismatch
      | PartiallyReconciled
      | Expected
      | Missing =>
        statusAcc + status.count
      | Posted(Manual)
      | Matched(Auto)
      | Matched(Manual)
      | Matched(Force)
      | Matched(WithTolerance)
      | Void
      | Archived
      | UnknownDomainTransactionStatus
      | Matched(UnknownDomainTransactionMatchedStatus)
      | Posted(UnknownDomainTransactionPostedStatus)
      | OverAmount(UnknownDomainTransactionAmountMismatchStatus)
      | UnderAmount(UnknownDomainTransactionAmountMismatchStatus) => statusAcc
      }
    })

    acc + exceptionCount
  })

  txnExceptions + processingEntries->Array.length
}

let getValueAtRisk = (~overviewRules: array<overviewRulesResponse>) =>
  overviewRules->Array.reduce(0.0, (acc, rule) => {
    let valueAtRisk = rule.status_breakdown->Array.reduce(0.0, (statusAcc, status) => {
      switch status.status {
      | UnderAmount(Mismatch)
      | OverAmount(Mismatch)
      | OverAmount(Expected)
      | UnderAmount(Expected)
      | SplitMismatch =>
        statusAcc +. Math.abs(status.credit_amount.value -. status.debit_amount.value)
      | _ => statusAcc
      }
    })

    acc +. valueAtRisk
  })

let getExpectedValue = (~overviewRules: array<overviewRulesResponse>) =>
  overviewRules->Array.reduce(0.0, (acc, rule) => {
    let expectedValue = rule.status_breakdown->Array.reduce(0.0, (statusAcc, status) => {
      switch status.status {
      | Expected | Missing => statusAcc +. Math.abs(status.credit_amount.value)
      | _ => statusAcc
      }
    })

    acc +. expectedValue
  })

let getCurrency = (~overviewRules: array<overviewRulesResponse>) =>
  overviewRules
  ->Array.flatMap(rule => rule.status_breakdown)
  ->Array.map(status => status.credit_amount.currency)
  ->getValueFromArray(0, "")

let getStatCards = (
  ~overviewRules: array<overviewRulesResponse>,
  ~processingEntries: array<processingEntryType>=[],
) => {
  let totalCount = getTotalCount(~overviewRules)
  let matchedCount = getMatchedCount(~overviewRules)
  let openExceptions = getOpenExceptions(~overviewRules, ~processingEntries)
  let valueAtRisk = getValueAtRisk(~overviewRules)
  let expectedValue = getExpectedValue(~overviewRules)
  let currency = getCurrency(~overviewRules)

  let matchRate =
    totalCount === 0 ? 0.0 : matchedCount->Int.toFloat /. totalCount->Int.toFloat *. 100.0

  let path = "v1/recon-engine/exceptions/recon"

  [
    {
      statCardTitle: MatchRate,
      statCardValue: Percentage(matchRate),
      statCardIcon: FontAwesome("percent"),
      statCardDescription: `${matchedCount->Int.toString} of ${totalCount->Int.toString} matched`,
      statCardType: Info,
      statCardUrl: None,
    },
    {
      statCardTitle: OpenExceptions,
      statCardValue: Number(openExceptions),
      statCardIcon: CustomIcon(
        <Icon name="nd-information-triangle" size=14 className="text-nd_gray-500" />,
      ),
      statCardDescription: "staging + txn exceptions",
      statCardType: Attention,
      statCardUrl: Some(path),
    },
    {
      statCardTitle: ValueAtRisk,
      statCardValue: Amount(valueAtRisk, currency),
      statCardIcon: CustomIcon(<Icon name="lock-icon" size=14 className="text-nd_gray-500" />),
      statCardDescription: "mismatch variance exposure",
      statCardType: Attention,
      statCardUrl: Some(path),
    },
    {
      statCardTitle: ExpectedValue,
      statCardValue: Amount(expectedValue, currency),
      statCardIcon: CustomIcon(<Icon name="history" size=14 className="text-nd_gray-500" />),
      statCardDescription: "amount expected",
      statCardType: Info,
      statCardUrl: Some(path),
    },
  ]
}

let getAutoMatchCount = (~overviewRules: array<overviewRulesResponse>) => {
  overviewRules->Array.reduce(0, (acc, rule) => {
    let autoMatchedCount = rule.status_breakdown->Array.reduce(0, (statusAcc, status) => {
      switch status.status {
      | Matched(Auto) | Matched(WithTolerance) => statusAcc + status.count
      | _ => statusAcc
      }
    })

    acc + autoMatchedCount
  })
}

let getManualCorrectionsCount = (~overviewRules: array<overviewRulesResponse>) => {
  overviewRules->Array.reduce(0, (acc, rule) => {
    let manualCorrectionsCount = rule.status_breakdown->Array.reduce(0, (statusAcc, status) => {
      switch status.status {
      | Matched(Manual) | Posted(Manual) | Matched(Force) | PartiallyReconciled =>
        statusAcc + status.count
      | _ => statusAcc
      }
    })

    acc + manualCorrectionsCount
  })
}

let getAgedCount = (~overviewRules: array<overviewRulesResponse>) => {
  overviewRules->Array.reduce(0, (acc, rule) => {
    let missingCount = rule.status_breakdown->Array.reduce(0, (statusAcc, status) => {
      switch status.status {
      | Missing => statusAcc + status.count
      | _ => statusAcc
      }
    })

    acc + missingCount
  })
}

let getConnectedStatCards = (
  ~overviewRules: array<overviewRulesResponse>,
  ~failedTransformationHistory: array<transformationHistoryType>,
  ~failedIngestionHistory: array<ingestionHistoryType>,
) => {
  let totalCount = getTotalCount(~overviewRules)
  let autoMatchedCount = getAutoMatchCount(~overviewRules)
  let manualCorrectionsCount = getManualCorrectionsCount(~overviewRules)
  let agedCount = getAgedCount(~overviewRules)

  let autoMatchRate =
    totalCount === 0 ? 0.0 : autoMatchedCount->Int.toFloat /. totalCount->Int.toFloat *. 100.0

  [
    {
      connectedStatCardTitle: AutoMatchRate,
      connectedStatCardValue: Percentage(autoMatchRate),
      connectedStatCardUrl: None,
    },
    {
      connectedStatCardTitle: FailedIngestions,
      connectedStatCardValue: Number(failedIngestionHistory->Array.length),
      connectedStatCardUrl: Some("v1/recon-engine/sources"),
    },
    {
      connectedStatCardTitle: MissingTransactions,
      connectedStatCardValue: OutOf(agedCount, totalCount),
      connectedStatCardUrl: Some("v1/recon-engine/exceptions/recon"),
    },
    {
      connectedStatCardTitle: FailedTransformations,
      connectedStatCardValue: Number(failedTransformationHistory->Array.length),
      connectedStatCardUrl: Some("v1/recon-engine/transformation"),
    },
    {
      connectedStatCardTitle: ManualCorrections,
      connectedStatCardValue: Number(manualCorrectionsCount),
      connectedStatCardUrl: None,
    },
  ]
}

let rec addCommas = str => {
  let len = String.length(str)
  if len <= 3 {
    str
  } else {
    let prefix = String.slice(~start=0, ~end=len - 3, str)
    let suffix = String.slice(~start=len - 3, ~end=len, str)
    addCommas(prefix) ++ "," ++ suffix
  }
}

let formatFloatNumber = (amount: float) => {
  let amountParts = amount->Float.toFixedWithPrecision(~digits=2)->String.split(".")
  let integerPart = amountParts->getValueFromArray(0, "0")

  amountParts
  ->Array.get(1)
  ->mapOptionOrDefault(addCommas(integerPart), decimal => `${addCommas(integerPart)}.${decimal}`)
}

let formatNumber = (amount: int) => {
  `${addCommas(amount->Int.toString)}`
}

let getOverviewChartGranularity = (~startTime, ~endTime): overviewChartGranularity => {
  let rangeDays =
    DateRangeUtils.getStartEndDiff(startTime, endTime) /. (1000.0 *. 60.0 *. 60.0 *. 24.0)

  if rangeDays <= 2.0 {
    Hour
  } else if rangeDays <= 90.0 {
    Day
  } else if rangeDays <= 365.0 {
    Week
  } else {
    Month
  }
}

let getOverviewChartBucketLabels = (~startTime, ~granularity) =>
  switch granularity {
  | Hour => (dateFormat(startTime, "DD MMM, h A"), dateFormat(startTime, "MMM DD, YYYY, h:mm A"))
  | Day | Week => (dateFormat(startTime, "DD MMM"), dateFormat(startTime, "MMM DD, YYYY"))
  | Month => (dateFormat(startTime, "MMM YYYY"), dateFormat(startTime, "MMM DD, YYYY"))
  }

let getBreakdownCategoryCounts = (
  statusBreakdown: array<ReconEngineTypes.overviewRuleStatusBreakdown>,
) =>
  statusBreakdown->Array.reduce((0, 0, 0, 0), ((matched, exceptions, expected, missing), status) =>
    switch status.status {
    | Matched(Auto)
    | Matched(Force)
    | Matched(WithTolerance)
    | Matched(Manual)
    | Posted(Manual) => (matched + status.count, exceptions, expected, missing)
    | OverAmount(Mismatch)
    | UnderAmount(Mismatch)
    | OverAmount(Expected)
    | UnderAmount(Expected)
    | DataMismatch
    | CurrencyMismatch
    | SplitMismatch
    | PartiallyReconciled => (matched, exceptions + status.count, expected, missing)
    | Expected => (matched, exceptions, expected + status.count, missing)
    | Missing => (matched, exceptions, expected, missing + status.count)
    | Archived
    | Void
    | UnknownDomainTransactionStatus
    | OverAmount(UnknownDomainTransactionAmountMismatchStatus)
    | UnderAmount(UnknownDomainTransactionAmountMismatchStatus)
    | Matched(UnknownDomainTransactionMatchedStatus)
    | Posted(UnknownDomainTransactionPostedStatus) => (matched, exceptions, expected, missing)
    }
  )

let getOverviewChartPoints = (
  ~overviewRules: array<overviewRulesTimeSeriesResponse>,
  ~granularity: overviewChartGranularity,
): array<overviewChartPoint> => {
  let timeSeriesBuckets = overviewRules->Array.get(0)->Option.mapOr([], rule => rule.time_series)

  timeSeriesBuckets->Array.mapWithIndex((bucket, index) => {
    let statusBreakdown = overviewRules->Array.flatMap(rule => {
      let ruleBucket =
        rule.time_series->getValueFromArray(
          index,
          Dict.make()->ReconEngineUtils.overviewRulesTimeSeriesMapper,
        )
      ruleBucket.status_breakdown
    })
    let (matchedCount, exceptionCount, expectedCount, missingCount) = getBreakdownCategoryCounts(
      statusBreakdown,
    )
    let totalCount = matchedCount + exceptionCount + expectedCount + missingCount
    let (label, tooltipLabel) = getOverviewChartBucketLabels(
      ~startTime=bucket.time_range.start_time,
      ~granularity,
    )

    {
      label,
      tooltipLabel,
      totalCount: totalCount->Int.toFloat,
      matchedCount: matchedCount->Int.toFloat,
      exceptionCount: exceptionCount->Int.toFloat,
      expectedCount: expectedCount->Int.toFloat,
      missingCount: missingCount->Int.toFloat,
      matchRate: totalCount == 0
        ? 0.0
        : matchedCount->Int.toFloat /. totalCount->Int.toFloat *. 100.0,
    }
  })
}

let overviewChartStatusConfig = [
  ("Matched", matchedColor, point => point.matchedCount),
  ("Exception", exceptionColor, point => point.exceptionCount),
  ("Expected", expectedColor, point => point.expectedCount),
  ("Missing", missingColor, point => point.missingCount),
]

let overviewChartTooltipFormatter = (~points: array<overviewChartPoint>) =>
  (
    @this
    (this: LineAndColumnGraphTypes.pointFormatter) => {
      let defaultPoint: LineAndColumnGraphTypes.point = {
        color: "",
        x: "",
        y: 0.0,
        point: {index: 0},
        key: "",
        series: {name: ""},
      }
      let defaultChartPoint: overviewChartPoint = {
        label: "",
        tooltipLabel: "",
        totalCount: 0.0,
        matchedCount: 0.0,
        exceptionCount: 0.0,
        expectedCount: 0.0,
        missingCount: 0.0,
        matchRate: 0.0,
      }
      let hoveredIndex = (this.points->getValueFromArray(0, defaultPoint)).point.index
      let point = points->getValueFromArray(hoveredIndex, defaultChartPoint)
      let percentage = point.matchRate->Float.toFixedWithPrecision(~digits=2)->removeTrailingZero

      let statusRows =
        overviewChartStatusConfig
        ->Array.map(((label, color, getValue)) => {
          let value = getValue(point)->Float.toInt
          `<div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:6px;">
            <div style="display:flex;align-items:center;gap:7px;">
              <span style="width:8px;height:8px;border-radius:2px;background:${color};flex-shrink:0;"></span>
              <span style="font-size:12px;color:rgba(255,255,255,.55);">${label}</span>
            </div>
            <span style="font-size:12px;font-weight:600;color:${color};">${formatNumber(
              value,
            )}</span>
          </div>`
        })
        ->Array.joinWith("")

      `<div style="min-width:240px;border-radius:12px;background:#1A1F2E;box-shadow:0 8px 24px rgba(0,0,0,.25);overflow:hidden;">
        <div style="padding:10px 14px;border-bottom:1px solid rgba(255,255,255,.08);">
          <div style="font-size:12px;font-weight:600;color:rgba(255,255,255,.9);letter-spacing:0.2px;">${point.tooltipLabel}</div>
          <div style="font-size:11px;color:rgba(255,255,255,.4);margin-top:2px;">${formatNumber(
          point.totalCount->Float.toInt,
        )} transactions total</div>
        </div>
        <div style="padding:10px 14px;">
          ${statusRows}
          <div style="border-top:1px solid rgba(255,255,255,.08);padding-top:8px;margin-top:4px;display:flex;align-items:center;justify-content:space-between;">
            <span style="font-size:11px;color:rgba(255,255,255,.4);text-transform:uppercase;letter-spacing:0.4px;">Match rate</span>
            <span style="font-size:13px;font-weight:700;color:${matchRateColor};">${percentage}%</span>
          </div>
        </div>
      </div>`
    }
  )->LineAndColumnGraphTypes.asTooltipPointFormatter

let getOverviewChartOptions = (
  points: array<overviewChartPoint>,
): LineAndColumnGraphTypes.lineColumnGraphPayload => {
  let style: LineAndColumnGraphTypes.style = {
    fontFamily: LineAndColumnGraphUtils.fontFamily,
    color: LineAndColumnGraphUtils.darkGray,
    fontSize: "14px",
  }

  let columnSeries = overviewChartStatusConfig->Array.map(((name, color, getValue)) => {
    LineAndColumnGraphTypes.showInLegend: true,
    name,
    \"type": "column",
    data: points->Array.map(getValue),
    color,
    yAxis: 1,
    stacking: "normal",
  })

  let matchRateSeries: LineAndColumnGraphTypes.dataObj = {
    showInLegend: true,
    name: "Match Rate",
    \"type": "line",
    data: points->Array.map(point => point.matchRate),
    color: matchRateColor,
    yAxis: 0,
  }

  {
    titleObj: {
      chartTitle: {text: "", align: "left", style},
      xAxisTitle: {text: "", style},
      yAxisTitle: {text: "", style},
      oppositeYAxisTitle: {text: "", style},
    },
    categories: points->Array.map(point => point.label),
    data: columnSeries->Array.concat([matchRateSeries]),
    tooltipFormatter: overviewChartTooltipFormatter(~points),
    yAxisFormatter: LineAndColumnGraphUtils.lineColumnGraphYAxisFormatter(
      ~statType=AmountWithSuffix,
      ~suffix="%",
    ),
    minValY2: 0,
    maxValY2: 100,
    legend: {
      useHTML: true,
      labelFormatter: LineAndColumnGraphUtils.labelFormatter,
      align: "left",
      verticalAlign: "top",
      floating: false,
      itemDistance: 24,
      margin: 24,
    },
  }
}
