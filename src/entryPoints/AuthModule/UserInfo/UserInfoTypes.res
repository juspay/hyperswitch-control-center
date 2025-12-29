type entity = [#Tenant | #Organization | #Merchant | #Profile]
type version = V1 | V2

/*
 This type should always have the common info that is required for both embeddable and normal user
 */
type commonInfoType = {
  orgId: string,
  profileId: string,
  merchantId: string,
  version: version,
}

// TODO: chaneg this to have two enums one for normal user one for embeddable user
type userInfo = {
  email: string,
  isTwoFactorAuthSetup: bool,
  name: string,
  recoveryCodesLeft: option<int>,
  roleId: string,
  verificationDaysLeft: option<int>,
  userEntity: entity,
  themeId: string,
  mutable transactionEntity: entity,
  mutable analyticsEntity: entity,
  ...commonInfoType,
}

/* There will be two type of user that can access the dashboard 
 1. DashboardUser - Normal hyperswitch user (Will contain userInfo details)
 2. EmbeddableUser - User accessing via embeddable flow ( As of now kept version as its needed in most of the place to call the api, but details are not provided by the api )
*/
type detailsInfoType = DashboardUser(userInfo) | EmbeddableUser

type providerStateType = {
  commonInfo: commonInfoType,
  details: detailsInfoType,
}

type userInfoProviderTypes = {
  state: providerStateType,
  setUpdatedDashboardUserInfo: userInfo => unit,
  setApplicationState: (providerStateType => providerStateType) => unit,
  resolvedUserInfo: userInfo,
  checkUserEntity: array<entity> => bool,
}
