@react.component
let make = (~className="pt-4") => {
  let theme = Recoil.useRecoilValueFromAtom(HSwitchRecoilAtoms.theme)
  let themeColors = HSwitchSDKUtils.getThemeColorsFromTheme(theme)
  <div
    className={`text-xs text-center w-full flex justify-center ${className}`}
    style={ReactDOMStyle.make(~color=themeColors.hyperswitchHeaderColor, ())}>
    <Icon customHeight="18" customWidth="130" name="powered-by-hyper" />
  </div>
}
