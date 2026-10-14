open LogicUtils
open ExplorerTypes
open ExplorerCatalog
open ExplorerUtils
open ExplorerSelection
open ExplorerData
open ExplorerDescriptions
open NewAnalyticsUtils

external nullablePoints: array<Nullable.t<float>> => array<float> = "%identity"

let maxBreakdownGroups = 12
let mutedColor = "#CACFD8"
let previousPeriodName = "Previous period"

let defaultLinePoint: LineGraphTypes.point = {
  color: "",
  x: "",
  y: 0.0,
  point: {index: 0},
  series: {name: ""},
}

let defaultColumnPoint: ColumnGraphTypes.point = {
  color: "",
  x: "",
  y: 0.0,
  point: {index: 0},
  key: "",
}

let getOutcomeColor = field =>
  switch field {
  | Success => green
  | Failed | AuthFailed => redColor
  | Excluded => goldenYellow
  | Other | Total => mutedColor
  }

let getImpactColor = impact =>
  switch impact {
  | Favorable => "#12B76A"
  | Unfavorable => "#F04E42"
  | Neutral => "#A0A0A0"
  }

let getDayLabel = day => day->String.slice(~start=0, ~end=10)->formatDateValue

let getAxisLabel = (~measure, ~currency, value) =>
  if isRate(measure) {
    `${value->Int.toString}%`
  } else {
    CurrencyFormatUtils.valueFormatter(
      value->Int.toFloat,
      isAmount(measure) ? Amount : Volume,
      ~currency,
    )
  }

let getChangeHtml = (~measure, ~current, ~previous) => {
  let color = getChangeImpact(measure, current, Some(previous))->getImpactColor
  `<span style="color:${color};margin-left:7px;">${formatChange(
      measure,
      current,
      Some(previous),
    )}</span>`
}

let getTooltipRow = (~color, ~label, ~value, ~change="") =>
  `<div style="display: flex; align-items: center;">
    <div style="width: 10px; height: 10px; background-color:${color}; border-radius:3px;"></div>
    <div style="margin-left: 8px;">${label}${change}</div>
    <div style="flex: 1; text-align: right; font-weight: bold; margin-left: 25px;">${value}</div>
  </div>`

let getSeriesName = (point: ColumnGraphTypes.point) =>
  point.series->Option.mapOr("", series => series.name)

let getTooltip = (~title, ~rows) =>
  InsightsUtils.getContentsUI(
    ~title=InsightsUtils.getTitleUI(~title),
    ~tableItems=rows->Array.joinWith(""),
  )

let hasPrevious = (context: chartContext, ~measure) => {
  let (_, previousCounts) = context.dataset->getMeasureCounts(measure)
  previousCounts.total > 0.0
}

let currentLabel = (context: chartContext) =>
  periodLabel(context.selection.startTime, context.selection.endTime)

let groupLabel = (context: chartContext, group: group) =>
  group.values->getValuesLabel(~split=context.selection.split, ~labelFor=context.labelFor)

let wholeKey = []->getRowKey

let trendTooltipFormatter = (~title, ~measure, ~currency, ~previousDays: array<string>) =>
  (
    @this
    (this: LineGraphTypes.pointFormatter) => {
      let format = value => formatDisplay(measure, value, ~currency)
      let isPrevious = (point: LineGraphTypes.point) =>
        point.series.name->String.startsWith(previousPeriodName)
      let previous = this.points->Array.find(isPrevious)
      let rows = this.points->Array.map(point =>
        if isPrevious(point) {
          getTooltipRow(
            ~color=point.color,
            ~label=previousDays->getValueFromArray(point.point.index, ""),
            ~value=point.y->format,
          )
        } else {
          getTooltipRow(
            ~color=point.color,
            ~label=previousDays->isEmptyArray ? point.series.name : point.x,
            ~value=point.y->format,
            ~change=previous->Option.mapOr("", previousPoint =>
              getChangeHtml(~measure, ~current=point.y, ~previous=previousPoint.y)
            ),
          )
        }
      )
      let day = (this.points->getValueFromArray(0, defaultLinePoint)).x
      getTooltip(~title=previousDays->isEmptyArray ? day : title, ~rows)
    }
  )->LineGraphTypes.asTooltipPointFormatter

