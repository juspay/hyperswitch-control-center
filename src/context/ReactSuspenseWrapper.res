@react.component
let make = (~children, ~loadingText="Loading...") => {
  <React.Suspense fallback={<Loader loadingText />}> {children} </React.Suspense>
}
