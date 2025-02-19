open SidebarTypes

let vaultHome = {
  Link({
    name: "Configuration",
    link: `/v2/vault/home`,
    icon: "nd-overview",
    access: Access,
    searchOptions: [("Vault home", ""), ("Vault configuration", "")],
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

let vaultSidebars = {
  [vaultHome, vaultCustomersAndTokens]
}
