open CheckBoxBinding

type size = CheckBoxIcon.size

let mapSize = (s: size): CheckBoxBinding.size =>
  switch s {
  | Small => CheckBoxBinding.Small
  | Large => CheckBoxBinding.Medium
  }

@react.component
let make = (
  ~isSelected,
  ~isDisabled=false,
  ~setIsSelected=?,
  ~size: size=Small,
  ~isSelectedStateMinus=false,
  ~checkboxDimension="w-4 h-4",
  ~isCheckboxSelectedClass=false,
  ~stopPropagationNeeded=false,
) => {
  let isBlendEnabled = BlendContext.useBlendEnabled()
  let useBlend = isBlendEnabled && setIsSelected->Option.isSome

  let checkedValue = if isSelectedStateMinus && isSelected {
    CheckedValue.fromIndeterminate("indeterminate")
  } else {
    CheckedValue.fromBool(isSelected)
  }

  let onCheckedChange = v =>
    switch setIsSelected {
    | Some(fn) => fn(v->CheckedValue.toBool)
    | None => ()
    }

  let blendCheckbox =
    <CheckBoxBinding
      checked={checkedValue} onCheckedChange disabled={isDisabled} size={mapSize(size)}
    />

  let blendNode = if stopPropagationNeeded {
    <div onClick={e => e->ReactEvent.Mouse.stopPropagation}> {blendCheckbox} </div>
  } else {
    blendCheckbox
  }

  <>
    <RenderIf condition={useBlend}> {blendNode} </RenderIf>
    <RenderIf condition={!useBlend}>
      <CheckBoxIcon
        isSelected
        isDisabled
        ?setIsSelected
        size
        isSelectedStateMinus
        checkboxDimension
        isCheckboxSelectedClass
        stopPropagationNeeded
      />
    </RenderIf>
  </>
}
