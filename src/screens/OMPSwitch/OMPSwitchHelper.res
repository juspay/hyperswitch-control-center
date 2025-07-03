module ListBaseComp = {
  @react.component
  let make = (
    ~heading="",
    ~subHeading,
    ~arrow,
    ~showEditIcon=false,
    ~onEditClick=_ => (),
    ~isDarkBg=false,
    ~showDropdownArrow=true,
    ~user: UserInfoTypes.entity,
  ) => {
    let {
      globalUIConfig: {sidebarColor: {secondaryTextColor, backgroundColor, borderColor}},
    } = React.useContext(ThemeProvider.themeContext)
    let {devOmpChart} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
    let arrowClassName = isDarkBg
      ? `${arrow
            ? "rotate-180"
            : "-rotate-0"} transition duration-[250ms] opacity-70 ${secondaryTextColor}`
      : `${arrow
            ? "rotate-0"
            : "rotate-180"} transition duration-[250ms] opacity-70 ${secondaryTextColor}`

    <>
      {switch user {
      | #Merchant =>
        <div
          className={`text-sm cursor-pointer font-semibold ${secondaryTextColor} hover:bg-opacity-80 flex flex-col gap-1`}>
          <div className="flex flex-row w-full justify-between">
            <span className={`text-xs ${secondaryTextColor} opacity-50 font-medium`}>
              {"Merchant Account"->React.string}
            </span>
            <RenderIf condition=devOmpChart>
              <ToolTip
                description="Organisation Chart"
                customStyle="!whitespace-nowrap"
                toolTipFor={<button
                  className={`${backgroundColor.sidebarNormal} border ${borderColor} w-5 h-5 rounded-md flex items-center justify-center`}
                  onClick={ev => {
                    ReactEvent.Mouse.stopPropagation(ev)
                    RescriptReactRouter.push(
                      GlobalVars.appendDashboardPath(~url="/organization-chart"),
                    )
                  }}>
                  <Icon name="github-fork" size=14 className={`${secondaryTextColor}`} />
                </button>}
                toolTipPosition=ToolTip.Right
              />
            </RenderIf>
          </div>
          <div className="text-left flex gap-2 w-13.5-rem justify-between">
            <p
              className={`fs-10 ${secondaryTextColor} overflow-scroll text-nowrap whitespace-pre `}>
              {subHeading->React.string}
            </p>
            {showDropdownArrow
              ? <Icon className={`${arrowClassName} ml-1`} name="nd-angle-down" size=12 />
              : React.null}
          </div>
        </div>

      | #Profile =>
        <div
          className="flex flex-row cursor-pointer items-center p-3 gap-2 md:min-w-44 justify-between h-8 bg-white border rounded-lg border-nd_gray-150 shadow-sm">
          <div className="md:max-w-40 max-w-16">
            <p
              className="overflow-scroll text-nowrap text-sm font-medium text-nd_gray-500 whitespace-pre">
              <span className={`text-xs text-nd_gray-400 font-medium`}>
                {"Profile :   "->React.string}
              </span>
              {React.string(subHeading)}
            </p>
          </div>
          {showDropdownArrow
            ? <Icon className={`${arrowClassName} ml-1`} name="nd-angle-down" size=12 />
            : React.null}
        </div>
      | _ => React.null
      }}
    </>
  }
}

module AddNewOMPButton = {
  @react.component
  let make = (
    ~user: UserInfoTypes.entity,
    ~setShowModal,
    ~customPadding="",
    ~customStyle="",
    ~customHRTagStyle="",
    ~addItemBtnStyle="",
  ) => {
    let allowedRoles = switch user {
    | #Organization => [#tenant_admin]
    | #Merchant => [#tenant_admin, #org_admin]
    | #Profile => [#tenant_admin, #org_admin, #merchant_admin]
    | _ => []
    }
    let hasOMPCreateAccess = OMPCreateAccessHook.useOMPCreateAccessHook(allowedRoles)
    let cursorStyles = GroupAccessUtils.cursorStyles(hasOMPCreateAccess)

    <ACLDiv
      authorization={hasOMPCreateAccess}
      noAccessDescription="You do not have the required permissions for this action. Please contact your admin."
      onClick={_ => setShowModal(_ => true)}
      isRelative=false
      contentAlign=Default
      tooltipForWidthClass="!h-full"
      className={`${cursorStyles} ${customPadding} ${addItemBtnStyle}`}
      showTooltip={hasOMPCreateAccess == Access}>
      {<>
        <hr className={customHRTagStyle} />
        <div
          className={` flex  items-center gap-2 font-medium  px-3.5 py-3 text-sm ${customStyle}`}>
          <Icon name="nd-plus" size=15 />
          {`Create new`->React.string}
        </div>
      </>}
    </ACLDiv>
  }
}

