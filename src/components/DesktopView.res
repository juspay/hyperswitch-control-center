@react.component
let make = (~children) => {
  let isMobileView = MatchMedia.useMobileChecker()

  <UIUtils.RenderIf condition={!isMobileView}> children </UIUtils.RenderIf>
}
