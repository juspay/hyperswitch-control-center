open ThemeTypes
open HyperSwitchConfigTypes

type themeCreate = {
  entity_type: string,
  tenant_id: string,
  org_id: option<string>,
  merchant_id: option<string>,
  profile_id: option<string>,
  theme_name: string,
  theme_data: customStylesTheme,
  email_config: option<emailConfig>,
}

let createLineage = (~orgId, ~merchantId, ~profileId) => {
  let entityType = SessionStorage.sessionStorage.getItem("entity_type")->Nullable.toOption
  switch entityType {
  | Some("tenant") => {
      entity_type: "tenant",
      tenant_id: "public",
      org_id: None,
      merchant_id: None,
      profile_id: None,
    }
  | Some("organization") => {
      entity_type: "organization",
      tenant_id: "public",
      org_id: Some(orgId),
      merchant_id: None,
      profile_id: None,
    }
  | Some("merchant") => {
      entity_type: "merchant",
      tenant_id: "public",
      org_id: Some(orgId),
      merchant_id: Some(merchantId),
      profile_id: None,
    }
  | Some("profile") => {
      entity_type: "profile",
      tenant_id: "public",
      org_id: Some(orgId),
      merchant_id: Some(merchantId),
      profile_id: Some(profileId),
    }
  | _ => {
      entity_type: "",
      tenant_id: "",
      org_id: None,
      merchant_id: None,
      profile_id: None,
    }
  }
}

let defaultCreate = (~lineage: lineage) => {
  entity_type: lineage.entity_type,
  tenant_id: lineage.tenant_id,
  org_id: lineage.org_id,
  merchant_id: lineage.merchant_id,
  profile_id: lineage.profile_id,
  theme_name: "Default Theme",
  theme_data: {
    ThemeProvider.newDefaultConfig
  },
  email_config: Some({
    entity_name: ThemeProvider.defaultEmailConfig.entity_name,
    entity_logo_url: ThemeProvider.defaultEmailConfig.entity_logo_url,
    primary_color: ThemeProvider.defaultEmailConfig.primary_color,
    foreground_color: ThemeProvider.defaultEmailConfig.foreground_color,
    background_color: ThemeProvider.defaultEmailConfig.background_color,
  }),
}
