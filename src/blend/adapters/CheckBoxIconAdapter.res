// Re-export legacy type so call sites using CheckBoxIconAdapter.size need no changes
type size = CheckBoxIcon.size

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

  // Blend's Checkbox is a button that calls stopPropagation internally.
  // It can only work when setIsSelected is provided — otherwise the parent
  // div click pattern is broken. Fall back to legacy when no setter is given.
  if isBlendEnabled && setIsSelected->Option.isSome {
    let checkedValue = if isSelectedStateMinus && isSelected {
      CheckBoxBinding.CheckedValue.fromIndeterminate("indeterminate")
    } else {
      CheckBoxBinding.CheckedValue.fromBool(isSelected)
    }

    let onCheckedChange = (v: CheckBoxBinding.CheckedValue.t) =>
      switch setIsSelected {
      | Some(fn) => fn(v->CheckBoxBinding.CheckedValue.toBool)
      | None => ()
      }

    let blendSize = switch size {
    | Small => CheckBoxBinding.Small
    | Large => CheckBoxBinding.Medium
    }

    let checkbox =
      <CheckBoxBinding
        checked={checkedValue} onCheckedChange disabled={isDisabled} size={blendSize}
      />

    if stopPropagationNeeded {
      <div onClick={e => e->ReactEvent.Mouse.stopPropagation}> {checkbox} </div>
    } else {
      checkbox
    }
  } else {
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
  }
}
