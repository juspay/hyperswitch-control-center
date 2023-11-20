open LazyUtils

type props = {
  url: string,
  width?: int,
  height?: int,
  className?: string,
  loading?: React.element,
  error?: React.element,
}

let make: props => React.element = reactLazy(.() => import_("./ReactPDFViewerSinglePage.bs.js"))
