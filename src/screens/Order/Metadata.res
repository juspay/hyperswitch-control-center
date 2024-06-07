@react.component
let make = (~displayValue) => {
  let (isTextVisible, setIsTextVisible) = React.useState(_ => false)

  let handleClick = ev => {
    ev->ReactEvent.Mouse.stopPropagation
    setIsTextVisible(_ => true)
  }

  <div>
    <UIUtils.RenderIf condition={isTextVisible == true}>
      <div>
        <HelperComponents.CopyTextCustomComp displayValue customTextCss="text-nowrap" />
      </div>
    </UIUtils.RenderIf>
    <UIUtils.RenderIf condition={isTextVisible == false}>
      <div className="flex text-nowrap gap-1">
        <p className=""> {`${displayValue->String.slice(~start=0, ~end=17)}`->React.string} </p>
        <span className="flex text-blue-811 text-sm font-extrabold" onClick={ev => handleClick(ev)}>
          {"..."->React.string}
        </span>
      </div>
    </UIUtils.RenderIf>
  </div>
}
