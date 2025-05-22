@react.component
let make = (~profileId) => {
  open Typography
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let (showManageModal, setShowManageModal) = React.useState(_ => false)
  <div className="relative flex flex-1 flex-col bg-white border rounded-lg p-4 pt-10 gap-8">
    <div className=" flex flex-1 flex-col gap-7">
      <div
        className="absolute top-0 left-0 flex items-center w-fit bg-green-200 text-green-800 py-1 px-2 rounded-tl-lg rounded-br-md font-semibold">
        <Icon name="check" size={8} className="mr-1" />
        <span className={`${body.sm.semibold}`}> {"Active"->React.string} </span>
      </div>
      <div className={"flex flex-col gap-3"}>
        <p className={`${body.md.semibold} text-nd_gray-600`}>
          {"Least Cost Routing Configuration"->React.string}
        </p>
        <RenderIf condition={profileId->LogicUtils.isNonEmptyString}>
          <div className={`flex gap-2 ${body.md.regular} text-lightgray_background  opacity-50`}>
            <HelperComponents.ProfileNameComponent profile_id={profileId} />
            <p> {`: ${profileId}`->React.string} </p>
          </div>
        </RenderIf>
      </div>
    </div>
    <ACLButton
      authorization={userHasAccess(~groupAccess=WorkflowsManage)}
      text="Manage"
      buttonType=Secondary
      customButtonStyle="w-28"
      buttonSize={Small}
      onClick={_ => {
        setShowManageModal(_ => true)
        mixpanelEvent(~eventName=`debit_routing_deactivate_modal`)
      }}
    />
    <DebitRoutingDeactivateModal showModal=showManageModal setShowModal=setShowManageModal />
  </div>
}
