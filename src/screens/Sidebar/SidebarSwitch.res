module OrgMerchantSwitchCollapsed = {
  @react.component
  let make = () => {
    let {userInfo: {orgId, merchantId}} = React.useContext(UserInfoProvider.defaultContext)
    let style = "p-2 mx-auto my-0.5 text-white font-semibold  fs-20 ring-1 ring-primary-blue-50/15 rounded-sm uppercase "

    <div className="flex flex-col gap-2">
      <div className={style}> {orgId->String.slice(~start=0, ~end=1)->React.string} </div>
      <div className={style}> {merchantId->String.slice(~start=0, ~end=1)->React.string} </div>
    </div>
  }
}

@react.component
let make = (~isSidebarExpanded=false) => {
  let {userInfo: {roleId}} = React.useContext(UserInfoProvider.defaultContext)
  let isInternalUser = roleId->HyperSwitchUtils.checkIsInternalUser
  let expandedContent = {
    <RenderIf condition={!isInternalUser}>
      <div className="flex justify-start items-center px-6 mt-8">
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
