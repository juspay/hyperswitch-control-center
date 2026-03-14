open Typography

@react.component
let make = (~showModal, ~setShowModal) => {
  let showToast = ToastState.useShowToast()
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let updateBusinessProfile = BusinessProfileHook.useUpdateBusinessProfile()
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()

  let handleUpdate = async () => {
    try {
      let body =
        [("is_debit_routing_enabled", false->JSON.Encode.bool)]->LogicUtils.getJsonFromArrayOfJson
      let _ = await updateBusinessProfile(~body)
      showToast(~message=`Successfully deactivated configuration`, ~toastType=ToastSuccess)
      setShowModal(_ => false)
    } catch {
    | _ =>
      showToast(~message=`Failed to deactivate configuration`, ~toastType=ToastError)
      setShowModal(_ => false)
    }
  }

  <Modal
    showModal
    setShowModal
    modalHeading="Disable Least Cost Routing Configuration"
    modalHeadingClass={`${heading.sm.semibold}`}
    modalClass="w-1/3 m-auto"
    childClass="p-0"
    modalHeadingDescriptionElement={<div className={`${body.md.medium} text-nd_gray-400 mt-2`}>
      {"Disabling this setting could limit cost optimization for debit transactions."->React.string}
    </div>}
    borderBottom=true>
    <div className="flex flex-col h-full w-full px-6">
      <div className={`${body.md.medium} text-nd_gray-600 py-6`}>
        {"Are you sure you want to deactivate the Least Cost Routing configuration?"->React.string}
      </div>
      <div className="flex justify-end gap-4 pb-8 pt-4">
        <Button
          text="Cancel"
          buttonType=Secondary
          customButtonStyle="w-fit p-2"
          onClick={_ => {
            setShowModal(_ => false)
          }}
          buttonSize=Small
        />
        <ACLButton
          text="Deactivate Configuration"
          buttonType=Primary
          authorization={userHasAccess(~groupAccess=WorkflowsManage)}
          onClick={_ => {
            handleUpdate()->ignore
            mixpanelEvent(~eventName=`debit_routing_disabled`)
          }}
          buttonSize=Small
        />
      </div>
    </div>
  </Modal>
}
