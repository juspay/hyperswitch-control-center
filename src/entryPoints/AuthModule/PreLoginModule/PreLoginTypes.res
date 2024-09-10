type preLoginTypes =
  | AUTH_SELECT
  | SSO
  | MERCHANT_SELECT
  | TOTP
  | FORCE_SET_PASSWORD
  | ACCEPT_INVITE
  | VERIFY_EMAIL
  | ACCEPT_INVITATION_FROM_EMAIL
  | RESET_PASSWORD
  | USER_INFO
  | ERROR

type invitationResponseType = {
  entityId: string,
  entityType: UserInfoTypes.entity,
  entityName: string,
  roleId: string,
}

type acceptInviteRequest = {
  entity_id: string,
  entity_type: string,
}
