let getFieldDisplayName = (field: string): string => {
  if field->String.startsWith("metadata.") {
    field->String.replace("metadata.", "")->LogicUtils.getTitle
  } else {
    // For non-metadata fields, just use the part after the last dot
    let fieldName = field->String.split(".")->Array.get(-1)->Option.getOr(field)
    fieldName->LogicUtils.getTitle
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
