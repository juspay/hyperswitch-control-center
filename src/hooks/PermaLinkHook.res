module BuildPermaLinkUrl = {
  // Utility function for building permalink URLs
  let buildPermaLinkUrl = (~orgId, ~merchantId, ~profileId, ~version) => {
    let url = Window.URL.make(
      `${Window.Location.origin}/${orgId}/${merchantId}/${profileId}/${version}/switch/user`,
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
}

// Reusable PermaLink Button Component
module PermaLinkButton = {
  @react.component
  let make = (~buildPermLink, ~onCopyClick=() => ()) => {
    <>
      <ToolTip
        description="This link encodes the current Organization → Merchant → Profile context and will send recipients to the same page and navigation hierarchy"
        toolTipFor={<HelperComponents.CopyTextCustomComp
          copyValue={Some(buildPermLink())}
          displayValue=Some("")
          customIcon="nd-permalink"
          customParentClass=""
          customIconCss=""
          customOnCopyClick={() => onCopyClick()}
        />}
        toolTipPosition=ToolTip.Top
      />
    </>
  }
}

type permaLinkHook = {
  buildPermLink: unit => string,
  permaLinkButton: React.element,
}

let usePermaLink = () => {
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let {userInfo: {orgId, merchantId, profileId, version}} = React.useContext(
    UserInfoProvider.defaultContext,
  )

  let handleDeepLinkClick = () => {
    mixpanelEvent(~eventName="copy_deep_link")
  }

  let buildPermLink = React.useCallback(() => {
    let version = (version :> string)
    BuildPermaLinkUrl.buildPermaLinkUrl(~orgId, ~merchantId, ~profileId, ~version)
  }, [orgId, merchantId, profileId])

  let permaLinkButton = <PermaLinkButton buildPermLink onCopyClick=handleDeepLinkClick />

  {
    buildPermLink,
    permaLinkButton,
  }
}
