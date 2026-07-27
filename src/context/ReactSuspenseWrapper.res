@react.component
let make = (~children, ~loadingText=Loading.loading) => {
  <React.Suspense fallback={<Loader loadingText />}>
    <ErrorBoundary> children </ErrorBoundary>
  </React.Suspense>
}
