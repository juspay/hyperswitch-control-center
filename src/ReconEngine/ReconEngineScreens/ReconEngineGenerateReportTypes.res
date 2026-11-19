type reportVariant = Transactions | Exceptions

type transactionReportType = TransactionReport | LinkedReport

type reportConfig = {
  modalHeading: string,
  endpoint: APIUtilsTypes.hyperswitchReconType,
  dateRangeLimit: int,
  predefinedDays: array<DateRangeUtils.customDateRange>,
  description: string,
}
