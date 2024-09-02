module ListBaseComp = {
  @react.component
  let make = (~heading, ~subHeading) => {
    let (arrow, setArrow) = React.useState(_ => false)

    <div
      className="flex items-center justify-between text-sm text-center text-white font-medium rounded hover:bg-opacity-80 bg-sidebar-blue"
      onClick={_ => setArrow(prev => !prev)}>
      <div className="flex flex-col items-start px-2 py-2">
        <p className="text-xs text-gray-400"> {heading->React.string} </p>
        <p className="fs-10"> {subHeading->React.string} </p>
      </div>
      <div className="px-2 py-2">
        <Icon
          className={arrow
            ? "-rotate-180 transition duration-[250ms] opacity-70"
            : "rotate-0 transition duration-[250ms] opacity-70"}
          name="arrow-without-tail-new"
          size=15
        />
      </div>
    </div>
  }
}

module AddNewMerchantProfileButton = {
  @react.component
  let make = (~user, ~setShowModal, ~customPadding="", ~customStyle="", ~customHRTagStyle="") => {
    let userPermissionJson = Recoil.useRecoilValueFromAtom(HyperswitchAtom.userPermissionAtom)
    let cursorStyles = PermissionUtils.cursorStyles(userPermissionJson.merchantDetailsManage)
    <ACLDiv
      permission={userPermissionJson.merchantDetailsManage}
      onClick={_ => setShowModal(_ => true)}
      isRelative=false
      contentAlign=Default
      tooltipForWidthClass="!h-full"
      className={`${cursorStyles} ${customPadding}`}>
      {<>
        <hr className={customHRTagStyle} />
        <div
          className={`group flex  items-center gap-2 font-medium px-2 py-2 text-sm ${customStyle}`}>
          <Icon name="plus-circle" size=15 />
          {`Add new ${user}`->React.string}
        </div>
      </>}
    </ACLDiv>
  }
}
