@react.component
let make = (~showModal, ~setShowModal) => {
  open Typography
  open DebitRoutingHook
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let updateBusinessProfileDetails = useDebitRoutingUpdate()
  <Modal
    showModal
    setShowModal
    modalHeading="Disable Least Cost Routing Configuration"
    modalHeadingClass={`${heading.sm.semibold}`}
    modalClass="w-1/3 m-auto"
    childClass="p-0"
    modalHeadingDescriptionElement={<div className={`${body.md.medium} text-nd_gray-400 mt-2`}>
      {"Disabling this setting may result in higher processing fees for debit transactions."->React.string}
    </div>}
    borderBottom=true>
    <div className="flex flex-col h-full w-full px-6">
      <div className={`${body.md.medium} text-sm text-nd_gray-600 py-6`}>
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
        <Button
          text="Deactivate Configuration"
          buttonType=Primary
          onClick={_ => {
            mixpanelEvent(~eventName=`debit_routing_disabled`)
            updateBusinessProfileDetails(false)->ignore
          }}
          buttonSize=Small
        />
      </div>
    </div>
  </Modal>
}
