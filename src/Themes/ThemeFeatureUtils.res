let appendVersionParam = (url, ~version) => {
  switch version {
  | Some(v) if v->LogicUtils.isNonEmptyString => `${url}?version=${v}`
  | _ => url
  }
}

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

let getFileFromEvent = ev => {
  let files = ReactEvent.Form.target(ev)["files"]
  files->LogicUtils.getValueFromArray(0, None)
}

let assetsMapper = (dict): ThemeTypes.assets => {
  open LogicUtils
  let toUrl = url => url->isNonEmptyString ? Some(ThemeTypes.Url(url)) : None
  {
    logo: switch dict->getOptionString("logoUrl") {
    | Some(url) => toUrl(url)
    | None => None
    },
    favicon: switch dict->getOptionString("faviconUrl") {
    | Some(url) => toUrl(url)
    | None => None
    },
  }
}

let buildThemeDataBody = (~settingsDict: Dict.t<JSON.t>, ~urlsDict: Dict.t<JSON.t>) => {
  open LogicUtils
  let themeDataEntries = [("settings", settingsDict->JSON.Encode.object)]
  if !(urlsDict->isEmptyDict) {
    themeDataEntries->Array.push(("urls", urlsDict->JSON.Encode.object))
  }
  [("theme_data", themeDataEntries->getJsonFromArrayOfJson)]->getJsonFromArrayOfJson
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
