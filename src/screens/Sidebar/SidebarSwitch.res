module OrgMerchantSwitchCollapsed = {
  @react.component
  let make = () => {
    let {orgId} = React.useContext(UserInfoProvider.defaultContext)
    let {merchantId} = React.useContext(UserInfoProvider.defaultContext)
    let className = "h-10 p-2 mx-auto my-0.5 ring-1 ring-blue-800 ring-opacity-15 rounded text-white font-semibold fs-20"
    <div className="flex flex-col gap-2">
      <img src="" alt={orgId->String.slice(~start=0, ~end=1)->String.toUpperCase} className />
      <div
        className="py-2 px-3 mx-auto my-0.5  text-white font-semibold fs-20 ring-1 ring-blue-800 ring-opacity-15 rounded uppercase">
        {merchantId->String.slice(~start=0, ~end=2)->React.string}
      </div>
    </div>
  }
}

@react.component
let make = (~isExpanded=false) => {
  <>
    <RenderIf condition={isExpanded}>
      <div className="flex flex-col items-end gap-2">
        <div className="w-full">
          <OrgSwitch />
        </div>
        <div className="flex">
          <div className="w-8 h-10 border-jp-gray-400 ml-10 border-dashed border-b border-l" />
          <div className="w-full">
            <MerchantSwitch />
          </div>
        </div>
      </div>
    </RenderIf>
    <RenderIf condition={!isExpanded}>
      <OrgMerchantSwitchCollapsed />
    </RenderIf>
  </>
}
