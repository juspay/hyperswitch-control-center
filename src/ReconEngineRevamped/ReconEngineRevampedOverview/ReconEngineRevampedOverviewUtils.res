open LogicUtils
open ReconEngineRevampedOverviewTypes

let getOverviewChartGranularity = (~startTime, ~endTime) => {
  let rangeMilliseconds = DateRangeUtils.getStartEndDiff(startTime, endTime)
  let rangeMinutes = rangeMilliseconds /. (1000.0 *. 60.0)

  if rangeMinutes <= 60.0 {
    FifteenMinutes
  } else if rangeMinutes <= 24.0 *. 60.0 {
    Hourly
  } else if rangeMinutes <= 30.0 *. 24.0 *. 60.0 {
    Daily
  } else {
    Weekly
  }
}

let getOverviewChartGranularityDuration = granularity =>
  switch granularity {
  | FifteenMinutes => 15.0 *. 60.0 *. 1000.0
  | Hourly => 60.0 *. 60.0 *. 1000.0
  | Daily => 24.0 *. 60.0 *. 60.0 *. 1000.0
  | Weekly => 7.0 *. 24.0 *. 60.0 *. 60.0 *. 1000.0
  }

let getOverviewChartBucketLabel = (~timestamp, ~granularity) => {
  let date = timestamp->Js.Date.fromFloat->DayJs.getDayJsForJsDate
  switch granularity {
  | FifteenMinutes | Hourly => date.format("DD MMM, h A")
  | Daily => date.format("DD MMM")
  | Weekly => date.format("DD MMM")
  }
}

let getOverviewChartTooltipLabel = (~timestamp, ~granularity) => {
  let date = timestamp->Js.Date.fromFloat->DayJs.getDayJsForJsDate
  switch granularity {
  | FifteenMinutes | Hourly => date.format("MMM DD, YYYY, h:mm A")
  | Daily | Weekly => date.format("MMM DD, YYYY")
  }
}

let getOverviewChartBuckets = (~startTime, ~endTime, ~granularity) => {
  let startTimestamp = startTime->Date.fromString->Date.getTime
  let endTimestamp = endTime->Date.fromString->Date.getTime
  let duration = getOverviewChartGranularityDuration(granularity)

  let rec buildBuckets = (currentTimestamp, buckets) => {
    if currentTimestamp >= endTimestamp {
      buckets
    } else {
      let nextBucketTimestamp = Math.min(currentTimestamp +. duration, endTimestamp)
      let bucketEndTimestamp =
        nextBucketTimestamp < endTimestamp ? nextBucketTimestamp -. 1.0 : nextBucketTimestamp
      let bucket = {
        startTime: currentTimestamp->Js.Date.fromFloat->Date.toISOString,
        endTime: bucketEndTimestamp->Js.Date.fromFloat->Date.toISOString,
        label: getOverviewChartBucketLabel(~timestamp=currentTimestamp, ~granularity),
        tooltipLabel: getOverviewChartTooltipLabel(~timestamp=currentTimestamp, ~granularity),
      }
      buildBuckets(nextBucketTimestamp, buckets->Array.concat([bucket]))
    }
  }

  buildBuckets(startTimestamp, [])
}

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
  overviewRules->Array.reduce(0, (acc, rule) => {
    let exceptionCount = rule.statuses->Array.reduce(0, (statusAcc, status) => {
      switch status.status {
      | OverAmountExpected
      | UnderAmountExpected
      | OverAmountMismatch
      | UnderAmountMismatch
      | DataMismatch
      | CurrencyMismatch
      | SplitMismatch
      | PartiallyReconciled =>
        statusAcc + status.count
      | Expected
      | Missing
      | PostedManual
      | MatchedAuto
      | MatchedManual
      | MatchedForce
      | MatchedWithTolerance
      | Void
      | Archived
      | UnknownStatus(_) => statusAcc
      }
    })

    acc + exceptionCount
  })
}

let getMatchedCount = (~overviewRules: array<overviewRulesResponse>) => {
  overviewRules->Array.reduce(0, (acc, rule) => {
    let exceptionCount = rule.statuses->Array.reduce(0, (statusAcc, status) => {
      switch status.status {
      | MatchedAuto
      | MatchedForce
      | MatchedWithTolerance
      | MatchedManual
      | PostedManual =>
        statusAcc + status.count
      | CurrencyMismatch
      | SplitMismatch
      | OverAmountExpected
      | Expected
      | Missing
      | OverAmountMismatch
      | UnderAmountExpected
      | UnderAmountMismatch
      | DataMismatch
      | PartiallyReconciled
      | Void
      | Archived
      | UnknownStatus(_) => statusAcc
      }
    })

    acc + exceptionCount
  })
}

