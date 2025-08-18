type ompType = [#platform | #standard]

// TODO: remove productType optional
type ompListTypes = {
  id: string,
  name: string,
  productType?: ProductTypes.productTypes,
  version?: UserInfoTypes.version,
  @as("type") type_?: ompType,
}
type ompListTypesCustom = {...ompListTypes, customComponent: React.element}

type opmView = {
  lable: string,
  entity: UserInfoTypes.entity,
}
type ompViews = array<opmView>

type ompList = {
  orgList: array<ompListTypes>,
  merchantList: array<ompListTypes>,
  profileList: array<ompListTypes>,
}

type adminType = [#tenant_admin | #org_admin | #merchant_admin | #non_admin]

type addOrgFormFields = OrgName | MerchantName
