@react.component
let make = (~fieldkey) => {
  let data = ReactFinalForm.useField(fieldkey).input.value
  <Clipboard.Copy data />
}
