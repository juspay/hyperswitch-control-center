module ListBaseComp = {
  @react.component
  let make = (~heading, ~subHeading, ~arrow) => {
    <div
      className="flex items-center justify-between text-sm text-center text-white font-medium rounded hover:bg-opacity-80 bg-sidebar-blue cursor-pointer">
      <div className="flex flex-col items-start px-2 py-2 w-5/6">
        <p className="text-xs text-gray-400"> {heading->React.string} </p>
        <div className="w-full text-left overflow-auto">
          <p className="fs-10"> {subHeading->React.string} </p>
        </div>
      </div>
      <div className="px-2 py-2">
        <Icon
          className={arrow
            ? "rotate-0 transition duration-[250ms] opacity-70"
            : "-rotate-180 transition duration-[250ms] opacity-70"}
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

module OMPViews = {
  @react.component
  let make = (
    ~views: OMPSwitchTypes.ompViews,
    ~selectedEntity: UserInfoTypes.entity,
    ~onChange,
  ) => {
    let cssBasedOnIndex = index => {
      if index == 0 {
        "rounded-l-md"
      } else if index == views->Array.length - 1 {
        "rounded-r-md"
      } else {
        ""
      }
    }

    <div className="flex h-fit">
      {views
      ->Array.mapWithIndex((value, index) => {
        let selectedStyle = selectedEntity == value.entity ? `bg-blue-200` : ""
        <div
          onClick={_ => onChange(value.entity)->ignore}
          className={`text-sm py-2 px-3 ${selectedStyle} border text-blue-500 border-blue-500 ${index->cssBasedOnIndex} cursor-pointer`}>
          {value.lable->React.string}
        </div>
      })
      ->React.array}
    </div>
  }
}
