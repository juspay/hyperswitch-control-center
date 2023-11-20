@react.component
let make = (~showOverlay, ~setShowOverlay, ~children) => {
  let (showFullscreen, setShowFullscreen) = React.useState(_ => FullscreenUtils.document.fullscreen)

  React.useEffect1(() => {
    if showFullscreen && !FullscreenUtils.document.fullscreen {
      FullscreenUtils.enableFullscreen()
    } else if !showFullscreen && FullscreenUtils.document.fullscreen {
      FullscreenUtils.exitFullscreen()
    }
    None
  }, [showFullscreen])

  <UIUtils.RenderIf condition=showOverlay>
    <div
      style={ReactDOMStyle.make(~zIndex="999", ())}
      className={`bg-black/40 fixed inset-0 w-screen h-screen backdrop-blur-sm `}>
      <div className="flex flex-row justify-end gap-4 m-3">
        <Icon
          name={showFullscreen ? "collpase-alt" : "expand-alt"}
          className="cursor-pointer fill-black"
          size=21
          onClick={_ => setShowFullscreen(prev => !prev)}
        />
        <Icon
          name="crossicon"
          className="cursor-pointer fill-black"
          size=23
          onClick={_ => setShowOverlay(_ => false)}
        />
      </div>
      <div className="flex items-center justify-center m-auto"> children </div>
    </div>
  </UIUtils.RenderIf>
}
