@react.component
let make = (~input: ReactFinalForm.fieldRenderPropsInput) => {
  <div className="flex items-center gap-5">
    <div className="flex items-center gap-2">
      <input
        name={input.name}
        label="Yes"
        value="yes"
        type_="radio"
        checked={input.value == "yes"->Js.Json.string}
        onChange=input.onChange
      />
      <label className="text-sm text-jp-gray-800"> {"Yes"->React.string} </label>
    </div>
    <div className="flex items-center gap-2">
      <input
        name={input.name}
        label="No"
        value="no"
        type_="radio"
        checked={input.value == "no"->Js.Json.string}
        onChange=input.onChange
      />
      <label className="text-sm text-jp-gray-800"> {"No"->React.string} </label>
    </div>
  </div>
}
