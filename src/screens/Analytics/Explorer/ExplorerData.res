open LogicUtils
open ExplorerTypes
open ExplorerCatalog
open ExplorerUtils
open ExplorerQuery

let emptyCounts = {
  total: 0.0,
  success: 0.0,
  failed: 0.0,
  authFailed: 0.0,
  awaiting: 0.0,
  threeDsAttempts: 0.0,
  amount: 0.0,
  backendRate: None,
}

let addCounts = (a, b) => {
  total: a.total +. b.total,
  success: a.success +. b.success,
  failed: a.failed +. b.failed,
  authFailed: a.authFailed +. b.authFailed,
  awaiting: a.awaiting +. b.awaiting,
  threeDsAttempts: a.threeDsAttempts +. b.threeDsAttempts,
  amount: a.amount +. b.amount,
  backendRate: None,
}

let sumCounts = countsList => countsList->Array.reduce(emptyCounts, addCounts)

let getCount = (counts, field) =>
  switch field {
  | Total => counts.total
  | Success => counts.success
  | Failed => counts.failed
  | Awaiting => counts.awaiting
  | AuthFailed => counts.authFailed
  }

let getDenominator = (counts, base) =>
  switch base {
  | AllRecords => counts.total
  | CompletedRecords => counts.total -. counts.awaiting
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
    awaiting: countIf(Awaiting),
    authFailed: isThreeDs ? countIf(AuthFailed) : 0.0,
    threeDsAttempts: isThreeDs ? records : 0.0,
    amount: dict->getFloat((config.amountMetric :> string), 0.0),
    backendRate: None,
  }
}

let getMeasureValue = (source, measure, counts) =>
  switch (measure, counts.backendRate) {
  | (SuccessRate, Some(rate)) => rate
  | _ =>
    switch getMeasureFormula(source, measure) {
    | Rate(field, base) =>
      calculatePercentage(counts->getCount(field), counts->getDenominator(base))
    | Count(field) => counts->getCount(field)
    | TotalAmount => counts.amount
    | AmountPerSuccess => counts.success > 0.0 ? counts.amount /. counts.success : 0.0
    }
  }

let getRateDenominator = (source, measure, counts) =>
  switch getMeasureFormula(source, measure) {
  | Rate(_, base) => counts->getDenominator(base)
  | Count(_) | TotalAmount | AmountPerSuccess => counts.total
  }

let measurable = (source, measure, counts) =>
  !isRate(measure) ||
  measure == SuccessRate && counts.backendRate->Option.isSome ||
  getRateDenominator(source, measure, counts) > 0.0

let displayValue = (source, measure, counts, ~currency) => {
  let value = getMeasureValue(source, measure, counts)
  isAmount(measure)
    ? CurrencyUtils.convertCurrencyFromLowestDenomination(~amount=value, ~currency)
    : value
}

let formatValue = (source, measure, counts, ~currency="") =>
  measurable(source, measure, counts)
    ? formatDisplay(measure, displayValue(source, measure, counts, ~currency), ~currency)
    : "–"

let overallRate = (rows, ~question) =>
  question
  ->getRateMetric
  ->Option.flatMap(metric =>
    rows
    ->getValueFromArray(0, JSON.Encode.null)
    ->getDictFromJsonObject
    ->getOptionFloat((metric :> string))
  )

let buildDataset = (question, responses) => {
  let source = question.source
  let needsCurrency = question->needsCurrency

  let amountCurrencies = needsCurrency
    ? responses.currentRows
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
    : []
  let amountCurrency =
    amountCurrencies->Array.includes(question.currency)
      ? question.currency
      : amountCurrencies->getValueFromArray(0, "")

  let keep = dict => !needsCurrency || dict->getDimensionValue(#currency) == amountCurrency
  let totalOf = (rows, ~rateRows) => {
    ...rows
    ->Array.map(getDictFromJsonObject)
    ->Array.filter(keep)
    ->Array.map(dict => getRowCounts(source, dict))
    ->sumCounts,
    backendRate: rateRows->overallRate(~question),
  }

  {
    overall: responses.currentRows->totalOf(~rateRows=responses.rateCurrent),
    overallPrevious: responses.previousRows->totalOf(~rateRows=responses.ratePrevious),
    amountCurrencies,
    amountCurrency,
  }
}
