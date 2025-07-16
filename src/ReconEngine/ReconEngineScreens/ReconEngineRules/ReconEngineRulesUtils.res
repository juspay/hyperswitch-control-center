open LogicUtils
let getFieldDisplayName = (field: string): string => {
  if field->String.startsWith("metadata.") {
    field->String.replace("metadata.", "")->getTitle
  } else {
    field->getTitle
  }
}

let createFormInput = (~name, ~value): ReactFinalForm.fieldRenderPropsInput => {
  name,
  onBlur: _ => (),
  onChange: _ => (),
  onFocus: _ => (),
  value: value->JSON.Encode.string,
  checked: true,
}

let createDropdownOption = (~label, ~value) => {
  SelectBox.label,
  value,
}
