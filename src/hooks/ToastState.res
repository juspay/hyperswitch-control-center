type toastType =
  | ToastError
  | ToastWarning
  | ToastInfo
  | ToastSuccess
  | ToastReject
type toastProps = {
  toastKey: string,
  message: string,
  toastType: toastType,
  autoClose: bool,
  toastDuration: int,
  buttonText?: string,
  helpLink?: string,
  toastElement: React.element,
}

let randomString = (length, chars) => {
  Belt.Array.make(length, 0)->Array.reduce("", (acc, _) => {
    let charIndex = Js.Math.random_int(0, chars->String.length)
    let newChar = chars->String.charAt(charIndex)
    acc ++ newChar
  })
}

let makeToastProps = (
  ~message,
  ~toastType,
  ~autoClose=false,
  ~toastDuration=0,
  ~buttonText=?,
  ~helpLink=?,
  ~toastElement=React.null,
  (),
) => {
  let rString = randomString(32, "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")

  {
    toastKey: rString,
    message,
    toastType,
    autoClose,
    toastDuration,
    ?buttonText,
    ?helpLink,
    toastElement,
  }
}

let defaultOpenToasts: array<toastProps> = []

let openToasts = Recoil.atom(. "openToasts", defaultOpenToasts)

type showToastFn = (
  ~message: string,
  ~toastType: toastType,
  ~toastDuration: int=?,
  ~autoClose: bool=?,
  ~buttonText: string=?,
  ~helpLink: string=?,
  ~toastElement: React.element=?,
  unit,
) => unit

let useShowToast = (): showToastFn => {
  let setOpenToasts = Recoil.useSetRecoilState(openToasts)
  React.useMemo1(
    (
      (),
      ~message,
      ~toastType: toastType,
      ~toastDuration=0,
      ~autoClose=false,
      ~buttonText=?,
      ~helpLink=?,
      ~toastElement=React.null,
      (),
    ) => {
      let toastProps = makeToastProps(
        ~message,
        ~toastType,
        ~toastDuration,
        ~autoClose,
        ~buttonText?,
        ~helpLink?,
        ~toastElement,
        (),
      )

      setOpenToasts(.prevArr => prevArr->Array.concat([toastProps]))
    },
    [setOpenToasts],
  )
}
