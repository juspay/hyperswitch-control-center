@react.component
let make = (~isModalOpen, ~setIsModalOpen, ~children) => {
  let setIsGlobalModalOpen = Recoil.useSetRecoilState(HSwitchRecoilAtoms.isModalOpen)

  let themeColors = HSwitchSDKUtils.getThemeColorsFromTheme(
    Recoil.useRecoilValueFromAtom(HSwitchRecoilAtoms.theme),
  )
  let isDesktop = HSwitchSDKUtils.getIsDesktop(
    Recoil.useRecoilValueFromAtom(HSwitchRecoilAtoms.size),
  )

  let handleModalClose = () => {
    if !isDesktop {
      setIsModalOpen(_ => false)
      setIsGlobalModalOpen(._ => false)
    }
  }

  React.useLayoutEffect0(() => {
    Window.addEventListener("click", ev => {
      let targetId = ReactEvent.Mouse.target(ev)["id"]
      if targetId === "modal-wrapper" {
        handleModalClose()
      }
    })
    Some(
      () => {
        Window.addEventListener("click", ev => {
          let targetId = ReactEvent.Mouse.target(ev)["id"]
          if targetId === "modal-wrapper" {
            handleModalClose()
          }
        })
      },
    )
  })

  <UIUtils.RenderIf condition={isModalOpen}>
    <div
      id="modal-wrapper"
      className={`z-50 inset-0 absolute flex items-center justify-center before:bg-[rgba(0,0,0,.2)] before:absolute before:inset-0 before:blur-[20px] ${isDesktop
          ? ""
          : ""}`}>
      <div
        className={`absolute flex flex-col justify-center items-center rounded-lg box-border shadow-modalShadow ${isDesktop
            ? "w-[356px]"
            : "w-full bottom-0"}`}
        style={ReactDOMStyle.make(~backgroundColor=themeColors.modalBackgroundColor, ())}
        onClick={_ => ()}>
        {children}
      </div>
    </div>
  </UIUtils.RenderIf>
}
