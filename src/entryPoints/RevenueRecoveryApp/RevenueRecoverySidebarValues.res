open SidebarTypes

let revenueRecoveryHome = {
  Link({
    name: "Home",
    link: `/v2/recovery/home`,
    access: Access,
    icon: "home",
  })
}

let revenueRecoveryPaymentProcessors = {
  Link({
    name: "Payment Processors",
    link: `/v2/recovery/payment-processors`,
    access: Access,
    icon: "payment",
  })
}

let revenueRecoveryBillingProcessors = {
  Link({
    name: "Billing Processors",
    link: `/v2/recovery/billing-processors`,
    access: Access,
    icon: "billing",
  })
}

let revenueRecoveryPayments = {
  Link({
    name: "Payments",
    link: `/v2/recovery/payments`,
    access: Access,
    icon: "payments",
  })
}

let recoverySidebars = {
  let links = [
    revenueRecoveryHome,
    revenueRecoveryPayments,
    revenueRecoveryPaymentProcessors,
    revenueRecoveryBillingProcessors,
  ]

  links
}
