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

type assetValue = Url(string) | File(JSON.t)

type assets = {
  logo: option<assetValue>,
  favicon: option<assetValue>,
  emailLogo: option<assetValue>,
}

type processedAssets = {
  urls: HyperSwitchConfigTypes.urlThemeConfig,
  emailLogoUrl: option<string>,
}

type themeOption = {
  label: string,
  value: string,
  icon: React.element,
  desc: string,
}
