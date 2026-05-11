// Toast Adapter - Conditionally uses legacy Recoil toast or Blend Snackbar based on BlendContext
// Follows the adapter pattern for gradual migration to Blend Design System

type toastType = ToastState.toastType

type showToastFn = ToastState.showToastFn

let useShowToast = (): showToastFn => {
  let isBlendEnabled = React.useContext(BlendContext.blendEnabledContext)
  let legacyShowToast = ToastState.useShowToast()

  React.useMemo1(() => {
    if isBlendEnabled {
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
        // Fall back to legacy toast when custom toastElement is provided
        // Blend Snackbar has no custom JSX slot
        if toastElement != React.null {
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

          let duration = if toastDuration > 0 {
            Some(toastDuration)
          } else if autoClose {
            Some(3000)
          } else {
            Some(3000)
          }

          let toastOptions: SnackbarBinding.addToastOptions = {
            header: "",
            description: ?Some(message),
            variant: ?Some(variant),
            ?duration,
            position: ?Some(SnackbarBinding.TopCenter),
          }

          let _ = SnackbarBinding.addSnackbar(toastOptions)
        }
      }
    } else {
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
      }
    }
  }, [isBlendEnabled])
}
