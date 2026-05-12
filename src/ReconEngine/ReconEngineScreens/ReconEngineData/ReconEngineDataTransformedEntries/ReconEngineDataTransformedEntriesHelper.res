open Typography

module TransformedEntriesOverviewCard = {
  @react.component
  let make = (~title, ~value, ~onClick=None, ~isActive=false) => {
    let (borderClass, titleClass, valueClass) = isActive
      ? ("border-primary", "text-primary", "text-primary")
      : ("border-nd_gray-200", "text-nd_gray-400", "text-nd_gray-800")

    let cursorClass = onClick->Option.isSome ? "cursor-pointer hover:bg-nd_gray-50" : ""

    <div
      className={`flex flex-col gap-4 bg-white border ${borderClass} rounded-xl p-4 shadow-xs ${cursorClass}`}
      onClick={_ => {
        onClick->Option.mapOr((), fn => fn())
      }}>
      <div className={`${body.md.medium} ${titleClass}`}> {title->React.string} </div>
      <div className={`${heading.md.semibold} ${valueClass}`}> {value->React.string} </div>
    </div>
  }
}
