open ModalUtils

type modalData = {
  heading: string,
  content: React.element,
}

module Back = {
  @react.component
  let make = (~onClick) => {
    <Icon
      size=18 name="chevron-left" className="cursor-pointer opacity-50 dark:opacity-100 " onClick
    />
  }
}

module ModalHeading = {
  @react.component
  let make = (
    ~headingClass,
    ~headerTextClass,
    ~headerAlignmentClass,
    ~modalHeading,
    ~showCloseIcon,
    ~showCloseOnLeft,
    ~showBackIcon,
    ~leftHeadingIcon,
    ~rightHeading,
    ~onCloseClick,
    ~onBackClick,
    ~modalHeadingDescription,
    ~modalSubInfo,
    ~showBorderBottom,
    ~centerHeading=false,
    ~headBgClass,
    ~modalHeadingDescriptionElement,
    ~showModalHeadingIconName,
    ~modalHeadingClass,
    ~modalParentHeadingClass,
    ~customIcon,
  ) => {
    let isHyperSwitchDashboard = HSwitchGlobalVars.isHyperSwitchDashboard
    let borderClass =
      showBorderBottom && !isHyperSwitchDashboard
        ? "border-b border-jp-gray-940 border-opacity-75 dark:border-jp-gray-960 dark:border-opacity-75"
        : ""

    let isMobileView = MatchMedia.useMatchMedia("(max-width: 700px)")

    let justifyClass = centerHeading ? "justify-center" : "justify-between"
    let headerTextClass = isMobileView ? "text-fs-18 font-semibold" : headerTextClass

    let descriptionStyle = isHyperSwitchDashboard
      ? "text-md font-medium leading-7 opacity-50 mt-1 w-full max-w-sm "
      : "text-sm mt-1 w-10/12 empty:hidden"

    let subInfoStyle = isHyperSwitchDashboard
      ? "text-md font-medium leading-7 opacity-50 mt-1 w-full max-w-sm empty:hidden"
      : "text-sm empty:hidden"

    <div
      className={`!p-4 ${headBgClass !== ""
          ? headBgClass
          : "bg-jp-gray-200 dark:bg-jp-gray-darkgray_background"} rounded-t-lg z-10  w-full  m-0 md:!pl-6  ${headingClass} ${borderClass} `}>
      {switch leftHeadingIcon {
      | Some(icon) =>
        <div className="fill-current flex-col justify-between h-0 bg-jp-gray-100">
          <div className="fill-current"> icon </div>
        </div>
      | None => React.null
      }}
      <div className={`flex ${headerAlignmentClass} ${justifyClass} ${headerTextClass}`}>
        <div className=modalParentHeadingClass>
          {if showCloseIcon && showCloseOnLeft && !showBackIcon {
            onCloseClick->ModalUtils.getCloseIcon
          } else {
            React.null
          }}
          {if showBackIcon {
            <div className="mr-4 pt-1.5">
              <Back onClick=onBackClick />
            </div>
          } else {
            React.null
          }}
          {if showModalHeadingIconName !== "" {
            <div className="flex items-center gap-4">
              {switch customIcon {
              | Some(icon) => icon
              | None => <Icon name=showModalHeadingIconName size=35 className="" />
              }}
              <AddDataAttributes attributes=[("data-modal-header-text", modalHeading)]>
                <div
                  className="font-inter-style font-semibold text-fs-16 leading-6 text-jp-2-gray-600">
                  {React.string(modalHeading)}
                </div>
              </AddDataAttributes>
            </div>
          } else {
            <AddDataAttributes attributes=[("data-modal-header-text", modalHeading)]>
              <div className={`${modalHeadingClass}`}> {React.string(modalHeading)} </div>
            </AddDataAttributes>
          }}
        </div>
        {switch rightHeading {
        | Some(rightHeadingElement) => rightHeadingElement
        | None => React.null
        }}
        {if showCloseIcon && !showCloseOnLeft {
          onCloseClick->ModalUtils.getCloseIcon
        } else {
          React.null
        }}
      </div>
      {if modalHeadingDescriptionElement !== React.null {
        modalHeadingDescriptionElement
      } else {
        <AddDataAttributes attributes=[("data-modal-description-text", modalHeading)]>
          <div className=descriptionStyle> {React.string(modalHeadingDescription)} </div>
        </AddDataAttributes>
      }}
      <div className=subInfoStyle> {React.string(modalSubInfo)} </div>
    </div>
  }
}

module ModalContent = {
  @react.component
  let make = (~handleContainerClick, ~bgClass, ~modalClass, ~children, ~customHeight="h-fit") => {
    <div
      id="neglectTopbarTheme"
      onClick=handleContainerClick
      className={`border border-jp-gray-500 dark:border-jp-gray-900 ${bgClass} shadow rounded-lg dark:text-opacity-75 dark:bg-jp-gray-darkgray_background ${modalClass} ${customHeight}`}>
      children
    </div>
  }
}

