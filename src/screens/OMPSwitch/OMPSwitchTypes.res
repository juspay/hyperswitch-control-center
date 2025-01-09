type orgMerchantList = {id: string, name: string, isPlatformAccount: bool}
type profileList = {id: string, name: string}

type opmView = {
  lable: string,
  entity: UserInfoTypes.entity,
}
type ompViews = array<opmView>

type ompList = {
  orgList: array<orgMerchantList>,
  merchantList: array<orgMerchantList>,
  profileList: array<profileList>,
}

type adminType = [#tenant_admin | #org_admin | #merchant_admin | #non_admin]

type addOrgFormFields = OrgName | MerchantName
