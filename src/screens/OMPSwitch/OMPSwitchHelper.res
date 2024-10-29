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
  let make = (
    ~user,
    ~setShowModal,
    ~customPadding="",
    ~customStyle="",
    ~customHRTagStyle="",
    ~addItemBtnStyle="",
  ) => {
    let {userHasAccess, hasAnyGroupAccess} = GroupACLHooks.useUserGroupACLHook()
    let cursorStyles = GroupAccessUtils.cursorStyles(
      // TODO: Remove `MerchantDetailsManage` permission in future
      hasAnyGroupAccess(
        userHasAccess(~groupAccess=MerchantDetailsManage),
        userHasAccess(~groupAccess=AccountManage),
      ),
    )
    <ACLDiv
      // TODO: Remove `MerchantDetailsManage` permission in future
      authorization={hasAnyGroupAccess(
        userHasAccess(~groupAccess=MerchantDetailsManage),
        userHasAccess(~groupAccess=AccountManage),
      )}
      onClick={_ => setShowModal(_ => true)}
      isRelative=false
      contentAlign=Default
      tooltipForWidthClass="!h-full"
      className={`${cursorStyles} ${customPadding} ${addItemBtnStyle}`}>
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
    open OMPSwitchUtils

    let {userInfo} = React.useContext(UserInfoProvider.defaultContext)
    let merchantList = Recoil.useRecoilValueFromAtom(HyperswitchAtom.merchantListAtom)
    let orgList = Recoil.useRecoilValueFromAtom(HyperswitchAtom.orgListAtom)
    let profileList = Recoil.useRecoilValueFromAtom(HyperswitchAtom.profileListAtom)

    let cssBasedOnIndex = index => {
      if index == 0 {
        "rounded-l-md"
      } else if index == views->Array.length - 1 {
        "rounded-r-md"
      } else {
        ""
      }
    }

    let getName = entityType => {
      let name = switch entityType {
      | #Organization => currentOMPName(orgList, userInfo.orgId)
      | #Merchant => currentOMPName(merchantList, userInfo.merchantId)
      | #Profile => currentOMPName(profileList, userInfo.profileId)
      | _ => ""
      }
      name->String.length > 10
        ? name
          ->String.substring(~start=0, ~end=10)
          ->String.concat("...")
        : name
    }

    <div className="flex h-fit">
      {views
      ->Array.mapWithIndex((value, index) => {
        let selectedStyle = selectedEntity == value.entity ? `bg-blue-200` : ""
        <div
          key={index->Int.toString}
          onClick={_ => onChange(value.entity)->ignore}
          className={`text-xs py-2 px-3 ${selectedStyle} border text-blue-500 border-blue-500 ${index->cssBasedOnIndex} cursor-pointer break-all`}>
          {`${value.lable} (${value.entity->getName})`->React.string}
        </div>
      })
      ->React.array}
    </div>
  }
}

module OMPCopyTextCustomComp = {
  @react.component
  let make = (
    ~displayValue,
    ~copyValue=None,
    ~customTextCss="",
    ~customParentClass="flex items-center",
    ~customOnCopyClick=() => (),
  ) => {
    let showToast = ToastState.useShowToast()
    let copyVal = switch copyValue {
    | Some(val) => val
    | None => displayValue
    }
    let onCopyClick = ev => {
      ev->ReactEvent.Mouse.stopPropagation
      Clipboard.writeText(copyVal)
      customOnCopyClick()
      showToast(~message="Copied to Clipboard!", ~toastType=ToastSuccess)
    }

    if displayValue->LogicUtils.isNonEmptyString {
      <div className=customParentClass>
        <div className=customTextCss> {displayValue->React.string} </div>
        <img
          alt="cursor"
          src={`/assets/copyid.svg`}
          className="cursor-pointer"
          onClick={ev => {
            onCopyClick(ev)
          }}
        />
      </div>
    } else {
      "NA"->React.string
    }
  }
}

let generateDropdownOptions: array<OMPSwitchTypes.ompListTypes> => array<
  SelectBox.dropdownOption,
> = dropdownList => {
  let options: array<SelectBox.dropdownOption> = dropdownList->Array.map((
    item
  ): SelectBox.dropdownOption => {
    label: item.name,
    value: item.id,
    icon: Button.CustomRightIcon(
      <ToolTip
        description={item.id}
        customStyle="!whitespace-nowrap"
        toolTipFor={<div className="cursor-pointer">
          <OMPCopyTextCustomComp displayValue=" " copyValue=Some({item.id}) />
        </div>}
        toolTipPosition=ToolTip.TopRight
      />,
    ),
  })
  options
}
