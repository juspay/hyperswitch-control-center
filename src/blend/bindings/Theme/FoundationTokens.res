// Opaque type — we don't inspect the token structure internally.
// We get Blend's default theme and pass it straight back to ThemeProvider.
type foundationThemeType

@module("@juspay/blend-design-system")
external foundationTheme: foundationThemeType = "FOUNDATION_THEME"

let defaultFoundationTokens = foundationTheme
