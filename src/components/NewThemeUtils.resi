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
module Section: {
  @react.component
  let make: (
    ~heading: string,
    ~subheading: string,
    ~children: React.element,
    ~outerMargin: string=?,
    ~rightHeadingElement: React.element=?,
  ) => React.element
}
module HeadlessSection: {
  @react.component
  let make: (~children: React.element) => React.element
}
module FloatingActions: {
  @react.component
  let make: (~children: React.element) => React.element
}

module Badge: {
  type color = Blue | Gray
  @react.component
  let make: (~number: int, ~color: color=?) => React.element
}
