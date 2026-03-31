@react.component
let make = (~input: ReactFinalForm.fieldRenderPropsInput) => {
  let isBlendEnabled = React.useContext(BlendContext.blendEnabledContext)
  let currentValue = input.value->LogicUtils.getStringFromJson("")

  if isBlendEnabled {
    <RadioBinding.Group
      name={input.name}
      value={currentValue}
      onChange={val => input.onChange(val->Identity.stringToFormReactEvent)}>
      <div className="flex items-center gap-5">
        <RadioBinding value="yes"> {"Yes"->React.string} </RadioBinding>
        <RadioBinding value="no"> {"No"->React.string} </RadioBinding>
      </div>
    </RadioBinding.Group>
  } else {
    <div className="flex items-center gap-5">
      <div className="flex items-center gap-2">
        <input
          name={input.name}
          label="Yes"
          value="yes"
          type_="radio"
          checked={input.value == "yes"->JSON.Encode.string}
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
          checked={input.value == "no"->JSON.Encode.string}
          onChange=input.onChange
        />
        <label className="text-sm text-jp-gray-800"> {"No"->React.string} </label>
      </div>
    </div>
  }
}
