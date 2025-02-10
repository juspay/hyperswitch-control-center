module SubHeading = {
  @react.component
  let make = (~title, ~subTitle) => {
    <div className="flex flex-col gap-y-1">
      <p className="text-xl font-semibold text-gray-700 leading-9"> {title->React.string} </p>
      <p className="text-base text-gray-400 font-medium"> {subTitle->React.string} </p>
    </div>
  }
}

module StepCard = {
  @react.component
  let make = (~stepName, ~description, ~isSelected, ~onClick, ~iconName) => {
    let ringClass = switch isSelected {
    | true => "border-blue-500"
    | false => "ring-gray-200"
    }
    <div
      key={stepName}
      className={`flex items-center gap-x-2.5 border ${ringClass} rounded-xl p-3 transition-shadow cursor-pointer justify-between`}
      onClick={onClick}>
      <div className="flex items-center gap-x-2.5">
        <img alt={iconName} src={`/Recon/${iconName}.svg`} className="w-8 h-8" />
        <div className="flex flex-col gap-1">
          <h3 className="text-medium font-semibold text-gray-600"> {stepName->React.string} </h3>
          <p className="text-sm font-medium text-gray-400"> {description->React.string} </p>
        </div>
      </div>
      {switch isSelected {
      | true => <Icon name="nd-circle-dot" customHeight="20" />
      | false => <div />
      }}
    </div>
  }
}
