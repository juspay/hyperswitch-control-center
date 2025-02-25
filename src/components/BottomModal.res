@react.component
let make = (~onCloseClick, ~children, ~headerText) => {
  let onClick = e => {
    e->ReactEvent.Mouse.stopPropagation
  }

  <div
    onClick
    className={`flex flex-col border border-gray-250 dark:border-gray-800  bg-gray-900/70 dark:bg-white-600/80 fixed h-screen w-screen z-40 pt-12 justify-end inset-0  backdrop-blur-xs overscroll-contain`}>
    <div
      className={`!pl-4 desktop:bg-gray-200 z-10 sticky w-full top-0 m-0 md:!pl-6 p-4 border border-gray-250 dark:border-gray-800 bg-gray-50 shadow-sm dark:bg-jp-gray-darkgray_background h-fit`}>
      <div className={`text-lg font-bold flex flex-row justify-between  -mr-2`}>
        {React.string(headerText)}
        <ModalCloseIcon onClick={onCloseClick} />
      </div>
    </div>
    <div
      className={`border border-gray-250 dark:border-gray-800  shadow-sm dark:bg-jp-gray-darkgray_background overflow-scroll`}>
      {children}
    </div>
  </div>
}
