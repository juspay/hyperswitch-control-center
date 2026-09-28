open APIUtils

// One owner in the authenticated app; sidebar/search consumers only read the result.
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
    let active = ref(true)
    let pending = ref(false)
    let resolved = ref(false)
    let retryTimer = ref(None)
    setCutoverState(_ => None)

    let rec probe = async attempt => {
      if active.contents && !pending.contents && !resolved.contents {
        pending := true
        let result = try {
          await checkRoutingEntryCutover()
        } catch {
        | _ => None
        }
        pending := false
        if active.contents {
          setCutoverState(_ => Some((key, result)))
          switch result {
          | Some(_) => resolved := true
          | None if attempt < 2 => retryTimer := Some(setTimeout(() => {
                  retryTimer := None
                  probe(attempt + 1)->ignore
                }, 1000 * (attempt + 1)))
          | None => ()
          }
        }
      }
    }
    let retryOnFocus = _ => {
      if retryTimer.contents->Option.isNone {
        probe(0)->ignore
      }
    }
    if embedDecisionEngine && sessionReady {
      probe(0)->ignore
      Window.addEventListener("focus", retryOnFocus)
    }
    Some(
      () => {
        active := false
        retryTimer.contents->Option.forEach(clearTimeout)
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

  // A stale key reads as None, so an OMP switch never shows the previous profile's answer.
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
