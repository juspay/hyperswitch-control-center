open LazyUtils

type props = {
  isHorizontal: option<bool>,
  keyExtractor: JSON.t => option<string>,
  listItems: array<JSON.t>,
  setListItems: (array<JSON.t> => array<JSON.t>) => unit,
}
let make: props => React.element = reactLazy(.() => import_("./DragNDropDemo.bs.js"))
