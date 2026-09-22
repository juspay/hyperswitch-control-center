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
