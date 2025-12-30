@react.component
let make = (~visibleForVersion: UserInfoTypes.version, ~children) => {
  let {version} = React.useContext(UserInfoProvider.defaultContext).getCommonTokenDetails()
  <RenderIf condition={version == visibleForVersion}> children </RenderIf>
}
