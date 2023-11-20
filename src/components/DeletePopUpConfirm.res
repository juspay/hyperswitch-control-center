@react.component
let make = (~handlePopUp, ~handleConfirm, ~confirmType, ~confirmText, ~buttonText) => {
  <AddDataAttributes attributes=[("data-component", confirmType)]>
    <div
      className="border border-jp-gray-500 dark:border-jp-gray-960 bg-jp-gray-950 dark:bg-white-600 dark:bg-opacity-80 fixed bg-opacity-70 h-screen w-screen z-20 inset-0 overflow-auto  ">
      <div
        className="absolute top-1/3 left-1/3  border border-t-orange-960 dark:border-jp-gray-960 h-60 w-3/12 bg-jp-gray-100 dark:bg-jp-gray-darkgray_background shadow rounded z-20 dark:text-opacity-75 rounded-t-xl ">
        <div className="h-2 bg-orange-960 rounded-t-xl" />
        <div className="flex flex-row">
          <p className="font-extrabold text-2xl  mt-10 ml-10"> {React.string(confirmType)} </p>
          <div className="absolute right-5 top-10">
            <ModalCloseIcon onClick=handlePopUp />
          </div>
        </div>
        <div className="ml-10 mt-4 mb-8 "> {React.string(confirmText)} </div>
        <div className="flex justify-end mb-4 mr-4">
          <span className="m-2 flex flex-row">
            <Button
              buttonType=SecondaryFilled
              text="No, don't delete"
              onClick=handlePopUp
              buttonSize=Small
            />
          </span>
          <span className="m-2 flex flex-row">
            <Button buttonType=Primary text=buttonText onClick=handleConfirm buttonSize=Small />
          </span>
        </div>
      </div>
    </div>
  </AddDataAttributes>
}
