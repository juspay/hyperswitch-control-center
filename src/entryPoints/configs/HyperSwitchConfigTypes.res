type urlThemeConfig = {
  faviconUrl: option<string>,
  logoUrl: option<string>,
}
type urlConfig = {
  apiBaseUrl: string,
  mixpanelToken: string,
  sdkBaseUrl: option<string>,
  agreementUrl: option<string>,
  agreementVersion: option<string>,
  applePayCertificateUrl: option<string>,
  reconIframeUrl: option<string>,
  dssCertificateUrl: option<string>,
  urlThemeConfig: urlThemeConfig,
}

// themes struct type

type colorPalette = {
  primary: string,
  secondary: string,
  sidebar: string,
  background: string,
}

type typographyConfig = {
  fontFamily: string,
  fontSize: string,
  headingFontSize: string,
  textColor: string,
  linkColor: string,
  linkHoverColor: string,
}

type buttonStyleConfig = {
  backgroundColor: string,
  textColor: string,
  hoverBackgroundColor: string,
}

type borderConfig = {
  defaultRadius: string,
  borderColor: string,
}

type spacingConfig = {
  padding: string,
  margin: string,
}

type buttonConfig = {
  primary: buttonStyleConfig,
  secondary: buttonStyleConfig,
}

type themeSettings = {
  colors: colorPalette,
  typography: typographyConfig,
  buttons: buttonConfig,
  borders: borderConfig,
  spacing: spacingConfig,
}

type customStylesTheme = {
  settings: themeSettings,
  urls: urlThemeConfig,
}

////type for extended themes
type colorPalette2 = {
  primary: string,
  secondary: string,
  background: string,
}
type sidebarConfig = {
  primary: string,
  secondary: string,
  hoverColor: string,
  textColor: string,
}
type themeSettings2 = {
  colors: colorPalette2,
  sidebar: sidebarConfig,
  typography: typographyConfig,
  buttons: buttonConfig,
  borders: borderConfig,
  spacing: spacingConfig,
}

type customStylesTheme2 = {
  settings: themeSettings2,
  urls: urlThemeConfig,
}
