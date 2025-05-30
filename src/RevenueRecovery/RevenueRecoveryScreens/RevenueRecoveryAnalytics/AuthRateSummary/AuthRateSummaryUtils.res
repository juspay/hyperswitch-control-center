open AuthRateSummaryTypes
open LogicUtils

let getStringFromVariant = value => {
  switch value {
  | SuccessRatePercentage => (#success_rate_percent: responseKeys :> string)
  | SuccessOrdersPercentage => (#success_orders_percentage: responseKeys :> string)
  | SoftDeclinesPercentage => (#soft_declines_percentage: responseKeys :> string)
  | HardDeclinesPercentage => (#hard_declines_percentage: responseKeys :> string)
  }
}

let itemToAuthRateSummaryObjMapper: Dict.t<JSON.t> => authRateSummaryObject = dict => {
  {
    success_rate_percent: dict->getFloat(SuccessRatePercentage->getStringFromVariant, 0.0),
    success_orders_percentage: dict->getFloat(SuccessOrdersPercentage->getStringFromVariant, 0.0),
    soft_declines_percentage: dict->getFloat(SoftDeclinesPercentage->getStringFromVariant, 0.0),
    hard_declines_percentage: dict->getFloat(HardDeclinesPercentage->getStringFromVariant, 0.0),
  }
}

let getTitleForColumn = (col: authRateSummaryCols): string => {
  switch col {
  | SuccessOrdersPercentage => "Success Orders"
  | SoftDeclinesPercentage => "Soft Declines"
  | HardDeclinesPercentage => "Hard Declines"
  | _ => "Unknown"
  }
}

let getColorForColumn = (col: authRateSummaryCols): string => {
  switch col {
  | SuccessOrdersPercentage => "#71aae3"
  | SoftDeclinesPercentage => "#eab96b"
  | HardDeclinesPercentage => "#f2a1a1"
  | _ => "#cccccc"
  }
}

open BarGraphTypes
open InsightsUtils

let getAuthRateSummaryOptions = (barGraphOptions: barGraphPayload) => {
  let {categories, data} = barGraphOptions

  {
    chart: {
      \"type": "bar",
      spacingLeft: 0,
      spacingRight: 0,
      height: 100.0,
      spacing: [0, 0, 0, 0],
    },
    title: {
      text: "",
    },
    xAxis: {visible: false, categories},
    yAxis: {min: 0, max: 100, visible: false},
    tooltip: {
      enabled: true,
    },
    plotOptions: {
      bar: {
        stacking: "normal",
        borderWidth: 7.0,
        borderColor: "#fff",
        marker: {
          enabled: false,
        },
        pointPadding: 0.2,
      },
    },
    series: data,
    credits: {
      enabled: false,
    },
  }
}

let authRateSummaryMapper = (~params: InsightsTypes.getObjects<JSON.t>): barGraphPayload => {
  let {data} = params

  let successOrdersData = getBarGraphObj(
    ~array=[data],
    ~key=SuccessOrdersPercentage->getStringFromVariant,
    ~name=SuccessOrdersPercentage->getTitleForColumn,
    ~color=SuccessOrdersPercentage->getColorForColumn,
  )

  let softDeclinesData = getBarGraphObj(
    ~array=[data],
    ~key=SoftDeclinesPercentage->getStringFromVariant,
    ~name=SoftDeclinesPercentage->getTitleForColumn,
    ~color=SoftDeclinesPercentage->getColorForColumn,
  )

  let hardDeclinesData = getBarGraphObj(
    ~array=[data],
    ~key=HardDeclinesPercentage->getStringFromVariant,
    ~name=HardDeclinesPercentage->getTitleForColumn,
    ~color=HardDeclinesPercentage->getColorForColumn,
  )

  let title = {
    text: "",
  }

  {
    categories: [""],
    data: [hardDeclinesData, softDeclinesData, successOrdersData],
    title,
    tooltipFormatter: bargraphTooltipFormatter(~title="Auth Rate Summary", ~metricType=Rate),
  }
}
