type preLoginType = {
  token: string,
  token_type: string,
  email_token: option<string>,
}

type authInfo = {
  token: string,
  merchant_id: string,
  name: string,
  email: string,
  role_id: string,
  is_two_factor_auth_setup: bool,
  recovery_codes_left: int,
}

type authType = BasicAuth(BasicAuthTypes.basicAuthInfo) | Auth(authInfo)

type authStatus =
  | LoggedOut
  | SSOPreLogin(preLoginType)
  | PreLogin(preLoginType)
  | LoggedIn(authType)
  | CheckingAuthStatus
