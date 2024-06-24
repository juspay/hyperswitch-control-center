type ssoflowType = SSO_FROM_REDIRECT | SSO_FROM_EMAIL | LOADING

type authMethodTypes = PASSWORD | OPEN_ID_CONNECT

type authNameTypes = [#Email_Password | #Okta | #Google | #Github]

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
