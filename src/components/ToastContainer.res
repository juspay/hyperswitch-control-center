module ToastHeading = {
  @react.component
  let make = (~toastProps: ToastState.toastProps, ~hideToast, ~toastDuration=0) => {
    React.useEffect2(() => {
      let duration = if toastDuration == 0 {
        3000
      } else {
        toastDuration
      }
      let timeout = {
        Js.Global.setTimeout(() => {
          hideToast(toastProps.toastKey)
        }, duration)
      }
      Some(
        () => {
          Js.Global.clearTimeout(timeout)
        },
      )
    }, (hideToast, toastProps))

    let toastColorClasses = switch toastProps.toastType {
    | ToastError => "bg-red-960 border-red-960 rounded-md"
    | ToastWarning => "bg-orange-950 border-orange-950 rounded-md"
    | ToastInfo => "bg-blue-950 border-blue-950 rounded-md"
    | ToastSuccess => "bg-green-800 border-green-800 rounded-md"
    | ToastReject => "bg-red-960 border-red-960 rounded-md"
    }

    let toastIconName = switch toastProps.toastType {
    | ToastSuccess => "check-circle"
    | ToastError => "times-circle"
    | ToastWarning => "exclamation-triangle"
    | ToastInfo => "info-circle"
    | ToastReject => "check-circle"
    }

    let toastClass = "p-4 font-semibold"
    let onClickButtonText = () => {
      RescriptReactRouter.push(
        switch toastProps.helpLink {
        | Some(str) => str
        | None => ""
        },
      )
    }

    let toastTextClass = "text-lg"
    <div
      className={`${toastColorClasses}  border ${toastClass} ${toastTextClass} text-jp-gray-text_darktheme flex flex-row justify-between`}>
      <Icon className="align-middle self-center" name=toastIconName />
      <AddDataAttributes attributes=[("data-toast", toastProps.message)]>
        <div className="inline-flex items-center ">
          <div className="px-3 break-word"> {toastProps.message->React.string} </div>
          {switch toastProps.buttonText {
          | Some(text) =>
            <div className="border-l">
              <div className="ml-2 border rounded-full pl-2 pr-2 cursor-pointer">
                <span className="text-sm" onClick={_ => onClickButtonText()}>
                  {React.string(text)}
                </span>
              </div>
            </div>
          | None => React.null
          }}
        </div>
      </AddDataAttributes>
    </div>
  }
}

module Toast = {
  external convertToWebapiEvent: ReactEvent.Mouse.t => Webapi.Dom.Event.t = "%identity"

  @react.component
  let make = (~toastProps: ToastState.toastProps, ~hideToast, ~toastDuration) => {
    let stopPropagation = React.useCallback0(ev => {
      ev->convertToWebapiEvent->Webapi.Dom.Event.stopPropagation
    })
    <div className=" m-2 shadow-lg z-100 pointer-events-auto" onClick=stopPropagation>
      <ToastHeading toastProps hideToast toastDuration />
    </div>
  }
}

@react.component
let make = (~children) => {
  let (openToasts, setOpenToasts) = Recoil.useRecoilState(ToastState.openToasts)

  let hideToast = React.useCallback1(key => {
    setOpenToasts(.prevArr => {
      Array.filter(
        prevArr,
        (toastProps: ToastState.toastProps) => {
          toastProps.toastKey !== key
        },
      )
    })
  }, [setOpenToasts])

  let toastClass = "items-center justify-start"

  let widthClass = "w-max max-w-4xl"

  <div className="relative">
    children
    <div>
      <div
        className={`absolute inset-0 overflow-scroll flex flex-col pointer-events-none m-4 ${toastClass} no-scrollbar`}>
        <div className={`flex flex-col pointer-events-auto w-auto ${widthClass}`}>
          {openToasts
          ->Array.map(toastProps => {
            if toastProps.toastElement != React.null {
              toastProps.toastElement
            } else {
              <Toast
                key={toastProps.toastKey}
                toastProps
                hideToast
                toastDuration={toastProps.toastDuration}
              />
            }
          })
          ->React.array}
        </div>
      </div>
    </div>
  </div>
}
