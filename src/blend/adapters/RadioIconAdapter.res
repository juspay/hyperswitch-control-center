type size = CheckBoxIcon.size
@react.component
let make = (
  ~isSelected,
  ~isDisabled=false,
  ~setIsSelected=?,
  ~size: size=Small,
  ~fill="#0EB025",
) => {
  let isBlendEnabled = BlendContext.useBlendEnabled()

  if isBlendEnabled {
    let blendSize = switch size {
    | Small => RadioBinding.Small
    | Large => RadioBinding.Medium
    }

    let onChange = switch setIsSelected {
    | Some(fn) => (_e: ReactEvent.Form.t) => fn(true)
    | None => (_e: ReactEvent.Form.t) => ()
    }

    <RadioBinding checked={isSelected} onChange disabled={isDisabled} size={blendSize} />
  } else {
    <RadioIcon isSelected isDisabled size fill />
  }
}
