open LogicUtils
open ReconEngineRevampedOverviewTypes

let getTotalCount = (~overviewRules: array<overviewRulesResponse>) =>
  overviewRules->Array.reduce(0, (acc, rule) => {
    let totalCount = rule.statuses->Array.reduce(0, (statusAcc, status) => {
      switch status.status {
      | Archived | Void => statusAcc
      | _ => statusAcc + status.count
      }
    })

    acc + totalCount
  })

let getValueAtRisk = (~overviewRules: array<overviewRulesResponse>) =>
  overviewRules->Array.reduce(0.0, (acc, rule) => {
    let valueAtRisk = rule.statuses->Array.reduce(0.0, (statusAcc, status) => {
      switch status.status {
      | UnderAmountMismatch | OverAmountMismatch | OverAmountExpected | UnderAmountExpected =>
        statusAcc +. Math.abs(status.credit_sum -. status.debit_sum)
      | _ => statusAcc
      }
    })

    acc +. valueAtRisk
  })

let getOpenExceptions = (~overviewRules: array<overviewRulesResponse>) => {
  let totalCount = getTotalCount(~overviewRules)
  let matchedCount = overviewRules->Array.reduce(0, (acc, rule) => {
    let matchedCount = rule.statuses->Array.reduce(0, (statusAcc, status) => {
      switch status.status {
      | MatchedAuto | MatchedManual | MatchedForce | MatchedWithTolerance | PostedManual =>
        statusAcc + status.count
      | _ => statusAcc
      }
    })

    acc + matchedCount
  })

  totalCount - matchedCount
}

let getExpectedValue = (~overviewRules: array<overviewRulesResponse>) =>
  overviewRules->Array.reduce(0.0, (acc, rule) => {
    let expectedValue = rule.statuses->Array.reduce(0.0, (statusAcc, status) => {
      switch status.status {
      | Expected | Missing => statusAcc +. Math.abs(status.credit_sum)
      | _ => statusAcc
      }
    })

    acc +. expectedValue
  })

let getCurrency = (~overviewRules: array<overviewRulesResponse>) =>
  overviewRules
  ->Array.flatMap(rule => rule.statuses)
  ->Array.map(status => status.currency)
  ->getValueFromArray(0, "")

let getStatCards = (~overviewRules: array<overviewRulesResponse>) => {
  let totalCount = getTotalCount(~overviewRules)
  let matchedCount = getTotalCount(~overviewRules) - getOpenExceptions(~overviewRules)
  let openExceptions = getOpenExceptions(~overviewRules)
  let valueAtRisk = getValueAtRisk(~overviewRules)
  let expectedValue = getExpectedValue(~overviewRules)
  let currency = getCurrency(~overviewRules)

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
      value: Amount(valueAtRisk, currency),
      icon: CustomIcon(<Icon name="lock-icon" size=14 className="text-nd_gray-500" />),
      description: "mismatch variance exposure",
      cardType: Attention,
    },
    {
      title: ExpectedValue,
      value: Amount(expectedValue, currency),
      icon: CustomIcon(<Icon name="history" size=14 className="text-nd_gray-500" />),
      description: "amount expected",
      cardType: Info,
    },
  ]
}

let getAutoMatchCount = (~overviewRules: array<overviewRulesResponse>) => {
  overviewRules->Array.reduce(0, (acc, rule) => {
    let autoMatchedCount = rule.statuses->Array.reduce(0, (statusAcc, status) => {
      switch status.status {
      | MatchedAuto | MatchedWithTolerance => statusAcc + status.count
      | _ => statusAcc
      }
    })

    acc + autoMatchedCount
  })
}

let getManualCorrectionsCount = (~overviewRules: array<overviewRulesResponse>) => {
  overviewRules->Array.reduce(0, (acc, rule) => {
    let manualCorrectionsCount = rule.statuses->Array.reduce(0, (statusAcc, status) => {
      switch status.status {
      | MatchedManual | PostedManual | MatchedForce | PartiallyReconciled =>
        statusAcc + status.count
      | _ => statusAcc
      }
    })

    acc + manualCorrectionsCount
  })
}

