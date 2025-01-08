// type ompListTypes = {id: string, name: string}

type orgType = Default | Platform
type merchantType = Default | Platform | Connected

type orgList = {id: string, name: string, orgType: orgType}
type merchantList = {id: string, name: string, merchantType: merchantType}
type profileList = {id: string, name: string}

type opmView = {
  lable: string,
  entity: UserInfoTypes.entity,
}
type ompViews = array<opmView>

type ompList = {
  orgList: array<orgList>,
  merchantList: array<merchantList>,
  profileList: array<profileList>,
}

type adminType = [#tenant_admin | #org_admin | #merchant_admin | #non_admin]

type addOrgFormFields = OrgName | MerchantName
