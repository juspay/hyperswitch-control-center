@react.component
let make = (~children) => {
  let isMobileView = MatchMedia.useMobileChecker()

  <RenderIf condition={!isMobileView}> children </RenderIf>
}
