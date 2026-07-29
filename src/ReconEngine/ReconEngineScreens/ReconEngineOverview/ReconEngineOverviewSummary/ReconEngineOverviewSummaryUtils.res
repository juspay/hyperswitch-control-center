open ReconEngineOverviewUtils
open LogicUtils
open CurrencyFormatUtils
open ReconEngineTypes

let matchedColor = "#52A87A"
let exceptionColor = "#D95F5F"
let expectedColor = "#4A90E2"
let missingColor = "#D4A032"
let matchRateColor = "#8B72CC"

let lessThan24HrsColor = "#CBD5E1"
let oneToThreeDaysColor = "#FCA5A5"
let threeToSevenDaysColor = "#F87171"
let greaterThanSevenDaysColor = "#DC2626"

let triageColors = ["#8B97A8", "#E8956A", "#5BAD91", "#4A90E2", "#C87880", "#7BABC8", "#D4AA55"]

let nodeCardWidth = 440.0
let nodeCardHeight = 300.0

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
        width: nodeCardWidth,
        height: nodeCardHeight,
      },
    )
  })

  layoutGraph(graph)->ignore

  let layoutedNodes = nodes->Array.map(node => {
    let position = getGraphNode(graph, node.id)
    let x = position.x -. nodeCardWidth /. 2.0
    let y = position.y -. nodeCardHeight /. 2.0

    {
      ...node,
      position: {x, y},
    }
  })

  (layoutedNodes, edges)
}

open ReconEngineOverviewSummaryTypes

let balancePairMapper: Dict.t<JSON.t> => balancePair = dict => {
  open ReconEngineUtils
  {
    debit: dict->getDictfromDict("debit")->getAmountPayload,
    credit: dict->getDictfromDict("credit")->getAmountPayload,
  }
}

let accountBalanceRowMapper: Dict.t<JSON.t> => accountBalanceRow = dict => {
  {
    accountName: dict->getString("account_name", ""),
    matched: dict->getDictfromDict("matched")->balancePairMapper,
    pending: dict->getDictfromDict("pending")->balancePairMapper,
    mismatched: dict->getDictfromDict("mismatched")->balancePairMapper,
  }
}

let addBalancePair = (existing: balancePair, incoming: balancePair): balancePair => {
  debit: {
    value: Math.abs(existing.debit.value) +. Math.abs(incoming.debit.value),
    currency: incoming.debit.currency,
  },
  credit: {
    value: Math.abs(existing.credit.value) +. Math.abs(incoming.credit.value),
    currency: incoming.credit.currency,
  },
}

let calculateTotals = (data: array<accountBalanceRow>) => {
  data->Array.reduce(Dict.make()->accountBalanceRowMapper, (acc, item) => {
    {
      ...acc,
      matched: addBalancePair(acc.matched, item.matched),
      pending: addBalancePair(acc.pending, item.pending),
      mismatched: addBalancePair(acc.mismatched, item.mismatched),
    }
  })
}

let balanceCountPairMapper: Dict.t<JSON.t> => balanceCountPair = dict => {
  open ReconEngineUtils
  {
    debit_count: dict->getInt("debit_count", 0),
    debit: dict->getDictfromDict("debit")->getAmountPayload,
    credit_count: dict->getInt("credit_count", 0),
    credit: dict->getDictfromDict("credit")->getAmountPayload,
  }
}

let accountTransactionDataToObjMapper: Dict.t<JSON.t> => accountTransactionData = dict => {
  {
    matched: dict->getDictfromDict("matched")->balanceCountPairMapper,
    pending: dict->getDictfromDict("pending")->balanceCountPairMapper,
    mismatched: dict->getDictfromDict("mismatched")->balanceCountPairMapper,
  }
}

