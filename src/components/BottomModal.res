@react.component
let make = (~onCloseClick, ~children, ~headerText) => {
  let onClick = e => {
    e->ReactEvent.Mouse.stopPropagation
  }

  <div
    onClick
    className={`flex flex-col border border-jp-gray-500 dark:border-jp-gray-960  bg-jp-gray-950 dark:bg-white-600 dark:bg-opacity-80 fixed bg-opacity-70 h-screen w-screen z-40 pt-12 flex justify-end inset-0  backdrop-blur-sm overscroll-contain`}>
    <div
      className={`!pl-4 desktop:bg-gray-200 z-10 sticky top-0 w-full top-0 m-0 md:!pl-6 dark:bg-jp-gray-850 p-4 border border-jp-gray-500 dark:border-jp-gray-900 bg-jp-gray-100 dark:bg-jp-gray-lightgray_background shadow dark:text-opacity-75  dark:bg-jp-gray-darkgray_background h-fit`}>
      <div className={`text-lg font-bold flex flex-row justify-between  -mr-2`}>
        {React.string(headerText)}
        <ModalCloseIcon onClick={onCloseClick} />
      </div>
    </div>
    <div
      className={`border border-jp-gray-500 dark:border-jp-gray-900  shadow  dark:text-opacity-75  dark:bg-jp-gray-darkgray_background overflow-scroll`}>
      {children}
    </div>
  </div>
}
