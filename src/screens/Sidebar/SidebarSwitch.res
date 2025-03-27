module OrgMerchantSwitchCollapsed = {
  @react.component
  let make = () => {
    let {userInfo: {orgId, merchantId}} = React.useContext(UserInfoProvider.defaultContext)
    let style = "p-2 mx-auto my-0.5 text-white font-semibold  fs-20 ring-1 ring-blue-800 ring-opacity-15 rounded uppercase "

    <div className="flex flex-col gap-2">
      <div className={style}> {orgId->String.slice(~start=0, ~end=1)->React.string} </div>
      <div className={style}> {merchantId->String.slice(~start=0, ~end=1)->React.string} </div>
    </div>
  }
}

@react.component
let make = (~isSidebarExpanded=false) => {
  let {userInfo: {roleId}} = React.useContext(UserInfoProvider.defaultContext)
  let {globalUIConfig: {sidebarColor: {borderColor}}} = React.useContext(ThemeProvider.themeContext)
  let isInternalUser = roleId->HyperSwitchUtils.checkIsInternalUser
  let expandedContent = {
    <RenderIf condition={!isInternalUser}>
      <div className={`flex justify-start items-center px-6 mt-7 border-b pb-4 ${borderColor}`}>
        <MerchantSwitch />
      </div>
    </RenderIf>
  }
  <>
    <RenderIf condition={isSidebarExpanded}> expandedContent </RenderIf>
    <RenderIf condition={!isSidebarExpanded}>
      <OrgMerchantSwitchCollapsed />
    </RenderIf>
  </>
}
