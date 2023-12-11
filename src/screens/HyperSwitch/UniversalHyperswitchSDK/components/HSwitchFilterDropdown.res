@react.component
let make = (
  ~list,
  ~selectedValue,
  ~setSelectedValue,
  ~showExtra,
  ~extraTitle,
  ~extraDesc,
  ~extraWidth,
  ~isShowFlag,
) => {
  let setRenderSDK = Recoil.useSetRecoilState(HSwitchRecoilAtoms.renderSDK)
  let isDesktop = HSwitchSDKUtils.getIsDesktop(
    Recoil.useRecoilValueFromAtom(HSwitchRecoilAtoms.size),
  )
  let isMobileScreen = Recoil.useRecoilValueFromAtom(HSwitchRecoilAtoms.isMobileScreen)

  let handleChange = name => {
    setSelectedValue(._ => name)

    setRenderSDK(._ => false)
    let _ = Js.Global.setTimeout(() => {
      setRenderSDK(._ => true)
    }, 500)
  }

  <div
    className={`flex flex-col justify-center items-center absolute z-[1] w-max top-6 ${isDesktop &&
      !isMobileScreen
        ? "left-auto right-auto"
        : "right-0 mr-[5%]"}`}>
    <div className={isDesktop && !isMobileScreen ? "" : "relative flex w-full justify-end pr-2"}>
      <Icon name="triangle" customWidth="21" customHeight="9" className="text-white" />
    </div>
    <div
      className="bg-white rounded border-[rgb(60,66,87)] text-sm font-normal shadow-filterDropdownShadow max-h-[841px] overflow-auto flex flex-col">
      {list
      ->Js.Array2.map(name => {
        let iconName = name->HSwitchSDKUtils.getCountryFromCustomerLocation->Js.String2.toLowerCase
        <button
          key={name}
          className="text-[rgb(84,105,212)] p-2 font-medium text-sm flex items-center hover:text-[rgb(60,66,87)] hover:bg-[rgb(246,248,251)]"
          onClick={_ => handleChange(name)}>
          <Icon size=12 name="tickMark" className={selectedValue != name ? "opacity-0" : ""} />
          {isShowFlag ? <Icon size=16 name={`${iconName}-flag`} className="ml-2" /> : React.null}
          <span className="ml-2"> {React.string(name)} </span>
        </button>
      })
      ->React.array}
      <UIUtils.RenderIf condition={showExtra}>
        <div
          className="text-[rgb(60,66,87)] text-sm mt-2 p-3 break-words shadow-filterExtraShadow"
          style={ReactDOMStyle.make(~width=extraWidth, ())}>
          <div className="flex flex-nowrap justify-start items-baseline text-[rgb(135,146,162)]">
            <Icon name="info-hs" size=12 />
            <div className="ml-2 mt-2 text-[rgb(105,115,134)]"> {React.string(extraTitle)} </div>
          </div>
          <div className="pl-5 pt-2 leading-4 font-normal text-xs"> {React.string(extraDesc)} </div>
        </div>
      </UIUtils.RenderIf>
    </div>
  </div>
}
