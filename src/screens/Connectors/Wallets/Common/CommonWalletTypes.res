type inputType = Text | Toggle | Select

type inputField = {
  name: string,
  label: string,
  placeholder: string,
  required: bool,
  options: array<string>,
  \"type": inputType,
}
