open SidebarTypes

let revenueRecoveryHome = {
  SubLevelLink({
    name: "Home",
    link: `v2/recovery/home`,
    access: Access,
    searchOptions: [("Recovery home", "")],
  })
}

let revenueRecoveryPaymentProcessors = {
  SubLevelLink({
    name: "Payment Processors",
    link: `v2/recovery/payment-processors`,
    access: Access,
    searchOptions: [("Payment Processors", "")],
  })
}

let revenueRecoveryBillingProcessors = {
  SubLevelLink({
    name: "Billing Processors",
    link: `v2/recovery/billing-processors`,
    access: Access,
    searchOptions: [("Billing Processors", "")],
  })
}

let revenueRecoveryPayments = {
  SubLevelLink({
    name: "Payments",
    link: `v2/recovery/payments`,
    access: Access,
    searchOptions: [("Payments", "")],
  })
}

let recoverySidebars = {
  let links = [
    revenueRecoveryHome,
    revenueRecoveryPayments,
    revenueRecoveryPaymentProcessors,
    revenueRecoveryBillingProcessors,
  ]

  Section({
    name: "Recovery",
    icon: "v2/recovery",
    showSection: true,
    links,
  })
}
