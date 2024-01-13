type headingSize = XSmall | Small | Medium | Large
module NewThemeHeading: {
  @react.component
  let make: (
    ~heading: string,
    ~description: string=?,
    ~headingColor: string=?,
    ~descriptionColor: string=?,
    ~headingSize: headingSize=?,
    ~rightActions: React.element=?,
    ~headingRightElemnt: React.element=?,
    ~alignItems: string=?,
    ~outerMargin: string=?,
  ) => React.element
}

module Badge: {
  type color = Blue | Gray
  @react.component
  let make: (~number: int, ~color: color=?) => React.element
}
