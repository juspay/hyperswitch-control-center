@react.component
let make = (~showModal, ~setShowModal) => {
  open Typography
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
    <div className="flex flex-col gap-12 h-full w-full">
      <div className="p-4">
        <div className="text-sm text-nd_gray-500">
          {"Are you sure you want to deactivate the Least Cost Routing configuration?"->React.string}
        </div>
      </div>
    </div>
  </Modal>
}
