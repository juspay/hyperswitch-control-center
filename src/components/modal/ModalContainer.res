module ModalHeading = {
  @react.component
  let make = (~title, ~hideModal) => {
    let handleClick = React.useCallback1(_ev => {
      hideModal()
    }, [hideModal])
    <div className="bg-purple-300 p-4 text-lg flex flex-row justify-between">
      <div> {title->React.string} </div>
      <button className="text-purple-700" onClick=handleClick>
        <Icon name="times" />
      </button>
    </div>
  }
}

module Modal = {
  external convertToWebapiEvent: ReactEvent.Mouse.t => Webapi.Dom.Event.t = "%identity"

  @react.component
  let make = (~modalProps: ModalsState.modalProps, ~hideModalAtIndex, ~index) => {
    let hideModal = React.useCallback2(() => {
      hideModalAtIndex(index)
    }, (hideModalAtIndex, index))

    let handleOutsideClick = React.useCallback2(_ev => {
      if modalProps.closeOnClickOutside {
        hideModal()
      }
    }, (modalProps.closeOnClickOutside, hideModal))

    let stopPropagation = React.useCallback0(ev => {
      ev->convertToWebapiEvent->Webapi.Dom.Event.stopPropagation
    })
    <div
      className="absolute inset-0 overflow-scroll bg-gray-500 bg-opacity-50 flex flex-col items-center"
      onClick=handleOutsideClick>
      <div className="w-full md:w-4/5 lg:w-3/5 md:my-40 shadow-lg" onClick=stopPropagation>
        <ModalHeading title=modalProps.title hideModal />
        <div className="bg-white p-4"> {modalProps.getContent(hideModal)} </div>
      </div>
    </div>
  }
}

@react.component
let make = (~children) => {
  let (openModals, setOpenModals) = Recoil.useRecoilState(ModalsState.openModals)
  let hideModalAtIndex = React.useCallback1(index => {
    setOpenModals(.prevArr => {
      Array.filterWithIndex(
        prevArr,
        (_, i) => {
          i !== index
        },
      )
    })
  }, [setOpenModals])
  let fontClass = "font-ibm-plex"

  <div className={`relative ${fontClass}`}>
    children
    <div>
      {openModals
      ->Array.mapWithIndex((modalProps, i) => {
        <Modal key={string_of_int(i)} modalProps index=i hideModalAtIndex />
      })
      ->React.array}
    </div>
  </div>
}
