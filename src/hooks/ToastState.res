type toastType =
  | ToastError
  | ToastWarning
  | ToastInfo
  | ToastSuccess

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
  Array.make(~length, 0)->Array.reduce("", (acc, _) => {
    let charIndex = Math.Int.random(0, chars->String.length)
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
  ~toastKey=?,
) => {
  let rString = switch toastKey {
  | Some(key) => key
  | None => randomString(32, "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")
  }

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

let openToasts = Recoil.atom("openToasts", defaultOpenToasts)

type showToastFn = (
  ~message: string,
  ~toastType: toastType,
  ~toastDuration: int=?,
  ~autoClose: bool=?,
  ~buttonText: string=?,
  ~helpLink: string=?,
  ~toastElement: React.element=?,
  ~toastKey: string=?,
) => unit

let useShowToast = (): showToastFn => {
  let setOpenToasts = Recoil.useSetRecoilState(openToasts)
  React.useMemo1(() => {
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
      let toastProps = makeToastProps(
        ~message,
        ~toastType,
        ~toastDuration,
        ~autoClose,
        ~buttonText?,
        ~helpLink?,
        ~toastElement,
        ~toastKey?,
      )

      setOpenToasts(prevArr => prevArr->Array.concat([toastProps]))
    }
  }, [setOpenToasts])
}

type hideToastFn = string => unit

let useHideToast = (): hideToastFn => {
  let setOpenToasts = Recoil.useSetRecoilState(openToasts)
  React.useMemo(() => {
    (toastKey: string) => {
      setOpenToasts(prevArr => {
        Array.filter(
          prevArr,
          (toastProps: toastProps) => {
            toastProps.toastKey !== toastKey
          },
        )
      })
    }
  }, [setOpenToasts])
}
