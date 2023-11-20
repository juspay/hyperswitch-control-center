let restrictedClass = "sm:w-10 md:w-20 w-40 "
let context = React.createContext(restrictedClass)

module Provider = {
  let make = React.Context.provider(context)
}

@react.component
let make = (~children, ~restrictedClass) => {
  <Provider value={restrictedClass}> {children} </Provider>
}
