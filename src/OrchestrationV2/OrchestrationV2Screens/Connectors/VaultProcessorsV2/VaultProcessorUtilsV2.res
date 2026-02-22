open VaultProcessorTypesV2
open VerticalStepIndicatorTypes

let vaultConnectorName = "hyperswitch_vault"

let sections = [
  {
    id: (#configureVault: vaultProcessorSectionsV2 :> string),
    name: "Configure Vault",
    icon: "nd-shield",
    subSections: None,
  },
]

let stringToSectionVariantMapper = string => {
  switch string {
  | "configureVault" => #configureVault
  | _ => #configureVault
  }
}

let getSectionVariant = ({sectionId}) => {
  switch sectionId {
  | "configureVault" | _ => #ConfigureVault
  }
}

let getVaultProcessorMixPanelEvent = currentStep => {
  switch currentStep->getSectionVariant {
  | #ConfigureVault => "orchestration_v2_vault_onboarding_step1"
  }
}

let getConnectorConfig = () => {
  {
    "connector_auth": {
      "SignatureKey": {
        "api_key": "API Key",
        "api_secret": "API Secret",
        "key1": "Key1",
      },
    },
  }->Identity.genericTypeToJson
}
