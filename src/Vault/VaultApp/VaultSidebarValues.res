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
    name: "Overview",
    link: `/v2/vault/home`,
    icon: "home",
    access: Access,
    searchOptions: [("Vault home", ""), ("Vault overview", "")],
    selectedIcon: "home",
  })
}

let vaultAPIKeys = {
  Link({
    name: "API Keys",
    link: `/v2/vault/api-keys`,
    icon: "nd-api-keys",
    access: Access,
    searchOptions: [("Vault API keys", "")],
    selectedIcon: "nd-api-keys",
  })
}

let vaultSidebars = {
  [vaultHome, vaultConfiguration, vaultCustomersAndTokens, vaultAPIKeys]
}
