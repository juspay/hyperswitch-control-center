module RoutingCustomModal = {
  @react.component
  let make = (
    ~showModal,
    ~setShowModal,
    ~cancelButton,
    ~submitButton,
    ~headingText,
    ~subHeadingText,
    ~leftIcon,
  ) => {
    <Modal
      showModal
      setShowModal
      modalClass="w-full md:w-4/12 mx-auto my-40 border-t-8 border-t-orange-960 rounded-xl">
      <div className="relative flex items-start px-4 pb-10 pt-8 gap-4">
        <Icon name=leftIcon size=25 className="w-8" onClick={_ => setShowModal(_ => false)} />
        <div className="flex flex-col gap-5">
          <p className="font-bold text-2xl"> {headingText->React.string} </p>
          <p className=" text-hyperswitch_black opacity-50 font-medium">
            {subHeadingText->React.string}
          </p>
        </div>
        <Icon
          className="absolute top-2 right-2"
          name="hswitch-close"
          size=22
          onClick={_ => setShowModal(_ => false)}
        />
      </div>
      <div className="flex items-end justify-end gap-4">
        {cancelButton}
        {submitButton}
      </div>
    </Modal>
  }
}
