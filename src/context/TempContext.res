type temp = {newVal: string}
let defaultSetter = (_: temp) => ()

let tempContext = React.createContext(({newVal: ""}, defaultSetter))

module Provider = {
  let make = React.Context.provider(tempContext)
}
@react.component
let make = (~children) => {
  let (state, setState) = React.useState(_ => {newVal: ""})
  let setSideBarObj = React.useCallback1(val => {
    setState(_ => val)
  }, [setState])

  <Provider value=(state, setSideBarObj)> children </Provider>
}
