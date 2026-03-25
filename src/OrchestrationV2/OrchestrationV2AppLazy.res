open LazyUtils

type props = {}

let make: props => React.element = reactLazy(() => import_("./OrchestrationV2App.res.js"))
