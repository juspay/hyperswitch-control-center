@react.component
let make = (~showWhenVersion: UserInfoTypes.version, ~children) => {
  let {userInfo: {version}} = React.useContext(UserInfoProvider.defaultContext)
  <RenderIf condition={version == showWhenVersion}> children </RenderIf>
}
