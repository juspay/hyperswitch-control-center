type alertType = SUCCESS | WARNING | ERROR | PRIMARY | INFO | LIGHT
@react.component
let make = (~title, ~alertType: alertType, ~className="", ~bodystr=?, ~bodyBullets=false) => {
  let color = switch alertType {
  | LIGHT => "text-gray-900 bg-gray-100 border-gray-900"
  | SUCCESS => " bg-green-300 text-green-900 "
  | WARNING => " bg-yellow-200 text-yellow-900 "
  | ERROR => " bg-red-200 text-red-900 "
  | PRIMARY => " bg-blue-200 text-blue-900 "
  | _ => ""
  }

  let dot =
    <div
      className={`rounded-full bg-jp-gray-950   bg-opacity-70 `}
      style={ReactDOMStyle.make(~padding="2.5px", ())}
    />
  <div className={`${color} rounded-lg p-3 ${className}`}>
    <div className="font-semibold"> {React.string(title)} </div>
    {switch bodystr {
    | Some(text) =>
      <div className={`flex flex-col gap-1 mt-1 `}>
        {text
        ->Js.Array2.map(text => {
          <div className="flex flex-row gap-2 items-center">
            <div> {bodyBullets ? {dot} : React.null} </div>
            <div> {React.string(text)} </div>
          </div>
        })
        ->React.array}
      </div>
    | None => React.null
    }}
  </div>
}
