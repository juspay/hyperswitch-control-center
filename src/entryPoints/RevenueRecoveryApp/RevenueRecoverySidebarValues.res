open SidebarTypes

let revenueRecoveryHome = {
  Link({
    name: "Home",
    link: `/v2/recovery`,
    access: Access,
    icon: "nd-home",
  })
}

let revenueRecoveryPaymentProcessors = {
  Link({
    name: "Connectors",
    link: `/v2/recovery/connectors`,
    access: Access,
    icon: "nd-connectors",
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

let recoverySidebars = {
  let links = [revenueRecoveryPayments, revenueRecoveryPaymentProcessors]

  links
}
