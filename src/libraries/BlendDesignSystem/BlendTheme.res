module ThemeProvider = {
  @module("@juspay/blend-design-system") @react.component
  external make: (
    ~children: React.element,
    ~foundationTokens: 'a=?,
    ~componentTokens: 'b=?,
    ~breakpoints: 'c=?,
    ~theme: string=?,
  ) => React.element = "ThemeProvider"
}

@module("@juspay/blend-design-system")
external useTheme: unit => {..} = "useTheme"

@module("@juspay/blend-design-system")
external foundationTheme: JSON.t = "FOUNDATION_THEME"
