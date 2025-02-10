open SidebarTypes

let vaultHome = {
  Link({
    name: "Configuration",
    link: `/v2/vault/home`,
    icon: "home",
    access: Access,
    searchOptions: [("Vault home", ""), ("Vault configuration", "")],
  })
}

let vaultCustomersAndTokens = {
  Link({
    name: "Customers & Tokens",
    link: `/v2/vault/customers-tokens`,
    icon: "home",
    access: Access,
    searchOptions: [("Vault customers", ""), ("Vault tokens", "")],
  })
}

let vaultSidebars = {
  [vaultHome, vaultCustomersAndTokens]
}
