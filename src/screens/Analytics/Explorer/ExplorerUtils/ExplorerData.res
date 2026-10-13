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
}

let addCounts = (a, b) => {
  total: a.total +. b.total,
  success: a.success +. b.success,
  failed: a.failed +. b.failed,
  authFailed: a.authFailed +. b.authFailed,
  excluded: a.excluded +. b.excluded,
  threeDsAttempts: a.threeDsAttempts +. b.threeDsAttempts,
  amount: a.amount +. b.amount,
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
  | ThreeDsAttempts => counts.threeDsAttempts
  }

let getRowCounts = (source, dict) => {
  let config = sourceConfig(source)
  let records = dict->getFloat((config.countMetric :> string), 0.0)
  let outcomes = getOutcomesOfStatus(source, dict->getDimensionValue(#status))
  let countIf = field => outcomes->Array.includes(field) ? records : 0.0
  let isThreeDs =
    dict->getDimensionValue(#authentication_type) == (#three_ds: authenticationType :> string)
  {
    total: records,
    success: countIf(Success),
    failed: countIf(Failed),
    excluded: countIf(Excluded),
    authFailed: isThreeDs ? countIf(AuthFailed) : 0.0,
    threeDsAttempts: isThreeDs ? records : 0.0,
    amount: dict->getFloat((config.amountMetric :> string), 0.0),
  }
}

let getMeasureValue = (source, measure, counts) =>
  switch getMeasureFormula(source, measure) {
  | Rate(field, base) => calculatePercentage(counts->getCount(field), counts->getDenominator(base))
  | Count(field) => counts->getCount(field)
  | TotalAmount => counts.amount
  | AmountPerSuccess => counts.success > 0.0 ? counts.amount /. counts.success : 0.0
  }

let getRateDenominator = (source, measure, counts) =>
  switch getMeasureFormula(source, measure) {
  | Rate(_, base) => counts->getDenominator(base)
  | Count(_) | TotalAmount | AmountPerSuccess => counts.total
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

let getCurrenciesBySuccess = (source, rows) =>
  rows
  ->Array.map(getDictFromJsonObject)
  ->Array.reduce(Dict.make(), (acc, dict) => {
    let currency = dict->getDimensionValue(#currency)
    if currency->isNonEmptyString {
      acc->Dict.set(
        currency,
        acc->Dict.get(currency)->Option.getOr(0.0) +. getRowCounts(source, dict).success,
      )
    }
    acc
  })
  ->Dict.toArray
  ->Array.toSorted(((_, a), (_, b)) => b -. a)
  ->Array.map(((currency, _)) => currency)

let buildDataset = (selection, responses) => {
  let {source, measure} = selection
  let needsCurrency = selection->needsCurrency

  let amountCurrencies = needsCurrency
    ? getCurrenciesBySuccess(source, responses.currentRows)
      ->Array.concat(getCurrenciesBySuccess(source, responses.previousRows))
      ->Array.concat([selection.currency])
      ->Array.filter(isNonEmptyString)
      ->ArrayUtils.getUniqueStrArray
    : []
  let amountCurrency =
    selection.currency->isNonEmptyString
      ? selection.currency
      : amountCurrencies->getValueFromArray(0, "")

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
      let (_, sum) = acc->Dict.get(key)->Option.getOr((values, emptyCounts))
      acc->Dict.set(key, (values, sum->addCounts(getRowCounts(source, dict))))
      acc
    })

  let overall = responses.currentRows->totalOf
  let currentGroups = responses.currentRows->groupsOf
  let previousGroups = responses.previousRows->groupsOf
  let groups =
    currentGroups
    ->Dict.toArray
    ->Array.map(((key, (values, current))) => {
      values,
      current,
      previous: previousGroups
      ->Dict.get(key)
      ->Option.map(((_, counts)) => counts)
      ->Option.filter(counts => counts.total > 0.0 && measurable(source, measure, counts)),
    })
    ->Array.filter(group =>
      isRate(measure)
        ? measurable(source, measure, group.current)
        : getMeasureValue(source, measure, group.current) > 0.0
    )

  {
    overall,
    overallPrevious: responses.previousRows->totalOf,
    inCurrency: responses.currentRows->totalOf(~keep=isInCurrency),
    inCurrencyPrevious: responses.previousRows->totalOf(~keep=isInCurrency),
    amountCurrencies,
    amountCurrency,
    sorted: groups->Array.toSorted((a, b) => b.current.total -. a.current.total),
    unmeasured: isRate(measure)
      ? currentGroups
        ->Dict.valuesToArray
        ->Array.filter(((_, counts)) => counts.total > 0.0 && !measurable(source, measure, counts))
      : [],
  }
}
