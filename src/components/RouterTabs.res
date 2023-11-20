type routeTab = {
  title: string,
  route: string,
  access: AuthTypes.authorization,
}

let getDefaultIndex = routes => {
  let currPath = RescriptReactRouter.useUrl().path
  let urlArr = []
  currPath->Js.List.iter((. str) => urlArr->Js.Array2.push(str)->ignore, _)
  let urlStr = `/${urlArr->Js.Array2.joinWith("/")}`

  let (_, index) = routes->Js.Array2.reducei((acc, {route}, i) => {
    let route = route->Js.String2.split("?")->Belt.Array.get(0)->Belt.Option.getWithDefault(route)
    let (oldDiff, _) = acc
    let diff = urlStr->Js.String2.length - route->Js.String2.length

    urlStr->Js.String2.includes(route) && diff < oldDiff ? (diff, i) : acc
  }, (urlStr->Js.String2.length, 0))

  index
}

@react.component
let make = (
  ~routeTabs as allRouteTabs: array<routeTab>,
  ~isScrollIntoViewRequired=false,
  ~lightThemeColor: string="blue-800",
  ~showBorder: bool=true,
  ~backgroundStyle: string="bg-gradient-to-b",
  ~tabContainerClass="",
  ~bottomMargin=?,
) => {
  let urlPrefix = LogicUtils.useUrlPrefix()
  let routeTabs = allRouteTabs->Js.Array2.filter(routeTab => {
    routeTab.access !== NoAccess
  })

  let defaultIndex = getDefaultIndex(routeTabs)

  let (initialIndex, setInitialIndex) = React.useState(() => defaultIndex)

  React.useEffect1(() => {
    setInitialIndex(_ => defaultIndex)
    None
  }, [defaultIndex])

  let tabs = routeTabs->Js.Array2.map((routeTab): Tabs.tab => {
    {title: routeTab.title, renderContent: () => React.null}
  })

  <Tabs
    tabs
    isScrollIntoViewRequired
    lightThemeColor
    showBorder
    backgroundStyle
    ?bottomMargin
    initialIndex={initialIndex >= 0 ? initialIndex : 0}
    onTitleClick={i => {
      switch routeTabs->Belt.Array.get(i) {
      | Some(routeTab) => RescriptReactRouter.push(`${urlPrefix}${routeTab.route}`)
      | None => ()
      }
    }}
    tabContainerClass
  />
}
