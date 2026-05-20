type size = CheckBoxIcon.size

@react.component
let make = (
  ~isSelected,
  ~isDisabled=false,
  ~setIsSelected=?,
  ~size: size=Small,
  ~fill="#0EB025",
) => {
  open LogicUtils
  let isBlendEnabled = BlendContext.useBlendEnabled()

  let mapSize = (s: size) =>
    switch s {
    | Small => RadioBinding.Small
    | Large => RadioBinding.Medium
    }

  let onChange = setIsSelected->mapOptionOrDefault(_e => (), fn => _e => fn(true))

  <>
    <RenderIf condition={isBlendEnabled}>
      <RadioBinding checked={isSelected} onChange disabled={isDisabled} size={mapSize(size)} />
    </RenderIf>
    <RenderIf condition={!isBlendEnabled}>
      <RadioIcon isSelected isDisabled size fill />
    </RenderIf>
  </>
}
