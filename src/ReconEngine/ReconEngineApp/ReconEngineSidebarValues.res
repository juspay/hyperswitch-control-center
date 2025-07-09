open SidebarTypes

let reconOverview = {
  Link({
    name: "Overview",
    link: `/v2/recon-engine/overview`,
    access: Access,
    icon: "nd-overview",
    selectedIcon: "nd-overview-fill",
  })
}

let reconTransactions = {
  Link({
    name: "Transactions",
    link: `/v2/recon-engine/transactions`,
    access: Access,
    icon: "",
  })
}

let reconExceptions = {
  Link({
    name: "Recon Exceptions",
    link: `/v2/recon-engine/exceptions`,
    access: Access,
    icon: "",
  })
}

let reconQueue = {
  Link({
    name: "Recon Queue",
    link: `/v2/recon-engine/queue`,
    access: Access,
    icon: "",
  })
}

let reconRuleCreation = {
  Link({
    name: "Recon Rule Creation",
    link: `/v2/recon-engine/rules`,
    access: Access,
    icon: "",
  })
}
let reconEngineSidebars = {
  let sidebar = [reconOverview, reconTransactions, reconExceptions, reconQueue, reconRuleCreation]
  sidebar
}
