open LazyUtils

type props = {
  isHorizontal: option<bool>,
  keyExtractor: Js.Json.t => option<string>,
  listItems: array<Js.Json.t>,
  setListItems: (array<Js.Json.t> => array<Js.Json.t>) => unit,
}
let make: props => React.element = reactLazy(.() => import_("./DragNDropDemo.bs.js"))
