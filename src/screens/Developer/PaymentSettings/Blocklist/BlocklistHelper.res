open Typography

module ActionIcon = {
  @react.component
  let make = (~iconName, ~description, ~isDisabled, ~onClick) => {
    <ToolTip
      description
      toolTipPosition=Top
      toolTipFor={<Icon
        name=iconName
        size=16
        onClick={_ => isDisabled ? () : onClick()}
        className={isDisabled
          ? "cursor-not-allowed text-nd_gray-300"
          : "cursor-pointer text-nd_gray-600"}
      />}
    />
  }
}

module Step = {
  @react.component
  let make = (~stepNumber, ~title, ~description, ~isLast=false, ~children) => {
    <div className="flex gap-4">
      <div className="flex flex-col items-center shrink-0">
        <div
          className={`h-7 w-7 rounded-full bg-nd_primary_blue-50 border border-nd_primary_blue-200 text-nd_primary_blue-500 flex items-center justify-center ${body.sm.semibold}`}>
          {stepNumber->Int.toString->React.string}
        </div>
        <RenderIf condition={!isLast}>
          <div className="w-px flex-1 bg-nd_gray-200 mt-2" />
        </RenderIf>
      </div>
      <div className={`flex-1 min-w-0 flex flex-col gap-4 ${isLast ? "" : "pb-8"}`}>
        <div className="pt-0.5">
          <h2 className={`text-nd_gray-700 ${body.lg.semibold}`}> {title->React.string} </h2>
          <p className={`text-nd_gray-500 mt-1 ${body.md.medium}`}> {description->React.string} </p>
        </div>
        {children}
      </div>
    </div>
  }
}

module Panel = {
  @react.component
  let make = (~children) => {
    <div className="border border-nd_gray-200 rounded-lg bg-white p-5 flex flex-col gap-4">
      {children}
    </div>
  }
}

module PanelHeader = {
  @react.component
  let make = (~title, ~description, ~action=React.null) => {
    <div className="flex flex-col sm:flex-row sm:items-start justify-between gap-4">
      <div className="min-w-0">
        <p className={`text-nd_gray-700 ${body.md.semibold}`}> {title->React.string} </p>
        <p className={`text-nd_gray-500 mt-1 ${body.sm.medium}`}> {description->React.string} </p>
      </div>
      <div className="shrink-0"> {action} </div>
    </div>
  }
}

module BackgroundJobNote = {
  @react.component
  let make = (~description) => {
    <div className="flex items-start gap-2">
      <Icon name="nd-toast-info" size=14 className="mt-0.5 shrink-0 text-nd_gray-400" />
      <p className={`text-nd_gray-500 ${body.sm.medium}`}> {description->React.string} </p>
    </div>
  }
}
