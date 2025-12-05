@react.component
let make = (~showModal, ~setShowModal) => {
  open Typography
  let showToast = ToastState.useShowToast()
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let updateBusinessProfile = BusinessProfileHook.useUpdateBusinessProfile()
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let handleUpdate = async () => {
    try {
      let body =
        [("is_debit_routing_enabled", true->JSON.Encode.bool)]->LogicUtils.getJsonFromArrayOfJson
      let _ = await updateBusinessProfile(~body)
      showToast(~message=`Successfully added configuration`, ~toastType=ToastSuccess)
      setShowModal(_ => false)
    } catch {
    | _ =>
      showToast(~message=`Failed to add configuration`, ~toastType=ToastError)
      setShowModal(_ => false)
    }
  }

  <Modal
    showModal
    setShowModal
    modalHeading="Enable Least Cost Routing Configuration"
    modalHeadingClass={`${heading.sm.semibold}`}
    modalClass="w-1/3 m-auto"
    childClass="p-0"
    modalHeadingDescriptionElement={<div className={`${body.md.medium} text-nd_gray-400 mt-2`}>
      {"Optimize processing fees on debit payments by routing traffic to the cheapest network"->React.string}
    </div>}
    borderBottom=true>
    <div className="flex flex-col h-full w-full px-6">
      <div className={`${body.md.medium} text-nd_gray-600 pt-6 pb-2`}>
        <span>
          {"To get started with least-cost routing, ensure connectors with local network support are configured "->React.string}
          <a
            href="https://docs.hyperswitch.io/explore-hyperswitch/payment-orchestration/smart-router/least-cost-routing#supported-configuration-for-least-cost-routing"
            target="_blank"
            className="inline-flex items-center">
            <Icon name="external-link-alt" size=10 className="ml-1 text-blue-500" />
          </a>
        </span>
      </div>
      <div className="flex justify-end gap-4 pb-8 pt-2">
        <Button
          text="Cancel"
          buttonType=Secondary
          onClick={_ => setShowModal(_ => false)}
          buttonSize=Small
        />
        <ACLButton
          text="Enable"
          buttonType=Primary
          authorization={userHasAccess(~groupAccess=WorkflowsManage)}
          onClick={_ => {
            handleUpdate()->ignore
            mixpanelEvent(~eventName=`debit_routing_enabled`)
          }}
          buttonSize=Small
        />
      </div>
    </div>
  </Modal>
}
