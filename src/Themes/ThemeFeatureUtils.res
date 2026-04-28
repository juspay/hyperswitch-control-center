let appendVersionParam = (url, ~version) => {
  switch version {
  | Some(v) if v->LogicUtils.isNonEmptyString => `${url}?version=${v}`
  | _ => url
  }
}

let getImgSrc = (url, ~themeConfigVersion) =>
  if url->String.startsWith("blob:") {
    url
  } else {
    appendVersionParam(url, ~version=themeConfigVersion)
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
    logo: dict->getOptionString("logoUrl")->Option.flatMap(toUrl),
    favicon: dict->getOptionString("faviconUrl")->Option.flatMap(toUrl),
  }
}

let buildThemeDataBody = (
  ~settings: HyperSwitchConfigTypes.themeSettings,
  ~urls: HyperSwitchConfigTypes.urlThemeConfig,
): JSON.t => {
  let body: ThemeUpdateType.themeUpdate = {
    theme_data: {settings, urls},
    email_config: None,
  }
  body->Identity.genericTypeToJson
}

let handleAssetFileSelect = (setAssets, key, ev) => {
  let files = ReactEvent.Form.target(ev)["files"]
  switch files->LogicUtils.getValueFromArray(0, None) {
  | Some(file) =>
    setAssets(prev => {
      let next = prev->Dict.copy
      next->Dict.set(key, file)
      next
    })
  | None => ()
  }
}

let handleAssetRemove = (setAssets, key) => {
  setAssets(prev => {
    prev->Dict.toArray->Array.filter(((k, _)) => k !== key)->Dict.fromArray
  })
}

let buildThemeDataBody = (
  ~settingsDict: Dict.t<JSON.t>,
  ~urlsDict: Dict.t<JSON.t>,
  ~emailConfigDict: option<Dict.t<JSON.t>>=?,
) => {
  open LogicUtils
  let themeDataEntries = [("settings", settingsDict->JSON.Encode.object)]
  if !(urlsDict->isEmptyDict) {
    themeDataEntries->Array.push(("urls", urlsDict->JSON.Encode.object))
  }
  let bodyEntries = [("theme_data", themeDataEntries->getJsonFromArrayOfJson)]
  switch emailConfigDict {
  | Some(dict) if !(dict->isEmptyDict) =>
    bodyEntries->Array.push(("email_config", dict->JSON.Encode.object))
  | _ => ()
  }
  bodyEntries->getJsonFromArrayOfJson
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
