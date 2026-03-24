open Typography
open ReconEngineTypes

module ComparisonField = {
  @react.component
  let make = (~label: string, ~sourceValue: string, ~targetValue: string) => {
    let isMismatch = sourceValue !== targetValue && sourceValue !== "" && targetValue !== ""
    let mismatchStyle = isMismatch ? "bg-nd_red-50 border-nd_red-200" : "bg-white border-nd_gray-150"

    <div className={`grid grid-cols-3 gap-4 px-4 py-3 border-b border-nd_gray-100 ${mismatchStyle}`}>
      <div className="flex flex-col">
        <p className={`text-nd_gray-500 ${body.sm.medium}`}> {label->React.string} </p>
      </div>
      <div className="flex flex-col">
        <p
          className={`text-nd_gray-800 ${body.sm.medium} ${isMismatch
              ? "text-nd_red-600 font-semibold"
              : ""}`}>
          {sourceValue->React.string}
        </p>
      </div>
      <div className="flex flex-col">
        <p
          className={`text-nd_gray-800 ${body.sm.medium} ${isMismatch
              ? "text-nd_red-600 font-semibold"
              : ""}`}>
          {targetValue->React.string}
        </p>
      </div>
    </div>
  }
}

let getEntryStatusString = (status: entryStatus): string => {
  switch status {
  | Posted => "Posted"
  | Mismatched => "Mismatched"
  | Expected => "Expected"
  | Archived => "Archived"
  | Pending => "Pending"
  | Void => "Void"
  | UnknownEntryStatus => "Unknown"
  }
}

let getEntryDirectionString = (direction: entryDirectionType): string => {
  switch direction {
  | Debit => "Debit"
  | Credit => "Credit"
  | UnknownEntryDirectionType => "Unknown"
  }
}

@react.component
let make = (~entries: array<transactionEntryType>) => {
  let sourceEntries =
    entries->Array.filter(entry =>
      switch entry.entry_type {
      | Credit => true
      | _ => false
      }
    )
  let targetEntries =
    entries->Array.filter(entry =>
      switch entry.entry_type {
      | Debit => true
      | _ => false
      }
    )

  let sourceEntry = sourceEntries->Array.get(0)
  let targetEntry = targetEntries->Array.get(0)

  <RenderIf condition={sourceEntry->Option.isSome && targetEntry->Option.isSome}>
    {switch (sourceEntry, targetEntry) {
    | (Some(source), Some(target)) =>
      <div className="border border-nd_gray-150 rounded-xl overflow-hidden mt-4">
        <div className="grid grid-cols-3 gap-4 px-4 py-3 bg-nd_gray-50 border-b border-nd_gray-150">
          <p className={`text-nd_gray-500 ${body.sm.semibold}`}> {"Field"->React.string} </p>
          <div className="flex flex-row items-center gap-2">
            <div className="w-2 h-2 rounded-full bg-blue-400" />
            <p className={`text-nd_gray-700 ${body.sm.semibold}`}>
              {`Source (${source.account.account_name})`->React.string}
            </p>
          </div>
          <div className="flex flex-row items-center gap-2">
            <div className="w-2 h-2 rounded-full bg-green-400" />
            <p className={`text-nd_gray-700 ${body.sm.semibold}`}>
              {`Target (${target.account.account_name})`->React.string}
            </p>
          </div>
        </div>
        <ComparisonField
          label="Amount"
          sourceValue={`${source.amount.value->Float.toString} ${source.amount.currency}`}
          targetValue={`${target.amount.value->Float.toString} ${target.amount.currency}`}
        />
        <ComparisonField
          label="Currency"
          sourceValue={source.amount.currency}
          targetValue={target.amount.currency}
        />
        <ComparisonField
          label="Direction"
          sourceValue={getEntryDirectionString(source.entry_type)}
          targetValue={getEntryDirectionString(target.entry_type)}
        />
        <ComparisonField
          label="Status"
          sourceValue={getEntryStatusString(source.status)}
          targetValue={getEntryStatusString(target.status)}
        />
        <ComparisonField label="Order ID" sourceValue={source.order_id} targetValue={target.order_id} />
        <ComparisonField
          label="Entry ID"
          sourceValue={source.entry_id}
          targetValue={target.entry_id}
        />
      </div>
    | _ => React.null
    }}
  </RenderIf>
}
