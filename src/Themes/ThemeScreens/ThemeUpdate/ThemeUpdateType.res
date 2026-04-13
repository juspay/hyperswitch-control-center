open HyperSwitchConfigTypes

type themeUpdate = {
  theme_name: string,
  theme_data: HyperSwitchConfigTypes.customStylesTheme,
  email_config: option<emailConfig>,
}
