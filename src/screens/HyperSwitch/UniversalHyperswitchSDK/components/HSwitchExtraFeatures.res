@react.component
let make = (~isShowFilters) => {
  let isMobileScreen = Recoil.useRecoilValueFromAtom(HSwitchRecoilAtoms.isMobileScreen)

  <div className={"bg-white py-4"}>
    <div className={`flex flex-col m-auto ${isMobileScreen ? "px-4" : "max-w-[60vw]"}`}>
      <div className="flex justify-between">
        <span className="font-extrabold text-lg text-[#8792A2]">
          {React.string("Hyperswitch")}
        </span>
        <div className="flex items-center">
          <a className="mr-3 text-[rgb(99,91,255)]" href=HSwitchSDKUtils.hyperswitchRegisterUrl>
            {React.string("Create Account")}
          </a>
          <div className="border-r border-solid border-[#e3e8ee] flex ml-[2px] mr-3 h-5" />
          <a
            className="text-[rgb(99,91,255)] flex items-center"
            href=HSwitchSDKUtils.hyperswitchDocsUrl>
            <span className="mr-3"> {React.string("Explore the docs")} </span>
            <Icon name="arrow-right" size=12 className="text-[#6C8EEF]" />
          </a>
        </div>
      </div>
      <div className="my-[14px] text-2xl font-bold"> {React.string("Explore Hyperswitch")} </div>
      <UIUtils.RenderIf condition={isShowFilters}>
        <HSwitchFilters />
      </UIUtils.RenderIf>
    </div>
  </div>
}
