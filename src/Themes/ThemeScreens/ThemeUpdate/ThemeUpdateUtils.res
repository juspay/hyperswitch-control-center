open ThemeCreateType
open LogicUtils

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
  try {
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
  } catch {
  | Exn.Error(_) as err => raise(err)
  }
}

let themeBodyMapper = (json: JSON.t): themeUpdate => {
  let dict = getDictFromJsonObject(json)
  let theme_name = getString(dict, "theme_name", "")
  let themeDataJson = getJsonObjectFromDict(dict, "theme_data")->ThemeProvider.parseThemeJson
  let theme_data = themeDataJson
  let emailConfigJson = dict->getvalFromDict("email_config")
  let email_config: option<HyperSwitchConfigTypes.emailConfig> = switch emailConfigJson {
  | Some(emailJson) => {
      let emailDict = getDictFromJsonObject(emailJson)
      Some({
        entity_name: getString(emailDict, "entity_name", ""),
        entity_logo_url: getString(emailDict, "entity_logo_url", ""),
        primary_color: getString(emailDict, "primary_color", ""),
        foreground_color: getString(emailDict, "foreground_color", ""),
        background_color: getString(emailDict, "background_color", ""),
      })
    }
  | None => None
  }
  {
    theme_name,
    theme_data,
    email_config,
  }
}
