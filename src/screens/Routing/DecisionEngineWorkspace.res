open APIUtils
open LogicUtils
open DecisionEngineUtils

@react.component
let make = () => {
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod(~showErrorToast=false)
  let url = RescriptReactRouter.useUrl()
  let showToast = ToastAdapter.useShowToast()
  let {profileId} = React.useContext(UserInfoProvider.defaultContext).getCommonSessionDetails()
  let connectorList = HyperswitchAtom.connectorListAtom->Recoil.useRecoilValueFromAtom

  let (iframeSrc, setIframeSrc) = React.useState(_ => "")
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let lastMintAt = React.useRef(0.)
  let mintSeq = React.useRef(0)
  let skipNextMint = React.useRef(false)

  let sectionSlug = url.path->sectionSlugFromPath
  let ruleId = url.search->getDictFromUrlSearchParams->Dict.get("rule")->Option.getOr("")
  let section = sections->Array.find(s => s.slug === sectionSlug)->Option.getOr(defaultSection)

  let mintHandoff = async () => {
    let entryUrl = getURL(~entityName=V1(ROUTING), ~methodType=Get, ~id=Some("entry"))
    let res = await updateDetails(`${entryUrl}?target=${section.target}`, JSON.Encode.null, Post)
    let dict = res->getDictFromJsonObject
    (dict->getBool("is_cutover", false), dict->getString("redirect_url", ""))
  }

  let handoffFragment = () =>
    connectorList->RoutingUtils.decisionEngineHandoffFragment(
      ~profileId,
      ~ruleId,
      ~route=section.dePath,
    )

  let loadFrame = async () => {
    let seq = mintSeq.current + 1
    mintSeq.current = seq
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let (isCutover, redirectUrl) = await mintHandoff()
      if mintSeq.current === seq {
        if !isCutover {
          RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url="/routing"))
        } else if redirectUrl->isNonEmptyString {
          let separator = redirectUrl->String.includes("?") ? "&" : "?"
          lastMintAt.current = Js.Date.now()
          setIframeSrc(_ => `${redirectUrl}${separator}embed=1${handoffFragment()}`)
          setScreenState(_ => PageLoaderWrapper.Success)
        } else {
          setScreenState(_ => PageLoaderWrapper.Error(""))
        }
      }
    } catch {
    | Exn.Error(_) =>
      if mintSeq.current === seq {
        setScreenState(_ => PageLoaderWrapper.Error(""))
      }
    }
  }

  let openInNewTab = async () => {
    try {
      let (_isCutover, redirectUrl) = await mintHandoff()
      if redirectUrl->isNonEmptyString {
        `${redirectUrl}${handoffFragment()}`->Window._open
      }
    } catch {
    | Exn.Error(_) =>
      showToast(
        ~message="Failed to open Decision Engine routing. Please try again.",
        ~toastType=ToastState.ToastError,
      )
    }
  }

  React.useEffect(() => {
    if skipNextMint.current {
      skipNextMint.current = false
    } else {
      loadFrame()->ignore
    }
    None
  }, (sectionSlug, ruleId, profileId))

  React.useEffect(() => {
    let onMessage = ev => {
      let event = ev->DecisionEngineTypes.toMessageEvent
      if event.origin === Window.Location.origin {
        let dict = event.data->JSON.Decode.object->Option.getOr(Dict.make())
        switch dict->getString("type", "")->DecisionEngineTypes.messageTypeFromString {
        | SessionExpired =>
          if Js.Date.now() -. lastMintAt.current > 5000. {
            loadFrame()->ignore
          }
        | RouteChanged => {
            let dePath = dict->getString("path", "")
            switch dePath->sectionForDePath {
            | Some(matched) => {
                let ruleStillOpen =
                  ruleId->isNonEmptyString && dePath->String.includes(`/${ruleId}/`)
                if matched.slug !== sectionSlug || (ruleId->isNonEmptyString && !ruleStillOpen) {
                  skipNextMint.current = true
                  RescriptReactRouter.replace(workspaceUrl(~slug=matched.slug))
                }
              }
            | None => ()
            }
          }
        | UnknownMessage => ()
        }
      }
    }
    Window.addEventListener("message", onMessage)
    Some(() => Window.removeEventListener("message", onMessage))
  }, (sectionSlug, ruleId, profileId, section.target))

  <div className="flex flex-col w-full h-[calc(100vh-4.75rem)]">
    <div
      className="flex items-center justify-between px-5 h-12 flex-shrink-0 border-b border-nd_gray-200 bg-white">
      <BreadCrumbNavigation
        path=[{title: "Smart Routing Configurations", link: "/routing"}]
        currentPageTitle={section.label}
      />
      <Button
        text="Open in new tab"
        buttonType={Secondary}
        buttonSize={Small}
        onClick={_ => openInNewTab()->ignore}
      />
    </div>
    <div className="flex-1 min-h-0">
      <PageLoaderWrapper screenState sectionHeight="h-full">
        <RenderIf condition={iframeSrc->isNonEmptyString}>
          <iframe
            src=iframeSrc title="Decision Engine" className="w-full h-full border-0 bg-white"
          />
        </RenderIf>
      </PageLoaderWrapper>
    </div>
  </div>
}
