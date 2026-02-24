open ThemeTypes

// TODO: to update tenant_id once we get it from userinfo
let createLineage = (~orgId, ~merchantId, ~profileId) => {
  let tenantId = "public"
  let entityType =
    SessionStorage.sessionStorage.getItem("entity_type")
    ->LogicUtils.getOptionalFromNullable
    ->Option.getOr("")
    ->UserInfoUtils.entityMapper
  switch entityType {
  | #Tenant => {
      entity_type: "tenant",
      tenant_id: tenantId,
      org_id: None,
      merchant_id: None,
      profile_id: None,
    }
  | #Organization => {
      entity_type: "organization",
      tenant_id: tenantId,
      org_id: Some(orgId),
      merchant_id: None,
      profile_id: None,
    }
  | #Merchant => {
      entity_type: "merchant",
      tenant_id: tenantId,
      org_id: Some(orgId),
      merchant_id: Some(merchantId),
      profile_id: None,
    }
  | #Profile => {
      entity_type: "profile",
      tenant_id: tenantId,
      org_id: Some(orgId),
      merchant_id: Some(merchantId),
      profile_id: Some(profileId),
    }
  | _ => {
      entity_type: "profile",
      tenant_id: tenantId,
      org_id: Some(orgId),
      merchant_id: Some(merchantId),
      profile_id: Some(profileId),
    }
  }
}
