let defaultFallback = ({resetError}: Sentry.ErrorBoundary.fallbackArg) => {
  <div className="text-red-600 font-bold text-center flex flex-col items-center">
    {"An error occured"->React.string}
    <Button text="reset" buttonType=Primary onClick={_ev => resetError()} />
  </div>
}

@react.component
let make = (~children, ~renderFallback=defaultFallback) => {
  <Sentry.ErrorBoundary fallback=renderFallback> children </Sentry.ErrorBoundary>
}
