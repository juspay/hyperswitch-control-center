open LogicUtils
open ReconEngineGenerateReportTypes

let linkedReportMaxDays = 7

let getReportConfig = (variant, reportType): reportConfig => {
  let (modalHeading, endpoint) = switch variant {
  | Transactions => ("Generate Report", #GENERATE_TRANSACTION_REPORT)
  | Exceptions => ("Generate Exception Report", #GENERATE_EXCEPTION_REPORT)
  }
  let config = {
    modalHeading,
    endpoint,
    dateRangeLimit: 180,
    predefinedDays: [Today, Yesterday, ThisMonth, LastMonth],
    description: "The generated report will be emailed to you and is limited to 100,000 rows. Narrow the date range if needed.",
  }
  switch (variant, reportType) {
  | (Transactions, LinkedReport) => {
      ...config,
      endpoint: #GENERATE_LINKED_REPORT,
      dateRangeLimit: linkedReportMaxDays,
      predefinedDays: [Today, Yesterday, Day(linkedReportMaxDays->Int.toFloat)],
      description: "Flows will be emailed to you. Choose a date range of up to 7 days.",
    }
  | (Transactions, TransactionReport) | (Exceptions, _) => config
  }
}

let validateReportRange = (variant, reportType, values) => {
  let errors = Dict.make()
  switch (variant, reportType) {
  | (Transactions, LinkedReport) =>
    let dates = values->getDictFromJsonObject
    let duration = DateRangeUtils.getStartEndDiff(
      dates->getString("start_time", ""),
      dates->getString("end_time", ""),
    )
    if duration > linkedReportMaxDays->Int.toFloat *. 86400000. {
      errors->Dict.set(
        "end_time",
        "Choose a date range of 7 days or less for flow reports."->JSON.Encode.string,
      )
    }
  | (Transactions, TransactionReport) | (Exceptions, _) => ()
  }
  errors->JSON.Encode.object
}

let getReportTabIndex = reportType =>
  switch reportType {
  | TransactionReport => 0
  | LinkedReport => 1
  }

let getReportTabTitle = reportType =>
  switch reportType {
  | TransactionReport => "Transactions"
  | LinkedReport => "Flows"
  }
