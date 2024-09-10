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
  | "sso" => SSO
  | "auth_select" => AUTH_SELECT
  | _ => ERROR
  }
}

let variantToStringFlowMapper = val => {
  switch val {
  | AUTH_SELECT => "auth_select"
  | MERCHANT_SELECT => "merchant_select"
  | TOTP => "totp"
  | FORCE_SET_PASSWORD => "force_set_password"
  | ACCEPT_INVITE => "accept_invite"
  | VERIFY_EMAIL => "verify_email"
  | ACCEPT_INVITATION_FROM_EMAIL => "accept_invitation_from_email"
  | RESET_PASSWORD => "reset_password"
  | USER_INFO => "user_info"
  | SSO => "sso"
  | ERROR => ""
  }
}

let divider =
  <div className="flex gap-2 items-center ">
    <hr className="w-full" />
    <p className=" text-gray-400"> {"OR"->React.string} </p>
    <hr className="w-full" />
  </div>

let itemToObjectMapper = dict => {
  open LogicUtils
  {
    entityId: dict->getString("entity_id", ""),
    entityType: dict->getString("entity_type", "")->UserInfoUtils.entityMapper,
    entityName: dict->getString("entity_name", ""),
    roleId: dict->getString("role_id", ""),
  }
}
