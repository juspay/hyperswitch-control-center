@react.component
let make = (
  ~isLoading: bool,
  ~hasData: bool,
  ~prevDisabled: bool,
  ~nextDisabled: bool,
  ~onPrev: unit => unit,
  ~onNext: unit => unit,
) => {
  let getButtonState = (disabled): Button.buttonState =>
    disabled || isLoading ? Button.Disabled : Button.Normal

  <RenderIf condition=hasData>
    <div className="flex flex-row justify-end items-center gap-2 py-4">
      <Button
        leftIcon={FontAwesome("chevron-left")}
        buttonType=Secondary
        buttonSize=Small
        buttonState={getButtonState(prevDisabled)}
        customButtonStyle="!w-8 !px-0"
        customIconMargin=""
        showTooltip=true
        tooltipText="Previous page"
        onClick={_ => onPrev()}
      />
      <Button
        leftIcon={FontAwesome("chevron-right")}
        buttonType=Secondary
        buttonSize=Small
        buttonState={getButtonState(nextDisabled)}
        customButtonStyle="!w-8 !px-0"
        customIconMargin=""
        showTooltip=true
        tooltipText="Next page"
        onClick={_ => onNext()}
      />
    </div>
  </RenderIf>
}
