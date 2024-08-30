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
let make = (~isExpanded=false) => {
  let expandedContent =
    <div className="flex flex-col items-end gap-2">
      <OrgSwitch />
      <div className="flex">
        <div className="w-6 h-10 border-blue-810 ml-5 border-dashed border-b border-l rounded-bl-lg" />
        <MerchantSwitch />
      </div>
    </div>

  <>
    <RenderIf condition={isExpanded}> expandedContent </RenderIf>
    <RenderIf condition={!isExpanded}>
      <OrgMerchantSwitchCollapsed />
    </RenderIf>
  </>
}
