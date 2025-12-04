type entityType = TENANT | ORGANIZATION | MERCHANT | PROFILE

type lineage = {
  entity_type: string,
  tenant_id: string,
  org_id: option<string>,
  merchant_id: option<string>,
  profile_id: option<string>,
}

let entityTypeToLevel = (entityType: string): entityType => {
  switch entityType {
  | "tenant" => TENANT
  | "organization" => ORGANIZATION
  | "merchant" => MERCHANT
  | "profile" => PROFILE
  | _ => TENANT // Default fallback for any unexpected values
  }
}

let entityLevelToLabel = (level: entityType): string => {
  switch level {
  | TENANT => "Tenant Level"
  | ORGANIZATION => "Organization Level"
  | MERCHANT => "Merchant Level"
  | PROFILE => "Profile Level"
  }
}
type themeOption = {
  label: string,
  value: string,
  icon: React.element,
  desc: string,
}
