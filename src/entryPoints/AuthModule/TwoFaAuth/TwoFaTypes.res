type twoFaPageState =
  | TOTP_SHOW_QR
  | TOTP_SHOW_RC
  | TOTP_INPUT_RECOVERY_CODE

type twoFaStatus = TWO_FA_NOT_SET | TWO_FA_SET

type twoFaValueType = {
  isCompleted: bool,
  attemptsRemaining: int,
}

type twoFatype = {
  totp: twoFaValueType,
  recoveryCode: twoFaValueType,
}

type checkTwofaResponseType = {
  status: option<twoFatype>,
  isSkippable: bool,
}

type expiredTypes =
  | TOTP_ATTEMPTS_EXPIRED
  | RC_ATTEMPTS_EXPIRED
  | TWO_FA_EXPIRED

type twoFaStatusType = TwoFaExpired(expiredTypes) | TwoFaNotExpired