module OMPViewBaseComp = {
  @react.component
  let make = (~displayName, ~arrow, ~disabled) => {
    let arrowClass = arrow
      ? "rotate-180 transition duration-[250ms] opacity-70"
      : "rotate-0 transition duration-[250ms] opacity-70"

    let containerClass = disabled
      ? "p-0.5 !bg-nd_gray-50 !text-nd_gray-400 cursor-not-allowed border-nd_br_gray-200"
      : "cursor-pointer p-0.5 border-nd_br_gray-400"

    let textClass = disabled ? "text-nd_gray-400" : "text-nd_gray-600"

    let displayNameClass = disabled ? "text-nowrap text-nd_gray-400" : "text-nowrap text-primary"

    let truncatedDisplayName = if displayName->String.length > 15 {
      <HelperComponents.EllipsisText
        displayValue=displayName endValue=15 showCopy=false expandText=false
      />
    } else {
      {displayName->React.string}
    }

    <div className={`flex items-center border rounded-lg text-sm font-medium ${containerClass}`}>
      <div className="flex flex-col items-start">
        <div className="text-left flex items-center gap-1 p-2">
          <Icon name="settings-new" size=18 className={textClass} />
          <p className={`sm:block hidden fs-10 ${textClass} overflow-scroll text-nowrap`}>
            {`View data for:`->React.string}
          </p>
          <span className={displayNameClass}> {truncatedDisplayName} </span>
          <Icon className={`${arrowClass} ml-1`} name="angle-up" size=15 />
        </div>
      </div>
    </div>
  }
}

let generateDropdownOptionsOMPViews = (dropdownList: OMPSwitchTypes.ompViews, getNameForId) => {
  let options: array<SelectBox.dropdownOption> = dropdownList->Array.map((
    item
  ): SelectBox.dropdownOption => {
    {
      label: `${item.entity->getNameForId}`,
      value: `${(item.entity :> string)}`,
      labelDescription: `(${item.lable})`,
      description: `${item.entity->getNameForId}`,
    }
  })
  options
}

module OMPViewsComp = {
  @react.component
  let make = (
    ~input,
    ~options,
    ~displayName,
    ~entityMapper=UserInfoUtils.entityMapper,
    ~disabled=false,
  ) => {
    let (arrow, setArrow) = React.useState(_ => false)

    let toggleChevronState = () => {
      setArrow(prev => !prev)
    }

    let customScrollStyle = "md:max-h-72 md:overflow-scroll md:px-1 md:pt-1"
    let dropdownContainerStyle = "rounded-lg border md:w-full md:shadow-md"

    <div className="flex h-fit rounded-lg hover:bg-opacity-80">
      <SelectBox.BaseDropdown
        allowMultiSelect=false
        buttonText=""
        input
        deselectDisable=true
        customButtonStyle="!rounded-md"
        options
        marginTop="mt-8"
        hideMultiSelectButtons=false
        addButton=false
        customStyle="md:rounded"
        searchable=false
        baseComponent={<OMPViewBaseComp displayName arrow disabled />}
        baseComponentCustomStyle="bg-white rounded-lg"
        optionClass="font-inter text-fs-14 font-normal leading-5"
        selectClass="font-inter text-fs-14 font-normal leading-5 font-semibold"
        labelDescriptionClass="font-inter text-fs-12 font-normal leading-4"
        customDropdownOuterClass="!border-none !w-full"
        toggleChevronState
        customScrollStyle
        dropdownContainerStyle
        shouldDisplaySelectedOnTop=true
        descriptionOnHover=true
        textEllipsisForDropDownOptions=true
        disableSelect=disabled
      />
    </div>
  }
}

