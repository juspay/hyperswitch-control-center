@react.component
let make = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~placeholder,
  ~isDisabled=false,
  ~inputMode="text",
  ~min=?,
  ~max=?,
) => {
  let valStr = switch input.value->Js.Json.classify {
  | JSONString(str) => str
  | JSONNumber(num) => num->Belt.Float.toString
  | _ => ""
  }
  <div>
    <TextInput input placeholder isDisabled type_="range" inputMode ?min ?max />
    {React.string(valStr)}
  </div>
}
