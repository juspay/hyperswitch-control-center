type snackbarType =
  | General
  | Success
  | Error
  | Warning
  | Information

type snackbarProps = {
  snackbarKey: string,
  heading: string,
  body: string,
  snackbarType: snackbarType,
  actionElement: React.element,
  onClose?: unit => unit,
}

let randomString = (length, chars) => {
  Belt.Array.make(length, 0)->Array.reduce("", (acc, _) => {
    let charIndex = Js.Math.random_int(0, chars->String.length)
    let newChar = chars->String.charAt(charIndex)
    acc ++ newChar
  })
}

let makeSnackbarProps = (
  ~heading,
  ~body,
  ~snackbarType,
  ~actionElement=React.null,
  ~onClose=?,
  (),
) => {
  let rString = randomString(32, "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")

  {
    snackbarKey: rString,
    heading,
    body,
    snackbarType,
    actionElement,
    ?onClose,
  }
}

let defaultOpenSnackbar: array<snackbarProps> = []

let openSnackbar = Recoil.atom(. "openSnackbar", defaultOpenSnackbar)

type showSnackbarFn = (
  ~heading: string,
  ~body: string,
  ~snackbarType: snackbarType,
  ~actionElement: React.element=?,
  ~onClose: unit => unit=?,
  unit,
) => unit

let useHideSnackbar = () => {
  let setOpenSnackBar = Recoil.useSetRecoilState(openSnackbar)

  React.useCallback1(key => {
    setOpenSnackBar(.prevArr => {
      Array.filter(
        prevArr,
        (snackbarProps: snackbarProps) => {
          snackbarProps.body !== key
        },
      )
    })
  }, [setOpenSnackBar])
}

let useShowSnackbar = (): showSnackbarFn => {
  let setOpenSnackbar = Recoil.useSetRecoilState(openSnackbar)
  React.useMemo1(
    ((), ~heading, ~body, ~snackbarType, ~actionElement=React.null, ~onClose=?, ()) => {
      let snackbarProps = makeSnackbarProps(
        ~heading,
        ~body,
        ~snackbarType,
        ~actionElement,
        ~onClose?,
        (),
      )

      setOpenSnackbar(.prevArr => prevArr->Array.concat([snackbarProps]))
    },
    [setOpenSnackbar],
  )
}
