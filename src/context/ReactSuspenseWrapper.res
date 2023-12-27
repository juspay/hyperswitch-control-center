@react.component
let make = (~children, ~loadingText="Loading...") => {
  <React.Suspense fallback={<Loader loadingText />}>
    <ErrorBoundary> children </ErrorBoundary>
  </React.Suspense>
}
