type size = CheckBoxIcon.size

let mapSize = (s: size) =>
  switch s {
  | Small => RadioBinding.Small
  | Large => RadioBinding.Medium
  }

@react.component
let make = (
  ~isSelected,
  ~isDisabled=false,
  ~setIsSelected=?,
  ~size: size=Small,
  ~fill="#0EB025",
) => {
  let isBlendEnabled = BlendContext.useBlendEnabled()

  let onChange = setIsSelected->Option.map(fn => (_e: ReactEvent.Form.t) => fn(true))

  <>
    <RenderIf condition={isBlendEnabled}>
      <RadioBinding checked={isSelected} ?onChange disabled={isDisabled} size={mapSize(size)} />
    </RenderIf>
    <RenderIf condition={!isBlendEnabled}>
      <RadioIcon isSelected isDisabled size fill />
    </RenderIf>
  </>
}
