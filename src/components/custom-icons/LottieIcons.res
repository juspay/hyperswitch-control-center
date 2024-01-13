let useLottieIcon = (isSelected, selectedLottieJson, deselectLottieJson) => {
  let hasRendered = React.useRef(false)

  let (defaultState, setDefaultState) = React.useState(() =>
    isSelected ? deselectLottieJson : selectedLottieJson
  )
  let (autoplay, setAutoplay) = React.useState(() => false)

  React.useEffect3(() => {
    if hasRendered.current {
      setAutoplay(_ => true)

      let newVal = isSelected ? selectedLottieJson : deselectLottieJson

      setDefaultState(_ => newVal)
    } else if selectedLottieJson != Js.Json.null && deselectLottieJson != Js.Json.null {
      setDefaultState(_ => isSelected ? deselectLottieJson : selectedLottieJson)
      hasRendered.current = true
    }

    None
  }, (isSelected, selectedLottieJson, deselectLottieJson))
  (defaultState, autoplay)
}
