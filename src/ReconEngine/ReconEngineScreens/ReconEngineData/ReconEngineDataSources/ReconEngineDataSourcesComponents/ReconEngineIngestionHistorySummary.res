open Typography
open ReconEngineTypes

let countByStatus = (
  historyData: array<Nullable.t<ingestionHistoryType>>,
): (int, int, int, int) => {
  historyData->Array.reduce((0, 0, 0, 0), ((processed, processing, pending, failed), item) => {
    switch item->Nullable.toOption {
    | Some(record) =>
      switch record.status {
      | Processed => (processed + 1, processing, pending, failed)
      | Processing => (processed, processing + 1, pending, failed)
      | Pending => (processed, processing, pending + 1, failed)
      | Failed => (processed, processing, pending, failed + 1)
      | _ => (processed, processing, pending, failed)
      }
    | None => (processed, processing, pending, failed)
    }
  })
}

module StatusPill = {
  @react.component
  let make = (~label: string, ~count: int, ~dotColor: string, ~bgColor: string) => {
    <div className={`flex flex-row items-center gap-2 px-3 py-1.5 rounded-lg ${bgColor}`}>
      <div className={`w-2 h-2 rounded-full ${dotColor}`} />
      <span className={`${body.sm.medium} text-nd_gray-600`}> {label->React.string} </span>
      <span className={`${body.sm.semibold} text-nd_gray-800`}>
        {count->Int.toString->React.string}
      </span>
    </div>
  }
}

@react.component
let make = (~historyData: array<Nullable.t<ingestionHistoryType>>) => {
  let (processed, processing, pending, failed) = React.useMemo(() => {
    countByStatus(historyData)
  }, [historyData])

  let total = processed + processing + pending + failed

  <RenderIf condition={total > 0}>
    <div className="flex flex-row flex-wrap items-center gap-2 mb-2">
      <span className={`${body.md.semibold} text-nd_gray-700 mr-2`}>
        {`${total->Int.toString} Records`->React.string}
      </span>
      <StatusPill label="Processed" count={processed} dotColor="bg-nd_green-400" bgColor="bg-nd_green-50" />
      <StatusPill label="Processing" count={processing} dotColor="bg-blue-400" bgColor="bg-blue-50" />
      <StatusPill label="Pending" count={pending} dotColor="bg-nd_yellow-400" bgColor="bg-nd_yellow-50" />
      <StatusPill label="Failed" count={failed} dotColor="bg-nd_red-400" bgColor="bg-nd_red-50" />
    </div>
  </RenderIf>
}
