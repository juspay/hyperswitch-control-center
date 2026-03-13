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
let themeSublevelLinks = (~userHasResourceAccess) => {
  SubLevelLink({
    name: "Theme",
    link: `/theme`,
    access: userHasResourceAccess(~resourceAccess=Theme),
    searchOptions: [("View theme", "")],
  })
}

let themeSidebars = {
  let sidebar = [themeTopLevelLink]
  sidebar
}
