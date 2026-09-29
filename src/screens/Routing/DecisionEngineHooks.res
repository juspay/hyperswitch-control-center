open APIUtils
open HyperswitchAtom
open LogicUtils

let useDecisionEngineTheme = (~iframeRef, ~iframeSrc) => {
  open DecisionEngineThemeUtils
  let {resolvedTheme} = React.useContext(ThemeProvider.themeContext)
  let (themeFrame, setThemeFrame) = React.useState(() => None)

  let handleThemeMessage = ev => {
    let event = ev->DOMUtils.toMessageEvent
    if isFrameMessage(~iframeRef, event) {
      event
      ->getReadyFrame
      ->Option.forEach(id => {
        setThemeFrame(_ => Some(({src: iframeSrc, id}: DecisionEngineTypes.themeFrame)))
      })
    }
  }

  React.useEffect(() => {
    Window.addEventListener("message", handleThemeMessage)
    Some(() => Window.removeEventListener("message", handleThemeMessage))
  }, [iframeSrc])

  React.useEffect(() => {
    switch (themeFrame, resolvedTheme) {
    | (Some(frame), Some(snapshot)) if frame.src === iframeSrc =>
      sendTheme(~iframeRef, ~frameId=frame.id, snapshot)
    | _ => ()
    }
    None
  }, (themeFrame, resolvedTheme, iframeSrc))
}

let useSyncDecisionEngineCutover = () => {
  let {embedDecisionEngine} = featureFlagAtom->Recoil.useRecoilValueFromAtom
  let setCutoverState = Recoil.useSetRecoilState(decisionEngineCutoverAtom)
  let {merchantId, profileId} = React.useContext(
    UserInfoProvider.defaultContext,
  ).getCommonSessionDetails()
  let checkRoutingEntryCutover = RoutingUtils.useCheckRoutingEntryCutover()
  let key = DecisionEngineUtils.getCutoverKey(~merchantId, ~profileId)

  let fetchCutoverStatus = async (~isActive) => {
    let result = await checkRoutingEntryCutover()
    if isActive.contents {
      setCutoverState(_ => Some((key, result)))
    }
  }

  React.useEffect(() => {
    let isActive = ref(true)
    if embedDecisionEngine {
      fetchCutoverStatus(~isActive)->ignore
    }
    Some(
      () => {
        isActive := false
        setCutoverState(_ => None)
      },
    )
  }, (key, embedDecisionEngine))
}

let useDecisionEngineCutover = () => {
  let {embedDecisionEngine} = featureFlagAtom->Recoil.useRecoilValueFromAtom
  let cutoverState = decisionEngineCutoverAtom->Recoil.useRecoilValueFromAtom
  let {merchantId, profileId} = React.useContext(
    UserInfoProvider.defaultContext,
  ).getCommonSessionDetails()
  let key = DecisionEngineUtils.getCutoverKey(~merchantId, ~profileId)

  if !embedDecisionEngine {
    Some(false)
  } else {
    switch cutoverState {
    | Some((storedKey, value)) if storedKey === key => value
    | _ => None
    }
  }
}

let useDecisionEngineNewTab = () => {
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod(~showErrorToast=false)
  let showToast = ToastAdapter.useShowToast()
  let {profileId} = React.useContext(UserInfoProvider.defaultContext).getCommonSessionDetails()
  let connectorList = connectorListAtom->Recoil.useRecoilValueFromAtom

  async (~target, ~ruleId="", ~route="") => {
    try {
      let entryUrl = getURL(~entityName=V1(ROUTING), ~methodType=Get, ~id=Some("entry"))
      let res = await updateDetails(`${entryUrl}?target=${target}`, JSON.Encode.null, Post)
      let redirectUrl = res->getDictFromJsonObject->getString("redirect_url", "")
      if redirectUrl->isNonEmptyString {
        let handoff =
          connectorList->RoutingUtils.decisionEngineHandoffFragment(~profileId, ~ruleId, ~route)
        `${redirectUrl}${handoff}`->Window._open
      }
    } catch {
    | Exn.Error(_) =>
      showToast(
        ~message="Failed to open Decision Engine routing. Please try again.",
        ~toastType=ToastState.ToastError,
      )
    }
  }
}