module OMPViews = {
  @react.component
  let make = (
    ~views: OMPSwitchTypes.ompViews,
    ~selectedEntity: UserInfoTypes.entity,
    ~onChange,
    ~entityMapper=UserInfoUtils.entityMapper,
    ~disabled=false,
    ~disabledDisplayName="",
  ) => {
    let (_, getNameForId) = OMPSwitchHooks.useOMPData()

    let input: ReactFinalForm.fieldRenderPropsInput = {
      name: "name",
      onBlur: _ => (),
      onChange: ev => {
        let value = ev->Identity.formReactEventToString
        onChange(value->UserInfoUtils.entityMapper)->ignore
      },
      onFocus: _ => (),
      value: (selectedEntity :> string)->JSON.Encode.string,
      checked: true,
    }

    let options = views->generateDropdownOptionsOMPViews(getNameForId)

    let displayName = disabled ? disabledDisplayName : selectedEntity->getNameForId
    <OMPViewsComp input options displayName disabled />
  }
}

module MerchantDropdownItem = {
  @react.component
  let make = (
    ~merchantName,
    ~productType,
    ~index: int,
    ~currentId,
    ~getMerchantList,
    ~switchMerch,
  ) => {
    open LogicUtils
    open APIUtils
    open ProductTypes
    open ProductUtils
    let (currentlyEditingId, setUnderEdit) = React.useState(_ => None)
    let handleIdUnderEdit = (selectedEditId: option<int>) => {
      setUnderEdit(_ => selectedEditId)
    }
    let {
      globalUIConfig: {sidebarColor: {backgroundColor, hoverColor, secondaryTextColor}},
    } = React.useContext(ThemeProvider.themeContext)
    let merchantList = Recoil.useRecoilValueFromAtom(HyperswitchAtom.merchantListAtom)
    let getURL = useGetURL()
    let updateDetails = useUpdateMethod()
    let showToast = ToastState.useShowToast()
    let {userInfo: {merchantId, version}} = React.useContext(UserInfoProvider.defaultContext)
    let isUnderEdit =
      currentlyEditingId->Option.isSome && currentlyEditingId->Option.getOr(0) == index
    let isMobileView = MatchMedia.useMobileChecker()

    let productTypeIconMapper = productType => {
      switch productType {
      | Orchestration(V1) => "orchestrator-home"
      | Recon => "recon-home"
      | Recovery => "recovery-home"
      | Vault => "vault-home"
      | CostObservability => "nd-piggy-bank"
      | DynamicRouting => "intelligent-routing-home"
      | Orchestration(V2) => "orchestrator-home"
      | Invalid => ""
      }
    }

    let isActive = currentId == merchantId
    let leftIconCss = {isActive && !isUnderEdit ? "" : isUnderEdit ? "hidden" : "invisible"}

    let leftIcon = if isActive && !isUnderEdit {
      <Icon name="nd-check" className={`${leftIconCss} ${secondaryTextColor}`} />
    } else if isActive && isUnderEdit {
      React.null
    } else if !isActive && !isUnderEdit {
      <ToolTip
        description={productType->getProductDisplayName}
        customStyle="!whitespace-nowrap"
        toolTipFor={<Icon
          name={productType->productTypeIconMapper}
          className={`${secondaryTextColor} opacity-50`}
          size=14
        />}
        toolTipPosition=ToolTip.Top
      />
    } else {
      React.null // Default case
    }

    let validateInput = (merchantName: string) => {
      let errors = Dict.make()
      let regexForMerchantName = "^([a-z]|[A-Z]|[0-9]|_|\\s)+$"
      let isDuplicate =
        merchantList->Array.some(merchant =>
          merchant.name->String.toLowerCase == merchantName->String.toLowerCase
        )
      let errorMessage = if merchantName->isEmptyString {
        "Merchant name cannot be empty"
      } else if merchantName->String.length > 64 {
        "Merchant name cannot exceed 64 characters"
      } else if !RegExp.test(RegExp.fromString(regexForMerchantName), merchantName) {
        "Merchant name should not contain special characters"
      } else if isDuplicate {
        "Merchant with this name already exists"
      } else {
        ""
      }
      if errorMessage->isNonEmptyString {
        Dict.set(errors, "merchant_name", errorMessage->JSON.Encode.string)
      }
      errors
    }

    let handleMerchantSwitch = id => {
      if !isActive {
        switchMerch(id)->ignore
      }
    }

    let onSubmit = async (newMerchantName: string) => {
      try {
        if version == V2 {
          let body =
            [("merchant_name", newMerchantName->JSON.Encode.string)]->getJsonFromArrayOfJson
          let accountUrl = getURL(
            ~entityName=V2(MERCHANT_ACCOUNT),
            ~methodType=Put,
            ~id=Some(merchantId),
          )
          let _ = await updateDetails(accountUrl, body, Put)
        } else {
          let body =
            [
              ("merchant_id", merchantId->JSON.Encode.string),
              ("merchant_name", newMerchantName->JSON.Encode.string),
            ]->getJsonFromArrayOfJson
          let accountUrl = getURL(
            ~entityName=V1(MERCHANT_ACCOUNT),
            ~methodType=Post,
            ~id=Some(merchantId),
          )
          let _ = await updateDetails(accountUrl, body, Post)
        }
        getMerchantList()->ignore
        showToast(~message="Updated Merchant name!", ~toastType=ToastSuccess)
      } catch {
      | _ => showToast(~message="Failed to update Merchant name!", ~toastType=ToastError)
      }
    }

    let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
    <>
      <div className={`rounded-lg`}>
        <InlineEditInput
          index
          labelText=merchantName
          customStyle={`w-full cursor-pointer mb-0 ${backgroundColor.sidebarSecondary} ${hoverColor} `}
          handleEdit=handleIdUnderEdit
          isUnderEdit
          showEditIcon={isActive && userHasAccess(~groupAccess=MerchantDetailsManage) === Access}
          showEditIconOnHover={!isMobileView}
          onSubmit
          labelTextCustomStyle={` truncate max-w-28 ${isActive
              ? `${secondaryTextColor}`
              : `${secondaryTextColor}`}`}
          validateInput
          customInputStyle={`!py-0 ${secondaryTextColor}`}
          customIconComponent={<ToolTip
            description={currentId}
            customStyle="!whitespace-nowrap"
            toolTipFor={<div className="cursor-pointer">
              <HelperComponents.CopyTextCustomComp
                customIconCss={`${secondaryTextColor}`}
                displayValue=Some("")
                copyValue=Some({currentId})
              />
            </div>}
            toolTipPosition=ToolTip.Right
          />}
          customIconStyle={isActive ? `${secondaryTextColor}` : ""}
          handleClick={_ => handleMerchantSwitch(currentId)}
          customWidth="min-w-56"
          leftIcon
        />
      </div>
    </>
  }
}

