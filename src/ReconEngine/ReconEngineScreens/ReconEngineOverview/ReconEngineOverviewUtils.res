open LogicUtils
open ReconEngineOverviewTypes

let accountItemToObjMapper = dict => {
  {
    account_name: dict->getString("account_name", ""),
    account_id: dict->getString("account_id", ""),
    currency: dict->getString("currency", ""),
    pending_balance: dict->getString("pending_balance", ""),
    posted_balance: dict->getString("posted_balance", ""),
  }
}

let reconRuleItemToObjMapper = dict => {
  {
    rule_id: dict->getString("rule_id", ""),
    rule_name: dict->getString("rule_name", ""),
    rule_description: dict->getString("rule_description", ""),
  }
}

let (
  startTimeFilterKey,
  endTimeFilterKey,
  smartRetryKey,
  compareToStartTimeKey,
  compareToEndTimeKey,
  comparisonKey,
) = (
  "startTime",
  "endTime",
  "is_smart_retry_enabled",
  "compareToStartTime",
  "compareToEndTime",
  "comparison",
)
let initialFixedFilterFields = (~events=?) => {
  let events = switch events {
  | Some(fn) => fn
  | _ => () => ()
  }
  let customButtonStyle = "border !rounded-lg !bg-none"
  let newArr = [
    (
      {
        localFilter: None,
        field: FormRenderer.makeMultiInputFieldInfo(
          ~label="",
          ~comboCustomInput=InputFields.filterDateRangeField(
            ~startKey=startTimeFilterKey,
            ~endKey=endTimeFilterKey,
            ~format="YYYY-MM-DDTHH:mm:ss[Z]",
            ~showTime=true,
            ~disablePastDates={false},
            ~disableFutureDates={true},
            ~predefinedDays=[
              Hour(0.5),
              Hour(1.0),
              Hour(2.0),
              Today,
              Yesterday,
              Day(2.0),
              Day(7.0),
              Day(30.0),
              ThisMonth,
              LastMonth,
            ],
            ~numMonths=2,
            ~disableApply=false,
            ~dateRangeLimit=180,
            ~events,
            ~customButtonStyle,
          ),
          ~inputFields=[],
          ~isRequired=false,
        ),
      }: EntityType.initialFilters<'t>
    ),
  ]

  newArr
}

let accountBalanceOptions: ColumnGraphTypes.columnGraphPayload = {
  title: {
    text: "",
  },
  data: [
    {
      showInLegend: false,
      name: "Account Balance",
      colorByPoint: true,
      data: [
        {
          name: "1 Day",
          y: 13711.0,
          color: "#8BC2F3",
        },
        {
          name: "2 Day",
          y: 44579.0,
          color: "#8BC2F3",
        },
        {
          name: "3 Day",
          y: 40510.0,
          color: "#8BC2F3",
        },
        {
          name: "4 Day",
          y: 48035.0,
          color: "#8BC2F3",
        },
        {
          name: "5 Day",
          y: 51640.0,
          color: "#8BC2F3",
        },
        {
          name: "6 Day",
          y: 51483.0,
          color: "#8BC2F3",
        },
        {
          name: "7 Day",
          y: 50049.0,
          color: "#8BC2F3",
        },
      ],
      color: "",
    },
  ],
  tooltipFormatter: ColumnGraphUtils.columnGraphTooltipFormatter(
    ~title="Account Balance",
    ~metricType=FormattedAmount,
  ),
  yAxisFormatter: ColumnGraphUtils.columnGraphYAxisFormatter(
    ~statType=FormattedAmount,
    ~currency="$",
  ),
}

let getAccountIcon = index => {
  switch index {
  | 0 => "settings"
  | 1 => "credit-card"
  | 2 => "nd-bank"
  | _ => "building"
  }
}

let getOverviewLineGraphTooltipFormatter = (
  @this
  (this: LineGraphTypes.pointFormatter) => {
    let title = `<div style="font-size: 16px; font-weight: bold;">Transaction Count</div>`

    let defaultValue: LineGraphTypes.point = {
      color: "",
      x: "",
      y: 0.0,
      point: {index: 0},
      series: {name: ""},
    }

    let primaryPoint = this.points->getValueFromArray(0, defaultValue)
    let secondaryPoint = this.points->getValueFromArray(1, defaultValue)

    let getRowHtml = (~iconColor, ~name, ~value) => {
      let valueString = value->Float.toString
      `<div style="display: flex; align-items: center;">
              <div style="width: 10px; height: 10px; background-color:${iconColor}; border-radius:3px;"></div>
              <div style="margin-left: 8px;">${name}</div>
              <div style="flex: 1; text-align: right; font-weight: bold;margin-left: 25px;">${valueString}</div>
          </div>`
    }

    let tableItems =
      [
        getRowHtml(
          ~iconColor=primaryPoint.color,
          ~name=primaryPoint.series.name,
          ~value=primaryPoint.y,
        ),
        getRowHtml(
          ~iconColor=secondaryPoint.color,
          ~name=secondaryPoint.series.name,
          ~value=secondaryPoint.y,
        ),
      ]->Array.joinWith("")

    let content = `
            <div style=" 
            padding:5px 12px;
            display:flex;
            flex-direction:column;
            justify-content: space-between;
            gap: 7px;">
                ${title}
                <div style="
                  margin-top: 5px;
                  display:flex;
                  flex-direction:column;
                  gap: 7px;">
                  ${tableItems}
                </div>
          </div>`

    `<div style="
      padding: 10px;
      width:fit-content;
      border-radius: 7px;
      background-color:#FFFFFF;
      padding:10px;
      box-shadow: 0px 4px 8px rgba(0, 0, 0, 0.2);
      border: 1px solid #E5E5E5;
      position:relative;">
          ${content}
      </div>`
  }
)->LineGraphTypes.asTooltipPointFormatter

let lineGraphYAxisFormatter = (
  @this
  (this: LineGraphTypes.yAxisFormatter) => {
    this.value->Int.toString
  }
)->LineGraphTypes.asTooltipPointFormatter

let getLineGraphOptions = () => {
  // Static data for posted and expected counts per day
  let categories = ["Jan 01", "Jan 02", "Jan 03", "Jan 04", "Jan 05", "Jan 06", "Jan 07"]

  let postedData = [120.0, 150.0, 180.0, 200.0, 175.0, 220.0, 250.0]
  let expectedData = [100.0, 140.0, 160.0, 190.0, 170.0, 210.0, 240.0]

  let lineGraphOptions: LineGraphTypes.lineGraphPayload = {
    chartHeight: LineGraphTypes.DefaultHeight,
    chartLeftSpacing: LineGraphTypes.DefaultLeftSpacing,
    categories,
    data: [
      {
        showInLegend: true,
        name: "Expected",
        data: postedData,
        color: "#8BC2F3",
      },
      {
        showInLegend: true,
        name: "Posted",
        data: expectedData,
        color: "#00D492",
      },
    ],
    title: {
      text: "",
      align: "left",
    },
    tooltipFormatter: getOverviewLineGraphTooltipFormatter,
    yAxisMaxValue: None,
    yAxisMinValue: None,
    yAxisFormatter: lineGraphYAxisFormatter,
    legend: {
      useHTML: true,
      labelFormatter: LineGraphUtils.valueFormatter,
      align: "left",
      verticalAlign: "top",
      floating: false,
      margin: 30,
    },
  }

  lineGraphOptions
}
