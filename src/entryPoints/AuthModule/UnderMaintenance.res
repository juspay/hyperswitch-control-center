@react.component
let make = () => {
  open HeadlessUI
  <>
    <Transition
      \"as"="span"
      enter={"transition ease-out duration-300"}
      enterFrom="opacity-0 translate-y-1"
      enterTo="opacity-100 translate-y-0"
      leave={"transition ease-in duration-300"}
      leaveFrom="opacity-100 translate-y-0"
      leaveTo="opacity-0 translate-y-1"
      show={true}>
      <div
        className={`flex flex-row px-4 py-2 md:gap-8 gap-4 rounded whitespace-nowrap text-fs-13 bg-yellow-200 border-yellow-200 font-semibold justify-center`}>
        <div className="flex gap-2">
          <div className="flex text-gray-500 items-center">
            {`Hyperswitch Control Center is under maintenance`->React.string}
          </div>
        </div>
      </div>
    </Transition>
    <NoDataFound
      message="Hyperswitch Control Center is under maintenance will be back in an hour"
      renderType=LoadError
    />
  </>
}
