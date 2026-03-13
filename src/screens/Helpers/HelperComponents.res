open Typography

module CopyTextCustomComp = {
  @react.component
  let make = (
    ~displayValue=None,
    ~copyValue=None,
    ~customTextCss="",
    ~customParentClass="flex items-center gap-2",
    ~customOnCopyClick=() => (),
    ~customIconCss="h-7 opacity-70",
    ~customIcon="nd-copy",
    ~customIconSize=15,
    ~customComponent=None,
  ) => {
    let showToast = ToastState.useShowToast()

    let copyVal = switch copyValue {
    | Some(val) => val
    | None =>
      switch displayValue {
      | Some(val) => val
      | None => ""
      }
    }
    let onCopyClick = ev => {
      ev->ReactEvent.Mouse.stopPropagation
      Clipboard.writeText(copyVal)
      customOnCopyClick()
      showToast(~message="Copied to Clipboard!", ~toastType=ToastSuccess)
    }

    switch displayValue {
    | Some(val) =>
      <div
        className={`${customParentClass} cursor-pointer`}
        onClick={ev => {
          onCopyClick(ev)
        }}>
        <div className=customTextCss> {val->React.string} </div>
        {switch customComponent {
        | Some(element) => element
        | None => <Icon size={customIconSize} name={customIcon} className={`${customIconCss} `} />
        }}
      </div>
    | None => "NA"->React.string
    }
  }
}

module EllipsisText = {
  @react.component
  let make = (
    ~displayValue,
    ~copyValue=None,
    ~endValue=17,
    ~showCopy=true,
    ~customTextStyle="",
    ~customEllipsisStyle="text-sm font-extrabold cursor-pointer",
    ~expandText=true,
    ~customOnCopyClick=_ => (),
  ) => {
    open LogicUtils
    let showToast = ToastState.useShowToast()
    let (isTextVisible, setIsTextVisible) = React.useState(_ => false)

    let handleClick = ev => {
      ev->ReactEvent.Mouse.stopPropagation
      if expandText {
        setIsTextVisible(_ => true)
      }
    }

    let copyVal = switch copyValue {
    | Some(val) => val
    | None => displayValue
    }

    let onCopyClick = ev => {
      ev->ReactEvent.Mouse.stopPropagation
      Clipboard.writeText(copyVal)
      customOnCopyClick()
      showToast(~message="Copied to Clipboard!", ~toastType=ToastSuccess)
    }

    <div className="flex text-nowrap gap-2">
      <RenderIf condition={isTextVisible}>
        <div className={customTextStyle}> {displayValue->React.string} </div>
      </RenderIf>
      <RenderIf condition={!isTextVisible && displayValue->isNonEmptyString}>
        <div className="flex gap-1">
          <p className={customTextStyle}>
            {`${displayValue->String.slice(~start=0, ~end=endValue)}`->React.string}
          </p>
          <RenderIf condition={displayValue->String.length > endValue}>
            <span className={customEllipsisStyle} onClick={ev => handleClick(ev)}>
              {"..."->React.string}
            </span>
          </RenderIf>
        </div>
      </RenderIf>
      <RenderIf condition={showCopy}>
        <Icon
          name="nd-copy" className="cursor-pointer opacity-70" onClick={ev => onCopyClick(ev)}
        />
      </RenderIf>
    </div>
  }
}

module KeyAndCopyArea = {
  @react.component
  let make = (~copyValue, ~shadowClass="") => {
    let showToast = ToastState.useShowToast()

    <div className={`flex gap-4 border rounded-md py-2 px-4 items-center bg-white ${shadowClass}`}>
      <p className="text-base text-grey-700 opacity-70 col-span-2 truncate">
        {copyValue->React.string}
      </p>
      <div
        className="px-2 py-1 border rounded-md flex gap-2 items-center cursor-pointer"
        onClick={_ => {
          Clipboard.writeText(copyValue)
          showToast(~message="Copied to Clipboard!", ~toastType=ToastSuccess)
        }}>
        <Icon name="nd-copy" customIconColor="rgb(156 163 175)" />
        <p className="text-grey-700 opacity-50"> {"Copy"->React.string} </p>
      </div>
    </div>
  }
}

module ConnectorCustomCell = {
  @react.component
  let make = (
    ~connectorName,
    ~connectorType: option<ConnectorTypes.connector>=?,
    ~customIconStyle="w-6 h-6 mr-2",
    ~showDefaultTag=false,
  ) => {
    let connector_Type = switch connectorType {
    | Some(connectorType) => connectorType
    | None => ConnectorTypes.Processor
    }
    if connectorName->LogicUtils.isNonEmptyString {
      <div className="flex items-center">
        <div className="flex items-center flex-nowrap break-all whitespace-nowrap mr-4">
          <GatewayIcon
            gateway={connectorName->String.toUpperCase} className={`${customIconStyle}`}
          />
          <div>
            {connectorName
            ->ConnectorUtils.getDisplayNameForConnector(~connectorType=connector_Type)
            ->React.string}
          </div>
        </div>
        <RenderIf condition={showDefaultTag}>
          <div
            className={`border border-nd_gray-200 bg-nd_gray-50 px-2 py-2-px rounded-lg ${body.sm.semibold}`}>
            {"Default"->React.string}
          </div>
        </RenderIf>
      </div>
    } else {
      "NA"->React.string
    }
  }
}

module ProfileNameComponent = {
  @react.component
  let make = (~profile_id: string, ~className="") => {
    let {name} =
      HyperswitchAtom.profileListAtom
      ->Recoil.useRecoilValueFromAtom
      ->Array.find(obj => obj.id == profile_id)
      ->Option.getOr({
        id: profile_id,
        name: "NA",
      })
    <div className> {(name->LogicUtils.isNonEmptyString ? name : "NA")->React.string} </div>
  }
}

module AutoSubmitter = {
  @react.component
  let make = (~autoApply, ~submit, ~defaultFilterKeys=[], ~submitInputOnEnter) => {
    let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
      ReactFinalForm.useFormSubscription(["values", "dirtyFields"])->Nullable.make,
    )
    let form = ReactFinalForm.useForm()
    React.useEffect(() => {
      let onKeyDown = ev => {
        let keyCode = ev->ReactEvent.Keyboard.keyCode
        if keyCode === 13 && submitInputOnEnter {
          form.submit()->ignore
        }
      }
      Window.addEventListener("keydown", onKeyDown)
      Some(() => Window.removeEventListener("keydown", onKeyDown))
    }, [])

    React.useEffect(() => {
      if formState.dirty {
        let defaultFieldsHaveChanged = defaultFilterKeys->Array.some(key => {
          formState.dirtyFields->Dict.get(key)->Option.getOr(false)
        })
        if autoApply || defaultFieldsHaveChanged {
          submit(formState.values, 0)->ignore
        }
      }

      None
    }, [formState.values])

    React.null
  }
}
