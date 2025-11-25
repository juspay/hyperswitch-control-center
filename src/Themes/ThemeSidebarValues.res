open SidebarTypes
open UserManagementTypes

let theme = (~userHasAccess) => {
  Link({
    name: "Theme",
    link: `/theme`,
    access: userHasAccess(~groupAccess=ThemeView),
    icon: "nd-overview",
    selectedIcon: "nd-overview-fill",
  })
}

let themeSidebars = {
  let sidebar = [theme]
  sidebar
}
