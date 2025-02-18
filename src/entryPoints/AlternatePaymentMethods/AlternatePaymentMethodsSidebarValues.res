open SidebarTypes

let altPaymentMethodsHome = {
  Link({
    name: "Home",
    link: `/v2/alt-payment-methods/home`,
    icon: "home",
    access: Access,
    searchOptions: [("Alt Payment Methods home", "")],
  })
}

let altPaymentMethodsSidebars = {
  [altPaymentMethodsHome]
}
