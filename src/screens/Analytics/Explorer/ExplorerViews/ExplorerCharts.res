open LogicUtils
open ExplorerTypes
open ExplorerCatalog
open ExplorerUtils
open ExplorerSelection
open ExplorerData
open ExplorerDescriptions

external nullablePoints: array<Nullable.t<float>> => array<float> = "%identity"

let maxBreakdownGroups = 12

let palette = ["#1C6DEA", "#E07A1F", "#11927E", "#8B5CF6", "#D6336C"]
let otherColor = "#99A0AE"
let previousColor = "#CACFD8"
let getGroupColor = index => palette->getValueFromArray(index, otherColor)

let getOutcomeColor = field =>
  switch field {
  | Success => "#11927E"
  | Failed | AuthFailed => "#DD2B0E"
  | Excluded => "#E07A1F"
  | Other | Total => otherColor
  }

let escapeHtml = text =>
  text
  ->String.replaceRegExp(%re("/&/g"), "&amp;")
  ->String.replaceRegExp(%re("/</g"), "&lt;")
  ->String.replaceRegExp(%re("/>/g"), "&gt;")

let getTooltipHtml = (~title, ~rows: array<(string, string, float)>, ~format) => {
  let items =
    rows
    ->Array.map(((color, name, value)) =>
      `<div style="display: flex; align-items: center;">
        <div style="width: 10px; height: 10px; background-color: ${color}; border-radius: 3px;"></div>
        <div style="margin-left: 8px;">${name->escapeHtml}</div>
        <div style="flex: 1; text-align: right; font-weight: 600; margin-left: 24px;">${format(
          value,
        )}</div>
      </div>`
    )
    ->Array.joinWith("")
  InsightsUtils.getContentsUI(
    ~title=InsightsUtils.getTitleUI(~title=title->escapeHtml),
    ~tableItems=items,
  )
}

let lineTooltipFormatter = (~format) =>
  (
    @this
    (this: LineGraphTypes.pointFormatter) =>
      getTooltipHtml(
        ~title=this.points->Array.get(0)->Option.mapOr("", point => point.x),
        ~rows=this.points->Array.map(point => (point.color, point.series.name, point.y)),
        ~format,
      )
  )->LineGraphTypes.asTooltipPointFormatter

let columnTooltipFormatter = (~format, ~reversed=false) =>
  (
    @this
    (this: ColumnGraphTypes.pointFormatter) => {
      let points = reversed ? this.points->Array.toReversed : this.points
      getTooltipHtml(
        ~title=this.points->Array.get(0)->Option.mapOr("", point => point.key),
        ~rows=points->Array.map(point => (
          point.color,
          point.series->Option.mapOr("", series => series.name),
          point.y,
        )),
        ~format=format(~total=this.points->Array.reduce(0.0, (acc, point) => acc +. point.y)),
      )
    }
  )->ColumnGraphTypes.asTooltipPointFormatter

let getAxisLabel = (~measure, value) =>
  isRate(measure) ? `${value->Int.toString}%` : value->Int.toFloat->formatNumberWithCommas

let lineYAxisFormatter = (~measure) =>
  (
    @this (this: LineGraphTypes.yAxisFormatter) => getAxisLabel(~measure, this.value)
  )->LineGraphTypes.asTooltipPointFormatter

let columnYAxisFormatter = (~measure) =>
  (
    @this (this: ColumnGraphTypes.yAxisFormatter) => getAxisLabel(~measure, this.value)
  )->ColumnGraphTypes.asTooltipPointFormatter

let getValueFormatter = (~measure, ~currency) => value => formatDisplay(measure, value, ~currency)

let getTrendOptions = (~categories, ~series, ~measure, ~currency) => {
  let format = getValueFormatter(~measure, ~currency)
  let base = LineGraphUtils.getLineGraphOptions({
    chartHeight: Custom(320),
    chartLeftSpacing: Custom(8),
    categories,
    data: series,
    title: {text: ""},
    yAxisMaxValue: isRate(measure) ? Some(100) : None,
    yAxisMinValue: Some(0),
    tooltipFormatter: lineTooltipFormatter(~format),
    yAxisFormatter: lineYAxisFormatter(~measure),
    legend: {
      useHTML: true,
      align: "left",
      verticalAlign: "top",
      x: 0,
      y: 0,
      margin: 16,
    },
  })
  {...base, plotOptions: {...base.plotOptions, line: {marker: {enabled: true}}}}
}

let getBreakdownOptions = (~series, ~measure, ~currency, ~barCount) => {
  let format = getValueFormatter(~measure, ~currency)
  let base = ColumnGraphUtils.getColumnGraphOptions({
    data: series,
    title: {text: ""},
    tooltipFormatter: columnTooltipFormatter(~format=(~total as _) => format),
    yAxisFormatter: columnYAxisFormatter(~measure),
  })
  {
    ...base,
    chart: {...base.chart, \"type": "bar", height: Math.Int.max(240, 60 + barCount * 44)},
    plotOptions: {series: {...base.plotOptions.series, pointWidth: 12, borderRadius: 3}},
  }
}

