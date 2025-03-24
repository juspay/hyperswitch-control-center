open SidebarTypes

let vaultConfiguration = {
  Link({
    name: "Configuration",
    link: `/v2/vault/onboarding`,
    icon: "nd-overview",
    access: Access,
    searchOptions: [("Vault configuration", "")],
    selectedIcon: "nd-overview-fill",
  })
}

let vaultCustomersAndTokens = {
  Link({
    name: "Customers & Tokens",
    link: `/v2/vault/customers-tokens`,
    icon: "nd-vault-customers",
    access: Access,
    searchOptions: [("Vault customers", ""), ("Vault tokens", "")],
    selectedIcon: "nd-vault-customers-fill",
  })
}
let vaultHome = {
  Link({
    name: "Home",
    link: `/v2/vault/home`,
    icon: "home",
    access: Access,
    searchOptions: [("Vault home", "")],
    selectedIcon: "home",
  })
}

let vaultSidebars = {
  [vaultHome, vaultConfiguration, vaultCustomersAndTokens]
}
