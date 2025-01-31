open SidebarTypes

let vaultConfiguration = {
  Link({
    name: "Configuration",
    link: `v2/vault/configuration`,
    icon: "home",
    access: Access,
    searchOptions: [("Vault home", ""), ("Vault configuration", "")],
  })
}

let vaultCustomersAndTokens = {
  Link({
    name: "Customers & Tokens",
    link: `v2/vault/customers-tokens`,
    icon: "home",
    access: Access,
    searchOptions: [("Vault customers", ""), ("Vault tokens", "")],
  })
}

let vaultSidebars = {
  [vaultConfiguration, vaultCustomersAndTokens]
}
