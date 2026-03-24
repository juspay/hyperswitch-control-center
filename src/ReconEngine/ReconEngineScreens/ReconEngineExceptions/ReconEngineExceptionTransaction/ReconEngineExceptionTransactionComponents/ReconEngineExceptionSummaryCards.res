open Typography
open ReconEngineTypes

module ExceptionCountBadge = {
  @react.component
  let make = (~label: string, ~count: int, ~dotColor: string) => {
    <div
      className="flex flex-row items-center gap-2 border border-nd_gray-150 rounded-lg px-3 py-2 bg-white">
      <div className={`w-2 h-2 rounded-full ${dotColor}`} />
      <p className={`text-nd_gray-500 ${body.sm.medium}`}> {label->React.string} </p>
      <p className={`text-nd_gray-800 ${body.sm.semibold}`}> {count->Int.toString->React.string} </p>
    </div>
  }
}

let categorizeExceptions = (exceptions: array<transactionType>): (int, int, int, int) => {
  exceptions->Array.reduce((0, 0, 0, 0), (
    (mismatched, missing, overUnder, dataIssues),
    transaction,
  ) => {
    switch transaction.transaction_status {
    | OverAmount(Mismatch) | UnderAmount(Mismatch) => (mismatched, missing, overUnder + 1, dataIssues)
    | Missing => (mismatched, missing + 1, overUnder, dataIssues)
    | DataMismatch => (mismatched, missing, overUnder, dataIssues + 1)
    | Expected | PartiallyReconciled | OverAmount(Expected) | UnderAmount(Expected) => (
        mismatched + 1,
        missing,
        overUnder,
        dataIssues,
      )
    | _ => (mismatched, missing, overUnder, dataIssues)
    }
  })
}

@react.component
let make = (~exceptionData: array<transactionType>) => {
  let (pendingCount, missingCount, varianceCount, dataMismatchCount) = React.useMemo(() => {
    categorizeExceptions(exceptionData)
  }, [exceptionData])

  let totalExceptions = exceptionData->Array.length

  <RenderIf condition={totalExceptions > 0}>
    <div className="flex flex-row flex-wrap items-center gap-3 mb-2">
      <div className="flex flex-row items-center gap-2">
        <p className={`text-nd_gray-800 ${body.md.semibold}`}>
          {`${totalExceptions->Int.toString} Exceptions`->React.string}
        </p>
      </div>
      <div className="h-5 w-px bg-nd_gray-200" />
      <ExceptionCountBadge label="Pending" count={pendingCount} dotColor="bg-nd_yellow-400" />
      <ExceptionCountBadge label="Missing" count={missingCount} dotColor="bg-nd_red-400" />
      <ExceptionCountBadge label="Variance" count={varianceCount} dotColor="bg-orange-400" />
      <ExceptionCountBadge label="Data Mismatch" count={dataMismatchCount} dotColor="bg-purple-400" />
    </div>
  </RenderIf>
}
