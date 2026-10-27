open LogicUtils
open ExplorerTypes
open ExplorerCatalog
open ExplorerUtils
open ExplorerSelection

let emptyCounts = {
  total: 0.0,
  success: 0.0,
  failed: 0.0,
  authFailed: 0.0,
  excluded: 0.0,
  threeDsAttempts: 0.0,
  amount: 0.0,
  lostAmount: 0.0,
}

let countsItemToObjMapper = (dict): counts => {
  total: dict->getFloat("total", 0.0),
  success: dict->getFloat("success", 0.0),
  failed: dict->getFloat("failed", 0.0),
  authFailed: dict->getFloat("authFailed", 0.0),
  excluded: dict->getFloat("excluded", 0.0),
  threeDsAttempts: dict->getFloat("threeDsAttempts", 0.0),
  amount: dict->getFloat("amount", 0.0),
  lostAmount: dict->getFloat("lostAmount", 0.0),
}

let groupItemToObjMapper = (dict): group => {
  values: dict->getStrArrayFromDict("values", []),
  current: dict->getDictfromDict("current")->countsItemToObjMapper,
  previous: None,
}

let addCounts = (a, b) => {
  total: a.total +. b.total,
  success: a.success +. b.success,
  failed: a.failed +. b.failed,
  authFailed: a.authFailed +. b.authFailed,
  excluded: a.excluded +. b.excluded,
  threeDsAttempts: a.threeDsAttempts +. b.threeDsAttempts,
  amount: a.amount +. b.amount,
  lostAmount: a.lostAmount +. b.lostAmount,
}

let sumCounts = countsList => countsList->Array.reduce(emptyCounts, addCounts)

let getCount = (counts, field) =>
  switch field {
  | Total => counts.total
  | Success => counts.success
  | Failed => counts.failed
  | Excluded => counts.excluded
  | AuthFailed => counts.authFailed
  | Other => counts.total -. counts.success -. counts.failed -. counts.excluded
  }

let getDenominator = (counts, base) =>
  switch base {
  | AllRecords => counts.total
  | EligibleRecords => counts.total -. counts.excluded
  | DecidedRecords => counts.success +. counts.failed
  | ThreeDsAttempts => counts.threeDsAttempts
  }

let getRowCounts = (source: source, dict) => {
  let config = sourceConfig(source)
  switch source {
  | #dispute => {
      ...emptyCounts,
      total: dict->getFloat("total_dispute", 0.0),
      success: dict->getFloat("disputes_won", 0.0),
      failed: dict->getFloat("disputes_lost", 0.0),
      excluded: dict->getFloat("disputes_challenged", 0.0),
      amount: dict->getFloat("disputed_amount", 0.0),
      lostAmount: dict->getFloat("dispute_lost_amount", 0.0),
    }
  | #intent | #attempt | #refund =>
    let records = dict->getFloat((config.countMetric :> string), 0.0)
    let status = config.statusDimension->mapOptionOrDefault("", key => dict->getDimensionValue(key))
    let outcomes = getOutcomesOfStatus(source, status)
    let countIf = field => outcomes->Array.includes(field) ? records : 0.0
    let isThreeDs =
      dict->getDimensionValue(#authentication_type) == (#three_ds: authenticationType :> string)
    {
      ...emptyCounts,
      total: records,
      success: countIf(Success),
      failed: countIf(Failed),
      excluded: countIf(Excluded),
      authFailed: isThreeDs ? countIf(AuthFailed) : 0.0,
      threeDsAttempts: isThreeDs ? records : 0.0,
      amount: config.amountMetrics
      ->Array.map(metric => dict->getFloat((metric :> string), 0.0))
      ->getValueFromArray(0, 0.0),
    }
  }
}

let getMeasureValue = (source, measure, counts) =>
  switch getMeasureFormula(source, measure) {
  | Rate(field, base) => calculatePercentage(counts->getCount(field), counts->getDenominator(base))
  | Count(field) => counts->getCount(field)
  | TotalAmount(Processed) => counts.amount
  | TotalAmount(Lost) => counts.lostAmount
  | AmountPerSuccess => counts.success > 0.0 ? counts.amount /. counts.success : 0.0
  }

let getRateDenominator = (source, measure, counts) =>
  switch getMeasureFormula(source, measure) {
  | Rate(_, base) => counts->getDenominator(base)
  | Count(_) | TotalAmount(_) | AmountPerSuccess => counts.total
  }

let measurable = (source, measure, counts) =>
  !isRate(measure) || getRateDenominator(source, measure, counts) > 0.0

let displayValue = (source, measure, counts, ~currency) => {
  let value = getMeasureValue(source, measure, counts)
  isAmount(measure)
    ? CurrencyUtils.convertCurrencyFromLowestDenomination(~amount=value, ~currency)
    : value
}

let formatValue = (source, measure, counts, ~currency) =>
  measurable(source, measure, counts)
    ? formatDisplay(measure, displayValue(source, measure, counts, ~currency), ~currency)
    : "–"

let getMeasureCounts = (dataset, measure) =>
  isAmount(measure)
    ? (dataset.inCurrency, dataset.inCurrencyPrevious)
    : (dataset.overall, dataset.overallPrevious)