module ModalOverlay = {
  @react.component
  let make = (
    ~handleOverlayClick,
    ~showModal,
    ~children,
    ~paddingClass,
    ~modalHeading,
    ~overlayBG,
    ~modalPosition="",
    ~noBackDrop=false,
    ~isBackdropBlurReq=true,
    ~addAttributeId="",
    ~alignModal,
  ) => {
    let isMobileView = MatchMedia.useMatchMedia("(max-width: 700px)")
    let mobileClass = isMobileView ? "flex flex-col " : ""
    let displayClass = showModal ? "block" : "hidden"
    let overlayBgStyle = HSwitchGlobalVars.isHyperSwitchDashboard
      ? isBackdropBlurReq ? `bg-grey-700 bg-opacity-50` : ""
      : overlayBG
    let backgroundDropStyles = isBackdropBlurReq ? "backdrop-blur-sm" : ""

    let attributeId =
      addAttributeId === ""
        ? switch modalHeading {
          | Some(_heading) => `:${modalHeading->Belt.Option.getWithDefault("")}`
          | None => ""
          }
        : `:${addAttributeId}`

    let zIndexClass = "z-40"

    <AddDataAttributes attributes=[("data-component", `modal` ++ attributeId)]>
      {noBackDrop
        ? <div className={`${displayClass} ${paddingClass} fixed inset-0 ${zIndexClass}`}>
            children
          </div>
        : <div
            onClick={handleOverlayClick}
            className={`${mobileClass} ${displayClass} ${overlayBgStyle} fixed h-screen w-screen ${zIndexClass} ${modalPosition} ${paddingClass} flex ${alignModal} inset-0 overflow-auto ${backgroundDropStyles}`}>
            children
          </div>}
    </AddDataAttributes>
  }
}

@react.component
let make = (
  ~showModal,
  ~setShowModal,
  ~children,
  ~modalHeading=?,
  ~customModalHeading=?,
  ~bgClass="bg-white dark:bg-jp-gray-lightgray_background",
  ~modalClass="md:mt-20 overflow-auto",
  ~childClass="p-2 m-2",
  ~headingClass="p-2",
  ~paddingClass="pt-12",
  ~centerHeading=false,
  ~modalHeadingDescription="",
  ~modalSubInfo="",
  ~closeOnOutsideClick=false,
  ~headerTextClass="font-bold text-fs-24",
  ~borderBottom=true,
  ~showCloseIcon=true,
  ~showCloseOnLeft=false,
  ~showBackIcon=false,
  ~leftHeadingIcon=?,
  ~rightHeading=?,
  ~onBackClick=_ => (),
  ~headBgClass="bg-white dark:bg-jp-gray-darkgray_background",
  ~revealFrom=Reveal.Top,
  ~modalHeadingDescriptionElement=React.null,
  ~onCloseClickCustomFun=_ => (),
  ~modalFooter=React.null,
  ~overlayBG="bg-jp-gray-950 dark:bg-white-600 dark:bg-opacity-80 bg-opacity-70",
  ~showModalHeadingIconName="",
  ~customHeight=?,
  ~modalHeadingClass="",
  ~modalPosition="",
  ~modalParentHeadingClass="flex flex-row flex-1",
  ~headerAlignmentClass="flex-row",
  ~noBackDrop=false,
  ~isBackdropBlurReq=true,
  ~addAttributeId="",
  ~customIcon=None,
  ~alignModal="justify-end",
) => {
  let showBorderBottom = borderBottom
  let _ = revealFrom

  let headerTextClass = headerTextClass->getHeaderTextClass

  let onCloseClick = _evt => {
    setShowModal(prev => !prev)
    onCloseClickCustomFun()
  }
  let onBackClick = _evt => onBackClick()

  let handleOverlayClick = ev => {
    if closeOnOutsideClick {
      open ReactEvent.Mouse
      ev->stopPropagation
      onCloseClick(ev)
      setShowModal(_ => false)
    }
  }

  let handleKeyUp = ev => {
    if closeOnOutsideClick {
      open ReactEvent.Keyboard

      let key = ev->key
      let keyCode = ev->keyCode
      if key === "Escape" || keyCode === 27 {
        setShowModal(_ => false)
      }
    }
  }

  React.useEffect2(() => {
    if showModal {
      Window.addEventListener("keyup", handleKeyUp)
    } else {
      Window.removeEventListener("keyup", handleKeyUp)
    }

    Some(
      () => {
        Window.removeEventListener("keyup", handleKeyUp)
      },
    )
  }, (showModal, closeOnOutsideClick))

  let handleContainerClick = ev => {
    if closeOnOutsideClick {
      open ReactEvent.Mouse
      ev->stopPropagation
    }
  }

  let animationClass = showModal->getAnimationClass

  <ModalOverlay
    showModal
    handleOverlayClick
    paddingClass
    modalHeading
    overlayBG
    modalPosition
    noBackDrop
    isBackdropBlurReq
    alignModal
    addAttributeId>
    // <Reveal showReveal=showModal revealFrom>
    <ModalContent
      handleContainerClick
      bgClass
      ?customHeight
      modalClass={`${animationClass} ${modalClass}`}
      key={showModal ? "true" : "false"}>
      {switch modalHeading {
      | Some(modalHeading) =>
        <ModalHeading
          headingClass
          headerTextClass
          headerAlignmentClass
          modalHeading
          showCloseIcon
          showCloseOnLeft
          showBackIcon
          leftHeadingIcon
          rightHeading
          onBackClick
          onCloseClick
          modalHeadingDescription
          modalSubInfo
          showBorderBottom
          centerHeading
          headBgClass
          modalHeadingDescriptionElement
          showModalHeadingIconName
          modalHeadingClass
          modalParentHeadingClass
          customIcon
        />

      | None => React.null
      }}
      {switch customModalHeading {
      | Some(element) => element
      | None => React.null
      }}
      <div className=childClass> children </div>
      {if modalFooter != React.null {
        <div className="h-[5rem]"> modalFooter </div>
      } else {
        React.null
      }}
    </ModalContent>
    // </Reveal>
  </ModalOverlay>
}
