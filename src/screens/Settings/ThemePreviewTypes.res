// ThemePreviewTypes.res

type buttonConfig = {
  backgroundColor: string,
  textColor: string,
  hoverBackgroundColor: string,
}

type sidebarConfig = {
  primary: string,
  textColor: string,
  textColorPrimary: string,
}

type buttonsConfig = {
  primary: buttonConfig,
  secondary: buttonConfig,
}

type theme = {
  themeName: string,
  primaryColor: string,
  sidebar: sidebarConfig,
  buttons: buttonsConfig,
  faviconUrl: string,
  logoUrl: string,
}

type sidebarItem = {
  label: string,
  active: bool,
}
