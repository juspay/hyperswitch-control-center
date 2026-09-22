open APIUtils

let useDecisionEngineCutover = (~embedDecisionEngine) => {
  let (cutover, setCutover) = React.useState(_ => None)
  let {profileId} = React.useContext(UserInfoProvider.defaultContext).getCommonSessionDetails()
  let checkRoutingEntryCutover = RoutingUtils.useCheckRoutingEntryCutover()

  React.useEffect(() => {
    if embedDecisionEngine {
      setCutover(_ => None)

      (
        async () => {
          let result = await checkRoutingEntryCutover()
          setCutover(_ => result)
        }
      )()->ignore
    } else {
      setCutover(_ => Some(false))
    }
    None
  }, (profileId, embedDecisionEngine))

  cutover
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
