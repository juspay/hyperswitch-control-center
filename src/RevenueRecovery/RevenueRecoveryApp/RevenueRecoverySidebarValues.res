open SidebarTypes

let defaultPath = "/v2/recovery/invoices"

let revenueRecoveryHome = {
  Link({
    name: "Home",
    link: `/v2/recovery`,
    access: Access,
    icon: "nd-home",
  })
}

let revenueRecoveryInvoices = {
  Link({
    name: "Invoices",
    link: `/v2/recovery/invoices`,
    access: Access,
    icon: "nd-operations",
  })
}

let revenueRecoverySummary = {
  Link({
    name: "Configuration Details",
    link: `/v2/recovery/summary`,
    access: Access,
    icon: "nd-connectors",
  })
}

let recoverySidebars = _isLiveMode => {
  [revenueRecoveryInvoices, revenueRecoverySummary]
}
