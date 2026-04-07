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

type assetAction =
  | Unchanged
  | Updated({file: option<JSON.t>})

let processAssetAction = async (
  ~originalUrl: option<string>,
  ~action: assetAction,
  ~assetName: string,
  ~uploadFn: (~assetFile: option<JSON.t>, ~assetName: string) => promise<JSON.t>,
  ~themeId: string,
) => {
  let baseUrl = GlobalVars.getHostUrl
  let newAssetUrl = `${baseUrl}/themes/${themeId}/${assetName}`
  switch (originalUrl, action) {
  | (None, Unchanged) => None
  | (Some(existingUrl), Unchanged) => Some(existingUrl->JSON.Encode.string)
  | (Some(_), Updated({file: None})) => None
  | (_, Updated({file: Some(file)})) => {
      let _ = await uploadFn(~assetFile=Some(file), ~assetName)
      Some(newAssetUrl->JSON.Encode.string)
    }
  | _ => None
  }
}

let processAssets = async (
  ~logoAction: assetAction,
  ~faviconAction: assetAction,
  ~originalLogoUrl: option<string>,
  ~originalFaviconUrl: option<string>,
  ~uploadFn: (~assetFile: option<JSON.t>, ~assetName: string) => promise<JSON.t>,
  ~themeId: string,
) => {
  let urlsDict = Dict.make()

  let logoResult = await processAssetAction(
    ~originalUrl=originalLogoUrl,
    ~action=logoAction,
    ~assetName="logo.png",
    ~uploadFn,
    ~themeId,
  )
  switch logoResult {
  | Some(url) => urlsDict->Dict.set("logoUrl", url)
  | None => ()
  }

  let faviconResult = await processAssetAction(
    ~originalUrl=originalFaviconUrl,
    ~action=faviconAction,
    ~assetName="favicon.png",
    ~uploadFn,
    ~themeId,
  )
  switch faviconResult {
  | Some(url) => urlsDict->Dict.set("faviconUrl", url)
  | None => ()
  }

  urlsDict
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
