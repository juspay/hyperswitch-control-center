@react.component
let make = () => {
  <RestrictedWidthProvider restrictedClass="">
    {<>
      <h1> {React.string("Hello")} </h1>
    </>}
  </RestrictedWidthProvider>
}
