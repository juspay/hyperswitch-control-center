type inputType = Text | Number | Toggle | Radio | Select | MultiSelect

type inputField = {
  name: string,
  label: string,
  placeholder: string,
  required: bool,
  options: array<string>,
  \"type": inputType,
}
