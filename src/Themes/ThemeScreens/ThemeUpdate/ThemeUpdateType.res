open HyperSwitchConfigTypes

type themeUpdate = {
  theme_data: HyperSwitchConfigTypes.customStylesTheme,
  email_config: option<emailConfig>,
}
