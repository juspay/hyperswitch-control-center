@react.component
let make = (~isShowFilters, ~isShowTestCards, ~children=React.null) => {
  let (shirtQuantity, setShirtQuantity) = React.useState(() => 1)
  let (capQuantity, setCapQuantity) = React.useState(() => 2)
  let isModalOpen = Recoil.useRecoilValueFromAtom(HSwitchRecoilAtoms.isModalOpen)

  let renderSDK = Recoil.useRecoilValueFromAtom(HSwitchRecoilAtoms.renderSDK)
  let theme = Recoil.useRecoilValueFromAtom(HSwitchRecoilAtoms.theme)
  let isDesktop = HSwitchSDKUtils.getIsDesktop(
    Recoil.useRecoilValueFromAtom(HSwitchRecoilAtoms.size),
  )

  let themeColors = HSwitchSDKUtils.getThemeColorsFromTheme(theme)
  let setSize = Recoil.useSetRecoilState(HSwitchRecoilAtoms.size)
  let setIsMobileScreen = Recoil.useSetRecoilState(HSwitchRecoilAtoms.isMobileScreen)
  let isMobileScreen = MatchMedia.useMatchMedia("(max-width: 1100px)")

  let (amount, setAmount) = Recoil.useRecoilState(HSwitchRecoilAtoms.amount)

  let mobileWrapperClass = "w-[336px] rounded-[48px] p-2 mx-auto h-[760px] shadow-websiteShadow"
  let desktopWrapperClass = "rounded-[8px] shadow-websiteShadow"

  let mobileHeaderWrapperClass = "relative h-full rounded-[40px] overflow-hidden bg-white shadow-mobileHeaderShadow"

  React.useEffect1(() => {
    if isMobileScreen {
      setSize(._ => "Mobile")
      setIsMobileScreen(._ => true)
    } else {
      setIsMobileScreen(._ => false)
    }

    None
  }, [isMobileScreen])

  React.useEffect2(() => {
    setAmount(._ => HSwitchSDKUtils.amountToDisplay(~shirtQuantity, ~capQuantity))
    None
  }, (shirtQuantity, capQuantity))

  let getMobileFrameButtonElement = className => {
    <div className={`bg-jb-black-800 absolute w-[0.4rem] ${className}`} />
  }

  <div>
    <HSwitchExtraFeatures isShowFilters />
    <div
      className={`max-w-[60vw] pt-[3%] m-auto relative ${isDesktop
          ? ""
          : "flex justify-center px-4"}`}>
      <div
        className={isDesktop ? "" : "relative px-[0.2rem] shadow-mobileFrameShadow rounded-[48px]"}>
        <UIUtils.RenderIf condition={!isDesktop}>
          {getMobileFrameButtonElement("left-0 top-[7.5rem] h-10 rounded-tl-md rounded-bl-md")}
          {getMobileFrameButtonElement("left-0 top-48 h-16 rounded-tl-md rounded-bl-md")}
          {getMobileFrameButtonElement("left-0 top-[17rem] h-16 rounded-tl-md rounded-bl-md")}
          {getMobileFrameButtonElement("right-0 top-52 h-24 rounded-tr-md rounded-br-md")}
        </UIUtils.RenderIf>
        <div
          className={isDesktop
            ? ""
            : "bg-grey-mobile_frame w-[336px] rounded-[48px] p-1 flex justify-center box-content"}>
          <div className={isDesktop ? "" : "bg-black w-[336px] rounded-[48px]"}>
            <div
              className={`relative z-0 ${isDesktop ? desktopWrapperClass : mobileWrapperClass}`}
              style={isDesktop
                ? ReactDOMStyle.make(
                    ~backgroundColor=themeColors.backgroundColor,
                    ~color=themeColors.color,
                    (),
                  )
                : ReactDOMStyle.make()}>
              <div className={`flex flex-col ${isDesktop ? "" : mobileHeaderWrapperClass}`}>
                <HSwitchHeader />
                <div
                  className={`flex mt-[1px] rounded-lg ${isDesktop
                      ? "relative min-h-[62vh] overflow-hidden max-h-[77vh]"
                      : `flex-col h-full ${isModalOpen ? "overflow-hidden" : "overflow-scroll"}`}`}
                  style={!isDesktop
                    ? ReactDOMStyle.make(
                        ~backgroundColor=themeColors.backgroundColor,
                        ~color=themeColors.color,
                        (),
                      )
                    : ReactDOMStyle.make()}>
                  <HSwitchPaymentCompletePopup />
                  <div
                    className={`py-[5%] pr-[5%] border-box ${isDesktop
                        ? "w-1/2 before:content-[' '] before:h-full before:absolute before:right-0 before:top-0 before:w-1/2 before:origin-right before:rounded-br-lg pl-[8%]"
                        : "w-full mb-8 flex flex-col pl-[5%]"} ${themeColors.boxShadowClassForSDK}`}>
                    <div className="flex items-center mb-8">
                      <Icon name="hyperswitch-logo" size=28 className="mr-2 mt-0.5" />
                      <div
                        className="text-sm font-medium"
                        style={ReactDOMStyle.make(~color=themeColors.hyperswitchHeaderColor, ())}>
                        {React.string("Hyperswitch Demo Store")}
                      </div>
                      <div
                        className="bg-[rgb(255,222,146)] text-[rgb(187,85,4)] text-[11px] font-bold leading-[14.3px] uppercase p-1 rounded-[4px] ml-[0.6rem] text-center">
                        {React.string(isDesktop ? "Test Mode" : "Test")}
                      </div>
                    </div>
                    <div
                      className={`flex flex-col mb-[32px] ${isDesktop
                          ? "items-baseline"
                          : "items-center"}`}>
                      <UIUtils.RenderIf condition={!isDesktop}>
                        <img
                          className="rounded-[6px] h-[130px] max-h-[130px] max-w-full mb-4"
                          src="assets/hyperswitchSDK/shirt.png"
                        />
                      </UIUtils.RenderIf>
                      <div
                        className="font-medium leading-[20.8px]"
                        style={ReactDOMStyle.make(~color=themeColors.payHeaderColor, ())}>
                        {React.string("Pay Hyperswitch")}
                      </div>
                      <div
                        className="leading-[46.8px] text-[36px] font-medium"
                        style={ReactDOMStyle.make(~color=themeColors.amountColor, ())}>
                        {React.string("US$")}
                        <span className="ml-1"> {React.string(amount)} </span>
                      </div>
                    </div>
                    <HSwitchViewProducts
                      shirtQuantity setShirtQuantity capQuantity setCapQuantity
                    />
                    <UIUtils.RenderIf condition={isDesktop}>
                      <HSwitchTermsAndPrivacy className="mt-[33vh]" />
                    </UIUtils.RenderIf>
                  </div>
                  <div
                    className={`z-10 ${isDesktop
                        ? "w-1/2 px-[8%] overflow-scroll py-[5%]"
                        : "w-full px-[5%] pb-[10%] pt-[5%]"}`}>
                    <UIUtils.RenderIf condition={renderSDK}> {children} </UIUtils.RenderIf>
                  </div>
                  <UIUtils.RenderIf condition={!isDesktop}>
                    <HSwitchTermsAndPrivacy className="mb-4" />
                  </UIUtils.RenderIf>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    <UIUtils.RenderIf condition={isShowTestCards}>
      <HSwitchTestCards />
    </UIUtils.RenderIf>
  </div>
}
