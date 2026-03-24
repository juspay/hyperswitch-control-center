@module("@juspay/blend-design-system") @react.component
external make: (
  ~children: React.element,
  ~foundationTokens: FoundationTokens.foundationThemeType=?,
  ~componentTokens: JSON.t=?,
) => React.element = "ThemeProvider"
