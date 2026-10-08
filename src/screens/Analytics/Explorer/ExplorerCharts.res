open LogicUtils
open ExplorerTypes
open ExplorerCatalog
open ExplorerUtils
open ExplorerQuery
open ExplorerData
open ExplorerDescriptions

external nullablePoints: array<Nullable.t<float>> => array<float> = "%identity"

let escapeHtml = text =>
  text
  ->String.replaceRegExp(%re("/&/g"), "&amp;")
  ->String.replaceRegExp(%re("/</g"), "&lt;")
  ->String.replaceRegExp(%re("/>/g"), "&gt;")

let tooltipHtml = (~title, ~rows: array<(string, string, float)>, ~format) => {
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

let lineTooltip = (~format) =>
  (
    @this
    (this: LineGraphTypes.pointFormatter) =>
      tooltipHtml(
        ~title=this.points->Array.get(0)->Option.mapOr("", point => point.x),
        ~rows=this.points->Array.map(point => (point.color, point.series.name, point.y)),
        ~format,
      )
  )->LineGraphTypes.asTooltipPointFormatter

let columnTooltip = (~format, ~reversed=false) =>
  (
    @this
    (this: ColumnGraphTypes.pointFormatter) => {
      let points = reversed ? this.points->Array.toReversed : this.points
      tooltipHtml(
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
    tooltipFormatter: lineTooltip(~format),
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
    tooltipFormatter: columnTooltip(~format=(~total as _) => format),
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
    tooltipFormatter: columnTooltip(
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

let getTrendPoints = (viewContext: viewContext, dailyPoints, ~days, ~groupKey) =>
  days->Array.map(day =>
    viewContext.question->pointValue(
      dailyPoints->getCountsOn(~groupKey, ~day),
      ~currency=viewContext.dataset.amountCurrency,
    )
  )

let getTrendSeries = (viewContext: viewContext, ~days) => {
  let {question, dataset} = viewContext
  if question.split->isEmptyArray {
    let (previousStart, previousEnd) = question->previousWindow
    [
      getLineSeries(
        ~name=viewContext.currentLabel,
        ~points=viewContext->getTrendPoints(dataset.currentDaily, ~days, ~groupKey=""),
        ~color=getGroupColor(0),
      ),
    ]->Array.concat(
      viewContext.hasPrevious
        ? [
            getLineSeries(
              ~name=`Previous period (${viewContext.previousLabel})`,
              ~points=viewContext->getTrendPoints(
                dataset.previousDaily,
                ~days=windowDays(previousStart, previousEnd),
                ~groupKey="",
              ),
              ~color=previousColor,
            ),
          ]
        : [],
    )
  } else {
    dataset.topByVolume->Array.mapWithIndex((group, index) =>
      getLineSeries(
        ~name=viewContext.groupLabel(group),
        ~points=viewContext->getTrendPoints(
          dataset.currentDaily,
          ~days,
          ~groupKey=group.values->getRowKey,
        ),
        ~color=getGroupColor(index),
      )
    )
  }
}

let getTrendChartOptions = (viewContext: viewContext) => {
  let {question, dataset} = viewContext
  let days = windowDays(question.startTime, question.endTime)
  getTrendOptions(
    ~categories=days->Array.map(shortDate),
    ~series=viewContext->getTrendSeries(~days),
    ~measure=question.measure,
    ~currency=dataset.amountCurrency,
  )
}

let getBreakdownSeries = (viewContext: viewContext, ~groups: array<group>) => {
  let {question, dataset} = viewContext
  let valueFor = counts =>
    displayValue(question.source, question.measure, counts, ~currency=dataset.amountCurrency)
  [
    getColumnSeries(
      ~name=viewContext.currentLabel,
      ~points=groups->Array.map(group => (viewContext.groupLabel(group), valueFor(group.current))),
      ~color=getGroupColor(0),
    ),
  ]->Array.concat(
    viewContext.hasPrevious
      ? [
          getColumnSeries(
            ~name="Previous period",
            ~points=groups->Array.filterMap(group =>
              group.previous->Option.map(previousCounts => (
                viewContext.groupLabel(group),
                valueFor(previousCounts),
              ))
            ),
            ~color=previousColor,
          ),
        ]
      : [],
  )
}

let getBreakdownChartOptions = (viewContext: viewContext) => {
  let {question, dataset} = viewContext
  let groups = dataset.sorted->Array.slice(~start=0, ~end=maxBreakdownGroups)
  getBreakdownOptions(
    ~series=viewContext->getBreakdownSeries(~groups),
    ~measure=question.measure,
    ~currency=dataset.amountCurrency,
    ~barCount=groups->Array.length,
  )
}

let getOutcomeSeries = (viewContext: viewContext) => {
  let {question, dataset} = viewContext
  let points = counts =>
    getSourceOutcomes(question.source)->Array.map(field => (
      outcomeLabel(question.source, field),
      counts->getCount(field),
    ))
  [
    getColumnSeries(
      ~name=viewContext.currentLabel,
      ~points=dataset.overall->points,
      ~color=getGroupColor(0),
    ),
  ]->Array.concat(
    viewContext.hasPrevious
      ? [
          getColumnSeries(
            ~name="Previous period",
            ~points=dataset.overallPrevious->points,
            ~color=previousColor,
          ),
        ]
      : [],
  )
}

let getOutcomeChartOptions = (viewContext: viewContext) =>
  getBreakdownOptions(
    ~series=viewContext->getOutcomeSeries,
    ~measure=Volume,
    ~currency="",
    ~barCount=getSourceOutcomes(viewContext.question.source)->Array.length,
  )

let getMixSeries = (viewContext: viewContext, ~days) => {
  let {question, dataset} = viewContext
  let perDay = pick => days->Array.map(day => (day->shortDate, pick(day)))
  if question.split->isEmptyArray {
    getSourceOutcomes(question.source)
    ->Array.map(field =>
      getColumnSeries(
        ~name=outcomeLabel(question.source, field),
        ~points=perDay(day =>
          dataset.currentDaily->getCountsOn(~groupKey="", ~day)->getCount(field)
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
          ~name=viewContext.groupLabel(group),
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

let getMixChartOptions = (viewContext: viewContext) => {
  let {question} = viewContext
  getMixOptions(
    ~series=viewContext->getMixSeries(~days=windowDays(question.startTime, question.endTime)),
  )
}
