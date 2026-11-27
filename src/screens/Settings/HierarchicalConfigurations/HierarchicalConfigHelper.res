module RadioCard = {
  @react.component
  let make = (~title, ~description, ~isSelected, ~onClick, ~isDisabled=false) => {
    open Typography

    let selectionClass = isSelected
      ? "border-nd_primary_blue-500 bg-nd_primary_blue-25"
      : "border-nd_gray-200 hover:border-nd_gray-300"
    let cursorClass = isDisabled ? "opacity-60 cursor-not-allowed" : "cursor-pointer"

    <div
      className={`flex items-start gap-3 p-4 border rounded-lg ${selectionClass} ${cursorClass}`}
      onClick={_ =>
        if !isDisabled {
          onClick()
        }}>
      <div className="pt-0.5">
        <RadioIcon isSelected fill="text-nd_primary_blue-500" />
      </div>
      <div className="flex flex-col gap-1">
        <span className={`${body.md.semibold} text-nd_gray-800`}> {title->React.string} </span>
        <span className={`${body.sm.regular} text-nd_gray-500`}> {description->React.string} </span>
      </div>
    </div>
  }
}
