@react.component
let make = () => {
  open Typography
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let (showManageModal, setShowManageModal) = React.useState(_ => false)
  <div className="flex flex-col border rounded w-full px-6 py-8 gap-4">
    <div
      className="flex items-center w-fit bg-green-700 text-white py-1 px-2 rounded-md font-semibold">
      <Icon name="check" size={10} className="mr-1" />
      <span className={`text-fs-11`}> {"ACTIVE"->React.string} </span>
    </div>
    <div className={"flex flex-col gap-2"}>
      <p className={`${body.md.semibold} text-lightgray_background `}>
        {"Least Cost Routing Configuration"->React.string}
      </p>
      <p className={`${body.md.medium} text-nd_gray-600 opacity-50`}>
        {"Least Cost Routing Configuration: Optimize processing fees on debit payments by routing traffic to the cheapest network. Manage button should land to the Least Cost Routing Configuration page"->React.string}
      </p>
    </div>
    <ACLButton
      authorization={userHasAccess(~groupAccess=WorkflowsManage)}
      text="Manage"
      buttonType=Secondary
      customButtonStyle="w-4/3"
      buttonSize={Small}
      onClick={_ => {
        setShowManageModal(_ => true)
        mixpanelEvent(~eventName=`debit_routing_deactivate_modal`)
      }}
    />
    <DebitRoutingDeactivateModal showModal=showManageModal setShowModal=setShowManageModal />
  </div>
}
