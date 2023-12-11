@react.component
let make = (~isShowFilters, ~isShowTestCards, ~children=React.null) => {
  let renderSDK = Recoil.useRecoilValueFromAtom(HSwitchRecoilAtoms.renderSDK)
  let theme = Recoil.useRecoilValueFromAtom(HSwitchRecoilAtoms.theme)
  let isDesktop = HSwitchSDKUtils.getIsDesktop(
    Recoil.useRecoilValueFromAtom(HSwitchRecoilAtoms.size),
  )
  let setIsMobileScreen = Recoil.useSetRecoilState(HSwitchRecoilAtoms.isMobileScreen)
  let isMobileScreen = MatchMedia.useMatchMedia("(max-width: 1100px)")

  let themeColors = HSwitchSDKUtils.getThemeColorsFromTheme(theme)

  let setSize = Recoil.useSetRecoilState(HSwitchRecoilAtoms.size)

  React.useEffect1(() => {
    if isMobileScreen {
      setSize(._ => "Mobile")
      setIsMobileScreen(._ => true)
    } else {
      setIsMobileScreen(._ => false)
    }

    None
  }, [isMobileScreen])

  <div>
    <UIUtils.RenderIf condition={isShowFilters}>
      <HSwitchFilters />
    </UIUtils.RenderIf>
    <div
      className={`relative z-0 shadow-websiteShadow`}
      style={ReactDOMStyle.make(
        ~backgroundColor=themeColors.backgroundColor,
        ~color=themeColors.color,
        (),
      )}>
      <HSwitchPaymentCompletePopup />
      <div className={`flex flex-col items-center`}>
        <div className={`z-10 py-[5%] ${isDesktop ? "w-1/2 px-[5%] max-w-2xl" : "w-[360px] px-8"}`}>
          <UIUtils.RenderIf condition={renderSDK}> {children} </UIUtils.RenderIf>
        </div>
      </div>
    </div>
    <UIUtils.RenderIf condition={isShowTestCards}>
      <HSwitchTestCards />
    </UIUtils.RenderIf>
  </div>
}
