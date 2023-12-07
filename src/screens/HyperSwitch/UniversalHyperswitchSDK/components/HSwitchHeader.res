@react.component
let make = () => {
  let isDesktop = HSwitchSDKUtils.getIsDesktop(
    Recoil.useRecoilValueFromAtom(HSwitchRecoilAtoms.size),
  )

  let desktopHeaderClass = "rounded-lg py-[6px] px-3"

  let mobileDomainClass = "p-4"
  let desktopDomainClass = "bg-[rgba(236,242,247,.4)] rounded-xl"

  let windowControlElement = <div className="mr-[6px] w-2 h-2 rounded-full bg-[#ecf2f7]" />

  <div
    className={`bg-[#fcfeff] flex items-center shadow-websiteHeaderShadow ${isDesktop
        ? desktopHeaderClass
        : ""}`}>
    <UIUtils.RenderIf condition={isDesktop}>
      <div className="flex mr-8">
        {windowControlElement}
        {windowControlElement}
        {windowControlElement}
      </div>
    </UIUtils.RenderIf>
    <div
      className={`flex mx-auto items-center justify-center font-semibold text-[8px] leading-3 text-[#0a2540] w-[615px] h-5 ${isDesktop
          ? desktopDomainClass
          : mobileDomainClass}`}>
      <ul className="grid grid-cols-[1fr_1fr_1fr] justify-center list-none items-center w-full">
        <li className="col-start-2 flex items-center">
          <Icon size=8 name="lock-hs" className="mr-1 text-[#6B7A94]" />
          <div> {React.string(HSwitchSDKUtils.websiteDomain)} </div>
        </li>
      </ul>
    </div>
  </div>
}
