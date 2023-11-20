module ButtonWrapper = {
  let makeInfoRecord = (~isFirst, ~isLast): ButtonGroupContext.buttonInfo => {
    {isFirst, isLast}
  }

  @react.component
  let make = (~element, ~count, ~index) => {
    let isFirst = index === 0
    let isLast = index === count - 1
    let value = React.useMemo2(() => makeInfoRecord(~isFirst, ~isLast), (isFirst, isLast))
    <ButtonGroupContext.Parent value> element </ButtonGroupContext.Parent>
  }
}

@react.component
let make = (~children, ~wrapperClass="flex flex-row") => {
  let count = children->React.Children.count
  <div className=wrapperClass>
    {children->React.Children.mapWithIndex((element, index) => {
      <ButtonWrapper element count index />
    })}
  </div>
}
