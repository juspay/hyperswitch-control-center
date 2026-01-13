type lineage = {
  entity_type: string,
  tenant_id: string,
  org_id: option<string>,
  merchant_id: option<string>,
  profile_id: option<string>,
}

type themeOption = {
  label: string,
  value: string,
  icon: React.element,
  desc: string,
}
