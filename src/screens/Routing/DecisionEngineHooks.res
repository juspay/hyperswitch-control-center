open APIUtils

let useSyncDecisionEngineCutover = (~embedDecisionEngine) => {
  let setCutoverState = Recoil.useSetRecoilState(HyperswitchAtom.decisionEngineCutoverAtom)
  let {merchantId, profileId} = React.useContext(
    UserInfoProvider.defaultContext,
  ).getCommonSessionDetails()
  let checkRoutingEntryCutover = RoutingUtils.useCheckRoutingEntryCutover()
  let key = `${merchantId}:${profileId}`
  let sessionReady =
    merchantId->LogicUtils.isNonEmptyString && profileId->LogicUtils.isNonEmptyString

  React.useEffect(() => {
    let probeState: DecisionEngineTypes.cutoverProbeState = {
      active: true,
      pending: false,
      resolved: false,
    }
    setCutoverState(_ => None)

    let probe = async () => {
      if probeState.active && !probeState.pending && !probeState.resolved {
        probeState.pending = true
        let result = try {
          await checkRoutingEntryCutover()
        } catch {
        | _ => None
        }
        probeState.pending = false
        if probeState.active {
          setCutoverState(_ => Some((key, result)))
          probeState.resolved = result->Option.isSome
        }
      }
    }
    let retryOnFocus = _ => probe()->ignore
    if embedDecisionEngine && sessionReady {
      probe()->ignore
      Window.addEventListener("focus", retryOnFocus)
    }
    Some(
      () => {
        probeState.active = false
        Window.removeEventListener("focus", retryOnFocus)
        setCutoverState(_ => None)
      },
    )
  }, (key, embedDecisionEngine, sessionReady))
}

let useDecisionEngineCutover = (~embedDecisionEngine) => {
  let cutoverState = HyperswitchAtom.decisionEngineCutoverAtom->Recoil.useRecoilValueFromAtom
  let {merchantId, profileId} = React.useContext(
    UserInfoProvider.defaultContext,
  ).getCommonSessionDetails()
  let key = `${merchantId}:${profileId}`

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
  let connectorList = HyperswitchAtom.connectorListAtom->Recoil.useRecoilValueFromAtom

  async (~target, ~ruleId="", ~route="") => {
    open LogicUtils
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
