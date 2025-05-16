open SidebarTypes

let hypersenseConfiguration = {
  Link({
    name: "Overview",
    link: `/v2/cost-observability/home`,
    icon: "home",
    access: Access,
    searchOptions: [("Cost observability overview", ""),("Cost observability home", "")],
    selectedIcon: "home",
  })
}

let hypersenseSidebars = {
  [hypersenseConfiguration]
}
