open RetryAnalyticsTypes
open LogicUtils
open CurrencyFormatUtils

let getStringFromVariant = value => {
  switch value {
  | Standardised_Code => "standardised_code"
  | Error_Category => "error_category"
  | Decline_Count => "failure_reason_count"
  | Decline_Percentage => "percentage"
  }
}

let getColumn = string => {
  switch string {
  | "error_category" => Error_Category
  | _ => Standardised_Code
  }
}

let normalizedDeclineMapper = (
  ~params: InsightsTypes.getObjects<JSON.t>,
): BarGraphTypes.barGraphPayload => {
  open BarGraphTypes
  open InsightsUtils
  let {data, xKey, yKey} = params
  let categories = [data]->JSON.Encode.array->getCategories(0, yKey)
  let barGraphData = getBarGraphObj(
    ~array=data->getArrayFromJson([]),
    ~key=xKey,
    ~name="Decline Count",
    ~color=NewAnalyticsUtils.redColor,
  )
  let title = {
    text: "",
  }
  {
    categories,
    data: [barGraphData],
    title,
    tooltipFormatter: bargraphTooltipFormatter(
      ~title="Normalized Decline Distribution",
      ~metricType=Volume,
    ),
  }
}

let tableItemToObjMapper: Dict.t<JSON.t> => normalizedDeclineObject = dict => {
  {
    standardised_code: dict->getString(Standardised_Code->getStringFromVariant, ""),
    error_category: dict->getString(Error_Category->getStringFromVariant, ""),
    count: dict->getInt(Decline_Count->getStringFromVariant, 0),
    percentage: 0.0,
  }
}

let getObjects: JSON.t => array<normalizedDeclineObject> = json => {
  let items =
    json
    ->getArrayFromJson([])
    ->Array.map(item => {
      tableItemToObjMapper(item->getDictFromJsonObject)
    })
  let total = items->Array.reduce(0, (acc, item) => acc + item.count)->Int.toFloat
  items->Array.map(item => {
    ...item,
    percentage: if total > 0.0 {
      item.count->Int.toFloat /. total *. 100.0
    } else {
      0.0
    },
  })
}

let getHeading = colType => {
  switch colType {
  | Standardised_Code =>
    Table.makeHeaderInfo(
      ~key=Standardised_Code->getStringFromVariant,
      ~title="Standardised Code",
      ~dataType=TextType,
    )
  | Error_Category =>
    Table.makeHeaderInfo(
      ~key=Error_Category->getStringFromVariant,
      ~title="Error Category",
      ~dataType=TextType,
    )
  | Decline_Count =>
    Table.makeHeaderInfo(
      ~key=Decline_Count->getStringFromVariant,
      ~title="Count",
      ~dataType=TextType,
    )
  | Decline_Percentage =>
    Table.makeHeaderInfo(
      ~key=Decline_Percentage->getStringFromVariant,
      ~title="Percentage (%)",
      ~dataType=TextType,
    )
  }
}

let getCell = (obj, colType): Table.cell => {
  switch colType {
  | Standardised_Code => Text(obj.standardised_code)
  | Error_Category => Text(obj.error_category)
  | Decline_Count => Text(obj.count->Int.toString)
  | Decline_Percentage => Text(obj.percentage->valueFormatter(Rate))
  }
}

let getTableData = json => {
  json->getArrayDataFromJson(tableItemToObjMapper)->Array.map(Nullable.make)
}

let tabs: array<NewAnalyticsTypes.optionType> = [
  {
    label: "Standardised Code",
    value: Standardised_Code->getStringFromVariant,
  },
  {
    label: "Error Category",
    value: Error_Category->getStringFromVariant,
  },
]

let defaulGroupBy: NewAnalyticsTypes.optionType = {
  label: "Standardised Code",
  value: Standardised_Code->getStringFromVariant,
}
