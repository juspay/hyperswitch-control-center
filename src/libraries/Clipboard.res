@val @scope(("navigator", "clipboard"))
external writeText: string => unit = "writeText"

module Copy = {
  @react.component
  let make = (
    ~data,
    ~toolTipPosition: ToolTip.toolTipPosition=Left,
    ~copyElement=?,
    ~iconSize=15,
    ~outerPadding="p-2",
  ) => {
    let (tooltipText, setTooltipText) = React.useState(_ => "copy")
    let onCopyClick = ev => {
      ev->ReactEvent.Mouse.stopPropagation
      setTooltipText(_ => "copied")

      writeText([data]->Js.Array2.joinWith("\n"))
    }

    let iconClass = HSwitchGlobalVars.isHyperSwitchDashboard ? "text-gray-300" : "text-jp-gray-900"

    <div
      className={`flex justify-end ${outerPadding}`}
      onMouseOut={_ => {
        setTooltipText(_ => "copy")
      }}>
      <div onClick={onCopyClick}>
        <ToolTip
          tooltipWidthClass="w-[60px]"
          bgColor={tooltipText == "copy" ? "" : "bg-green-950 text-white"}
          arrowBgClass={tooltipText == "copy" ? "" : "#36AF47"}
          description=tooltipText
          toolTipFor={switch copyElement {
          | Some(element) => element
          | None =>
            <div className={`${iconClass} flex items-center cursor-pointer`}>
              <Icon name="copy" size=iconSize />
            </div>
          }}
          toolTipPosition
          tooltipPositioning=#absolute
        />
      </div>
    </div>
  }
}
