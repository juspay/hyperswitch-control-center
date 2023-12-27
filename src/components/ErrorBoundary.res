let defaultFallback =
  <div className="text-red-600 font-bold text-center flex flex-col items-center h-screen w-screen">
    {"An error occured"->React.string}
    <Button text="reset" buttonType=Primary onClick={_ => Window.Location.reload()} />
  </div>

@react.component
let make = (~children, ~renderFallback=defaultFallback) => {
  <RescriptReactErrorBoundary fallback={params => renderFallback}>
    {children}
  </RescriptReactErrorBoundary>
}
