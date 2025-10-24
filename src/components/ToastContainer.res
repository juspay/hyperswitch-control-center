module ToastHeading = {
  @react.component
  let make = (~toastProps: ToastState.toastProps, ~hideToast, ~toastDuration=0) => {
    React.useEffect(() => {
      let duration = if toastDuration == 0 {
        3000
      } else {
        toastDuration
      }
      let timeout = {
        setTimeout(() => {
          hideToast(toastProps.toastKey)
        }, duration)
      }
      Some(
        () => {
          clearTimeout(timeout)
        },
      )
    }, (hideToast, toastProps))

    let toastColorClasses = switch toastProps.toastType {
    | ToastError => "border-l-red-status"
    | ToastWarning => "border-l-orange-500"
    | ToastInfo => "border-l-blue-600"
    | ToastSuccess => "border-l-green-status"
    }

    let toastIconName = switch toastProps.toastType {
    | ToastSuccess => "nd-toast-success"
    | ToastError
    | ToastWarning => "nd-toast-warning"
    | ToastInfo => "nd-toast-info"
    }

    let toastIconColorClass = switch toastProps.toastType {
    | ToastSuccess => "text-green-status"
    | ToastError => "text-red-status"
    | ToastWarning => "text-orange-400"
    | ToastInfo => "text-nd_primary_blue-500"
    }

    let onClickButtonText = () => {
      RescriptReactRouter.push(
        switch toastProps.helpLink {
        | Some(str) => GlobalVars.appendDashboardPath(~url=str)
        | None => GlobalVars.appendDashboardPath(~url="")
        },
      )
    }

    <div
      className={`${toastColorClasses} rounded-lg shadow-sm bg-white border border-l-4 p-4 flex items-center justify-between`}>
      <div className="flex items-center">
        <Icon className={`${toastIconColorClass} mr-3`} name=toastIconName />
        <AddDataAttributes attributes=[("data-toast", toastProps.message)]>
          <div className="text-gray-800 font-medium"> {toastProps.message->React.string} </div>
        </AddDataAttributes>
      </div>
      {switch toastProps.buttonText {
      | Some(text) =>
        <div className="ml-4">
          <button
            onClick={_ => onClickButtonText()}
            className="text-sm text-gray-600 hover:text-gray-800 font-medium">
            {React.string(text)}
          </button>
        </div>
      | None => React.null
      }}
    </div>
  }
}

module Toast = {
  external convertToWebapiEvent: ReactEvent.Mouse.t => Webapi.Dom.Event.t = "%identity"

  @react.component
  let make = (~toastProps: ToastState.toastProps, ~hideToast, ~toastDuration) => {
    let stopPropagation = React.useCallback(ev => {
      ev->convertToWebapiEvent->Webapi.Dom.Event.stopPropagation
    }, [])
    <div className="m-2 shadow-lg rounded-lg pointer-events-auto z-50" onClick=stopPropagation>
      <ToastHeading toastProps hideToast toastDuration />
    </div>
  }
}

module CustomToastWrapper = {
  @react.component
  let make = (~toastProps: ToastState.toastProps, ~hideToast, ~toastDuration) => {
    React.useEffect(() => {
      let duration = if toastDuration == 0 {
        5000
      } else {
        toastDuration
      }
      let timeout = setTimeout(() => {
        hideToast(toastProps.toastKey)
      }, duration)

      Some(
        () => {
          clearTimeout(timeout)
        },
      )
    }, [toastProps.toastKey])

    toastProps.toastElement
  }
}

@react.component
let make = (~children) => {
  let (openToasts, setOpenToasts) = Recoil.useRecoilState(ToastState.openToasts)

  let hideToast = React.useCallback(key => {
    setOpenToasts(prevArr => {
      Array.filter(
        prevArr,
        (toastProps: ToastState.toastProps) => {
          toastProps.toastKey !== key
        },
      )
    })
  }, [setOpenToasts])

  <div className="relative">
    {children}
    <div>
      <div
        className="fixed top-4 left-1/2 transform -translate-x-1/2 flex flex-col gap-2 pointer-events-none max-w-md z-50">
        {openToasts
        ->Array.map(toastProps => {
          if toastProps.toastElement != React.null {
            <CustomToastWrapper
              key={toastProps.toastKey}
              toastProps
              hideToast
              toastDuration={toastProps.toastDuration}
            />
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
}
