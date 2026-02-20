open Typography

module TransformedEntriesOverviewCard = {
  @react.component
  let make = (~title, ~value) => {
    <div
      className="flex flex-col gap-4 bg-white border border-nd_gray-200 rounded-xl p-4 shadow-xs">
      <div className={`${body.md.medium} text-nd_gray-400`}> {title->React.string} </div>
      <div className={`${heading.md.semibold} text-nd_gray-800`}> {value->React.string} </div>
    </div>
  }
}
