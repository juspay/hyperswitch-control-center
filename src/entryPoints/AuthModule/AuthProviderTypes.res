type preLoginType = {
  token: option<string>,
  token_type: string,
  email_token: option<string>,
}

type authInfo = {token: option<string>}

type authType = BasicAuth(BasicAuthTypes.basicAuthInfo) | Auth(authInfo)

type authStatus =
  | LoggedOut
  | PreLogin(preLoginType)
  | LoggedIn(authType)
  | CheckingAuthStatus
