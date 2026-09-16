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
