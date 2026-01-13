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

type embeddableInfoType = {
  ...commonInfoType,
}

/* There will be two type of user that can access the dashboard 
 1. DashboardSession - Normal hyperswitch user (Will contain userInfo details)
 2. EmbeddableSession - User accessing via embeddable flow ( As of now kept version as its needed in most of the place to call the api, but details are not provided by the api )
*/
type sessionType = DashboardSession(userInfo) | EmbeddableSession(embeddableInfoType)

type userInfoProviderTypes = {
  state: sessionType,
  setApplicationState: (sessionType => sessionType) => unit,
  getResolvedUserInfo: unit => userInfo,
  setUpdatedDashboardSessionInfo: userInfo => unit,
  getResolvedEmbeddableInfo: unit => embeddableInfoType,
  setUpdatedEmbeddableSessionInfo: embeddableInfoType => unit,
  getCommonSessionDetails: unit => commonInfoType,
  checkUserEntity: array<entity> => bool,
  isEmbeddableSession: unit => bool,
}
