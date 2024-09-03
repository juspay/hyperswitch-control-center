@react.component
let make = (~view, ~count="", ~onViewClick, ~isActiveView) => {
  open TransactionViewUtils

  let textClass = isActiveView ? "text-blue-500" : "font-semibold text-jp-gray-700"
  let countTextClass = isActiveView ? "text-blue-500" : "font-semibold text-jp-gray-900"
  let borderClass = isActiveView ? "border-blue-500" : ""

  <div
    className={`flex flex-col justify-center flex-auto gap-1 bg-white text-semibold border rounded-md px-4 py-2.5 w-14 my-8 cursor-pointer hover:bg-gray-50 ${borderClass}`}
    onClick={_ => onViewClick(view)}>
    <p className={textClass}> {view->getViewsDisplayName->React.string} </p>
    <RenderIf condition={!(count->LogicUtils.isEmptyString)}>
      <p className={countTextClass}> {count->React.string} </p>
    </RenderIf>
  </div>
}
