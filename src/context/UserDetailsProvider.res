type defaultContextValues = {
  name: string,
  setName: (string => string) => unit,
  email: string,
  setEmail: (string => string) => unit,
}

let defaultUserDetailsContext = {
  name: "",
  setName: _ => (),
  email: "",
  setEmail: _ => (),
}

let userDetailsContext = React.createContext(defaultUserDetailsContext)

module UserDetails = {
  let make = React.Context.provider(userDetailsContext)
}

@react.component
let make = (~children) => {
  let (name, setName) = React.useState(_ => "")
  let (email, setEmail) = React.useState(_ => "")

  let value = {name, setName, email, setEmail}

  <UserDetails value> children </UserDetails>
}