module ProfileDropdownItem = {
  @react.component
  let make = (~profileName, ~index: int, ~currentId, ~profileSwitch) => {
    open LogicUtils
    open APIUtils
    let (currentlyEditingId, setUnderEdit) = React.useState(_ => None)
    let handleIdUnderEdit = (selectedEditId: option<int>) => {
      setUnderEdit(_ => selectedEditId)
    }
    let getURL = useGetURL()
    let updateDetails = useUpdateMethod()
    let fetchDetails = useGetMethod()
    let showToast = ToastState.useShowToast()
    let {userInfo: {profileId, version}} = React.useContext(UserInfoProvider.defaultContext)
    let isUnderEdit =
      currentlyEditingId->Option.isSome && currentlyEditingId->Option.getOr(0) == index
    let (_, setProfileList) = Recoil.useRecoilState(HyperswitchAtom.profileListAtom)
    let isMobileView = MatchMedia.useMobileChecker()
    let isActive = currentId == profileId
    let setBusinessProfileRecoil =
      HyperswitchAtom.businessProfileFromIdAtom->Recoil.useSetRecoilState

    let getProfileList = async () => {
      try {
        let response = switch version {
        | V1 => {
            let url = getURL(~entityName=V1(USERS), ~userType=#LIST_PROFILE, ~methodType=Get)
            await fetchDetails(url)
          }
        | V2 => {
            let url = getURL(~entityName=V2(USERS), ~userType=#LIST_PROFILE, ~methodType=Get)
            await fetchDetails(url, ~version=V2)
          }
        }
        setProfileList(_ => response->getArrayDataFromJson(OMPSwitchUtils.profileItemToObjMapper))
      } catch {
      | _ => {
          setProfileList(_ => [OMPSwitchUtils.ompDefaultValue(profileId, "")])
          showToast(~message="Failed to fetch profile list", ~toastType=ToastError)
        }
      }
    }
    let validateInput = (profileName: string) => {
      let errors = Dict.make()
      let regexForProfileName = "^([a-z]|[A-Z]|[0-9]|_|\\s)+$"
      let errorMessage = if profileName->isEmptyString {
        "Profile name cannot be empty"
      } else if profileName->String.length > 64 {
        "Profile name cannot exceed 64 characters"
      } else if !RegExp.test(RegExp.fromString(regexForProfileName), profileName) {
        "Profile name should not contain special characters"
      } else {
        ""
      }
      if errorMessage->isNonEmptyString {
        Dict.set(errors, "profile_name", errorMessage->JSON.Encode.string)
      }
      errors
    }

    let handleProfileSwitch = id => {
      if !isActive {
        profileSwitch(id)->ignore
      }
    }

    let onSubmit = async (newProfileName: string) => {
      try {
        let body = [("profile_name", newProfileName->JSON.Encode.string)]->getJsonFromArrayOfJson
        let accountUrl = getURL(
          ~entityName=V1(BUSINESS_PROFILE),
          ~methodType=Post,
          ~id=Some(profileId),
        )
        let res = await updateDetails(accountUrl, body, Post)
        setBusinessProfileRecoil(_ => res->BusinessProfileMapper.businessProfileTypeMapper)
        let _ = await getProfileList()
        showToast(~message="Updated Profile name!", ~toastType=ToastSuccess)
      } catch {
      | _ => showToast(~message="Failed to update Profile name!", ~toastType=ToastError)
      }
    }

    let leftIconCss = {isActive && !isUnderEdit ? "" : isUnderEdit ? "hidden" : "invisible"}
    let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()

    <>
      <div
        className={`rounded-lg mb-1 ${isUnderEdit
            ? `hover:bg-transparent`
            : `hover:bg-jp-gray-100`}`}>
        <InlineEditInput
          index
          labelText=profileName
          customStyle="w-full cursor-pointer !bg-transparent mb-0"
          handleEdit=handleIdUnderEdit
          isUnderEdit
          showEditIcon={isActive &&
          userHasAccess(~groupAccess=MerchantDetailsManage) === Access &&
          version == V1}
          showEditIconOnHover={!isMobileView}
          onSubmit
          labelTextCustomStyle={` truncate max-w-28 ${isActive ? " text-nd_gray-700" : ""}`}
          validateInput
          customInputStyle="!py-0 text-nd_gray-600"
          customIconComponent={<ToolTip
            description={currentId}
            customStyle="!whitespace-nowrap"
            toolTipFor={<div className="cursor-pointer">
              <HelperComponents.CopyTextCustomComp
                displayValue=Some("") copyValue=Some(currentId) customIconCss="text-nd_gray-600"
              />
            </div>}
            toolTipPosition=ToolTip.Right
          />}
          customIconStyle={isActive ? "text-nd_gray-600" : ""}
          handleClick={_ => handleProfileSwitch(currentId)}
          customWidth="min-w-48"
          leftIcon={<Icon name="nd-check" className={`${leftIconCss}`} />}
        />
      </div>
    </>
  }
}

let generateDropdownOptions: (
  array<OMPSwitchTypes.ompListTypes>,
  ~customIconCss: string,
) => array<SelectBox.dropdownOption> = (dropdownList, ~customIconCss) => {
  let options: array<SelectBox.dropdownOption> = dropdownList->Array.map((
    item
  ): SelectBox.dropdownOption => {
    {
      label: item.name,
      value: item.id,
      icon: Button.CustomRightIcon(
        <ToolTip
          description={item.id}
          customStyle="!whitespace-nowrap"
          toolTipFor={<div className="cursor-pointer">
            <HelperComponents.CopyTextCustomComp
              displayValue=Some("") copyValue=Some({item.id}) customIconCss
            />
          </div>}
          toolTipPosition=ToolTip.TopRight
        />,
      ),
    }
  })
  options
}

let generateDropdownOptionsCustomComponent: array<OMPSwitchTypes.ompListTypesCustom> => array<
  SelectBox.dropdownOption,
> = dropdownList => {
  let options: array<SelectBox.dropdownOption> = dropdownList->Array.map((
    item
  ): SelectBox.dropdownOption => {
    let option: SelectBox.dropdownOption = {
      label: item.name,
      value: item.id,
      customComponent: item.customComponent,
      icon: Button.CustomRightIcon(
        <ToolTip
          description={item.id}
          customStyle="!whitespace-nowrap"
          toolTipFor={<div className="cursor-pointer">
            <HelperComponents.CopyTextCustomComp displayValue=Some("") copyValue=Some({item.id}) />
          </div>}
          toolTipPosition=ToolTip.TopRight
        />,
      ),
    }
    option
  })
  options
}
