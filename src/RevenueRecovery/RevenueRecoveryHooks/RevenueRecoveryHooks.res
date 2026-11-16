open RevenueRecoveryProfileTypes
open RevenueRecoveryProfileUtils

// Profiles without a mode are treated as monitoring, as the backend does when a billing connector
// is added
let useSavedRetryMode = () =>
  HyperswitchAtom.recoveryProfileAtom
  ->Recoil.useRecoilValueFromAtom
  ->Option.flatMap(profile => profile.retryAlgorithm)
  ->Option.getOr(Monitoring)

// Changing the mode starts or stops retries on real invoices
let useConfirmModeChange = () => {
  let showPopUp = PopUpState.useShowPopUp()
  let triggerModel =
    HyperswitchAtom.recoveryProfileAtom
    ->Recoil.useRecoilValueFromAtom
    ->Option.map(profile => profile.triggerModel)
    ->Option.getOr(InternalTriggers)
  (~mode, ~onConfirm) =>
    showPopUp({
      popUpType: (Warning, WithIcon),
      heading: `Switch to ${mode->getRetryAlgorithmLabel}?`,
      description: switch (mode, triggerModel) {
      | (Smart, InternalTriggers) => "We'll start retrying failed invoices."
      | (Smart, ExternalTriggers) => "We'll start sending out retry times for failed invoices."
      | _ => "Failed invoices will be recorded and no retries will be scheduled."
      }->React.string,
      handleConfirm: {
        text: "Switch",
        onClick: _ => onConfirm(),
      },
      handleCancel: {text: "Cancel"},
    })
}
