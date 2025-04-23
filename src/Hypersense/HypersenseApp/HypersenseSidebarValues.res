open SidebarTypes

let hypersenseConfiguration = {
  Link({
    name: "Home",
    link: `/v2/cost-observability/home`,
    icon: "home",
    access: Access,
    selectedIcon: "home",
  })
}

let hypersenseSidebars = {
  [hypersenseConfiguration]
}