let generateStatusDataWithTransactionAmounts = (transactionData: accountTransactionData) => {
  [
    {
      statusType: MatchedAmount,
      reconStatusData: {
        inAmount: transactionData.matched.debit,
        outAmount: transactionData.matched.credit,
        inTxns: transactionData.matched.debit_count,
        outTxns: transactionData.matched.credit_count,
      },
    },
    {
      statusType: PendingAmount,
      reconStatusData: {
        inAmount: transactionData.pending.debit,
        outAmount: transactionData.pending.credit,
        inTxns: transactionData.pending.debit_count,
        outTxns: transactionData.pending.credit_count,
      },
    },
    {
      statusType: MismatchedAmount,
      reconStatusData: {
        inAmount: transactionData.mismatched.debit,
        outAmount: transactionData.mismatched.credit,
        inTxns: transactionData.mismatched.debit_count,
        outTxns: transactionData.mismatched.credit_count,
      },
    },
  ]
}

let getAccountOverviewMap = (ruleAccountsOverview: array<ruleAccountsOverview>): Dict.t<
  accountStatusOverview,
> => {
  let dict = Dict.make()
  ruleAccountsOverview->Array.forEach(rule => {
    rule.accounts->Array.forEach(account => {
      let merged =
        dict
        ->Dict.get(account.account_id)
        ->mapOptionOrDefault(
          account,
          existing => {
            ...existing,
            status_breakdown: Array.concat(existing.status_breakdown, account.status_breakdown),
          },
        )
      dict->Dict.set(account.account_id, merged)
    })
  })
  dict
}

let getAccountOverview = (
  accountOverviewMap: Dict.t<accountStatusOverview>,
  accountId: string,
): accountStatusOverview => {
  accountOverviewMap->getValueFromDict(
    accountId,
    Dict.make()->ReconEngineUtils.accountStatusOverviewMapper,
  )
}

