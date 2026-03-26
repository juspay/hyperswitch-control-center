open SplitPaymentsSectionTypes
open LogicUtils
open CurrencyFormatUtils

let getStringFromVariant = value => {
  switch value {
  | Payments_Success_Rate_Distribution => "payments_success_rate_distribution"
  | Payments_Success_Rate_Distribution_Without_Smart_Retries => "payments_success_rate_distribution_without_smart_retries"
  | Split_Payment_Connector => "split_payment_connector"
  }
}

let getColumn = string => {
  switch string {
  | "split_payment_connector" => Split_Payment_Connector
  | _ => Split_Payment_Connector
  }
}

let splitPaymentsDistributionPieMapper = (data: JSON.t) => {
  let queryData = data->getArrayFromJson([])
  let rateKey = Payments_Success_Rate_Distribution_Without_Smart_Retries->getStringFromVariant
  let connectorKey = Split_Payment_Connector->getStringFromVariant

  let pieData: array<PieGraphTypes.pieGraphDataType> =
    queryData->Array.map(item => {
      let dict = item->getDictFromJsonObject
      let dataObj: PieGraphTypes.pieGraphDataType = {
        name: dict->getString(connectorKey, "")->snakeToTitle,
        y: dict->getFloat(rateKey, 0.0),
      }
      dataObj
    })

  let payload: PieGraphTypes.pieGraphPayload<int> = {
    chartSize: "80%",
    title: {
      text: "",
    },
    data: [
      {
        \"type": "",
        name: "",
        showInLegend: true,
        data: pieData,
        innerSize: "70%",
      },
    ],
    tooltipFormatter: PieGraphUtils.pieGraphTooltipFormatter(
      ~title="Split Payments Distribution",
      ~valueFormatterType=Rate,
    ),
    legendFormatter: (
      @this
      (this: PieGraphTypes.legendLabelFormatter) => {
        let name = this.name->snakeToTitle
        `<div style="font-size: 14px; font-weight: 600; padding: 4px 0;">${name} | ${this.y->Int.toString}%</div>`
      }
    )->PieGraphTypes.asLegendPointFormatter,
    startAngle: 0,
    endAngle: 360,
    legend: {
      align: "right",
      verticalAlign: "middle",
      enabled: true,
      layout: "vertical",
    },
  }

  let defaultOptions = payload->PieGraphUtils.getPieChartOptions

  {
    ...defaultOptions,
    chart: {
      ...defaultOptions.chart,
      width: 600,
      height: 300,
    },
    plotOptions: {
      pie: {
        ...defaultOptions.plotOptions.pie,
        center: ["30%", "50%"],
      },
    },
  }
}

open InsightsTypes
open NewAnalyticsTypes

type splitPaymentsDistributionObject = {
  payments_success_rate_distribution: float,
  payments_success_rate_distribution_without_smart_retries: float,
  split_payment_connector: string,
}

let tableItemToObjMapper: Dict.t<JSON.t> => splitPaymentsDistributionObject = dict => {
  {
    payments_success_rate_distribution: dict->getFloat(
      Payments_Success_Rate_Distribution->getStringFromVariant,
      0.0,
    ),
    payments_success_rate_distribution_without_smart_retries: dict->getFloat(
      Payments_Success_Rate_Distribution_Without_Smart_Retries->getStringFromVariant,
      0.0,
    ),
    split_payment_connector: dict->getString(Split_Payment_Connector->getStringFromVariant, ""),
  }
}

let getObjects: JSON.t => array<splitPaymentsDistributionObject> = json => {
  json
  ->getArrayFromJson([])
  ->Array.map(item => {
    tableItemToObjMapper(item->getDictFromJsonObject)
  })
}

let getHeading = colType => {
  switch colType {
  | Payments_Success_Rate_Distribution =>
    Table.makeHeaderInfo(
      ~key=Payments_Success_Rate_Distribution->getStringFromVariant,
      ~title="Success Rate Distribution",
      ~dataType=TextType,
    )
  | Payments_Success_Rate_Distribution_Without_Smart_Retries =>
    Table.makeHeaderInfo(
      ~key=Payments_Success_Rate_Distribution_Without_Smart_Retries->getStringFromVariant,
      ~title="Success Rate Distribution",
      ~dataType=TextType,
    )
  | Split_Payment_Connector =>
    Table.makeHeaderInfo(
      ~key=Split_Payment_Connector->getStringFromVariant,
      ~title="Split Payment Connector",
      ~dataType=TextType,
    )
  }
}

let getCell = (obj, colType): Table.cell => {
  switch colType {
  | Payments_Success_Rate_Distribution =>
    Text(obj.payments_success_rate_distribution->valueFormatter(Rate))
  | Payments_Success_Rate_Distribution_Without_Smart_Retries =>
    Text(obj.payments_success_rate_distribution_without_smart_retries->valueFormatter(Rate))
  | Split_Payment_Connector => Text(obj.split_payment_connector)
  }
}

let getTableData = json => {
  json->getArrayDataFromJson(tableItemToObjMapper)->Array.map(Nullable.make)
}

let defaulGroupBy = {
  label: "Split Payment Connector",
  value: Split_Payment_Connector->getStringFromVariant,
}

let getKeyForModule = (field, ~isSmartRetryEnabled) => {
  switch (field, isSmartRetryEnabled) {
  | (Payments_Success_Rate_Distribution, Smart_Retry) => Payments_Success_Rate_Distribution
  | (Payments_Success_Rate_Distribution, Default) | _ =>
    Payments_Success_Rate_Distribution_Without_Smart_Retries
  }->getStringFromVariant
}

let isSmartRetryEnbldForSplitPmtDist = isEnabled => {
  switch isEnabled {
  | Smart_Retry => Payments_Success_Rate_Distribution
  | Default => Payments_Success_Rate_Distribution_Without_Smart_Retries
  }
}

let splitPaymentFilter = () => {
  let filters = Dict.make()
  filters->Dict.set("is_split_payment", [true->JSON.Encode.bool]->JSON.Encode.array)
  filters
}
