open CheckBoxBinding
open CheckedValue

type size = CheckBoxIcon.size

let mapSize = (s: size) =>
  switch s {
  | Small => Small
  | Large => Medium
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
  let useBlend = BlendContext.useBlendEnabled()

  let checkedValue = if isSelectedStateMinus && isSelected {
    fromIndeterminate("indeterminate")
  } else {
    fromBool(isSelected)
  }

  let onCheckedChange = v =>
    switch setIsSelected {
    | Some(fn) => fn(v->toBool)
    | None => ()
    }

  let blendCheckbox =
    <CheckBoxBinding
      checked={checkedValue} onCheckedChange disabled={isDisabled} size={mapSize(size)}
    />

  let blendNode = stopPropagationNeeded
    ? <div className="relative" onClick={e => e->ReactEvent.Mouse.stopPropagation}>
        {blendCheckbox}
      </div>
    : <div className="relative"> {blendCheckbox} </div>

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
