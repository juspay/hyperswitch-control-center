open ViewUtils

module ViewCards = {
  @react.component
  let make = (~view, ~count="", ~onViewClick, ~isActiveView) => {
    let textClass = isActiveView ? "text-blue-500" : "text-jp-gray-800"
    let borderClass = isActiveView ? "border-blue-500" : ""

    <div
      className={`flex flex-col justify-center flex-auto gap-1 bg-white text-semibold border rounded-md px-4 py-3 w-14 my-2 cursor-pointer hover:bg-gray-50 ${borderClass}`}
      onClick={_ => onViewClick(view)}>
      <p className={textClass}> {view->getViewsDisplayName->React.string} </p>
      <RenderIf condition={!(count->LogicUtils.isEmptyString)}>
        <p className={textClass}> {count->React.string} </p>
      </RenderIf>
    </div>
  }
}
