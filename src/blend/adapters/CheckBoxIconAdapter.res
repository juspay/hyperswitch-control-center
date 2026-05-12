// Re-export legacy type so call sites using CheckBoxIconAdapter.size need no changes
type size = CheckBoxIcon.size
module CheckedValue = CheckBoxBinding.CheckedValue

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
  // Legacy-only styling props — Blend's Checkbox derives its visual size from `size`,
  // so these are forwarded to <CheckBoxIcon> but ignored when Blend mode is active.
  ~checkboxDimension="w-4 h-4",
  ~isCheckboxSelectedClass=false,
  ~stopPropagationNeeded=false,
) => {
  let isBlendEnabled = BlendContext.useBlendEnabled()

  // Blend's Checkbox is a button that calls stopPropagation internally.
  // It can only work when setIsSelected is provided — otherwise the parent
  // div click pattern is broken. Fall back to legacy when no setter is given.
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
