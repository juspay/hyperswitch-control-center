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

// Match the pickers' inclusive calendar-day limits, including inherited form values.
let getReportDateRangeError = (~limit, values) => {
  let dates = values->getDictFromJsonObject
  let start = dates->getString("start_time", "")
  let end = dates->getString("end_time", "")
  let startDate = start->DayJs.getDayJsForString
  let endDate = end->DayJs.getDayJsForString
  if start === "" || end === "" || !startDate.isValid() || !endDate.isValid() {
    Some("Choose a valid start and end date.")
  } else if endDate.diff(start, "millisecond") < 0 {
    Some("End date must be after start date.")
  } else {
    let calendarDays = (endDate.format("YYYY-MM-DD")->DayJs.getDayJsForString).diff(
      startDate.format("YYYY-MM-DD"),
      "day",
    )
    calendarDays >= limit ||
      DateRangeUtils.getStartEndDiff(start, end) > limit->Int.toFloat *. 86400000. -. 1000.
      ? Some(`Choose a date range of ${limit->Int.toString} days or less.`)
      : None
  }
}

let getReportEventType = (variant, reportType) =>
  switch (variant, reportType) {
  | (Transactions, TransactionReport) => "transactions"
  | (Transactions, LinkedReport) => "flows"
  | (Exceptions, _) => "exceptions"
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