let getMixOptions = (~series) => {
  let base = ColumnGraphUtils.getColumnGraphOptions({
    data: series,
    title: {text: ""},
    tooltipFormatter: columnTooltipFormatter(
      ~format=(~total) => value =>
        `${value->formatNumberWithCommas} · ${calculatePercentage(
            value,
            total,
          )->formatPercentage}`,
      ~reversed=true,
    ),
    yAxisFormatter: (
      @this (this: ColumnGraphTypes.yAxisFormatter) => `${this.value->Int.toString}%`
    )->ColumnGraphTypes.asTooltipPointFormatter,
  })
  {
    ...base,
    chart: {...base.chart, height: 320},
    plotOptions: {
      series: {...base.plotOptions.series, stacking: "percent", pointWidth: 14, borderRadius: 2},
    },
  }
}

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

let hasPrevious = (context: chartContext) => context.dataset.overallPrevious.total > 0.0

let currentLabel = (context: chartContext) =>
  periodLabel(context.selection.startTime, context.selection.endTime)

let groupLabel = (context: chartContext, group: group) =>
  group.values->getValuesLabel(~split=context.selection.split, ~labelFor=context.labelFor)

let withPreviousSeries = (context, current, getPrevious) =>
  context->hasPrevious ? [current, getPrevious()] : [current]

let wholeKey = []->getRowKey

let getTrendPoints = (context: chartContext, dailyPoints, ~days, ~groupKey) =>
  days->Array.map(day =>
    context.selection->getPointValue(
      dailyPoints->getCountsOn(~groupKey, ~day),
      ~currency=context.dataset.amountCurrency,
    )
  )

let getTrendSeries = (context: chartContext, ~days) => {
  let {selection, dataset} = context
  if selection.split->isEmptyArray {
    let (previousStart, previousEnd) = selection->previousWindow
    context->withPreviousSeries(
      getLineSeries(
        ~name=context->currentLabel,
        ~points=context->getTrendPoints(dataset.currentDaily, ~days, ~groupKey=wholeKey),
        ~color=getGroupColor(0),
      ),
      () =>
        getLineSeries(
          ~name=`Previous period (${periodLabel(previousStart, previousEnd)})`,
          ~points=context->getTrendPoints(
            dataset.previousDaily,
            ~days=getWindowDays(previousStart, previousEnd),
            ~groupKey=wholeKey,
          ),
          ~color=previousColor,
        ),
    )
  } else {
    dataset.topByVolume->Array.mapWithIndex((group, index) =>
      getLineSeries(
        ~name=context->groupLabel(group),
        ~points=context->getTrendPoints(
          dataset.currentDaily,
          ~days,
          ~groupKey=group.values->getRowKey,
        ),
        ~color=getGroupColor(index),
      )
    )
  }
}

let getTrendChartOptions = (context: chartContext) => {
  let {selection, dataset} = context
  let days = getWindowDays(selection.startTime, selection.endTime)
  getTrendOptions(
    ~categories=days->Array.map(formatShortDate),
    ~series=context->getTrendSeries(~days),
    ~measure=selection.measure,
    ~currency=dataset.amountCurrency,
  )
}

let getBreakdownSeries = (context: chartContext, ~groups: array<group>) => {
  let {selection, dataset} = context
  let valueFor = counts =>
    displayValue(selection.source, selection.measure, counts, ~currency=dataset.amountCurrency)
  context->withPreviousSeries(
    getColumnSeries(
      ~name=context->currentLabel,
      ~points=groups->Array.map(group => (context->groupLabel(group), valueFor(group.current))),
      ~color=getGroupColor(0),
    ),
    () =>
      getColumnSeries(
        ~name="Previous period",
        ~points=groups->Array.filterMap(group =>
          group.previous->Option.map(
            previousCounts => (context->groupLabel(group), valueFor(previousCounts)),
          )
        ),
        ~color=previousColor,
      ),
  )
}

let getBreakdownChartOptions = (context: chartContext) => {
  let {selection, dataset} = context
  let groups = dataset.groups->Array.slice(~start=0, ~end=maxBreakdownGroups)
  getBreakdownOptions(
    ~series=context->getBreakdownSeries(~groups),
    ~measure=selection.measure,
    ~currency=dataset.amountCurrency,
    ~barCount=groups->Array.length,
  )
}

let getOutcomeSeries = (context: chartContext) => {
  let {selection, dataset} = context
  let points = counts =>
    outcomes->Array.map(field => (outcomeLabel(selection.source, field), counts->getCount(field)))
  context->withPreviousSeries(
    getColumnSeries(
      ~name=context->currentLabel,
      ~points=dataset.overall->points,
      ~color=getGroupColor(0),
    ),
    () =>
      getColumnSeries(
        ~name="Previous period",
        ~points=dataset.overallPrevious->points,
        ~color=previousColor,
      ),
  )
}

let getOutcomeChartOptions = (context: chartContext) =>
  getBreakdownOptions(
    ~series=context->getOutcomeSeries,
    ~measure=#volume,
    ~currency="",
    ~barCount=outcomes->Array.length,
  )

let getMixSeries = (context: chartContext, ~days) => {
  let {selection, dataset} = context
  let perDay = pick => days->Array.map(day => (day->formatShortDate, pick(day)))
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
        ->Array.filter(point => point.day == day && !(topKeys->Array.includes(point.groupKey)))
        ->Array.reduce(0.0, (acc, point) => acc +. point.counts.total)
      ),
      ~color=otherColor,
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
          ~color=getGroupColor(index),
        )
      )
      ->Array.toReversed,
    )
  }
}

let getMixChartOptions = (context: chartContext) => {
  let {selection} = context
  getMixOptions(
    ~series=context->getMixSeries(~days=getWindowDays(selection.startTime, selection.endTime)),
  )
}
