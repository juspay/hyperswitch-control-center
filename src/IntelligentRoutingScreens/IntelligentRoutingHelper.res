let simulatorBanner =
  <div
    className="absolute z-10 top-76-px left-0 w-full py-4 px-10 bg-orange-50 flex justify-between items-center">
    <div className="flex gap-4 items-center">
      <Icon name="nd-information-triangle" size=24 />
      <p className="text-nd_gray-600 text-base leading-6 font-medium">
        {"You are in demo environment and this is sample setup."->React.string}
      </p>
    </div>
  </div>

let stepperHeading = (~title: string, ~subTitle: string) =>
  <div className="flex flex-col gap-y-1">
    <p className="text-2xl font-semibold text-nd_gray-700 leading-9"> {title->React.string} </p>
    <p className="text-sm text-nd_gray-400 font-medium leading-5"> {subTitle->React.string} </p>
  </div>

let columnGraphOptions: ColumnGraphTypes.columnGraphPayload = {
  title: {
    text: "Revenue Uplift",
    align: "left",
    x: 10,
    y: 10,
  },
  data: [
    {
      showInLegend: true,
      name: "Actual",
      colorByPoint: false,
      data: [
        {
          name: "10:00",
          y: 2.0,
          color: "#B992DD",
        },
        {
          name: "11:00",
          y: 8.0,
          color: "#B992DD",
        },
        {
          name: "12:00",
          y: 9.0,
          color: "#B992DD",
        },
      ],
      color: "#B992DD",
    },
    {
      showInLegend: true,
      name: "Simulated",
      colorByPoint: false,
      data: [
        {
          name: "10:00",
          y: 10.0,
          color: "#1E90FF",
        },
        {
          name: "11:00",
          y: 20.0,
          color: "#1E90FF",
        },
        {
          name: "12:00",
          y: 30.0,
          color: "#1E90FF",
        },
      ],
      color: "#1E90FF",
    },
  ],
  tooltipFormatter: ColumnGraphUtils.columnGraphTooltipFormatter(
    ~title="Revenue Uplift",
    ~metricType=AmountWithSuffix,
  ),
  yAxisFormatter: ColumnGraphUtils.columnGraphYAxisFormatter(
    ~statType=AmountWithSuffix,
    ~currency="$",
    ~suffix="M",
  ),
}

let lineGraphOptions: LineGraphTypes.lineGraphPayload = {
  title: {
    text: "Overall Authorization Rate",
    align: "left",
    x: 10,
    y: 10,
  },
  categories: ["10:00", "11:00", "12:00"],
  data: [
    {
      showInLegend: true,
      name: "Actual",
      data: [2.0, 8.0, 9.0],
      color: "#B992DD",
    },
    {
      showInLegend: true,
      name: "Simulated",
      data: [10.0, 20.0, 30.0],
      color: "#1E90FF",
    },
  ],
  tooltipFormatter: NewAnalyticsUtils.tooltipFormatter(
    ~title="Authorization Rate",
    ~metricType=Amount,
    ~currency="",
    ~comparison=Some(EnableComparison),
    ~secondaryCategories=[],
    ~reverse=true,
  ),
  yAxisMaxValue: None,
}

let lineColumnGraphOptions: LineAndColumnGraphTypes.lineColumnGraphPayload = {
  title: {
    text: "Processor wise transaction distribution with Auth Rate",
    align: "left",
    x: 10,
    y: 10,
  },
  categories: ["10:00", "11:00", "12:00", "1:00", "2:00"],
  data: [
    {
      showInLegend: true,
      name: "Processor's Auth Rate",
      \"type": "column",
      data: [120, 100, 60, 90, 70],
      color: "#B5B28E",
      yAxis: 0,
    },
    {
      showInLegend: true,
      name: "Actual Transactions",
      \"type": "line",
      data: [80, 90, 95, 85, 92],
      color: "#A785D8",
      yAxis: 1,
    },
    {
      showInLegend: true,
      name: "Simulated Transactions",
      \"type": "line",
      data: [110, 100, 70, 90, 80],
      color: "#4185F4",
      yAxis: 1,
    },
  ],
  tooltipFormatter: LineAndColumnGraphUtils.lineColumnGraphTooltipFormatter(
    ~title="Metrics",
    ~metricType=Amount,
  ),
}
