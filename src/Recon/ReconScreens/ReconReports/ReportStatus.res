open ReconReportUtils
open ReportsTypes

let useGetAllReportStatus = (order: allReportPayload) => {
  let orderStatusLabel = order.recon_status->LogicUtils.capitalizeString
  let fixedStatusCss = "text-xs text-white font-semibold px-2 py-1 rounded flex items-center gap-2"
  switch order.recon_status->getReconStatusTypeFromString {
  | Reconciled =>
    <div className={`${fixedStatusCss}  bg-nd_green-50 dark:bg-opacity-50`}>
      <p className="text-nd_green-400"> {orderStatusLabel->React.string} </p>
    </div>
  | Unreconciled =>
    <div className={`${fixedStatusCss} bg-nd_red-50 dark:bg-opacity-50`}>
      <p className="text-nd_red-400"> {orderStatusLabel->React.string} </p>
    </div>
  | Missing =>
    <div className={`${fixedStatusCss} bg-orange-50 dark:bg-opacity-50`}>
      <p className="text-orange-400"> {orderStatusLabel->React.string} </p>
    </div>
  }
}
