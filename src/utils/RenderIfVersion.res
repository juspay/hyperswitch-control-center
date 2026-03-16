@react.component
let make = (~visibleForVersion: UserInfoTypes.version, ~children) => {
  let {version} = React.useContext(UserInfoProvider.defaultContext).getCommonSessionDetails()
  <RenderIf condition={version == visibleForVersion}> children </RenderIf>
}
