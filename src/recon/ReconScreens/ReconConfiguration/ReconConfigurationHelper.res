module SubHeading = {
  @react.component
  let make = (~title, ~subTitle) => {
    <div className="flex flex-col gap-y-1">
      <p className="text-2xl font-semibold text-nd_gray-700 leading-9"> {title->React.string} </p>
      <p className="text-sm text-nd_gray-400 font-medium leading-5"> {subTitle->React.string} </p>
    </div>
  }
}

module StepCard = {
  @react.component
  let make = (
    ~stepName,
    ~description="",
    ~isSelected,
    ~onClick,
    ~iconName,
    ~isLoading=false,
    ~customSelectionComponent,
    ~customOuterClass="",
    ~customSelectionBorderClass=?,
    ~isDisabled=false,
  ) => {
    let borderClass = switch (customSelectionBorderClass, isSelected) {
    | (Some(val), true) => val
    | (_, true) => "border-blue-500"
    | _ => ""
    }

    let disabledClass = if isDisabled {
      "opacity-60 filter blur-xs pointer-events-none cursor-not-allowed"
    } else {
      "cursor-pointer"
    }

    <div
      key={stepName}
      className={`flex items-center gap-x-2.5 border rounded-xl p-3 transition-shadow justify-between w-full ${borderClass}  ${disabledClass} ${customOuterClass}`}
      onClick={onClick}>
      <div className="flex flex-row items-center gap-x-4">
        <Icon name=iconName className="w-8 h-8" />
        <div className="flex flex-col gap-1">
          <h3 className="text-sm font-semibold text-nd_gray-600 leading-5">
            {stepName->React.string}
          </h3>
          <RenderIf condition={description->String.length > 0}>
            <p className="text-xs font-medium text-nd_gray-400"> {description->React.string} </p>
          </RenderIf>
        </div>
      </div>
      <RenderIf condition={isSelected}>
        {<div className="flex flex-row items-center gap-2"> customSelectionComponent </div>}
      </RenderIf>
      <RenderIf condition={isDisabled}>
        <div className="h-4 w-4 border border-nd_gray-300 rounded-full" />
      </RenderIf>
    </div>
  }
}
