type props = {
  isHorizontal?: bool,
  listItems: array<JSON.t>,
  setListItems: (array<JSON.t> => array<JSON.t>) => unit,
  keyExtractor: JSON.t => option<string>,
}

let default: props => React.element
