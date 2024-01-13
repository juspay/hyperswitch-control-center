module JsonBox = {
  @react.component
  let make = (~json) => {
    <div
      className="flex-1 border border-purple-500 m-2  overflow-scroll whitespace-pre font-fira-code">
      {json->Js.Json.stringifyWithSpace(2)->React.string}
    </div>
  }
}

@val @scope(("window", "location")) external hostname: string = "hostname"

@react.component
let make = (~wrapperClass="", ~jsonModifier=?, ~restrictToLocal=true, ~displayProps=true) => {
  let subs = ReactFinalForm.useFormSubscription(["values"])

  let canRender = if restrictToLocal {
    hostname === "localhost"
  } else {
    true
  }

  if canRender {
    <div className={`${wrapperClass} flex flex-col overflow-hidden`}>
      <ReactFinalForm.FormSpy subscription=subs>
        {props => {
          <>
            {if displayProps {
              <JsonBox json=props.values />
            } else {
              React.null
            }}
            {switch jsonModifier {
            | Some(modifierFn) => <JsonBox json={modifierFn(props.values)} />
            | None => React.null
            }}
          </>
        }}
      </ReactFinalForm.FormSpy>
    </div>
  } else {
    React.null
  }
}
