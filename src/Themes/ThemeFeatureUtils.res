open LogicUtils

let defaultEmailLogoUrl = `${GlobalVars.getHostUrl}/email-assets/HyperswitchLogo.png`

let appendVersionParam = (url, ~version) => {
  switch version {
  | Some(v) if v->isNonEmptyString => `${url}?version=${v}`
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
  files->getValueFromArray(0, None)
}

let maxAssetFileSizeBytes = 2 * 1024 * 1024

let isSupportedAssetType = (~fileName, ~accept) => {
  let lowerFileName = fileName->String.toLowerCase
  accept
  ->String.split(",")
  ->Array.some(ext => {
    let trimmedExt = ext->String.trim->String.toLowerCase
    trimmedExt->isNonEmptyString && lowerFileName->String.endsWith(trimmedExt)
  })
}

let assetsMapper = (dict): ThemeTypes.assets => {
  let toUrl = url => url->isNonEmptyString ? Some(ThemeTypes.Url(url)) : None
  {
    logo: dict->getOptionString("logoUrl")->Option.flatMap(toUrl),
    favicon: dict->getOptionString("faviconUrl")->Option.flatMap(toUrl),
    emailLogo: dict->getOptionString("emailLogoUrl")->Option.flatMap(toUrl),
  }
}

let getAssetDisplayUrl = (asset: option<ThemeTypes.assetValue>): option<string> =>
  asset->Option.map(value =>
    switch value {
    | Url(url) => url
    | File(file) =>
      DownloadUtils.createObjectURL((file->Identity.jsonToAnyType: DownloadUtils.blobInstanceType))
    }
  )

let buildThemeDataBody = (
  ~settings: HyperSwitchConfigTypes.themeSettings,
  ~urls: HyperSwitchConfigTypes.urlThemeConfig,
  ~emailConfig: HyperSwitchConfigTypes.emailConfig,
): JSON.t => {
  let body: ThemeUpdateType.themeUpdate = {
    theme_data: {settings, urls},
    email_config: emailConfig,
  }
  body->Identity.genericTypeToJson
}

let buildEmailConfigObject = (
  emailConfig: HyperSwitchConfigTypes.emailConfig,
  ~emailLogoUrl: option<string>,
): HyperSwitchConfigTypes.emailConfig => {
  let resolvedUrl = emailLogoUrl->Option.getOr(defaultEmailLogoUrl)

  {
    entity_name: emailConfig.entity_name,
    entity_logo_url: resolvedUrl,
    primary_color: emailConfig.primary_color,
    foreground_color: emailConfig.foreground_color,
    background_color: emailConfig.background_color,
  }
}

let entities: array<ThemeTypes.themeOption> = [
  {
    label: "Organization",
    value: "organization",
    icon: <Icon name="organization-entity" size=20 />,
    desc: "Applies the theme to all merchants and profiles",
  },
  {
    label: "Merchant",
    value: "merchant",
    icon: <Icon name="merchant-entity" size=20 />,
    desc: "Applies the theme to a specific merchant and its profiles",
  },
  {
    label: "Profile",
    value: "profile",
    icon: <Icon name="profile-entity" size=20 />,
    desc: "Applies the theme to a specific profile only",
  },
]
