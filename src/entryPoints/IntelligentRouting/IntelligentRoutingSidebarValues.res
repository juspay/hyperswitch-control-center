open SidebarTypes

let intelligentRoutingHome = {
  Link({
    name: "Configuration",
    link: `/v2/dynamic-routing`,
    icon: "nd-overview",
    access: Access,
    searchOptions: [("Intelligent Routing home", ""), ("Intelligent Routing configuration", "")],
    selectedIcon: "nd-overview-fill",
  })
}

let intelligentRoutingSidebars = {
  [intelligentRoutingHome]
}
