open LazyUtils

type props = {
  url: string,
  className?: string,
  loading?: React.element,
  error?: React.element,
}

let make: props => React.element = reactLazy(.() => import_("./ReactPDFViewerPagination.bs.js"))
