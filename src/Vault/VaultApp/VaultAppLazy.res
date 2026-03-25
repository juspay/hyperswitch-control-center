open LazyUtils

type props = {}

let make: props => React.element = reactLazy(() => import_("./VaultApp.res.js"))
