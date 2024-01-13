type popUpType = Success | Primary | Secondary | Danger | Warning | Denied
type iconType = WithIcon | WithoutIcon
type popUpSize = Small | Large

type popupAction = {
  text: string,
  icon?: Button.iconType,
  onClick?: ReactEvent.Mouse.t => unit,
}

type popUpProps = {
  heading: string,
  description: React.element,
  popUpType: (popUpType, iconType),
  handleCancel?: popupAction,
  handleConfirm: popupAction,
  popUpSize?: popUpSize,
}

let defaultOpenPopUp: array<popUpProps> = []

let openPopUp = Recoil.atom(. "openPopUp", defaultOpenPopUp)

let useShowPopUp = () => {
  let setOpenPopUp = Recoil.useSetRecoilState(openPopUp)

  React.useCallback1((popUpProps: popUpProps) => {
    setOpenPopUp(.prevArr => prevArr->Array.concat([popUpProps]))
  }, [setOpenPopUp])
}
