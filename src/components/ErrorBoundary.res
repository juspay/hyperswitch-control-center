/*
 ? Reference - https://github.com/rescript-lang/rescript-react/blob/master/src/RescriptReactErrorBoundary.res
 */

let defaultFallback = _ =>
  <div className="text-red-600 font-bold text-center flex flex-col items-center">
    {"An error occured"->React.string}
    <Button text="reset" buttonType=Primary onClick={_ => Window.Location.reload()} />
  </div>

@react.component
let make = (~children, ~renderFallback=defaultFallback) => {
  <RescriptReactErrorBoundary fallback={renderFallback}> {children} </RescriptReactErrorBoundary>
}
