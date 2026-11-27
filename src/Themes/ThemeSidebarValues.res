open SidebarTypes
open UserManagementTypes

let themeTopLevelLink = (~userHasResourceAccess) => {
  Link({
    name: "Theme",
    link: `/theme`,
    access: userHasResourceAccess(~resourceAccess=Theme),
    icon: "nd-overview",
    selectedIcon: "nd-overview-fill",
  })
}

let themeSidebars = {
  let sidebar = [themeTopLevelLink]
  sidebar
}
