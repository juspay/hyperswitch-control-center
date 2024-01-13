type lazyScreen

type lazyScreenLoader = unit => promise<lazyScreen>

@val
external import_: string => promise<lazyScreen> = "import"

type reactLazy<'component> = (. lazyScreenLoader) => 'component

@module("react") @val
external reactLazy: reactLazy<'a> = "lazy"
