type authType = BasicAuth(BasicAuthTypes.basicAuthInfo) | ToptAuth(TotpTypes.totpAuthInfo)

type authStatus = LoggedOut | LoggedIn(authType) | CheckingAuthStatus
