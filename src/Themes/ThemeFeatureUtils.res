let getStepVariantfromString = (stepString: string): ThemeTypes.lineageSelectionSteps => {
  switch stepString {
  | "entityselection" => EntitySelection
  | "orgview" => OrgView
  | "merchantlevelconfig" => MerchantLevelConfig
  | "profilelevelconfig" => ProfileLevelConfig
  | _ => EntitySelection
  }
}

let getEntityTypeFromStep = (stepVariant: ThemeTypes.lineageSelectionSteps) =>
  switch stepVariant {
  | OrgView => "organization"
  | MerchantLevelConfig => "merchant"
  | ProfileLevelConfig => "profile"
  | _ => ""
  }

let entities: array<ThemeTypes.themeOption> = [
  {
    label: "Organization",
    value: "organization",
    icon: <Icon name="organization-entity" size=20 />,
    desc: "Change themes to all merchants and profiles",
  },
  {
    label: "Merchant",
    value: "merchant",
    icon: <Icon name="merchant-entity" size=20 />,
    desc: "Change themes to specific merchant and its profiles",
  },
  {
    label: "Profile",
    value: "profile",
    icon: <Icon name="profile-entity" size=20 />,
    desc: "Change themes to specific profile only",
  },
]
