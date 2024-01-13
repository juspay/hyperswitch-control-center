open PopUpState
open PopUpConfirmUtils

external toMouseEvent: JsxEvent.synthetic<ReactEvent.Keyboard.tag> => JsxEvent.synthetic<
  JsxEvent.Mouse.tag,
> = "%identity"

module Close = {
  @react.component
  let make = (~onClick) => {
    <AddDataAttributes attributes=[("data-component", `popUpConfirmClose`)]>
      {onClick->getCloseIcon}
    </AddDataAttributes>
  }
}

@react.component
let make = (
  ~handlePopUp,
  ~handleConfirm=?,
  ~handleCancel=?,
  ~confirmType,
  ~confirmText: React.element,
  ~confirmButtonDisabled=false,
  ~buttonText: option<string>=?,
  ~confirmButtonIcon: Button.iconType=NoIcon,
  ~cancelButtonIcon: Button.iconType=NoIcon,
  ~popUpType: popUpType=Warning,
  ~cancelButtonText: option<string>=?,
  ~showIcon: bool=false,
  ~showPopUp,
  ~showCloseIcon=true,
  ~popUpSize: popUpSize=Large,
) => {
  let isMobileView = MatchMedia.useMobileChecker()
  let (popUpHeadingColor, topBorderColor) = switch popUpType {
  | Success => ("bg-green-800", "border-t-green-800")
  | Primary => ("bg-blue-800", "border-t-blue-800")
  | Secondary => ("bg-yellow-300", "border-t-yellow-300")
  | Danger | Denied => ("bg-red-600", "border-t-red-600")
  | Warning => ("bg-orange-960", "border-t-orange-960")
  }
  let appPrefix = LogicUtils.useUrlPrefix()
  let rounded_top_border = "rounded-t-xl"

  let btnWidthClass = isMobileView ? "w-full" : ""
  let customButtonStyle = `px-2 py-0 h-9 rounded-md ${btnWidthClass}`
  let textStyle = "font-medium text-fs-13"
  let showModal = showPopUp ? "flex" : "hidden"
  let popupMargin = isMobileView ? "pt-4 pl-4" : "pr-4 pl-8 pt-6"
  let btnPosition = isMobileView ? "gap-6 justify-between" : "gap-4 justify-end"
  let paddingCss = isMobileView ? "px-4" : "px-8"

  let handleOverlayClick = ev => {
    open ReactEvent.Mouse
    ev->stopPropagation
  }

  let actionButton = switch buttonText {
  | Some(text) =>
    let buttonType: Button.buttonType = switch popUpType {
    | Success
    | Primary
    | Secondary
    | Warning =>
      Primary
    | Danger | Denied => Delete
    }
    let buttonState: Button.buttonState = confirmButtonDisabled ? Button.Disabled : Button.Normal
    switch handleConfirm {
    | Some(onClick) =>
      <Button
        leftIcon=confirmButtonIcon buttonType text onClick textStyle customButtonStyle buttonState
      />
    | None =>
      <Button
        leftIcon=confirmButtonIcon
        buttonType
        text
        textStyle
        customButtonStyle
        type_="submit"
        buttonState
      />
    }
  | _ => React.null
  }

  let cancelButton = switch cancelButtonText {
  | Some(text) =>
    let buttonType: Button.buttonType = SecondaryFilled
    switch handleCancel {
    | Some(onClick) =>
      <Button buttonType text onClick textStyle customButtonStyle leftIcon=cancelButtonIcon />
    | None =>
      <Button
        buttonType text onClick=handlePopUp textStyle customButtonStyle leftIcon=cancelButtonIcon
      />
    }
  | None => React.null
  }

  let handleKeyUp = ev => {
    open ReactEvent.Keyboard
    let key = ev->key
    let keyCode = ev->keyCode
    if key === "Escape" || keyCode === 27 {
      switch handleCancel {
      | Some(onClick) => onClick(ev->toMouseEvent)
      | None => ()
      }
    }
  }

  React.useEffect1(() => {
    if showPopUp {
      Window.addEventListener("keyup", handleKeyUp)
    } else {
      Window.removeEventListener("keyup", handleKeyUp)
    }

    Some(
      () => {
        Window.removeEventListener("keyup", handleKeyUp)
      },
    )
  }, [showPopUp])

  <AddDataAttributes attributes=[("data-component", `popUpConfirm ${confirmType}`)]>
    <div
      className={`${showModal} ${overlayStyle} fixed cursor-default h-screen w-screen z-100 inset-0 overflow-auto`}
      onClick=handleOverlayClick>
      // <Reveal showReveal=showPopUp revealFrom=Reveal.Top>
      <div
        className={`${topBorderColor} absolute lg:top-1/3 md:top-1/3 left-0 lg:left-1/3 border border-jp-gray-500 dark:border-jp-gray-960 w-full bottom-0 md:bottom-auto ${modalWidth} bg-jp-gray-100 dark:bg-jp-gray-lightgray_background shadow ${containerBorderRadius} z-20 dark:text-opacity-75 ${rounded_top_border}`}>
        <div className={`h-2 w-12/12 p-0 mt-0 ${popUpHeadingColor} ${rounded_top_border}`} />
        <div className={`flex flex-row ${popupMargin} justify-between`}>
          <div className="flex flex-row gap-5 pt-4 items-center w-full">
            <UIUtils.RenderIf condition=showIcon>
              {switch popUpType {
              | Warning =>
                <img className=imageStyle src={`${appPrefix}/icons/warning.svg`} alt="warning" />
              | Danger =>
                <img className=imageStyle src={`${appPrefix}/icons/error.svg`} alt="danger" />
              | Success => <Icon className=iconStyle size=40 name="check-circle" />
              | Primary => <Icon className=iconStyle size=40 name="info-circle" />
              | Secondary => <Icon className=iconStyle size=40 name="info-circle" />
              | Denied => <Icon name="denied" size=50 className=iconStyle />
              }}
            </UIUtils.RenderIf>
            <div className="w-full">
              <AddDataAttributes attributes=[("data-header-text", confirmType)]>
                <div className=headerStyle> {confirmType->React.string} </div>
              </AddDataAttributes>
              <AddDataAttributes attributes=[("data-description-text", "popUp Confirmation")]>
                <div className=subHeaderStyle> {confirmText} </div>
              </AddDataAttributes>
            </div>
          </div>
          <div className="flex justify-end ">
            <UIUtils.RenderIf condition=showCloseIcon>
              <Close onClick=handlePopUp />
            </UIUtils.RenderIf>
          </div>
        </div>
        <div className={`flex justify-between items-center flex-row ${paddingCss} py-4 mt-4`}>
          <div className={`flex flex-row items-center w-full ${btnPosition}`}>
            {cancelButton}
            {actionButton}
          </div>
        </div>
      </div>
      //  </Reveal>
    </div>
  </AddDataAttributes>
}
