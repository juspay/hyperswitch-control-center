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
    ~reverse=true,
  ),
  yAxisFormatter: ColumnGraphUtils.columnGraphYAxisFormatter(
    ~statType=AmountWithSuffix,
    ~currency="$",
    ~suffix="M",
  ),
}

let barGraphOptions: BarGraphTypes.barGraphPayload = {
  title: {
    text: "Revenue Uplift",
  },
  categories: ["10:00", "11:00", "11:00"],
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
  tooltipFormatter: NewAnalyticsUtils.bargraphTooltipFormatter(
    ~title="Revenue Uplift",
    ~metricType=No_Type,
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
    ~title="Revenue Uplift",
    ~metricType=Amount,
    ~currency="",
    ~comparison=Some(EnableComparison),
    ~secondaryCategories=[],
    ~reverse=true,
  ),
  yAxisMaxValue: Some(100),
}
