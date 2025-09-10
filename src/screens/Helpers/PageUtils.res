module DialogBox = {
  @react.component
  let make = (~isOpen: bool, ~onClose: unit => unit) => {
    open Typography

    let handleKeyUp = ev => {
      open ReactEvent.Keyboard
      let key = ev->key
      let keyCode = ev->keyCode
      if key === "Escape" || keyCode === 27 {
        onClose()
      }
    }

    React.useEffect(() => {
      if isOpen {
        setTimeout(() => {
          onClose()
        }, 3000)->ignore
        Window.addEventListener("keyup", handleKeyUp)
      } else {
        Window.removeEventListener("keyup", handleKeyUp)
      }

      Some(
        () => {
          Window.removeEventListener("keyup", handleKeyUp)
        },
      )
    }, [isOpen])

    <RenderIf condition=isOpen>
      <div
        className="z-50 absolute flex opacity-100 w-[370px] left-[350px]" onClick={_ => onClose()}>
        <div
          className="bg-white rounded-lg shadow  overflow-hidden"
          onClick={e => e->ReactEvent.Mouse.stopPropagation}
          role="dialog"
          ariaLabelledby="dialog-title"
          ariaModal=true>
          <div className="flex items-center justify-between p-4 sm:p-6 pb-3 sm:pb-4">
            <div className="flex items-center gap-2">
              <div id="dialog-title" className={`${heading.md.semibold} text-gray-900`}>
                {"Share this page"->React.string}
              </div>
            </div>
            <div className="cursor-pointer" onClick={_ => onClose()}>
              <Icon name="close" size=10 className="text-gray-500" />
            </div>
          </div>
          <div className="px-4 sm:px-6 pb-3 sm:pb-4">
            <div className={`${body.md.medium} text-gray-600 leading-relaxed`}>
              {"This link encodes the current Organization → Merchant → Profile context and will send recipients directly to the same page and navigation hierarchy"->React.string}
            </div>
          </div>
          <div className="px-4 sm:px-6 pb-4 sm:pb-6 flex cursor-pointer" onClick={_ => onClose()}>
            <p className={`${body.md.bold} text-blue-500`}> {"Got it!"->React.string} </p>
          </div>
        </div>
      </div>
    </RenderIf>
  }
}
module PageHeading = {
  @react.component
  let make = (
    ~title,
    ~subTitle=?,
    ~customTitleStyle="",
    ~customSubTitleStyle="text-lg font-medium",
    ~customHeadingStyle="py-2",
    ~isTag=false,
    ~tagText="",
    ~customTagStyle="bg-extra-light-grey border-light-grey",
    ~leftIcon=None,
    ~customTagComponent=?,
    ~customTitleSectionStyles="",
    ~showPermLink=true,
  ) => {
    // let (showShareDialog, setShowShareDialog) = React.useState(_ => false)
    let {userInfo: {orgId, merchantId, profileId, version}} = React.useContext(
      UserInfoProvider.defaultContext,
    )
    let mixpanelEvent = MixpanelHook.useSendEvent()
    let buildPermLink = () => {
      let url = Window.URL.make(
        `${Window.Location.origin}/${orgId}/${merchantId}/${profileId}/${(version :> string)}/switch/user`,
        `${Window.Location.origin}`,
      )
      let queryParams = Window.Location.search
      let path = `${Window.Location.pathName->Js.String2.replaceByRe(
          Js.Re.fromString("/dashboard"),
          "",
        )}${queryParams}`
      url->Window.URL.searchParams->Window.URL.append("path", path)
      url->Window.URL.href
    }
    let handleDeepLinkClick = () => {
      // setShowShareDialog(_ => true)
      mixpanelEvent(~eventName="copy_deep_link")
    }

    let headerTextStyle = HSwitchUtils.getTextClass((H1, Optional))
    <div className={`${customHeadingStyle}`}>
      {switch leftIcon {
      | Some(icon) => <Icon name={icon} size=56 />
      | None => React.null
      }}
      <div className={`flex items-center gap-4 ${customTitleSectionStyles}`}>
        <div className={`${headerTextStyle} ${customTitleStyle}`}> {title->React.string} </div>
        <RenderIf condition=showPermLink>
          <HelperComponents.CopyTextCustomComp
            copyValue={Some(buildPermLink())}
            displayValue=Some("")
            customIcon="nd-permalink"
            customParentClass=""
            customIconCss=""
            customOnCopyClick={() => handleDeepLinkClick()}
          />
        </RenderIf>
        <RenderIf condition=isTag>
          <div
            className={`text-sm text-grey-700 font-semibold border  rounded-full px-2 py-1 ${customTagStyle}`}>
            {tagText->React.string}
          </div>
        </RenderIf>
        <RenderIf condition={!isTag && customTagComponent->Option.isSome}>
          {customTagComponent->Option.getOr(React.null)}
        </RenderIf>
      </div>
      {switch subTitle {
      | Some(text) =>
        <RenderIf condition={text->LogicUtils.isNonEmptyString}>
          <div className={`opacity-50 mt-2 ${customSubTitleStyle}`}> {text->React.string} </div>
        </RenderIf>
      | None => React.null
      }}
      // <DialogBox isOpen=showShareDialog onClose={() => setShowShareDialog(_ => false)} />
    </div>
  }
}
