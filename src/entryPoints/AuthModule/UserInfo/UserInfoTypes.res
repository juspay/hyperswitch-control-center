type entity = [#Internal | #Organization | #Merchant | #Profile]
type userInfo = {
  email: string,
  isTwoFactorAuthSetup: bool,
  merchantId: string,
  name: string,
  orgId: string,
  recoveryCodesLeft: option<int>,
  roleId: string,
  verificationDaysLeft: option<int>,
  profileId: string,
  userEntity: entity,
  transactionEntity: entity,
  analyticsEntity: entity,
}

type userInfoProviderTypes = {
  userInfo: userInfo,
  setUserInfoData: userInfo => unit,
}
