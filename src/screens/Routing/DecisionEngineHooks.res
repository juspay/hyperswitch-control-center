open APIUtils

// Several live instances (sidebar, global search, search results); the ref collapses them to one probe per key.
let probedKey = ref("")

let useDecisionEngineCutover = (~embedDecisionEngine) => {
  let (cutoverState, setCutoverState) = Recoil.useRecoilState(
    HyperswitchAtom.decisionEngineCutoverAtom,
  )
  let {merchantId, profileId} = React.useContext(
    UserInfoProvider.defaultContext,
  ).getCommonSessionDetails()
  let checkRoutingEntryCutover = RoutingUtils.useCheckRoutingEntryCutover()

  let key = `${merchantId}:${profileId}`
  // Probing before the session names a merchant and profile can only 400.
  let sessionReady =
    merchantId->LogicUtils.isNonEmptyString && profileId->LogicUtils.isNonEmptyString

  let syncCutover = async () => {
    let result = await checkRoutingEntryCutover()
    setCutoverState(_ => Some((key, result)))
  }

  React.useEffect(() => {
    if probedKey.contents !== key {
      if !embedDecisionEngine {
        probedKey := key
        setCutoverState(_ => Some((key, Some(false))))
      } else if sessionReady {
        probedKey := key
        syncCutover()->ignore
      }
    }
    None
  }, (key, embedDecisionEngine, sessionReady))

  // A stale key reads as None, so an OMP switch never shows the previous profile's answer.
  switch cutoverState {
  | Some((storedKey, value)) if storedKey === key => value
  | _ => None
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