let getCurrencyWeight = (source, measure, counts) =>
  switch getMeasureFormula(source, measure) {
  | TotalAmount(Lost) => counts.failed
  | _ => counts.success
  }

let getCurrenciesByWeight = (source, measure, rows) =>
  rows
  ->Array.map(getDictFromJsonObject)
  ->Array.reduce(Dict.make(), (acc, dict) => {
    let currency = dict->getDimensionValue(#currency)
    if currency->isNonEmptyString {
      acc->Dict.set(
        currency,
        acc->getValueFromDict(currency, 0.0) +.
          getCurrencyWeight(source, measure, getRowCounts(source, dict)),
      )
    }
    acc
  })
  ->Dict.toArray
  ->Array.toSorted(((_, a), (_, b)) => compareLogic(a, b))
  ->Array.map(((currency, _)) => currency)

let buildDataset = (selection, responses) => {
  let {source, measure} = selection
  let needsCurrency = selection->needsCurrency
  let filteredCurrencies = selection->getSelectedFilterValues(#currency)
  let pickedCurrency =
    filteredCurrencies->isEmptyArray || filteredCurrencies->Array.includes(selection.currency)
      ? selection.currency
      : ""

  let amountCurrencies = needsCurrency
    ? getCurrenciesByWeight(source, measure, responses.currentRows)
      ->Array.concat(getCurrenciesByWeight(source, measure, responses.previousRows))
      ->Array.concat([pickedCurrency])
      ->Array.filter(isNonEmptyString)
      ->ArrayUtils.getUniqueStrArray
    : []
  let amountCurrency = switch filteredCurrencies {
  | [currency] => currency
  | _ =>
    pickedCurrency->isNonEmptyString ? pickedCurrency : amountCurrencies->getValueFromArray(0, "")
  }

  let isInCurrency = dict => !needsCurrency || dict->getDimensionValue(#currency) == amountCurrency
  let totalOf = (rows, ~keep=_ => true) =>
    rows
    ->Array.map(getDictFromJsonObject)
    ->Array.filter(keep)
    ->Array.map(dict => getRowCounts(source, dict))
    ->sumCounts
  let groupsOf = rows =>
    rows
    ->Array.map(getDictFromJsonObject)
    ->Array.filter(isInCurrency)
    ->Array.reduce(Dict.make(), (acc, dict) => {
      let values = selection.split->Array.map(key => dict->getDimensionValue(key))
      let key = values->getRowKey
      let (_, sum) = acc->getValueFromDict(key, (values, emptyCounts))
      acc->Dict.set(key, (values, sum->addCounts(getRowCounts(source, dict))))
      acc
    })
  let dailyOf = rows =>
    rows
    ->Array.map(getDictFromJsonObject)
    ->Array.filter(isInCurrency)
    ->Array.reduce(Dict.make(), (acc, dict) => {
      let groupKey = selection.split->Array.map(key => dict->getDimensionValue(key))->getRowKey
      let day = dict->getRowDay
      let key = getDailyKey(~groupKey, ~day)
      let point = acc->getValueFromDict(key, {groupKey, day, counts: emptyCounts})
      acc->Dict.set(key, {...point, counts: point.counts->addCounts(getRowCounts(source, dict))})
      acc
    })

  let currentGroups = responses.currentRows->groupsOf
  let previousGroups = responses.previousRows->groupsOf
  let allGroups =
    currentGroups
    ->Dict.toArray
    ->Array.map(((key, (values, current))) => {
      values,
      current,
      previous: previousGroups
      ->getOptionValFromDict(key)
      ->Option.map(((_, counts)) => counts),
    })
    ->Array.toSorted((a, b) => compareLogic(a.current.total, b.current.total))
  let groups = allGroups->Array.filter(group => measurable(source, measure, group.current))

  {
    overall: responses.currentRows->totalOf,
    overallPrevious: responses.previousRows->totalOf,
    inCurrency: responses.currentRows->totalOf(~keep=isInCurrency),
    inCurrencyPrevious: responses.previousRows->totalOf(~keep=isInCurrency),
    amountCurrencies,
    amountCurrency,
    groups,
    topByVolume: allGroups->Array.slice(~start=0, ~end=topGroupCount),
    topMeasured: groups->Array.slice(~start=0, ~end=topGroupCount),
    unmeasured: isRate(measure)
      ? currentGroups
        ->Dict.valuesToArray
        ->Array.filter(((_, counts)) => !measurable(source, measure, counts))
        ->Array.toSorted(((_, a), (_, b)) => compareLogic(a.total, b.total))
      : [],
    currentDaily: responses.currentDaily->dailyOf,
    previousDaily: responses.previousDaily->dailyOf,
  }
}

let getCountsOn = (points, ~groupKey, ~day) =>
  points
  ->getOptionValFromDict(getDailyKey(~groupKey, ~day))
  ->mapOptionOrDefault(emptyCounts, point => point.counts)

let getPointValue = (selection, counts, ~currency) =>
  measurable(selection.source, selection.measure, counts)
    ? Nullable.make(displayValue(selection.source, selection.measure, counts, ~currency))
    : Nullable.null
