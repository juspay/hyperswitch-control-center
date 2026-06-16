type toastType = ToastState.toastType

type showToastFn = ToastState.showToastFn

let useShowToast = (): showToastFn => {
  let isBlendEnabled = React.useContext(BlendContext.blendEnabledContext)
  let legacyShowToast = ToastState.useShowToast()

  React.useMemo1(() => {
    (
      ~message,
      ~toastType: ToastState.toastType,
      ~toastDuration=0,
      ~autoClose=false,
      ~buttonText=?,
      ~helpLink=?,
      ~toastElement=React.null,
      ~toastKey=?,
    ) => {
      if !isBlendEnabled || toastElement != React.null {
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
        | ToastState.ToastSuccess => SnackbarBinding.Success
        | ToastState.ToastError => SnackbarBinding.Error
        | ToastState.ToastWarning => SnackbarBinding.Warning
        | ToastState.ToastInfo => SnackbarBinding.Info
        }

        let duration = toastDuration > 0 ? toastDuration : 3000

        let toastOptions: SnackbarBinding.addToastOptions = {
          header: "",
          description: message,
          variant,
          duration,
          position: SnackbarBinding.TopCenter,
        }

        let _ = SnackbarBinding.addSnackbar(toastOptions)
      }
    }
  }, [isBlendEnabled])
}
