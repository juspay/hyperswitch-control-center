@react.component
let make = (
  ~modalHeading="Select Options",
  ~showModal,
  ~setShowModal,
  ~headerTextClass="text-2xl font-extrabold tracking-tight ml-3.5",
  ~element,
  ~revealFrom=Reveal.Right,
  ~closeOnOutsideClick=true,
  ~submitButtonText="Update",
  ~onSubmitModal,
  ~showLoderButton=false,
  ~totalNotifications=0,
  ~setNotificationCount=?,
  ~notificationCount=0,
  ~onBackClick,
  ~showBackIcon,
  ~modalWidth="w-[430px] !border-none",
  ~btnRequired=false,
  ~iconName="",
  ~showCloseIcon=true,
  ~onMarkAllAsReadClick=?,
  ~showMarkAllRead=false,
  ~refreshOutages=false,
  ~refresh=false,
  ~showModalHeadingIconName="",
  ~onCloseClickCustomFun=_ => (),
  ~iscollapasableSidebar=false,
  ~headingClassOverride="",
  ~overlayBG="!shadow-xl !blur-none !bg-none !backdrop-blur-none !rounded-none !border-transparent",
  ~isBackdropBlurReq=true,
  ~headerAlignmentClass="flex-row",
  ~customIcon=None,
) => {
  let customHeight = btnRequired === false ? `h-full` : `h-screen`
  let customButton =
    <Button
      text=submitButtonText
      buttonType=Primary
      buttonState={if refreshOutages {
        if refresh {
          Normal
        } else {
          Disabled
        }
      } else {
        Normal
      }}
      leftIcon={CustomIcon(
        <Icon
          name=iconName
          size=17
          className="-mr-1 jp-gray-900 fill-opacity-50 dark:jp-gray-text_darktheme ml-3"
        />,
      )}
      onClick={onSubmitModal}
    />
  <Modal
    modalHeading
    showModal
    setShowModal
    closeOnOutsideClick
    revealFrom
    showBackIcon
    showCloseIcon
    showModalHeadingIconName
    onBackClick
    onCloseClickCustomFun
    isBackdropBlurReq
    overlayBG
    modalClass={`${modalWidth} ${customHeight} float-right overflow-hidden !bg-white dark:!bg-jp-gray-lightgray_background !rounded-none !shadow-xl !backdrop-blur-none`}
    headingClass={`py-6 px-2.5 border-b border-solid border-slate-300 dark:border-slate-500 ${headingClassOverride}`}
    headerTextClass
    childClass="p-0 m-0"
    customIcon
    headerAlignmentClass
    paddingClass="pt-0 overflow-hidden">
    {showLoderButton && showMarkAllRead
      ? <div
          className="text-xs text-sky-500 relative -top-10 left-64 w-fit cursor-pointer"
          onClick={_ => {
            switch onMarkAllAsReadClick {
            | Some(onMarkAllAsReadClick) => onMarkAllAsReadClick()
            | _ => ()
            }
          }}>
          {React.string("Mark all as read")}
        </div>
      : React.null}
    <div
      className="overflow-auto p-6 border-b border-solid  border-slate-300 dark:border-slate-500 relative"
      style={ReactDOMStyle.make(~height=btnRequired ? "calc(100vh - 9.6rem)" : "100vh", ())}>
      element
      {showLoderButton && notificationCount > 10
        ? <div
            className="flex fixed items-center justify-center"
            style={ReactDOMStyle.make(~top="100px", ~right="100px", ())}>
            <Button
              text="Load Previous"
              customButtonStyle="rounded-full "
              rightIcon={FontAwesome("arrow-up")}
              onClick={_ => {
                switch setNotificationCount {
                | Some(setNotificationCount) => setNotificationCount(_ => notificationCount - 10)
                | _ => ()
                }
              }}
            />
          </div>
        : React.null}
      {totalNotifications - notificationCount > 0 && showLoderButton
        ? <div className="sticky bottom-20 flex items-center justify-center">
            <Button
              text="Load More"
              customButtonStyle="rounded-full bg-stone-800/50"
              rightIcon={FontAwesome("arrow-down")}
              onClick={_ => {
                switch setNotificationCount {
                | Some(setNotificationCount) => setNotificationCount(_ => notificationCount + 10)
                | _ => ()
                }
              }}
            />
          </div>
        : React.null}
    </div>
    {btnRequired
      ? <div className="flex items-center justify-center my-5">
          {if refreshOutages {
            if refresh {
              customButton
            } else {
              <ToolTip
                description="kindly wait at least 1 minute to make a refresh"
                toolTipFor=customButton
                toolTipPosition=ToolTip.Top
              />
            }
          } else {
            customButton
          }}
        </div>
      : React.null}
  </Modal>
}
