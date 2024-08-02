type userInfo = {
  email: string,
  isTwoFactorAuthSetup: bool,
  merchantId: string,
  name: string,
  orgId: string,
  recoveryCodesLeft: option<int>,
  roleId: string,
  verificationDaysLeft: option<int>,
}
