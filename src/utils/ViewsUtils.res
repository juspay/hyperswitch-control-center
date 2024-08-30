type viewTypes = All | Succeeded | Failed | Dropoffs | Cancelled

let paymentViewsArray: array<viewTypes> = [All, Succeeded, Failed, Dropoffs, Cancelled]

let getViewsDisplayName = (view: viewTypes) => {
  switch view {
  | All => "All"
  | Succeeded => "Succeeded"
  | Failed => "Failed"
  | Dropoffs => "Dropoffs"
  | Cancelled => "Cancelled"
  }
}

let getAllPaymentsLabel = obj => {
  open LogicUtils
  obj
  ->getDictFromJsonObject
  ->getDictfromDict("status_with_count")
  ->Dict.keysToArray
  ->Array.joinWith(",")
}

let getViewsLabel = (view, obj) => {
  switch view {
  | All => getAllPaymentsLabel(obj)
  | Succeeded => "succeeded"
  | Failed => "failed"
  | Dropoffs => "requires_payment_method"
  | Cancelled => "cancelled"
  }
}

let getViewTypeFromString = view => {
  switch view {
  | "succeeded" => Succeeded
  | "cancelled" => Cancelled
  | "failed" => Failed
  | "requires_payment_method" => Dropoffs
  | _ => All
  }
}

let getAllPaymentsCount = obj => {
  open LogicUtils
  let countArray =
    obj
    ->getDictFromJsonObject
    ->getDictfromDict("status_with_count")
    ->Dict.toArray
    ->Array.map(item => {
      let (_, value) = item
      value
    })
  countArray->Array.reduce(0, (acc, curr) =>
    (acc->Int.toFloat +. curr->getFloatFromJson(0.0))->Float.toInt
  )
}

let paymentCount = (view, obj) => {
  open LogicUtils
  switch view {
  | All => getAllPaymentsCount(obj)
  | _ =>
    obj
    ->getDictFromJsonObject
    ->getDictfromDict("status_with_count")
    ->getInt(view->getViewsLabel(obj), 0)
  }
}

module ViewCards = {
  @react.component
  let make = (~view, ~count="", ~onViewClick, ~isActiveView) => {
    let textClass = isActiveView ? "text-blue-500" : "text-jp-gray-800"
    let borderClass = isActiveView ? "border-blue-500" : ""

    <div
      className={`flex flex-col justify-center flex-auto gap-1 bg-white text-semibold border rounded-md px-4 py-3 w-14 my-2 cursor-pointer hover:bg-gray-50 ${borderClass}`}
      onClick={_ => onViewClick(view)}>
      <p className={` ${textClass}`}> {view->getViewsDisplayName->React.string} </p>
      <RenderIf condition={!(count->LogicUtils.isEmptyString)}>
        <p className={` ${textClass}`}> {count->React.string} </p>
      </RenderIf>
    </div>
  }
}
