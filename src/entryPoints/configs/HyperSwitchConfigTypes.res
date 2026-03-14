type urlThemeConfig = {
  faviconUrl: option<string>,
  logoUrl: option<string>,
}
type emailConfig = {
  entity_name: string,
  entity_logo_url: string,
  primary_color: string,
  foreground_color: string,
  background_color: string,
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
  dynamoSimulationTemplateUrl: option<string>,
  urlThemeConfig: urlThemeConfig,
  hypersenseUrl: string,
  clarityBaseUrl: option<string>,
}

// Type definition for themes
type colorPalette = {
  primary: string,
  secondary: string,
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

type sidebarConfig = {
  primary: string,
  textColor: string,
  textColorPrimary: string,
}

type themeSettings = {
  colors: colorPalette,
  sidebar: sidebarConfig,
  typography: typographyConfig,
  buttons: buttonConfig,
  borders: borderConfig,
  spacing: spacingConfig,
}

type customStylesTheme = {
  settings: themeSettings,
  urls: urlThemeConfig,
}
