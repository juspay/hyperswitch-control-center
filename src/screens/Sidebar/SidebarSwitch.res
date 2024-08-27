module OrgMerchantSwitchCollapsed = {
  @react.component
  let make = () => {
    let {orgId} = React.useContext(UserInfoProvider.defaultContext)
    let {merchantId} = React.useContext(UserInfoProvider.defaultContext)
    let style = "h-10 p-2 mx-auto my-0.5 text-white font-semibold  fs-20 ring-1 ring-blue-800 ring-opacity-15 rounded uppercase "

    <div className="flex flex-col gap-2">
      <img src="" alt={orgId->String.slice(~start=0, ~end=1)} className={`${style} h-10`} />
      <div className={style}> {merchantId->String.slice(~start=0, ~end=2)->React.string} </div>
    </div>
  }
}

@react.component
let make = (~isExpanded=false) => {
  let expandedContent =
    <div className="flex flex-col items-end gap-2">
      <OrgSwitch />
      <div className="flex">
        <div className="w-8 h-10 border-jp-gray-400 ml-10 border-dashed border-b border-l" />
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
