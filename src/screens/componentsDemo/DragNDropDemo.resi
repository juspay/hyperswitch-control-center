type props = {
  isHorizontal?: bool,
  listItems: array<Js.Json.t>,
  setListItems: (array<Js.Json.t> => array<Js.Json.t>) => unit,
  keyExtractor: Js.Json.t => option<string>,
}

let default: props => React.element
