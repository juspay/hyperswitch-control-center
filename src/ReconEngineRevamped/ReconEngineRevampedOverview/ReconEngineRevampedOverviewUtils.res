open LogicUtils
open ReconEngineRevampedOverviewTypes

let getTotalCount = (~overviewRules: array<overviewRulesResponse>) =>
  overviewRules->Array.reduce(0, (acc, rule) => {
    let statusCounts = rule.status_counts
    let totalCount =
      statusCounts.partially_reconciled.count +
      statusCounts.matched_force.count +
      statusCounts.expected.count +
      statusCounts.matched_auto.count +
      statusCounts.matched_manual.count +
      statusCounts.under_amount_expected.count +
      statusCounts.under_amount_mismatch.count +
      statusCounts.data_mismatch.count +
      statusCounts.over_amount_expected.count +
      statusCounts.over_amount_mismatch.count +
      statusCounts.posted_manual.count +
      statusCounts.currency_mismatch.count +
      statusCounts.matched_with_tolerance.count +
      statusCounts.split_mismatch.count

    acc + totalCount
  })

let getValueAtRisk = (~overviewRules: array<overviewRulesResponse>) =>
  overviewRules->Array.reduce(0.0, (acc, rule) => {
    let statusCounts = rule.status_counts
    let valueAtRisk =
      Math.abs(
        statusCounts.under_amount_mismatch.credit_sum -.
        statusCounts.under_amount_mismatch.debit_sum,
      ) +.
      Math.abs(
        statusCounts.over_amount_mismatch.credit_sum -. statusCounts.over_amount_mismatch.debit_sum,
      )

    acc +. valueAtRisk
  })

let getOpenExceptions = (~overviewRules: array<overviewRulesResponse>) => {
  let totalCount = getTotalCount(~overviewRules)
  let matchedCount = overviewRules->Array.reduce(0, (acc, rule) => {
    let statusCounts = rule.status_counts
    let matchedCount =
      statusCounts.matched_auto.count +
      statusCounts.matched_manual.count +
      statusCounts.matched_force.count +
      statusCounts.matched_with_tolerance.count +
      statusCounts.posted_manual.count

    acc + matchedCount
  })

  totalCount - matchedCount
}

let getUnReconciledValue = (~overviewRules: array<overviewRulesResponse>) =>
  overviewRules->Array.reduce(0.0, (acc, rule) => {
    let statusCounts = rule.status_counts
    let unreconciledValue =
      Math.abs(statusCounts.expected.credit_sum -. statusCounts.expected.debit_sum) +.
      Math.abs(
        statusCounts.over_amount_expected.credit_sum -. statusCounts.over_amount_expected.debit_sum,
      ) +.
      Math.abs(
        statusCounts.under_amount_expected.credit_sum -.
        statusCounts.under_amount_expected.debit_sum,
      )

    acc +. unreconciledValue
  })

let getStatCards = (~overviewRules: array<overviewRulesResponse>) => {
  let totalCount = getTotalCount(~overviewRules)
  let matchedCount = getTotalCount(~overviewRules) - getOpenExceptions(~overviewRules)
  let openExceptions = getOpenExceptions(~overviewRules)
  let valueAtRisk = getValueAtRisk(~overviewRules)
  let unreconciledValue = getUnReconciledValue(~overviewRules)

  let matchRate =
    totalCount === 0 ? 0.0 : matchedCount->Int.toFloat /. totalCount->Int.toFloat *. 100.0

  [
    {
      title: MatchRate,
      value: Percentage(matchRate),
      icon: FontAwesome("percent"),
      description: `${matchedCount->Int.toString} of ${totalCount->Int.toString} matched`,
      cardType: Info,
    },
    {
      title: OpenExceptions,
      value: Number(openExceptions),
      icon: CustomIcon(
        <Icon name="nd-information-triangle" size=14 className="text-nd_gray-500" />,
      ),
      description: "staging + txn exceptions",
      cardType: Attention,
    },
    {
      title: ValueAtRisk,
      value: Amount(valueAtRisk, "USD"),
      icon: CustomIcon(<Icon name="lock-icon" size=14 className="text-nd_gray-500" />),
      description: "mismatch variance exposure",
      cardType: Attention,
    },
    {
      title: UnreconciledValue,
      value: Amount(unreconciledValue, "USD"),
      icon: CustomIcon(<Icon name="history" size=14 className="text-nd_gray-500" />),
      description: "expected variance",
      cardType: Info,
    },
  ]
}

let connectedStatCards = [
  {
    title: AutoMatchRate,
    value: Percentage(51.3),
  },
  {
    title: Aged,
    value: OutOf(287, 318),
  },
  {
    title: SourcesHealthy,
    value: SlashOutOf(3, 4),
  },
  {
    title: FailedIngestions,
    value: Number(7),
  },
  {
    title: ManualCorrections,
    value: Number(126),
  },
]

let overviewRulesStatusCountItemMapper: Dict.t<
  JSON.t,
> => overviewRulesStatusCountItemType = dict => {
  {
    count: dict->getInt("count", 0),
    credit_sum: dict->getFloat("credit_sum", 0.0),
    debit_sum: dict->getFloat("debit_sum", 0.0),
  }
}

let overviewRulesStatusCountMapper: Dict.t<JSON.t> => overviewRulesStatusCountType = dict => {
  {
    partially_reconciled: dict
    ->getDictfromDict("partially_reconciled")
    ->overviewRulesStatusCountItemMapper,
    matched_force: dict->getDictfromDict("matched_force")->overviewRulesStatusCountItemMapper,
    expected: dict->getDictfromDict("expected")->overviewRulesStatusCountItemMapper,
    matched_auto: dict->getDictfromDict("matched_auto")->overviewRulesStatusCountItemMapper,
    matched_manual: dict->getDictfromDict("matched_manual")->overviewRulesStatusCountItemMapper,
    under_amount_expected: dict
    ->getDictfromDict("under_amount_expected")
    ->overviewRulesStatusCountItemMapper,
    under_amount_mismatch: dict
    ->getDictfromDict("under_amount_mismatch")
    ->overviewRulesStatusCountItemMapper,
    data_mismatch: dict->getDictfromDict("data_mismatch")->overviewRulesStatusCountItemMapper,
    void: dict->getDictfromDict("void")->overviewRulesStatusCountItemMapper,
    over_amount_expected: dict
    ->getDictfromDict("over_amount_expected")
    ->overviewRulesStatusCountItemMapper,
    over_amount_mismatch: dict
    ->getDictfromDict("over_amount_mismatch")
    ->overviewRulesStatusCountItemMapper,
    posted_manual: dict->getDictfromDict("posted_manual")->overviewRulesStatusCountItemMapper,
    currency_mismatch: dict
    ->getDictfromDict("currency_mismatch")
    ->overviewRulesStatusCountItemMapper,
    matched_with_tolerance: dict
    ->getDictfromDict("matched_with_tolerance")
    ->overviewRulesStatusCountItemMapper,
    archived: dict->getDictfromDict("archived")->overviewRulesStatusCountItemMapper,
    split_mismatch: dict->getDictfromDict("split_mismatch")->overviewRulesStatusCountItemMapper,
  }
}

let overviewRulesResponseMapper: Dict.t<JSON.t> => overviewRulesResponse = dict => {
  {
    rule_id: dict->getString("rule_id", ""),
    rule_name: dict->getString("rule_name", ""),
    status_counts: dict->getDictfromDict("status_counts")->overviewRulesStatusCountMapper,
  }
}