let getAgedCount = (~overviewRules: array<overviewRulesResponse>) => {
  overviewRules->Array.reduce(0, (acc, rule) => {
    let missingCount = rule.statuses->Array.reduce(0, (statusAcc, status) => {
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
  ~failedIngestionHistoryList: array<overviewIngestionHistoryResponse>,
  ~failedTransformationHistoryList: array<overviewTransformationHistoryResponse>,
) => {
  let totalCount = getTotalCount(~overviewRules)
  let autoMatchedCount = getAutoMatchCount(~overviewRules)
  let manualCorrectionsCount = getManualCorrectionsCount(~overviewRules)
  let agedCount = getAgedCount(~overviewRules)

  let autoMatchRate =
    totalCount === 0 ? 0.0 : autoMatchedCount->Int.toFloat /. totalCount->Int.toFloat *. 100.0

  [
    {
      title: AutoMatchRate,
      value: Percentage(autoMatchRate),
    },
    {
      title: FailedIngestions,
      value: Number(failedIngestionHistoryList->Array.length),
    },
    {
      title: Aged,
      value: OutOf(agedCount, totalCount),
    },
    {
      title: FailedTransformations,
      value: Number(failedTransformationHistoryList->Array.length),
    },
    {
      title: ManualCorrections,
      value: Number(manualCorrectionsCount),
    },
  ]
}

let overviewRuleStatusTypeFromString = status =>
  switch status {
  | "expected" => Expected
  | "missing" => Missing
  | "over_amount_expected" => OverAmountExpected
  | "over_amount_mismatch" => OverAmountMismatch
  | "under_amount_expected" => UnderAmountExpected
  | "under_amount_mismatch" => UnderAmountMismatch
  | "data_mismatch" => DataMismatch
  | "currency_mismatch" => CurrencyMismatch
  | "split_mismatch" => SplitMismatch
  | "archived" => Archived
  | "void" => Void
  | "partially_reconciled" => PartiallyReconciled
  | "matched_auto" => MatchedAuto
  | "matched_manual" => MatchedManual
  | "matched_force" => MatchedForce
  | "matched_with_tolerance" => MatchedWithTolerance
  | "posted_manual" => PostedManual
  | status => UnknownStatus(status)
  }

let overviewRuleStatusMapper: Dict.t<JSON.t> => overviewRuleStatus = dict => {
  {
    status: dict->getString("status", "")->overviewRuleStatusTypeFromString,
    count: dict->getInt("count", 0),
    credit_sum: dict->getFloat("credit_sum", 0.0),
    debit_sum: dict->getFloat("debit_sum", 0.0),
    currency: dict->getString("currency", ""),
  }
}

let overviewRulesResponseMapper: Dict.t<JSON.t> => overviewRulesResponse = dict => {
  {
    rule_id: dict->getString("rule_id", ""),
    rule_name: dict->getString("rule_name", ""),
    statuses: dict
    ->getArrayFromDict("statuses", [])
    ->Array.map(status => status->getDictFromJsonObject->overviewRuleStatusMapper),
  }
}

let overviewIngestionHistoryResponseMapper = (dict): overviewIngestionHistoryResponse => {
  {
    id: dict->getString("id", ""),
    ingestion_id: dict->getString("ingestion_id", ""),
    ingestion_history_id: dict->getString("ingestion_history_id", ""),
    file_name: dict->getString("file_name", "N/A"),
    account_id: dict->getString("account_id", ""),
    status: dict->getString("status", ""),
    upload_type: dict->getString("upload_type", ""),
    created_at: dict->getString("created_at", ""),
    ingestion_name: dict->getString("ingestion_name", ""),
    version: dict->getInt("version", 0),
    discarded_at: dict->getString("discarded_at", ""),
    discarded_status: dict->getString("discarded_status", ""),
  }
}

let transformationDataMapper = (dict): transformationData => {
  {
    transformation_result: dict->getString("transformation_result", ""),
    total_count: dict->getInt("total_count", 0),
    transformed_count: dict->getInt("transformed_count", 0),
    ignored_count: dict->getInt("ignored_count", 0),
    staging_entry_ids: dict->getStrArrayFromDict("staging_entry_ids", []),
    errors: dict->getStrArrayFromDict("errors", []),
  }
}

let overviewTransformationHistoryResponseMapper = (dict): overviewTransformationHistoryResponse => {
  {
    transformation_history_id: dict->getString("transformation_history_id", ""),
    transformation_id: dict->getString("transformation_id", ""),
    account_id: dict->getString("account_id", ""),
    ingestion_history_id: dict->getString("ingestion_history_id", ""),
    transformation_name: dict->getString("transformation_name", ""),
    status: dict->getString("status", ""),
    data: dict
    ->getJsonObjectFromDict("data")
    ->getDictFromJsonObject
    ->transformationDataMapper,
    processed_at: dict->getString("processed_at", ""),
    created_at: dict->getString("created_at", ""),
  }
}
