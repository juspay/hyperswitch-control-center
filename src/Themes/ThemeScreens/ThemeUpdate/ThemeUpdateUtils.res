open ThemeCreateType

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

let themeDataJsonMapper = (uiConfg: JSON.t): HyperSwitchConfigTypes.customStylesTheme => {
  open LogicUtils
  let dict = uiConfg->getDictFromJsonObject
  let settings = dict->getDictfromDict("settings")
  let url = dict->getDictfromDict("urls")
  let colorsConfig = settings->getDictfromDict("colors")
  let sidebarConfig = settings->getDictfromDict("sidebar")
  let typography = settings->getDictfromDict("typography")
  let borders = settings->getDictfromDict("borders")
  let spacing = settings->getDictfromDict("spacing")
  let colorsBtnPrimary = settings->getDictfromDict("buttons")->getDictfromDict("primary")
  let colorsBtnSecondary = settings->getDictfromDict("buttons")->getDictfromDict("secondary")
  let {settings: defaultSettings, _} = ThemeProvider.fallbackThemeConfig
  {
    settings: {
      colors: {
        primary: colorsConfig->getString("primary", defaultSettings.colors.primary),
        secondary: colorsConfig->getString("secondary", defaultSettings.colors.secondary),
        background: colorsConfig->getString("background", defaultSettings.colors.background),
      },
      sidebar: {
        primary: sidebarConfig->getString("primary", defaultSettings.sidebar.primary),
        textColor: sidebarConfig->getString("textColor", defaultSettings.sidebar.textColor),
        textColorPrimary: sidebarConfig->getString(
          "textColorPrimary",
          defaultSettings.sidebar.textColorPrimary,
        ),
      },
      typography: {
        fontFamily: typography->getString("fontFamily", defaultSettings.typography.fontFamily),
        fontSize: typography->getString("fontSize", defaultSettings.typography.fontSize),
        headingFontSize: typography->getString(
          "headingFontSize",
          defaultSettings.typography.headingFontSize,
        ),
        textColor: typography->getString("textColor", defaultSettings.typography.textColor),
        linkColor: typography->getString("linkColor", defaultSettings.typography.linkColor),
        linkHoverColor: typography->getString(
          "linkHoverColor",
          defaultSettings.typography.linkHoverColor,
        ),
      },
      buttons: {
        primary: {
          backgroundColor: colorsBtnPrimary->getString(
            "backgroundColor",
            defaultSettings.buttons.primary.backgroundColor,
          ),
          textColor: colorsBtnPrimary->getString(
            "textColor",
            defaultSettings.buttons.primary.textColor,
          ),
          hoverBackgroundColor: colorsBtnPrimary->getString(
            "hoverBackgroundColor",
            defaultSettings.buttons.primary.hoverBackgroundColor,
          ),
        },
        secondary: {
          backgroundColor: colorsBtnSecondary->getString(
            "backgroundColor",
            defaultSettings.buttons.secondary.backgroundColor,
          ),
          textColor: colorsBtnSecondary->getString(
            "textColor",
            defaultSettings.buttons.secondary.textColor,
          ),
          hoverBackgroundColor: colorsBtnSecondary->getString(
            "hoverBackgroundColor",
            defaultSettings.buttons.secondary.hoverBackgroundColor,
          ),
        },
      },
      borders: {
        defaultRadius: borders->getString("defaultRadius", defaultSettings.borders.defaultRadius),
        borderColor: borders->getString("borderColor", defaultSettings.borders.borderColor),
      },
      spacing: {
        padding: spacing->getString("padding", defaultSettings.spacing.padding),
        margin: spacing->getString("margin", defaultSettings.spacing.margin),
      },
    },
    urls: {
      faviconUrl: url->getOptionString("faviconUrl"),
      logoUrl: url->getOptionString("logoUrl"),
    },
  }
}

let themeBodyMapper = (json: JSON.t): themeUpdate => {
  let dict = LogicUtils.getDictFromJsonObject(json)
  let theme_name = LogicUtils.getString(dict, "theme_name", "")
  let themeDataJson = LogicUtils.getJsonObjectFromDict(dict, "theme_data")->themeDataJsonMapper
  let theme_data = themeDataJson
  let emailConfigJson = dict->LogicUtils.getvalFromDict("email_config")
  let email_config: option<HyperSwitchConfigTypes.emailConfig> = switch emailConfigJson {
  | Some(emailJson) => {
      let emailDict = LogicUtils.getDictFromJsonObject(emailJson)
      Some({
        entity_name: LogicUtils.getString(emailDict, "entity_name", ""),
        entity_logo_url: LogicUtils.getString(emailDict, "entity_logo_url", ""),
        primary_color: LogicUtils.getString(emailDict, "primary_color", ""),
        foreground_color: LogicUtils.getString(emailDict, "foreground_color", ""),
        background_color: LogicUtils.getString(emailDict, "background_color", ""),
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
