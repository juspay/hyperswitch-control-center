let useMatchMedia = mediaQuery => {
  let mediaQueryList = React.useMemo(() => {
    Window.matchMedia(mediaQuery)
  }, [mediaQuery])

  let (isMatched, setIsMatched) = React.useState(_ => {
    mediaQueryList.matches
  })

  React.useEffect(() => {
    let screenTest = (ev: Window.MatchMedia.matchEvent) => {
      let matched = ev.matches
      setIsMatched(_prev => matched)
    }
    mediaQueryList.addListener(screenTest)

    Some(() => mediaQueryList.removeListener(screenTest))
  }, [mediaQueryList])
  isMatched
}

let useMobileChecker = () => {
  useMatchMedia("(max-width: 700px)")
}
