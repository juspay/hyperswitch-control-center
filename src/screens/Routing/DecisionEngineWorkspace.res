open APIUtils
open LogicUtils
open DecisionEngineUtils

let remintThrottleMs = 5000.

@react.component
let make = () => {
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod(~showErrorToast=false)
  let url = RescriptReactRouter.useUrl()
  let {profileId} = React.useContext(UserInfoProvider.defaultContext).getCommonSessionDetails()
  let connectorList = HyperswitchAtom.connectorListAtom->Recoil.useRecoilValueFromAtom
  let openDecisionEngineNewTab = DecisionEngineHooks.useDecisionEngineNewTab()

  let (iframeSrc, setIframeSrc) = React.useState(_ => "")
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let mintState = React.useRef(({seq: 0, at: 0.}: DecisionEngineTypes.mintState))
  let skipNextMint = React.useRef(false)

  let sectionSlugOpt = url.path->sectionSlugFromPathOpt
  let sectionSlug = sectionSlugOpt->Option.getOr(defaultSection.slug)
  let lastSectionSlug = React.useRef(defaultSection.slug)
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
    let seq = mintState.current.seq + 1
    mintState.current = {...mintState.current, seq}
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let (isCutover, redirectUrl) = await mintHandoff()
      if mintState.current.seq === seq {
        if !isCutover {
          RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url="/routing"))
        } else if redirectUrl->isNonEmptyString {
          let separator = redirectUrl->String.includes("?") ? "&" : "?"
          mintState.current = {...mintState.current, at: Js.Date.now()}
          setIframeSrc(_ => `${redirectUrl}${separator}embed=1${handoffFragment()}`)
          setScreenState(_ => PageLoaderWrapper.Success)
        } else {
          setScreenState(_ => PageLoaderWrapper.Error(""))
        }
      }
    } catch {
    | Exn.Error(_) =>
      if mintState.current.seq === seq {
        setScreenState(_ => PageLoaderWrapper.Error(""))
      }
    }
  }

  // An OMP switch truncates the path to /dashboard/routing-workspace, dropping the user onto Rule-Based.
  React.useEffect(() => {
    switch sectionSlugOpt {
    | Some(slug) => lastSectionSlug.current = slug
    | None => RescriptReactRouter.replace(workspaceUrl(~slug=lastSectionSlug.current))
    }
    None
  }, [sectionSlug])

  React.useEffect(() => {
    if skipNextMint.current {
      skipNextMint.current = false
    } else {
      loadFrame()->ignore
    }
    None
  }, (sectionSlug, ruleId, profileId))

  let handleMessage = ev => {
    let event = ev->DOMUtils.toMessageEvent
    if event.origin === Window.Location.origin {
      let dict = event.data->JSON.Decode.object->Option.getOr(Dict.make())
      switch dict->getString("type", "")->DecisionEngineTypes.messageTypeFromString {
      | SessionExpired =>
        // One-shot: skip if a mint happened within remintThrottleMs; the next section/rule/profile
        // change re-mints.
        if Js.Date.now() -. mintState.current.at > remintThrottleMs {
          loadFrame()->ignore
        }
      | RouteChanged => {
          let dePath = dict->getString("path", "")
          switch dePath->sectionForDePath {
          | Some(matched) => {
              let ruleStillOpen = ruleId->isNonEmptyString && dePath->String.includes(`/${ruleId}/`)
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

  React.useEffect(() => {
    Window.addEventListener("message", handleMessage)
    Some(() => Window.removeEventListener("message", handleMessage))
  }, (sectionSlug, ruleId, profileId, section.target))

  <div className="flex flex-col w-full h-[calc(100vh-4.75rem)]">
    <div
      className="flex items-center justify-between px-5 h-12 flex-shrink-0 border-b border-nd_gray-200 bg-white">
      // No parent crumb: a cut-over profile should not be sent back to the legacy routing screen.
      <BreadCrumbNavigation currentPageTitle={section.label} />
      <Button
        text="Open in new tab"
        buttonType={Secondary}
        buttonSize={Small}
        onClick={_ =>
          openDecisionEngineNewTab(~target=section.target, ~ruleId, ~route=section.dePath)->ignore}
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