let barTooltipFormatter = (~measure, ~currency) =>
  (
    @this
    (this: ColumnGraphTypes.pointFormatter) => {
      let format = value => formatDisplay(measure, value, ~currency)
      let previous = this.points->Array.find(point => point->getSeriesName == previousPeriodName)
      let rows = this.points->Array.map(point =>
        getTooltipRow(
          ~color=point.color,
          ~label=point->getSeriesName,
          ~value=point.y->format,
          ~change=switch previous {
          | Some(previousPoint) if point->getSeriesName != previousPeriodName =>
            getChangeHtml(~measure, ~current=point.y, ~previous=previousPoint.y)
          | _ => ""
          },
        )
      )
      getTooltip(~title=(this.points->getValueFromArray(0, defaultColumnPoint)).key, ~rows)
    }
  )->ColumnGraphTypes.asTooltipPointFormatter

let mixTooltipFormatter = (
  @this
  (this: ColumnGraphTypes.pointFormatter) => {
    let total = this.points->Array.reduce(0.0, (acc, point) => acc +. point.y)
    let rows =
      this.points
      ->Array.toReversed
      ->Array.map(point =>
        getTooltipRow(
          ~color=point.color,
          ~label=point->getSeriesName,
          ~value=`${point.y->formatNumberWithCommas} · ${calculatePercentage(
              point.y,
              total,
            )->formatPercentage}`,
        )
      )
    getTooltip(~title=(this.points->getValueFromArray(0, defaultColumnPoint)).key, ~rows)
  }
)->ColumnGraphTypes.asTooltipPointFormatter

let getLineSeries = (~name, ~points, ~color): LineGraphTypes.dataObj => {
  showInLegend: true,
  name,
  data: points->nullablePoints,
  color,
}

let getColumnSeries = (
  ~name,
  ~points: array<(string, float)>,
  ~color,
): ColumnGraphTypes.seriesObj => {
  showInLegend: true,
  name,
  colorByPoint: false,
  data: points->Array.map(((label, y)): ColumnGraphTypes.dataObj => {name: label, y, color}),
  color,
}

let getTrendPoints = (context: chartContext, dailyPoints, ~days, ~groupKey) =>
  days->Array.map(day =>
    context.selection->getPointValue(
      dailyPoints->getCountsOn(~groupKey, ~day),
      ~currency=context.dataset.amountCurrency,
    )
  )

let getTrendSeries = (context: chartContext, ~days, ~previousDays) => {
  let {selection, dataset} = context
  if selection.split->isEmptyArray {
    let (previousStart, previousEnd) = selection->previousWindow
    let current = getLineSeries(
      ~name=context->currentLabel,
      ~points=context->getTrendPoints(dataset.currentDaily, ~days, ~groupKey=wholeKey),
      ~color=getColor(0),
    )
    let previous = getLineSeries(
      ~name=`${previousPeriodName} (${periodLabel(previousStart, previousEnd)})`,
      ~points=context->getTrendPoints(
        dataset.previousDaily,
        ~days=previousDays,
        ~groupKey=wholeKey,
      ),
      ~color=mutedColor,
    )
    context->hasPrevious(~measure=selection.measure) ? [current, previous] : [current]
  } else {
    dataset.topByVolume->Array.mapWithIndex((group, index) =>
      getLineSeries(
        ~name=context->groupLabel(group),
        ~points=context->getTrendPoints(
          dataset.currentDaily,
          ~days,
          ~groupKey=group.values->getRowKey,
        ),
        ~color=getColor(index),
      )
    )
  }
}

let getTrendChartOptions = (context: chartContext) => {
  let {selection, dataset} = context
  let {measure} = selection
  let currency = dataset.amountCurrency
  let days = getWindowDays(selection.startTime, selection.endTime)
  let (previousStart, previousEnd) = selection->previousWindow
  let previousDays = getWindowDays(previousStart, previousEnd)
  let base = LineGraphUtils.getLineGraphOptions({
    chartHeight: DefaultHeight,
    chartLeftSpacing: DefaultLeftSpacing,
    categories: days->Array.map(getDayLabel),
    data: context->getTrendSeries(~days, ~previousDays),
    title: {text: ""},
    yAxisMaxValue: isRate(measure) ? Some(100) : None,
    yAxisMinValue: Some(0),
    tooltipFormatter: trendTooltipFormatter(
      ~title=measureLabel(selection.source, measure),
      ~measure,
      ~currency,
      ~previousDays=selection.split->isEmptyArray ? previousDays->Array.map(getDayLabel) : [],
    ),
    yAxisFormatter: (
      @this (this: LineGraphTypes.yAxisFormatter) => getAxisLabel(~measure, ~currency, this.value)
    )->LineGraphTypes.asTooltipPointFormatter,
    legend: {
      useHTML: true,
      labelFormatter: LineGraphUtils.valueFormatter,
    },
  })
  {...base, plotOptions: {...base.plotOptions, line: {marker: {enabled: true}, connectNulls: true}}}
}

