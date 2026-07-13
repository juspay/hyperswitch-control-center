@react.component
let make = (
  ~cursors: ReconEngineTypes.cursors,
  ~isLoading: bool,
  ~show: bool,
  ~onPrev: unit => unit,
  ~onNext: unit => unit,
) => {
  let getButtonState = (cursor): Button.buttonState =>
    cursor->Option.isNone || isLoading ? Button.Disabled : Button.Normal

  <RenderIf condition=show>
    <div className="flex flex-row justify-end items-center gap-3 py-4">
      <Button
        text="Prev"
        buttonType=Secondary
        buttonSize=Small
        buttonState={getButtonState(cursors.prev)}
        onClick={_ => onPrev()}
      />
      <Button
        text="Next"
        buttonType=Primary
        buttonSize=Small
        buttonState={getButtonState(cursors.next)}
        onClick={_ => onNext()}
      />
    </div>
  </RenderIf>
}
