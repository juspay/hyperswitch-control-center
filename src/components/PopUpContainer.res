open PopUpState

@react.component
let make = (~children) => {
  let (openPopUps, setOpenPopUp) = Recoil.useRecoilState(PopUpState.openPopUp)
  let activePopUp = openPopUps->Belt.Array.get(0)
  let popUp = switch activePopUp {
  | Some(popUp) => {
      let handleConfirm = ev => {
        setOpenPopUp(.prevArr => prevArr->Js.Array2.sliceFrom(1))
        switch popUp.handleConfirm.onClick {
        | Some(onClick) => onClick(ev)
        | None => ()
        }
      }

      let handlePopUp = ev => {
        setOpenPopUp(.prevArr => prevArr->Js.Array2.sliceFrom(1))
        switch popUp.handleCancel {
        | Some(fn) =>
          switch fn.onClick {
          | Some(onClick) => onClick(ev)
          | None => ev->ReactEvent.Mouse.stopPropagation
          }
        | None => ()
        }
      }

      let handleCancel = ev => {
        setOpenPopUp(.prevArr => prevArr->Js.Array2.sliceFrom(1))
        switch popUp.handleCancel {
        | Some(fn) =>
          switch fn.onClick {
          | Some(onClick) => onClick(ev)
          | None => ev->ReactEvent.Mouse.stopPropagation
          }
        | None => ()
        }
      }
      let {heading, description, popUpType} = popUp
      let popUpSize = switch popUp.popUpSize {
      | Some(size) => size
      | None => Large
      }

      let (buttonText, confirmButtonIcon) = (popUp.handleConfirm.text, popUp.handleConfirm.icon)

      let (cancelButtonText, showCloseIcon, cancelButtonIcon) = switch popUp.handleCancel {
      | Some(obj) => (Some(obj.text), Some(true), obj.icon)
      | None => (None, None, None)
      }

      let (popUpTypeActual, showIcon) = popUpType
      let showIcon = switch showIcon {
      | WithIcon => true
      | WithoutIcon => false
      }

      <PopUpConfirm
        handlePopUp
        handleConfirm
        handleCancel
        confirmType=heading
        confirmText=description
        buttonText
        ?confirmButtonIcon
        ?cancelButtonIcon
        popUpType=popUpTypeActual
        ?cancelButtonText
        showIcon
        showPopUp=true
        ?showCloseIcon
        popUpSize
      />
    }

  | None => React.null
  }

  <div className="relative">
    children
    {popUp}
  </div>
}
