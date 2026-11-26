open ThemeTypes
open HyperSwitchConfigTypes
open ThemeProvider

type themeCreateTypography = {fontFamily: string}

type themeCreateSettings = {
  colors: colorPalette,
  sidebar: sidebarConfig,
  buttons: buttonConfig,
  typography: themeCreateTypography,
}

type themeCreateData = {settings: themeCreateSettings}

type themeCreate = {
  entity_type: string,
  tenant_id: string,
  org_id: option<string>,
  merchant_id: option<string>,
  profile_id: option<string>,
  theme_name: string,
  theme_data: themeCreateData,
  email_config: option<emailConfig>,
}

let defaultCreate = (~lineage: lineage) => {
  entity_type: lineage.entity_type,
  tenant_id: lineage.tenant_id,
  org_id: lineage.org_id,
  merchant_id: lineage.merchant_id,
  profile_id: lineage.profile_id,
  theme_name: "Default Theme",
  theme_data: {
    settings: {
      colors: {fallbackThemeConfig.settings.colors},
      sidebar: {fallbackThemeConfig.settings.sidebar},
      buttons: {fallbackThemeConfig.settings.buttons},
      typography: {fontFamily: fallbackThemeConfig.settings.typography.fontFamily},
    },
  },
  email_config: Some(defaultEmailConfig),
}
