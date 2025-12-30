@react.component
let make = (~visibleForVersion: UserInfoTypes.version, ~children) => {
  let {version} = React.useContext(UserInfoProvider.defaultContext).getCommonDetails()
  <RenderIf condition={version == visibleForVersion}> children </RenderIf>
}
