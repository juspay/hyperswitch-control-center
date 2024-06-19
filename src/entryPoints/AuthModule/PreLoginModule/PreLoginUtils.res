open PreLoginTypes

let flowTypeStrToVariantMapperForNewFlow = val => {
  switch val {
  // old types
  | "merchant_select" => MERCHANT_SELECT
  | "totp" => TOTP
  // rotate password
  | "force_set_password" => FORCE_SET_PASSWORD
  // merchant select
  | "accept_invite" => ACCEPT_INVITE
  | "accept_invitation_from_email" => ACCEPT_INVITATION_FROM_EMAIL
  | "verify_email" => VERIFY_EMAIL
  | "reset_password" => RESET_PASSWORD
  // home call
  | "user_info" => USER_INFO
  | _ => ERROR
  }
}

let variantToStringFlowMapper = val => {
  switch val {
  | MERCHANT_SELECT => "merchant_select"
  | TOTP => "totp"
  | FORCE_SET_PASSWORD => "force_set_password"
  | ACCEPT_INVITE => "accept_invite"
  | VERIFY_EMAIL => "verify_email"
  | ACCEPT_INVITATION_FROM_EMAIL => "accept_invitation_from_email"
  | RESET_PASSWORD => "reset_password"
  | USER_INFO => "user_info"
  | ERROR => ""
  }
}
