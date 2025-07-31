module CustomNumeric = {
  @react.component
  let make = (~num: float, ~mapper, ~customStyling) => {
    <div className={customStyling}> {React.string(num->mapper)} </div>
  }
}
