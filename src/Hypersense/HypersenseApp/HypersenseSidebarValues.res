open SidebarTypes

let hypersenseConfiguration = {
  Link({
    name: "Home",
    link: `/v2/hypersense/home`,
    icon: "home",
    access: Access,
    selectedIcon: "home",
  })
}

let hypersenseSidebars = {
  [hypersenseConfiguration]
}
