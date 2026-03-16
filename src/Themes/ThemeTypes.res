@unboxed
type lineageSelectionSteps =
  | @as("entityselection") EntitySelection
  | @as("orgview") OrgView
  | @as("merchantlevelconfig") MerchantLevelConfig
  | @as("profilelevelconfig") ProfileLevelConfig

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
