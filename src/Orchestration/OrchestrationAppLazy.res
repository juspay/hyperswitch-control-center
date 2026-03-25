open LazyUtils

type props = {
  setScreenState: (PageLoaderWrapper.viewType => PageLoaderWrapper.viewType) => unit,
}

let make: props => React.element = reactLazy(() => import_("./OrchestrationApp.res.js"))
