open SidebarTypes

let revenueRecoveryHome = {
  Link({
    name: "Home",
    link: `/v2/recovery`,
    access: Access,
    icon: "nd-home",
  })
}

let revenueRecoveryPayments = {
  Link({
    name: "Overview",
    link: `/v2/recovery/overview`,
    access: Access,
    icon: "nd-operations",
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

let recoverySidebars = {
  let links = [revenueRecoveryInvoices, revenueRecoverySummary]

  if "recovery"->LogicUtils.isEmptyString {
    links->Array.unshift(revenueRecoveryPayments)
  }

  links
}
