type preLoginType = {
  token: string,
  token_type: string,
  email_token: option<string>,
}
type authType = BasicAuth(BasicAuthTypes.basicAuthInfo) | TotpAuth(TwoFaTypes.twoFaAuthInfo)

type authStatus = LoggedOut | PreLogin(preLoginType) | LoggedIn(authType) | CheckingAuthStatus
