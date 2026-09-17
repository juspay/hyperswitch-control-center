// Whether the current profile has cut over to the Decision Engine. Cutover is a per-profile async
// probe (POST routing/entry → is_cutover), not a feature flag, so it can't be read straight from
// the flag atom. Returns None while unknown/loading; consumers fall back to the native layout until
// it resolves to Some(true).
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
