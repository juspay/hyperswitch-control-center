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
  let {devOrgSidebar} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let {globalUIConfig: {sidebarColor: {borderColor}}} = React.useContext(ThemeProvider.themeContext)
  let expandedContent =
    <div className={`border-b ${borderColor}`}>
      <OrgSwitch />
    </div>

  <>
    <RenderIf condition={isSidebarExpanded && !devOrgSidebar}> expandedContent </RenderIf>
    <RenderIf condition={!isSidebarExpanded}>
      <OrgMerchantSwitchCollapsed />
    </RenderIf>
  </>
}