let getOverviewChartPoint = (~label, ~tooltipLabel, ~overviewRules) => {
  let totalCount = getTotalCount(~overviewRules)
  let openExceptions = getOpenExceptions(~overviewRules)
  let matchedCount = totalCount - openExceptions
  let matchRate =
    totalCount === 0 ? 0.0 : matchedCount->Int.toFloat /. totalCount->Int.toFloat *. 100.0

  {
    label,
    tooltipLabel,
    totalCount: totalCount->Int.toFloat,
    matchedCount: matchedCount->Int.toFloat,
    matchRate,
  }
}

let overviewChartTooltipFormatter = (~points) =>
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
      let totalPoint = this.points->getValueFromArray(0, defaultPoint)
      let matchRatePoint = this.points->getValueFromArray(1, defaultPoint)
      let chartPoint = points->Array.get(totalPoint.point.index)
      let totalCount =
        chartPoint
        ->Option.map(point => point.totalCount)
        ->Option.getOr(totalPoint.y)
        ->Float.toInt
      let matchedCount =
        chartPoint
        ->Option.map(point => point.matchedCount)
        ->Option.getOr(0.0)
        ->Float.toInt
      let percentage =
        matchRatePoint.y
        ->Float.toFixedWithPrecision(~digits=2)
        ->removeTrailingZero
      let tooltipLabel =
        chartPoint
        ->Option.map(point => point.tooltipLabel)
        ->Option.getOr(totalPoint.key)

      `<div style="padding:12px 14px;border-radius:10px;background:#fff;box-shadow:0 6px 18px rgba(29,41,57,.12);border:1px solid #E1E4EA;color:#525866;">
        <div style="font-size:12px;margin-bottom:7px;font-weight:700;">${tooltipLabel}</div>
        <div style="font-size:14px;font-weight:400;">${ReconEngineRevampedUtils.formatNumber(
          totalCount,
        )} transactions</div>
        <div style="font-size:13px;font-weight:500;color:#247DF9;margin-top:5px;">${percentage}% matched (${ReconEngineRevampedUtils.formatNumber(
          matchedCount,
        )})</div>
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

  {
    titleObj: {
      chartTitle: {
        text: "",
        align: "left",
        style,
      },
      xAxisTitle: {
        text: "",
        style,
      },
      yAxisTitle: {
        text: "",
        style,
      },
      oppositeYAxisTitle: {
        text: "",
        style,
      },
    },
    categories: points->Array.map(point => point.label),
    data: [
      {
        showInLegend: false,
        name: "Reconciliation Volume",
        \"type": "column",
        data: points->Array.map(point => point.totalCount),
        color: "#A9C8F6",
        yAxis: 1,
      },
      {
        showInLegend: false,
        name: "Match Rate",
        \"type": "line",
        data: points->Array.map(point => point.matchRate),
        color: "#2F73E0",
        yAxis: 0,
        lineWidth: 2,
      },
    ],
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
    columnPointWidth: Some(14),
    hideAxisLabels: false,
    chartHeight: 280,
  }
}

let getOverviewStatusDistribution = (~overviewRules: array<overviewRulesResponse>): array<
  overviewStatusDistributionItem,
> => {
  let counts = overviewRules->Array.reduce((0, 0, 0, 0, 0), (acc, rule) => {
    rule.statuses->Array.reduce(acc, (
      (reconciled, matched, exceptionCount, pending, voidCount),
      status,
    ) => {
      switch status.status {
      | PostedManual => (reconciled + status.count, matched, exceptionCount, pending, voidCount)
      | MatchedAuto | MatchedManual | MatchedForce | MatchedWithTolerance => (
          reconciled,
          matched + status.count,
          exceptionCount,
          pending,
          voidCount,
        )
      | Expected | Missing => (
          reconciled,
          matched,
          exceptionCount,
          pending + status.count,
          voidCount,
        )
      | Void => (reconciled, matched, exceptionCount, pending, voidCount + status.count)
      | OverAmountExpected
      | UnderAmountExpected
      | OverAmountMismatch
      | UnderAmountMismatch
      | DataMismatch
      | CurrencyMismatch
      | SplitMismatch
      | PartiallyReconciled => (
          reconciled,
          matched,
          exceptionCount + status.count,
          pending,
          voidCount,
        )
      | Archived | UnknownStatus(_) => (reconciled, matched, exceptionCount, pending, voidCount)
      }
    })
  })
  let (reconciled, matched, exceptionCount, pending, voidCount) = counts

  [
    {name: "Reconciled", count: reconciled, color: "#4F86D9"},
    {name: "Exception", count: exceptionCount, color: "#EA8A8F"},
    {name: "Matched", count: matched, color: "#7AB891"},
    {name: "Expected", count: pending, color: "#C9A35B"},
    {name: "Void", count: voidCount, color: "#8B97A8"},
  ]
}

let overviewStatusTooltipFormatter = (~totalCount) => {
  (
    @this
    (this: PieGraphTypes.pointFormatter) => {
      let count = this.y->Float.toInt
      let percentage = if totalCount == 0 {
        0
      } else {
        Math.round(this.y /. totalCount->Int.toFloat *. 100.0)->Float.toInt
      }

      `<div style="padding:10px 12px;border-radius:10px;background:#fff;box-shadow:0 6px 18px rgba(29,41,57,.12);border:1px solid #E1E4EA;color:#525866;">
        <div style="display:flex;align-items:center;gap:8px;font-size:13px;font-weight:400;">
          <span style="width:8px;height:8px;border-radius:9999px;background:${this.color};flex-shrink:0;"></span>
          <span>${this.point.name}</span>
        </div>
        <div style="font-size:13px;font-weight:400;margin-top:4px;">
          ${count->ReconEngineRevampedUtils.formatNumber} &middot; ${percentage->Int.toString}%
        </div>
      </div>`
    }
  )->PieGraphTypes.asTooltipPointFormatter
}

let getOverviewStatusDistributionOptions = (
  distribution: array<overviewStatusDistributionItem>,
): PieGraphTypes.pieGraphOptions<int> => {
  let totalCount = distribution->Array.reduce(0, (total, item) => total + item.count)
  let data: array<PieGraphTypes.pieGraphDataType> = distribution->Array.map(item => {
    let point: PieGraphTypes.pieGraphDataType = {
      name: item.name,
      y: item.count->Int.toFloat,
      color: item.color,
    }
    point
  })
  let payload: PieGraphTypes.pieGraphPayload<int> = {
    data: [
      {
        \"type": "pie",
        innerSize: "72%",
        showInLegend: false,
        name: "Status distribution",
        data,
      },
    ],
    title: {text: ""},
    tooltipFormatter: overviewStatusTooltipFormatter(~totalCount),
    legendFormatter: PieGraphUtils.pieGraphLegendFormatter(),
    chartSize: "88%",
    startAngle: 0,
    endAngle: 360,
    legend: {
      enabled: false,
    },
  }
  let options = payload->PieGraphUtils.getPieChartOptions

  {
    ...options,
    chart: {
      ...options.chart,
      width: 220,
      height: 220,
    },
    title: {
      text: `<div style="display:flex;flex-direction:column;align-items:center;">
        <span style="font-size:24px;font-weight:600;color:#1F2937;line-height:28px;">${totalCount->ReconEngineRevampedUtils.formatNumber}</span>
        <span style="font-size:12px;font-weight:400;color:#667085;line-height:18px;">Total</span>
      </div>`,
      align: "center",
      verticalAlign: "middle",
      y: 8,
      useHTML: true,
    },
    plotOptions: {
      pie: {
        ...options.plotOptions.pie,
        innerSize: "72%",
        showInLegend: false,
        borderRadius: 4,
      },
    },
  }
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

let getStatCards = (
  ~overviewRules: array<overviewRulesResponse>,
  ~manualReviewStagingEntries: array<overviewStagingEntryResponse>,
) => {
  let totalCount = getTotalCount(~overviewRules)
  let matchedCount = getMatchedCount(~overviewRules)
  let openExceptions = getOpenExceptions(~overviewRules) + manualReviewStagingEntries->Array.length
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

let processingEntryDiscardedDataItemToObjMapper = (dataDict): processingEntryDiscardedDataType => {
  {
    reason: dataDict->getString("reason", ""),
    status: dataDict->getString("status", ""),
  }
}

let accountRefItemToObjMapper = dict => {
  {
    account_id: dict->getString("account_id", ""),
    account_name: dict->getString("account_name", ""),
  }
}

let processingEntryDataItemToObjMapper = (dataDict): processingEntryDataType => {
  {
    status: dataDict->getString("status", ""),
    needs_manual_review_type: dataDict->getString("needs_manual_review_type", ""),
  }
}

let overviewStagingEntryResponseMapper = (dict): overviewStagingEntryResponse => {
  let discardedDataDict =
    dict->getDictfromDict("discarded_data")->processingEntryDiscardedDataItemToObjMapper
  {
    id: dict->getString("id", ""),
    staging_entry_id: dict->getString("staging_entry_id", ""),
    account: dict
    ->getDictfromDict("account")
    ->accountRefItemToObjMapper,
    entry_type: dict->getString("entry_type", ""),
    amount: dict->getDictfromDict("amount")->getFloat("value", 0.0),
    currency: dict->getDictfromDict("amount")->getString("currency", ""),
    status: dict->getString("status", ""),
    effective_at: dict->getString("effective_at", ""),
    processing_mode: dict->getString("processing_mode", ""),
    metadata: dict->getJsonObjectFromDict("metadata"),
    transformation_id: dict->getString("transformation_id", ""),
    transformation_history_id: dict->getString("transformation_history_id", ""),
    order_id: dict->getString("order_id", ""),
    version: dict->getInt("version", 0),
    discarded_status: dict->getOptionString("discarded_status"),
    data: dict->getDictfromDict("data")->processingEntryDataItemToObjMapper,
    discarded_data: Some(discardedDataDict),
  }
}
