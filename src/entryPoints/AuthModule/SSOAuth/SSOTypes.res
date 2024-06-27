type authMethodTypes = PASSWORD | OPEN_ID_CONNECT

type authNameTypes = [#Email_Password | #Okta | #Google | #Github]

type okta = {
  code: option<string>,
  state: option<string>,
}

type redirectmethods = [#Okta(okta) | #Google | #Github]
type ssoflowType = SSO_FROM_REDIRECT(redirectmethods) | LOADING

type authMethodType = {
  \"type": authMethodTypes,
  name: authNameTypes,
}

type authMethodResponseType = {
  id: string,
  auth_id: string,
  auth_method: authMethodType,
  allow_signup: bool,
}
