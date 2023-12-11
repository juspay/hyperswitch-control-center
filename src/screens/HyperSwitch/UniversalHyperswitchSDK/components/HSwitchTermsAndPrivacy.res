@react.component
let make = (~className="") => {
  let themeColors = HSwitchSDKUtils.getThemeColorsFromTheme(
    Recoil.useRecoilValueFromAtom(HSwitchRecoilAtoms.theme),
  )
  let isDesktop = HSwitchSDKUtils.getIsDesktop(
    Recoil.useRecoilValueFromAtom(HSwitchRecoilAtoms.size),
  )

  let aTagClassName = `mr-3 underline decoration-dotted decoration-[${themeColors.textSecondaryColor}] text-[${themeColors.textSecondaryColor}] text-xs cursor-pointer`

  let css = `.desktopWrapperClass {
      position: absolute;
      bottom: 7%;
    }`

  <>
    <style> {React.string(css)} </style>
    <div
      className={`flex justify-center items-center ${isDesktop ? "desktopWrapperClass" : "mb-4"}`}>
      <UIUtils.RenderIf condition={isDesktop}>
        <PoweredBy className={`pt-1 pr-4 border-solid border-r-[1px]`} />
      </UIUtils.RenderIf>
      <a
        href=HSwitchSDKUtils.hyperswitchTermsOfServiceUrl
        className={`mr-3 ${isDesktop ? "pl-4" : ""} ${aTagClassName}`}>
        {React.string("Terms")}
      </a>
      <a href=HSwitchSDKUtils.hyperswitchPrivacyPolicyUrl className=aTagClassName>
        {React.string("Privacy")}
      </a>
    </div>
  </>
}
