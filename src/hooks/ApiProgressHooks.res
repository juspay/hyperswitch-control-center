let pendingRequestCount = Recoil.atom(. "pendingRequestCount", 0)

let useReqProgressIndicator = () => {
  let count = Recoil.useRecoilValueFromAtom(pendingRequestCount)

  let isMakingRequests = count !== 0

  React.useEffect0(() => {
    NProgress.actuallyConfigure()
    None
  })

  React.useEffect1(() => {
    if isMakingRequests {
      NProgress.start()
      Some(() => NProgress.done())
    } else {
      None
    }
  }, [isMakingRequests])
}
