@react.component
let make = (~visibleForVersion: UserInfoTypes.version, ~children) => {
  let {userInfo: {version}} = React.useContext(UserInfoProvider.defaultContext)
  <RenderIf condition={version == visibleForVersion}> children </RenderIf>
}
