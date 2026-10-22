open ToastState
open SnackbarBinding

type toastType = ToastState.toastType

let useShowToast = () => {
  let isBlendEnabled = React.useContext(BlendContext.blendEnabledContext)
  let legacyShowToast = ToastState.useShowToast()

  React.useMemo(() => {
    (
      ~message,
      ~toastType: toastType,
      ~toastDuration=0,
      ~autoClose=false,
      ~buttonText=?,
      ~helpLink=?,
      ~toastElement=React.null,
      ~toastKey=?,
    ) => {
      if !isBlendEnabled || toastElement !== React.null {
        legacyShowToast(
          ~message,
          ~toastType,
          ~toastDuration,
          ~autoClose,
          ~buttonText?,
          ~helpLink?,
          ~toastElement,
          ~toastKey?,
        )
      } else {
        let variant = switch toastType {
        | ToastSuccess => Success
        | ToastError => SnackbarBinding.Error
        | ToastWarning => Warning
        | ToastInfo => Info
        }

        let duration = toastDuration > 0 ? toastDuration : 3000

        let actionButton = buttonText->Option.map(label => {
          label,
          onClick: () =>
            RescriptReactRouter.push(
              GlobalVars.appendDashboardPath(~url=helpLink->Option.getOr("")),
            ),
        })

        let toastOptions: addToastOptions = {
          header: message,
          ?actionButton,
          variant,
          duration,
          position: TopCenter,
          width: "min(var(--app-snackbar-width), calc(100vw - var(--app-snackbar-gutter)))",
          maxWidth: "calc(100vw - var(--app-snackbar-gutter))",
          minWidth: "0",
        }

        let _ = addSnackbarV2(toastOptions)
      }
    }
  }, (isBlendEnabled, legacyShowToast))
}
