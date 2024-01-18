@react.component
let make = (~showModal, ~setShowModal, ~text) => {
  <UIUtils.RenderIf condition={showModal}>
    <Modal
      showModal
      setShowModal
      modalClass="w-80 !h-56 flex items-center justify-center m-auto"
      paddingClass=""
      childClass="flex items-center justify-center h-full w-full">
      <div className="flex flex-col items-center gap-2">
        <Loader />
        <div className="text-xl font-semibold mb-4"> {text->React.string} </div>
      </div>
    </Modal>
  </UIUtils.RenderIf>
}
