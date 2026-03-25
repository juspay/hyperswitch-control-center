open LazyUtils

type props = {
  source: string,
  style?: ReactDOM.Style.t,
}

let make: props => React.element = reactLazy(() => import_("@uiw/react-markdown-preview"))

module MdPreview = {
  let make = make
}
