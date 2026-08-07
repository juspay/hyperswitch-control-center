@react.component
let make = (
  ~cursors: ReconEngineTypes.cursors,
  ~isLoading: bool,
  ~hasData: bool,
  ~onPrev: unit => unit,
  ~onNext: unit => unit,
) => {
  let getButtonState = (cursor): Button.buttonState =>
    cursor->Option.isNone || isLoading ? Button.Disabled : Button.Normal

  <RenderIf condition=hasData>
    <div className="flex flex-row justify-end items-center gap-2 py-4">
      <Button
        leftIcon={FontAwesome("chevron-left")}
        buttonType=Secondary
        buttonSize=Small
        buttonState={getButtonState(cursors.prev)}
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
        buttonState={getButtonState(cursors.next)}
        customButtonStyle="!w-8 !px-0"
        customIconMargin=""
        showTooltip=true
        tooltipText="Next page"
        onClick={_ => onNext()}
      />
    </div>
  </RenderIf>
}
