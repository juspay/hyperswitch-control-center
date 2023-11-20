type t
type append
external toString: 't => string = "%identity"
external toRef: 'a => 't = "%identity"
@new external formData: unit => t = "FormData"
@send external append: (t, string, 'a) => unit = "append"
@send external delete: (t, string) => unit = "delete"
@send external click: Dom.element => unit = "click"

type advanceFile = {
  file: Js.Json.t,
  fileName: string,
}

module FancyInput = {
  @react.component
  let make = (~children, ~onChange, ~inputRef) =>
    <div>
      <input
        type_="file" accept="image/*,.pdf" hidden=true onChange ref={inputRef->ReactDOM.Ref.domRef}
      />
      children
    </div>
}

@react.component
let make = (~buttonText, ~onFileUpload) => {
  let inputRef = React.useRef(Js.Nullable.null)

  let focusInput = () =>
    inputRef.current->Js.Nullable.toOption->Belt.Option.forEach(input => input->click)
  let onClick = _ => focusInput()

  let onChange = evt => {
    let target = ReactEvent.Form.target(evt)

    if target["files"]->Js.Array2.length > 0 {
      let file = target["files"]["0"]
      onFileUpload(file, file["name"])
    }
  }

  <div>
    <FancyInput inputRef onChange>
      <div className="">
        <Button text=buttonText onClick />
      </div>
    </FancyInput>
  </div>
}
