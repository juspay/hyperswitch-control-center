open SidebarTypes
open UserManagementTypes

let themeTopLevelLink = (~userHasAccess) => {
  Link({
    name: "Theme",
    link: `/theme`,
    access: userHasAccess(~groupAccess=ThemeView),
    icon: "nd-overview",
    selectedIcon: "nd-overview-fill",
  })
}
let themeSublevelLinks = (~userHasAccess) => {
  SubLevelLink({
    name: "Theme",
    link: `/theme`,
    access: userHasAccess(~groupAccess=ThemeView),
    searchOptions: [("View theme", "")],
  })
}

let themeSidebars = {
  let sidebar = [themeTopLevelLink]
  sidebar
}
