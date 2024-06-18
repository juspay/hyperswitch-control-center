open SsoTypes

let flowTypeStrToVariantMapper = val => {
  switch val {
  | "sso" => SSO_FROM_EMAIL
  | "user_info" => USER_INFO
  | _ => ERROR
  }
}