let getHorizontalBarOptions = (~series, ~measure, ~currency, ~barCount) => {
  let base = ColumnGraphUtils.getColumnGraphOptions({
    data: series,
    title: {text: ""},
    tooltipFormatter: barTooltipFormatter(~measure, ~currency),
    yAxisFormatter: (
      @this (this: ColumnGraphTypes.yAxisFormatter) => getAxisLabel(~measure, ~currency, this.value)
    )->ColumnGraphTypes.asTooltipPointFormatter,
  })
  {
    ...base,
    chart: {...base.chart, \"type": "bar", height: Math.Int.max(240, 60 + barCount * 44)},
    plotOptions: {series: {...base.plotOptions.series, pointWidth: 12, borderRadius: 3}},
  }
}

let getBreakdownChartOptions = (context: chartContext) => {
  let {selection, dataset} = context
  let currency = dataset.amountCurrency
  let groups = dataset.groups->Array.slice(~start=0, ~end=maxBreakdownGroups)
  let valueFor = counts => displayValue(selection.source, selection.measure, counts, ~currency)
  let current = getColumnSeries(
    ~name=context->currentLabel,
    ~points=groups->Array.map(group => (context->groupLabel(group), valueFor(group.current))),
    ~color=getColor(0),
  )
  let previous = getColumnSeries(
    ~name=previousPeriodName,
    ~points=groups->Array.filterMap(group =>
      group.previous->Option.map(counts => (context->groupLabel(group), valueFor(counts)))
    ),
    ~color=mutedColor,
  )
  getHorizontalBarOptions(
    ~series=context->hasPrevious(~measure=selection.measure) ? [current, previous] : [current],
    ~measure=selection.measure,
    ~currency,
    ~barCount=groups->Array.length,
  )
}

let getOutcomeChartOptions = (context: chartContext) => {
  let {selection, dataset} = context
  let points = counts =>
    outcomes->Array.map(field => (outcomeLabel(selection.source, field), counts->getCount(field)))
  let current = getColumnSeries(
    ~name=context->currentLabel,
    ~points=dataset.overall->points,
    ~color=getColor(0),
  )
  let previous = getColumnSeries(
    ~name=previousPeriodName,
    ~points=dataset.overallPrevious->points,
    ~color=mutedColor,
  )
  getHorizontalBarOptions(
    ~series=context->hasPrevious(~measure=#volume) ? [current, previous] : [current],
    ~measure=#volume,
    ~currency="",
    ~barCount=outcomes->Array.length,
  )
}

let getMixSeries = (context: chartContext, ~days) => {
  let {selection, dataset} = context
  let perDay = pick => days->Array.map(day => (day->getDayLabel, pick(day)))
  if selection.split->isEmptyArray {
    outcomes
    ->Array.map(field =>
      getColumnSeries(
        ~name=outcomeLabel(selection.source, field),
        ~points=perDay(day =>
          dataset.currentDaily->getCountsOn(~groupKey=wholeKey, ~day)->getCount(field)
        ),
        ~color=getOutcomeColor(field),
      )
    )
    ->Array.toReversed
  } else {
    let topKeys = dataset.topByVolume->Array.map(group => group.values->getRowKey)
    let other = getColumnSeries(
      ~name="Other",
      ~points=perDay(day =>
        dataset.currentDaily
        ->Dict.valuesToArray
        ->Array.filter(point => point.day == day && !(topKeys->Array.includes(point.groupKey)))
        ->Array.reduce(0.0, (acc, point) => acc +. point.counts.total)
      ),
      ~color=mutedColor,
    )
    let otherIsEmpty = other.data->Array.every(point => point.y == 0.0)
    (otherIsEmpty ? [] : [other])->Array.concat(
      dataset.topByVolume
      ->Array.mapWithIndex((group, index) =>
        getColumnSeries(
          ~name=context->groupLabel(group),
          ~points=perDay(day =>
            (dataset.currentDaily->getCountsOn(~groupKey=group.values->getRowKey, ~day)).total
          ),
          ~color=getColor(index),
        )
      )
      ->Array.toReversed,
    )
  }
}

let getMixChartOptions = (context: chartContext) => {
  let {selection} = context
  let base = ColumnGraphUtils.getColumnGraphOptions({
    data: context->getMixSeries(~days=getWindowDays(selection.startTime, selection.endTime)),
    title: {text: ""},
    tooltipFormatter: mixTooltipFormatter,
    yAxisFormatter: (
      @this (this: ColumnGraphTypes.yAxisFormatter) => `${this.value->Int.toString}%`
    )->ColumnGraphTypes.asTooltipPointFormatter,
  })
  {
    ...base,
    plotOptions: {series: {...base.plotOptions.series, stacking: "percent", pointWidth: 14}},
  }
}
