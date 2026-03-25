open LazyUtils

type props = {
  value?: string,
  style?: string,
  size?: int,
  viewBox?: string,
}

let make: props => React.element = reactLazy(() => import_("react-qr-code"))
