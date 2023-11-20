type popOverSize = Small | Medium

@react.component
let make = (
  ~title="",
  ~description="",
  ~descriptionElement=?,
  ~popOverSize=Small,
  ~dismissable=false,
  ~popOverPosition: option<ToolTip.toolTipPosition>=?,
  ~popOverFor=?,
  ~popOverArrowSize=5,
) => {
  let paddingClass = switch popOverSize {
  | Small => "p-4"
  | Medium => "px-4 py-5"
  }
  let gapClass = switch popOverSize {
  | Small => "gap-1.5"
  | Medium => "gap-2"
  }

  let titleClass = switch popOverSize {
  | Small => "text-fs-16 font-medium text-jp-2-dark-gray-2000"
  | Medium => "text-fs-20 font-medium text-jp-2-dark-gray-2000"
  }
  let descriptionClass = switch popOverSize {
  | Small => "text-fs-12 font-normal text-jp-2-dark-gray-2000"
  | Medium => "text-fs-14 font-normal text-jp-2-dark-gray-2000"
  }
  let descriptionComponent = switch descriptionElement {
  | Some(element) => element
  | None =>
    <div className={`flex flex-col w-80 ${gapClass} ${paddingClass}`}>
      <span className=titleClass> {React.string(title)} </span>
      <span className=descriptionClass> {React.string(description)} </span>
    </div>
  }

  <ToolTip
    descriptionComponent
    toolTipPosition=?popOverPosition
    tooltipWidthClass="w-fit"
    hoverOnToolTip=true
    dismissable
    descriptionComponentClass="flex flex-row-reverse items-start"
    toolTipFor=?popOverFor
    tooltipArrowSize=popOverArrowSize
  />
}
