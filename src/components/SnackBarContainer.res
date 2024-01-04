module Snackbar = {
  @react.component
  let make = (~snackbarProps: SnackBarState.snackbarProps, ~hideSnackbar) => {
    let borderCss = snackbarProps.snackbarType != General ? "border-l-4" : ""

    let borderColor = switch snackbarProps.snackbarType {
    | General
    | Information => "border-jp-2-primary-300"
    | Success => "border-jp-2-light-green-700"
    | Error => "border-jp-2-light-red-700"
    | Warning => "border-jp-2-light-orange-600"
    }

    let snackbarIconName = switch snackbarProps.snackbarType {
    | Success => "success-snackbar"
    | Warning => "warning-snackbar"
    | Information => "info-snackbar"
    | Error => "error-snackbar"
    | General => ""
    }

    let leftIcon = if snackbarProps.snackbarType != General {
      <div>
        <Icon name=snackbarIconName size=24 />
      </div>
    } else {
      React.null
    }

    let handleClick = React.useCallback1(_ev => {
      switch snackbarProps.onClose {
      | Some(fn) => fn()
      | _ => ()
      }

      hideSnackbar(snackbarProps.snackbarKey)
    }, [hideSnackbar])

    <div
      className={`p-3 pr-4 m-2 mr-3 shadow-lg z-50 pointer-events-auto bg-jp-2-light-gray-1800 max-w-md rounded ${borderCss} ${borderColor}`}>
      <div className="flex flex-row gap-2">
        {leftIcon}
        <div className="flex flex-col gap-4">
          <div className="gap-0">
            <div className="font-semibold text-fs-16 mb-2 text-jp-2-dark-gray-2000">
              {React.string(snackbarProps.heading)}
            </div>
            <div className="font-normal text-fs-14 leading-5 text-jp-2-light-gray-600">
              {React.string(snackbarProps.body)}
            </div>
          </div>
          {snackbarProps.actionElement}
        </div>
        <div>
          <button className=" hover:text-jp-gray-900 pl-5" onClick={handleClick}>
            <Icon size=16 name="close-snackbar" />
          </button>
        </div>
      </div>
    </div>
  }
}

@react.component
let make = (~children) => {
  let (openSnackbar, setOpenSnackbar) = Recoil.useRecoilState(SnackBarState.openSnackbar)

  let hideSnackbar = React.useCallback1(key => {
    setOpenSnackbar(.prevArr => {
      Array.filter(
        prevArr,
        (snackbarProps: SnackBarState.snackbarProps) => {
          snackbarProps.snackbarKey !== key
        },
      )
    })
  }, [setOpenSnackbar])

  <div className="relative">
    children
    <div>
      <div
        className={`absolute inset-0 overflow-scroll flex flex-col pointer-events-none m-4 items-end grid justify-end content-end no-scrollbar`}>
        <div
          className={`flex flex-col font-inter-style pointer-events-auto w-auto self-start w-max max-w-4xl`}>
          {openSnackbar
          ->Array.map(snackbarProps => {
            <Snackbar key={snackbarProps.snackbarKey} snackbarProps hideSnackbar />
          })
          ->React.array}
        </div>
      </div>
    </div>
  </div>
}
