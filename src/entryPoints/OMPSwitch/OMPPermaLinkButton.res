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

@react.component
let make = (~permaLinkFor=?) => {
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let {userInfo: {orgId, merchantId, profileId, version}} = React.useContext(
    UserInfoProvider.defaultContext,
  )
  let handleDeepLinkClick = () => {
    mixpanelEvent(~eventName="copy_deep_link")
  }
  let permaLink = React.useMemo(() => {
    let version = (version :> string)
    BuildPermaLinkUrl.buildPermaLinkUrl(~orgId, ~merchantId, ~profileId, ~version)
  }, [orgId, merchantId, profileId])

  let customComponent = switch permaLinkFor {
  | Some(comp) => Some(comp)
  | _ => None
  }
  <ToolTip
    description="This link keeps the Org → Merchant → Profile context and opens the same page."
    toolTipFor={<HelperComponents.CopyTextCustomComp
      copyValue={Some(permaLink)}
      displayValue=Some("")
      customIcon="nd-permalink"
      customParentClass=""
      customIconCss=""
      customOnCopyClick={() => handleDeepLinkClick()}
      customComponent={customComponent}
    />}
    toolTipPosition=ToolTip.Top
  />
}
