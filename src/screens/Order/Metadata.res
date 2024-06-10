@react.component
let make = (~displayValue) => {
  open UIUtils
  let (isTextVisible, setIsTextVisible) = React.useState(_ => false)

  let handleClick = ev => {
    ev->ReactEvent.Mouse.stopPropagation
    setIsTextVisible(_ => true)
  }

  <div>
    <RenderIf condition={isTextVisible}>
      <div>
        <HelperComponents.CopyTextCustomComp displayValue customTextCss="text-nowrap" />
      </div>
    </RenderIf>
    <RenderIf condition={!isTextVisible && displayValue->LogicUtils.isNonEmptyString}>
      <div className="flex text-nowrap gap-1">
        <p className=""> {`${displayValue->String.slice(~start=0, ~end=17)}`->React.string} </p>
        <span className="flex text-blue-811 text-sm font-extrabold" onClick={ev => handleClick(ev)}>
          {"..."->React.string}
        </span>
      </div>
    </RenderIf>
  </div>
}
