@react.component
let make = () => {
  open Typography
  let (showLeastCostModal, setShowLeastCostModal) = React.useState(_ => false)
  let (showManageModal, setShowManageModal) = React.useState(_ => false)
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let businessProfileRecoilVal =
    HyperswitchAtom.businessProfileFromIdAtom->Recoil.useRecoilValueFromAtom
  let debitRoutingValue = businessProfileRecoilVal.is_debit_routing_enabled->Option.getOr(false)
  let handleButtonClick = _ => {
    if debitRoutingValue {
      setShowManageModal(_ => true)
    } else {
      setShowLeastCostModal(_ => true)
    }
  }
  let buttonText = debitRoutingValue ? "Manage" : "Setup"
  <div className="flex flex-1 flex-col bg-white border rounded p-4 gap-8">
    <div className="flex flex-1 flex-col gap-7">
      <div className="flex w-full items-center flex-wrap justify-between">
        <Icon name="leastCostRouting" size=15 className="w-20" />
      </div>
      <div className="flex flex-1 flex-col gap-3 text-nd_gray-600">
        <p className={`${body.md.semibold}`}>
          {"Least Cost Routing Configuration"->React.string}
        </p>
        <p className={`${body.md.medium} opacity-50`}>
          {"Optimize processing fees on debit payments by routing traffic to the cheapest network"->React.string}
        </p>
      </div>
    </div>
    <ACLButton
      text={buttonText}
      authorization={userHasAccess(~groupAccess=WorkflowsManage)}
      customButtonStyle="w-28"
      buttonType={Secondary}
      buttonSize=Small
      onClick={_ => {
        handleButtonClick()
        mixpanelEvent(~eventName=`debit_routing`)
      }}
    />
    <DebitRoutingConfigureModal showModal=showLeastCostModal setShowModal=setShowLeastCostModal />
    <DebitRoutingDeactivateModal showModal=showManageModal setShowModal=setShowManageModal />
  </div>
}
