open LottieFiles
@react.component
let make = (~isSelected) => {
  /* let selectedTickJson = useSelectedTickJson()
   let deselectTickJson = useDeselectTickJson() */
  let selectedTickJson = useLottieJson(selectedTick)
  let deselectTickJson = useLottieJson(deselectTick)

  let (defaultState, autoplay) = LottieIcons.useLottieIcon(
    isSelected,
    selectedTickJson,
    deselectTickJson,
  )

  <div className="h-4 w-4">
    <ReactSuspenseWrapper loadingText="">
      <Lottie
        key={autoplay ? "true" : "false"}
        animationData={defaultState}
        autoplay={autoplay}
        loop=false
      />
    </ReactSuspenseWrapper>
  </div>
}
