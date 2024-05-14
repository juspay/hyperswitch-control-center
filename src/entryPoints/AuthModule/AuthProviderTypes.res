type authType = BasicAuth(BasicAuthTypes.basicAuthInfo) | TotpAuth(TotpTypes.totpAuthInfo)

type authStatus = LoggedOut | LoggedIn(authType) | CheckingAuthStatus
