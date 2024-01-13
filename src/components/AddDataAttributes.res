let spreadProps = React.cloneElement

@react.component
let make = (~attributes: array<(string, string)>, ~children) => {
  let attributesDict = attributes->Dict.fromArray
  let ignoreAttributes = React.useContext(AddAttributesContext.ignoreAttributesContext)

  if !ignoreAttributes {
    children->spreadProps(attributesDict)
  } else {
    children
  }
}