let getMatchedAndTotalCount = (statusBreakdown: array<accountStatusBreakdown>): (int, int) => {
  statusBreakdown->Array.reduce((0, 0), ((matchedCount, totalCount), status) => {
    let recordCount = status.credit_txn_count + status.debit_txn_count
    switch status.status {
    | Matched(Force)
    | Matched(Manual)
    | Matched(Auto)
    | Posted(Manual)
    | Matched(WithTolerance) => (matchedCount + recordCount, totalCount + recordCount)
    | PartiallyReconciled
    | Missing
    | DataMismatch
    | Expected
    | OverAmount(Expected)
    | UnderAmount(Expected)
    | OverAmount(Mismatch)
    | UnderAmount(Mismatch)
    | SplitMismatch
    | CurrencyMismatch => (matchedCount, totalCount + recordCount)
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
  `${getPercentage(~count=matchedCount, ~total=totalCount)->valueFormatter(Rate)} Matched`

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
  ~ruleType: string,
  ~sourceAccountId: string,
  ~targetAccountId: string,
  ~sourceStatusBreakdown: array<accountStatusBreakdown>,
  ~selectedNodeId,
) => {
  let (matchedCount, totalCount) = getMatchedAndTotalCount(sourceStatusBreakdown)
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
      ruleType,
      percentageLabel,
    },
    style: isHighlighted
      ? {stroke: highlightStrokeColor, strokeWidth: 2.0}
      : {stroke: normalStrokeColor, strokeWidth: 2.0},
  }
}

let getEdges = (
  ~reconRulesList: array<ReconEngineRulesTypes.rulePayload>,
  ~ruleAccountsOverview: array<ruleAccountsOverview>,
  ~selectedNodeId,
) =>
  ruleAccountsOverview->Array.flatMap(rule => {
    let sourceAccount = rule.accounts->Array.find(account => account.rule_account_type === Source)
    let targetAccounts =
      rule.accounts->Array.filter(account => account.rule_account_type === Target)
    let ruleType =
      reconRulesList
      ->Array.find(r => r.rule_id === rule.rule_id)
      ->mapOptionOrDefault("Unknown", r => getCompactRuleType(r.strategy))

    sourceAccount->mapOptionOrDefault([], source =>
      targetAccounts->Array.map(
        target =>
          makeEdge(
            ~ruleType,
            ~sourceAccountId=source.account_id,
            ~targetAccountId=target.account_id,
            ~sourceStatusBreakdown=source.status_breakdown,
            ~selectedNodeId,
          ),
      )
    )
  })

let addBalance = (existing: balanceType, incoming: balanceType): balanceType => {
  value: existing.value +. incoming.value,
  currency: incoming.currency,
}

let addStatusToBalanceCountPair = (
  pair: balanceCountPair,
  status: accountStatusBreakdown,
): balanceCountPair => {
  debit_count: pair.debit_count + status.debit_txn_count,
  debit: addBalance(pair.debit, status.debit_amount),
  credit_count: pair.credit_count + status.credit_txn_count,
  credit: addBalance(pair.credit, status.credit_amount),
}

let accountTransactionDataFromStatusBreakdown = (
  statusBreakdown: array<accountStatusBreakdown>,
): accountTransactionData => {
  statusBreakdown->Array.reduce(Dict.make()->accountTransactionDataToObjMapper, (acc, status) => {
    switch status.status {
    | Matched(Force)
    | Matched(Manual)
    | Matched(Auto)
    | Posted(Manual)
    | Matched(WithTolerance) => {...acc, matched: addStatusToBalanceCountPair(acc.matched, status)}
    | Expected
    | Missing
    | PartiallyReconciled
    | OverAmount(Expected)
    | UnderAmount(Expected) => {...acc, pending: addStatusToBalanceCountPair(acc.pending, status)}
    | OverAmount(Mismatch)
    | UnderAmount(Mismatch)
    | DataMismatch
    | CurrencyMismatch
    | SplitMismatch => {...acc, mismatched: addStatusToBalanceCountPair(acc.mismatched, status)}
    | Archived
    | Void
    | UnknownDomainTransactionStatus
    | Matched(UnknownDomainTransactionMatchedStatus)
    | Posted(UnknownDomainTransactionPostedStatus)
    | OverAmount(UnknownDomainTransactionAmountMismatchStatus)
    | UnderAmount(UnknownDomainTransactionAmountMismatchStatus) => acc
    }
  })
}

let generateNodesAndEdgesWithTransactionAmounts = (
  reconRulesList: array<ReconEngineRulesTypes.rulePayload>,
  ruleAccountsOverview: array<ruleAccountsOverview>,
  ~selectedNodeId: option<string>,
  ~onNodeClick: option<string => unit>=?,
) => {
  let accountOverviewMap = getAccountOverviewMap(ruleAccountsOverview)

  let nodes =
    accountOverviewMap
    ->Dict.valuesToArray
    ->Array.mapWithIndex((account, index) => {
      let transactionData = accountTransactionDataFromStatusBreakdown(account.status_breakdown)

      let statusData = generateStatusDataWithTransactionAmounts(transactionData)
      let nodeId = `${account.account_id}-node`
      let isSelected = selectedNodeId->mapOptionOrDefault(false, id => id === nodeId)

      {
        id: nodeId,
        ReconEngineOverviewSummaryTypes.nodeType: "reconNode",
        position: {x: Int.toFloat(index * 100), y: 0.0},
        data: {
          label: account.account_name,
          accountType: account.account_type,
          statusData,
          selected: isSelected,
          onNodeClick: onNodeClick->Option.map(clickHandler => () => clickHandler(nodeId)),
        },
      }
    })

  let edges = getEdges(~reconRulesList, ~ruleAccountsOverview, ~selectedNodeId)

  getLayoutedElements(nodes, edges, "LR")
}

let getHeaderText = (amountType: amountType, currency: string) => {
  switch amountType {
  | MatchedAmount => `Matched Amount (${currency})`
  | PendingAmount => `Pending Amount (${currency})`
  | MismatchedAmount => `Mismatched Amount (${currency})`
  }
}

let getAmountPair = (amountType: amountType, data: accountBalanceRow) => {
  switch amountType {
  | MatchedAmount => (data.matched.debit, data.matched.credit)
  | PendingAmount => (data.pending.debit, data.pending.credit)
  | MismatchedAmount => (data.mismatched.debit, data.mismatched.credit)
  }
}

let accountOverviewToBalanceRow = (account: accountStatusOverview): accountBalanceRow => {
  let transactionData = accountTransactionDataFromStatusBreakdown(account.status_breakdown)

  {
    accountName: account.account_name,
    matched: {
      debit: transactionData.matched.debit,
      credit: transactionData.matched.credit,
    },
    pending: {
      debit: transactionData.pending.debit,
      credit: transactionData.pending.credit,
    },
    mismatched: {
      debit: transactionData.mismatched.debit,
      credit: transactionData.mismatched.credit,
    },
  }
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

let getSourceAndTargetAccounts = (
  ruleAccountsOverview: array<ruleAccountsOverview>,
  ~ruleId: string,
): (accountStatusOverview, array<accountStatusOverview>) => {
  let accounts =
    ruleAccountsOverview
    ->Array.find(rule => rule.rule_id === ruleId)
    ->mapOptionOrDefault([], rule => rule.accounts)

  let source =
    accounts
    ->Array.find(account => account.rule_account_type === Source)
    ->Option.getOr(Dict.make()->ReconEngineUtils.accountStatusOverviewMapper)

  let targets = accounts->Array.filter(account => account.rule_account_type === Target)
  (source, targets)
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
  ~stagingOverviewData: array<accountStagingEntriesOverview>,
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

  let stagingExceptions =
    ReconEngineDataTransformedEntriesUtils.getTotalNeedsManualReviewEntries(
      stagingOverviewData,
    )->Float.toInt

  txnExceptions + stagingExceptions
}

let getExceptionCountFromBreakdown = (statusBreakdown: array<overviewRuleStatusBreakdown>) =>
  statusBreakdown->Array.reduce(0, (statusAcc, status) =>
    switch status.status {
    | OverAmount(Expected)
    | UnderAmount(Expected)
    | OverAmount(Mismatch)
    | UnderAmount(Mismatch)
    | DataMismatch
    | CurrencyMismatch
    | SplitMismatch
    | PartiallyReconciled
    | Missing =>
      statusAcc + status.count
    | _ => statusAcc
    }
  )

let exceptionAgingBucketConfig = [
  ("< 24h", lessThan24HrsColor),
  ("1–3 days", oneToThreeDaysColor),
  ("3–7 days", threeToSevenDaysColor),
  ("> 7 days", greaterThanSevenDaysColor),
]

let getAgingBucketIndex = (~bucketStartTime: string) => {
  let now = DayJs.getDayJs()
  let hoursAgo = now.diff(bucketStartTime, "hour")
  if hoursAgo < 24 {
    0
  } else if hoursAgo < 24 * 3 {
    1
  } else if hoursAgo < 24 * 7 {
    2
  } else {
    3
  }
}

let getExceptionAgingDataFromTimeSeries = (
  ~overviewRules: array<overviewRulesTimeSeriesResponse>,
): array<exceptionAgingData> => {
  let contributions =
    overviewRules->Array.flatMap(rule =>
      rule.time_series->Array.map(bucket => (
        getAgingBucketIndex(~bucketStartTime=bucket.time_range.start_time),
        getExceptionCountFromBreakdown(bucket.status_breakdown),
      ))
    )

  exceptionAgingBucketConfig->Array.mapWithIndex(((label, color), index): exceptionAgingData => {
    label,
    color,
    total: contributions->Array.reduce(0, (acc, (i, count)) => i == index ? acc + count : acc),
  })
}

let getExceptionTriageItems = (~overviewRules: array<overviewRulesResponse>): array<
  exceptionTriageItem,
> => {
  let counts = Dict.make()
  let add = (label, count) => counts->Dict.set(label, counts->getValueFromDict(label, 0) + count)

  overviewRules->Array.forEach(rule =>
    rule.status_breakdown->Array.forEach(status =>
      switch status.status {
      | DataMismatch => add("Data mismatch", status.count)
      | UnderAmount(_) => add("Under amount", status.count)
      | OverAmount(_) => add("Over amount", status.count)
      | Missing => add("Missing", status.count)
      | SplitMismatch => add("Split mismatch", status.count)
      | CurrencyMismatch => add("Currency mismatch", status.count)
      | PartiallyReconciled => add("Partially reconciled", status.count)
      | _ => ()
      }
    )
  )

  counts
  ->Dict.toArray
  ->Array.map(((label, total)): exceptionTriageItem => {label, total})
  ->Array.filter(item => item.total > 0)
  ->Array.toSorted((a, b) => Int.compare(b.total, a.total))
}

let getTriageColor = index =>
  triageColors->getValueFromArray(mod(index, triageColors->Array.length), exceptionColor)

let exceptionTriageTooltipFormatter = (~totalCount) =>
  (
    @this
    (this: PieGraphTypes.pointFormatter) => {
      let pct = getPercentage(~count=this.y->Float.toInt, ~total=totalCount)->valueFormatter(Rate)
      `<div style="min-width:190px;max-width:260px;border-radius:12px;background:#1A1F2E;box-shadow:0 8px 24px rgba(0,0,0,.25);overflow:hidden;">
        <div style="padding:10px 14px;">
          <div style="display:flex;align-items:flex-start;justify-content:space-between;gap:12px;">
            <div style="display:flex;align-items:flex-start;gap:7px;min-width:0;flex:1;">
              <span style="width:8px;height:8px;border-radius:2px;background:${this.color};flex-shrink:0;margin-top:4px;"></span>
              <span style="font-size:12px;color:rgba(255,255,255,.7);word-break:break-word;">${this.point.name}</span>
            </div>
            <span style="font-size:12px;font-weight:600;color:rgba(255,255,255,.9);flex-shrink:0;">${this.y
        ->Float.toInt
        ->Int.toString}</span>
          </div>
          <div style="margin-top:6px;padding-top:6px;border-top:1px solid rgba(255,255,255,.08);display:flex;align-items:center;justify-content:space-between;">
            <span style="font-size:11px;color:rgba(255,255,255,.4);text-transform:uppercase;letter-spacing:0.4px;">exceptions</span>
            <span style="font-size:11px;font-weight:600;color:${this.color};">${pct}</span>
          </div>
        </div>
      </div>`
    }
  )->PieGraphTypes.asTooltipPointFormatter

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

let getMatchedAmount = (~overviewRules: array<overviewRulesResponse>) =>
  overviewRules->Array.reduce(0.0, (acc, rule) => {
    let matchedAmount = rule.status_breakdown->Array.reduce(0.0, (statusAcc, status) => {
      switch status.status {
      | Matched(Auto)
      | Matched(Force)
      | Matched(Manual)
      | Matched(WithTolerance)
      | Posted(Manual) =>
        statusAcc +. status.credit_amount.value
      | _ => statusAcc
      }
    })

    acc +. matchedAmount
  })

let getCurrency = (~overviewRules: array<overviewRulesResponse>) =>
  overviewRules
  ->Array.flatMap(rule => rule.status_breakdown)
  ->Array.map(status => status.credit_amount.currency)
  ->getValueFromArray(0, "")

let getStatCards = (
  ~overviewRules: array<overviewRulesResponse>,
  ~stagingOverviewData: array<accountStagingEntriesOverview>=[],
) => {
  let totalCount = getTotalCount(~overviewRules)
  let matchedCount = getMatchedCount(~overviewRules)
  let openExceptions = getOpenExceptions(~overviewRules, ~stagingOverviewData)
  let valueAtRisk = getValueAtRisk(~overviewRules)
  let expectedValue = getExpectedValue(~overviewRules)
  let currency = getCurrency(~overviewRules)

  let matchRate = getPercentage(~count=matchedCount, ~total=totalCount)

  let reconExceptionsPath = GlobalVars.appendDashboardPath(~url="v1/recon-engine/exceptions/recon")

  [
    {
      statCardTitle: MatchRate,
      statCardValue: Percentage(matchRate),
      statCardIcon: FontAwesome("percent"),
      statCardDescription: `${matchedCount->Int.toString} of ${totalCount->Int.toString} matched`,
      statCardType: Info,
      statCardPath: None,
    },
    {
      statCardTitle: OpenExceptions,
      statCardValue: Number(openExceptions),
      statCardIcon: CustomIcon(
        <Icon name="nd-information-triangle" size=14 className="text-nd_gray-500" />,
      ),
      statCardDescription: "staging + txn exceptions",
      statCardType: Attention,
      statCardPath: Some(reconExceptionsPath),
    },
    {
      statCardTitle: ValueAtRisk,
      statCardValue: Amount(valueAtRisk, currency),
      statCardIcon: CustomIcon(<Icon name="lock-icon" size=14 className="text-nd_gray-500" />),
      statCardDescription: "mismatch variance exposure",
      statCardType: Attention,
      statCardPath: Some(reconExceptionsPath),
    },
    {
      statCardTitle: ExpectedValue,
      statCardValue: Amount(expectedValue, currency),
      statCardIcon: CustomIcon(<Icon name="history" size=14 className="text-nd_gray-500" />),
      statCardDescription: "amount expected",
      statCardType: Info,
      statCardPath: Some(reconExceptionsPath),
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

let getMissingCount = (~overviewRules: array<overviewRulesResponse>) => {
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
  open GlobalVars

  let totalCount = getTotalCount(~overviewRules)
  let autoMatchedCount = getAutoMatchCount(~overviewRules)
  let manualCorrectionsCount = getManualCorrectionsCount(~overviewRules)
  let missingCount = getMissingCount(~overviewRules)

  let autoMatchRate = getPercentage(~count=autoMatchedCount, ~total=totalCount)

  [
    {
      connectedStatCardTitle: AutoMatchRate,
      connectedStatCardValue: Percentage(autoMatchRate),
      connectedStatCardType: Info,
      connectedStatCardPath: None,
    },
    {
      connectedStatCardTitle: FailedIngestions,
      connectedStatCardValue: Number(failedIngestionHistory->Array.length),
      connectedStatCardType: Info,
      connectedStatCardPath: Some(appendDashboardPath(~url="v1/recon-engine/sources")),
    },
    {
      connectedStatCardTitle: MissingTransactions,
      connectedStatCardValue: OutOf(missingCount, totalCount),
      connectedStatCardType: Info,
      connectedStatCardPath: Some(appendDashboardPath(~url="v1/recon-engine/exceptions/recon")),
    },
    {
      connectedStatCardTitle: FailedTransformations,
      connectedStatCardValue: Number(failedTransformationHistory->Array.length),
      connectedStatCardType: Info,
      connectedStatCardPath: Some(appendDashboardPath(~url="v1/recon-engine/transformation")),
    },
    {
      connectedStatCardTitle: ManualCorrections,
      connectedStatCardValue: Number(manualCorrectionsCount),
      connectedStatCardType: Info,
      connectedStatCardPath: None,
    },
  ]
}

let getDetailsConnectedStatCards = (~overviewRule: overviewRulesResponse): array<
  connectedStatCardData,
> => {
  open GlobalVars

  let totalCount = getTotalCount(~overviewRules=[overviewRule])
  let matchedCount = getMatchedCount(~overviewRules=[overviewRule])
  let openExceptions = getOpenExceptions(~overviewRules=[overviewRule], ~stagingOverviewData=[])
  let valueAtRisk = getValueAtRisk(~overviewRules=[overviewRule])
  let expectedValue = getExpectedValue(~overviewRules=[overviewRule])
  let matchedAmount = getMatchedAmount(~overviewRules=[overviewRule])
  let currency = getCurrency(~overviewRules=[overviewRule])
  let matchRate = getPercentage(~count=matchedCount, ~total=totalCount)

  let urlPath = `v1/recon-engine/exceptions/recon?rule_id=${overviewRule.rule_id}`

  [
    {
      connectedStatCardTitle: MatchRate,
      connectedStatCardValue: Percentage(matchRate),
      connectedStatCardType: Info,
      connectedStatCardPath: None,
    },
    {
      connectedStatCardTitle: OpenExceptions,
      connectedStatCardValue: Number(openExceptions),
      connectedStatCardType: Attention,
      connectedStatCardPath: Some(appendDashboardPath(~url=urlPath)),
    },
    {
      connectedStatCardTitle: ValueAtRisk,
      connectedStatCardValue: Amount(valueAtRisk, currency),
      connectedStatCardType: Attention,
      connectedStatCardPath: Some(appendDashboardPath(~url=urlPath)),
    },
    {
      connectedStatCardTitle: ExpectedValue,
      connectedStatCardValue: Amount(expectedValue, currency),
      connectedStatCardType: Info,
      connectedStatCardPath: Some(appendDashboardPath(~url=`${urlPath}&status=expected,missing`)),
    },
    {
      connectedStatCardTitle: MatchedAmountValue,
      connectedStatCardValue: Amount(matchedAmount, currency),
      connectedStatCardType: Info,
      connectedStatCardPath: None,
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

let getBreakdownCategoryCounts = (statusBreakdown: array<overviewRuleStatusBreakdown>) =>
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

let getRuleActivityItems = (~overviewRules: array<overviewRulesResponse>): array<
  ruleActivityItem,
> => {
  overviewRules
  ->Array.map(rule => {
    let volume = rule.status_breakdown->Array.reduce(0, (acc, status) => acc + status.count)
    let (matchedCount, exceptionCount, _, _) = getBreakdownCategoryCounts(rule.status_breakdown)
    let matchRate = getPercentage(~count=matchedCount, ~total=volume)
    {overview_rule: rule, volume, exceptions: exceptionCount, matchRate}
  })
  ->Array.toSorted((a, b) => Int.compare(b.exceptions, a.exceptions))
}

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
      matchRate: getPercentage(~count=matchedCount, ~total=totalCount),
    }
  })
}

let overviewChartStatusConfig = [
  ("Matched", matchedColor, point => point.matchedCount),
  ("Exception", exceptionColor, point => point.exceptionCount),
  ("Expected", expectedColor, point => point.expectedCount),
  ("Missing", missingColor, point => point.missingCount),
]

let reconciliationSeriesTypeFromString = (seriesName: string): reconciliationSeriesType => {
  switch seriesName {
  | "Matched" => MatchedSeries
  | "Exception" => ExceptionSeries
  | "Expected" => ExpectedSeries
  | "Missing" => MissingSeries
  | _ => UnknownReconciliationSeriesType
  }
}

let getOverviewChartSeriesStatusFilter = (seriesName: string): string => {
  open ReconEngineFilterUtils

  switch seriesName->reconciliationSeriesTypeFromString {
  | ExceptionSeries =>
    getTransactionStatusValueFromStatusList([
      OverAmount(Mismatch),
      UnderAmount(Mismatch),
      OverAmount(Expected),
      UnderAmount(Expected),
      DataMismatch,
      CurrencyMismatch,
      SplitMismatch,
      PartiallyReconciled,
    ])->Array.joinWith(",")
  | ExpectedSeries => getTransactionStatusValueFromStatusList([Expected])->Array.joinWith(",")
  | MissingSeries => getTransactionStatusValueFromStatusList([Missing])->Array.joinWith(",")
  | MatchedSeries
  | UnknownReconciliationSeriesType => ""
  }
}

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
      let percentage = point.matchRate->valueFormatter(Rate)

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
            <span style="font-size:13px;font-weight:700;color:${matchRateColor};">${percentage}</span>
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

let getExceptionTriagePieOptions = (
  ~items: array<exceptionTriageItem>,
  ~totalCount: int,
): PieGraphTypes.pieGraphOptions<int> => {
  let data = items->Array.mapWithIndex((item, index) => {
    let point: PieGraphTypes.pieGraphDataType = {
      name: item.label,
      y: item.total->Int.toFloat,
      color: getTriageColor(index),
    }
    point
  })

  let payload: PieGraphTypes.pieGraphPayload<int> = {
    data: [
      {
        \"type": "pie",
        innerSize: "72%",
        showInLegend: false,
        name: "Exception triage",
        data,
      },
    ],
    title: {text: ""},
    tooltipFormatter: exceptionTriageTooltipFormatter(~totalCount),
    legendFormatter: PieGraphUtils.pieGraphLegendFormatter(),
    chartSize: "88%",
    startAngle: 0,
    endAngle: 360,
    legend: {enabled: false},
  }

  let options = payload->PieGraphUtils.getPieChartOptions
  {
    ...options,
    chart: {...options.chart, width: 220, height: 220},
    tooltip: ?options.tooltip->Option.map(t => {...t, outside: true}),
    title: {
      text: `<div style="display:flex;flex-direction:column;align-items:center;">
        <span style="font-size:22px;font-weight:600;color:#1F2937;line-height:26px;">${totalCount->formatNumber}</span>
        <span style="font-size:11px;font-weight:400;color:#667085;line-height:16px;">exceptions</span>
      </div>`,
      align: "center",
      verticalAlign: "middle",
      y: 8,
      x: 0,
      useHTML: true,
    },
  }
}
