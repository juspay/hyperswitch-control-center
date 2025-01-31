module ListBaseComp = {
  @react.component
  let make = (
    ~heading,
    ~subHeading,
    ~arrow,
    ~showEditIcon=false,
    ~onEditClick=_ => (),
    ~isDarkBg=false,
    ~showDropdownArrow=true,
  ) => {
    let {globalUIConfig: {sidebarColor: {secondaryTextColor}}} = React.useContext(
      ThemeProvider.themeContext,
    )
    let baseCompStyle = isDarkBg
      ? "text-white hover:bg-opacity-80 bg-sidebar-blue"
      : "text-black hover:bg-opacity-80"

    let iconName = isDarkBg ? "arrow-without-tail-new" : "arrow-without-tail"

    let arrowDownClass = isDarkBg
      ? `rotate-0 transition duration-[250ms] opacity-70 ${secondaryTextColor}`
      : `rotate-180 transition duration-[250ms] opacity-70 `

    let arrowUpClass = isDarkBg
      ? `-rotate-180 transition duration-[250ms] opacity-70 ${secondaryTextColor}`
      : `rotate-0 transition duration-[250ms] opacity-70 `

    let textColor = isDarkBg ? `${secondaryTextColor}` : "text-grey-900"
    let width = isDarkBg ? "w-[12rem]" : "min-w-[5rem] w-fit max-w-[10rem]"
    let paddingSubheading = isDarkBg ? "pl-2" : ""
    let paddingHeading = isDarkBg ? "pl-2" : ""

    let endValue = isDarkBg ? 20 : 15
    let maxLength = isDarkBg ? 20 : 15

    let subHeadingElement = if subHeading->String.length > maxLength {
      <HelperComponents.EllipsisText
        displayValue=subHeading endValue showCopy=false customTextStyle={textColor}
      />
    } else {
      {subHeading->React.string}
    }

    <div className={`text-sm font-medium cursor-pointer ${baseCompStyle}`}>
      <div className={`flex flex-col items-start`}>
        <RenderIf condition={heading->LogicUtils.isNonEmptyString}>
          <p className={`text-xs text-left text-gray-400 ${paddingHeading}`}>
            {heading->React.string}
          </p>
        </RenderIf>
        <div className="text-left flex gap-2">
          <p
            className={`fs-10 ${textColor} ${width} ${paddingSubheading} overflow-scroll text-nowrap`}>
            {subHeadingElement}
          </p>
          <RenderIf condition={!showDropdownArrow}>
            <ToolTip
              description={subHeading}
              customStyle="!whitespace-nowrap"
              toolTipFor={<div className="cursor-pointer">
                <HelperComponents.CopyTextCustomComp
                  displayValue=" " copyValue=Some({subHeading})
                />
              </div>}
              toolTipPosition=ToolTip.Right
            />
          </RenderIf>
          <RenderIf condition={showEditIcon}>
            <Icon name="pencil-edit" size=15 onClick=onEditClick className="mx-2" />
          </RenderIf>
          <RenderIf condition={showDropdownArrow}>
            <Icon
              className={`${arrow ? arrowDownClass : arrowUpClass} ml-1`} name={iconName} size=15
            />
          </RenderIf>
        </div>
      </div>
    </div>
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
          className={`group flex  items-center gap-2 font-medium  px-3.5 py-3 text-sm ${customStyle}`}>
          <Icon name="nd-plus" size=15 />
          {`Create new`->React.string}
        </div>
      </>}
    </ACLDiv>
  }
}

module OMPViewBaseComp = {
  @react.component
  let make = (~displayName, ~arrow) => {
    let arrowUpClass = "rotate-0 transition duration-[250ms] opacity-70"
    let arrowDownClass = "rotate-180 transition duration-[250ms] opacity-70"

    let truncatedDisplayName = if displayName->String.length > 15 {
      <HelperComponents.EllipsisText
        displayValue=displayName endValue=15 showCopy=false expandText=false
      />
    } else {
      {displayName->React.string}
    }

    <div
      className="flex items-center text-sm font-medium cursor-pointer secondary-gradient-border rounded-lg h-40-px">
      <div className="flex flex-col items-start">
        <div className="text-left flex items-center gap-1 p-2">
          <Icon name="settings-new" size=18 />
          <p className="text-jp-gray-900 fs-10 overflow-scroll text-nowrap">
            {`View data for:`->React.string}
          </p>
          <span className="text-primary text-nowrap"> {truncatedDisplayName} </span>
          <Icon
            className={`${arrow ? arrowDownClass : arrowUpClass} ml-1`}
            name="arrow-without-tail"
            size=15
          />
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
  let make = (~input, ~options, ~displayName, ~entityMapper=UserInfoUtils.entityMapper) => {
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
        baseComponent={<OMPViewBaseComp displayName arrow />}
        baseComponentCustomStyle="bg-white rounded"
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

    let displayName = selectedEntity->getNameForId

    <OMPViewsComp input options displayName />
  }
}

module MerchantDropdownItem = {
  @react.component
  let make = (~merchantName, ~index: int, ~currentId) => {
    open LogicUtils
    open APIUtils
    let (currentlyEditingId, setUnderEdit) = React.useState(_ => None)
    let handleIdUnderEdit = (selectedEditId: option<int>) => {
      setUnderEdit(_ => selectedEditId)
    }
    let internalSwitch = OMPSwitchHooks.useInternalSwitch()
    let url = RescriptReactRouter.useUrl()
    let getURL = useGetURL()
    let updateDetails = useUpdateMethod()
    let fetchDetails = useGetMethod()
    let showToast = ToastState.useShowToast()
    let {userInfo: {merchantId}} = React.useContext(UserInfoProvider.defaultContext)
    let (showSwitchingMerch, setShowSwitchingMerch) = React.useState(_ => false)
    let isUnderEdit =
      currentlyEditingId->Option.isSome && currentlyEditingId->Option.getOr(0) == index
    let (_, setMerchantList) = Recoil.useRecoilState(HyperswitchAtom.merchantListAtom)
    let getMerchantList = async () => {
      try {
        let url = getURL(~entityName=USERS, ~userType=#LIST_MERCHANT, ~methodType=Get)
        let response = await fetchDetails(url)
        setMerchantList(_ => response->getArrayDataFromJson(OMPSwitchUtils.merchantItemToObjMapper))
      } catch {
      | _ => {
          setMerchantList(_ => OMPSwitchUtils.ompDefaultValue(merchantId, ""))
          showToast(~message="Failed to fetch merchant list", ~toastType=ToastError)
        }
      }
    }
    let validateInput = (merchantName: string) => {
      let errors = Dict.make()
      let regexForMerchantName = "^([a-z]|[A-Z]|[0-9]|_|\\s)+$"

      let errorMessage = if merchantName->isEmptyString {
        "Merchant name cannot be empty"
      } else if merchantName->String.length > 64 {
        "Merchant name cannot exceed 64 characters"
      } else if !RegExp.test(RegExp.fromString(regexForMerchantName), merchantName) {
        "Merchant name should not contain special characters"
      } else {
        ""
      }
      if errorMessage->isNonEmptyString {
        Dict.set(errors, "merchant_name", errorMessage->JSON.Encode.string)
      }
      errors
    }

    let switchMerch = async value => {
      try {
        setShowSwitchingMerch(_ => true)
        let _ = await internalSwitch(~expectedMerchantId=Some(value))
        RescriptReactRouter.replace(GlobalVars.extractModulePath(url))
        setShowSwitchingMerch(_ => false)
      } catch {
      | _ => {
          showToast(~message="Failed to switch merchant", ~toastType=ToastError)
          setShowSwitchingMerch(_ => false)
        }
      }
    }
    let handleMerchantSwitch = id => {
      switchMerch(id)->ignore
    }

    let onSubmit = async (newMerchantName: string) => {
      try {
        let body =
          [
            ("merchant_id", merchantId->JSON.Encode.string),
            ("merchant_name", newMerchantName->JSON.Encode.string),
          ]->getJsonFromArrayOfJson
        let accountUrl = getURL(
          ~entityName=MERCHANT_ACCOUNT,
          ~methodType=Post,
          ~id=Some(merchantId),
        )
        let _ = await updateDetails(accountUrl, body, Post)
        let _ = await getMerchantList()
        showToast(~message="Updated Merchant name!", ~toastType=ToastSuccess)
      } catch {
      | _ => showToast(~message="Failed to update Merchant name!", ~toastType=ToastError)
      }
    }

    let isActive = currentId == merchantId
    let leftIconCss = {isActive && !isUnderEdit ? "" : isUnderEdit ? "hidden" : "invisible"}
    let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
    <>
      <div
        className={`rounded-lg mb-1 ${isUnderEdit
            ? `hover:bg-transparent`
            : `hover:bg-jp-gray-100`}`}>
        <InlineEditInput
          index
          labelText=merchantName
          customStyle="w-full cursor-pointer !bg-transparent mb-0"
          handleEdit=handleIdUnderEdit
          isUnderEdit
          showEditIcon={isActive && userHasAccess(~groupAccess=MerchantDetailsManage) === Access}
          onSubmit
          labelTextCustomStyle={` truncate max-w-28 ${isActive ? " text-nd_gray-700" : ""}`}
          validateInput
          customInputStyle="!py-0 text-nd_gray-600"
          customIconComponent={<HelperComponents.CopyTextCustomComp
            displayValue=" " copyValue=Some(merchantId) customIconCss="text-nd_gray-600"
          />}
          customIconStyle={isActive ? "text-nd_gray-600" : ""}
          handleClick={_ => handleMerchantSwitch(currentId)}
          customWidth="min-w-48"
          leftIcon={<Icon name="nd-check" className={`${leftIconCss}`} />}
        />
      </div>
      <LoaderModal
        showModal={showSwitchingMerch}
        setShowModal={setShowSwitchingMerch}
        text="Switching merchant..."
      />
    </>
  }
}

module ProfileDropdownItem = {
  @react.component
  let make = (~profileName, ~index: int, ~currentId) => {
    open LogicUtils
    open APIUtils
    let (currentlyEditingId, setUnderEdit) = React.useState(_ => None)
    let handleIdUnderEdit = (selectedEditId: option<int>) => {
      setUnderEdit(_ => selectedEditId)
    }
    let internalSwitch = OMPSwitchHooks.useInternalSwitch()
    let url = RescriptReactRouter.useUrl()
    let getURL = useGetURL()
    let updateDetails = useUpdateMethod()
    let fetchDetails = useGetMethod()
    let showToast = ToastState.useShowToast()
    let {userInfo: {profileId}} = React.useContext(UserInfoProvider.defaultContext)
    let (showSwitchingProfile, setShowSwitchingProfile) = React.useState(_ => false)
    let isUnderEdit =
      currentlyEditingId->Option.isSome && currentlyEditingId->Option.getOr(0) == index
    let (_, setProfileList) = Recoil.useRecoilState(HyperswitchAtom.profileListAtom)
    let getProfileList = async () => {
      try {
        let url = getURL(~entityName=USERS, ~userType=#LIST_PROFILE, ~methodType=Get)
        let response = await fetchDetails(url)
        setProfileList(_ => response->getArrayDataFromJson(OMPSwitchUtils.profileItemToObjMapper))
      } catch {
      | _ => {
          setProfileList(_ => OMPSwitchUtils.ompDefaultValue(profileId, ""))
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

    let profileSwitch = async value => {
      try {
        setShowSwitchingProfile(_ => true)
        let _ = await internalSwitch(~expectedProfileId=Some(value))
        RescriptReactRouter.replace(GlobalVars.extractModulePath(url))
        setShowSwitchingProfile(_ => false)
      } catch {
      | _ => {
          showToast(~message="Failed to switch profile", ~toastType=ToastError)
          setShowSwitchingProfile(_ => false)
        }
      }
    }
    let handleProfileSwitch = id => {
      profileSwitch(id)->ignore
    }

    let onSubmit = async (newProfileName: string) => {
      try {
        let body = [("profile_name", newProfileName->JSON.Encode.string)]->getJsonFromArrayOfJson
        let accountUrl = getURL(~entityName=BUSINESS_PROFILE, ~methodType=Post, ~id=Some(profileId))
        let _ = await updateDetails(accountUrl, body, Post)
        let _ = await getProfileList()
        showToast(~message="Updated Profile name!", ~toastType=ToastSuccess)
      } catch {
      | _ => showToast(~message="Failed to update Profile name!", ~toastType=ToastError)
      }
    }

    let isActive = currentId == profileId
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
          showEditIcon={isActive && userHasAccess(~groupAccess=MerchantDetailsManage) === Access}
          onSubmit
          labelTextCustomStyle={` truncate max-w-28 ${isActive ? " text-nd_gray-700" : ""}`}
          validateInput
          customInputStyle="!py-0 text-nd_gray-600"
          customIconComponent={<HelperComponents.CopyTextCustomComp
            displayValue=" " copyValue=Some(profileId) customIconCss="text-nd_gray-600"
          />}
          customIconStyle={isActive ? "text-nd_gray-600" : ""}
          handleClick={_ => handleProfileSwitch(currentId)}
          customWidth="min-w-48"
          leftIcon={<Icon name="nd-check" className={`${leftIconCss}`} />}
        />
      </div>
      <LoaderModal
        showModal={showSwitchingProfile}
        setShowModal={setShowSwitchingProfile}
        text="Switching profile..."
      />
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
              displayValue=" " copyValue=Some({item.id}) customIconCss
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
            <HelperComponents.CopyTextCustomComp displayValue=" " copyValue=Some({item.id}) />
          </div>}
          toolTipPosition=ToolTip.TopRight
        />,
      ),
    }
    option
  })
  options
}
module EditOrgName = {
  @react.component
  let make = (~showModal, ~setShowModal, ~orgList, ~orgId, ~getOrgList) => {
    open LogicUtils
    open APIUtils
    let getURL = useGetURL()
    let updateDetails = useUpdateMethod()
    let showToast = ToastState.useShowToast()
    let initialValues =
      [
        ("organization_name", OMPSwitchUtils.currentOMPName(orgList, orgId)->JSON.Encode.string),
      ]->Dict.fromArray

    let validateForm = (values: JSON.t) => {
      let errors = Dict.make()
      let organizationName =
        values->getDictFromJsonObject->getString("organization_name", "")->String.trim
      let regexForOrganizationName = "^([a-z]|[A-Z]|[0-9]|_|\\s)+$"

      let errorMessage = if organizationName->isEmptyString {
        "Organization name cannot be empty"
      } else if organizationName->String.length > 64 {
        "Organization name cannot exceed 64 characters"
      } else if !RegExp.test(RegExp.fromString(regexForOrganizationName), organizationName) {
        "Organization name should not contain special characters"
      } else {
        ""
      }

      if errorMessage->isNonEmptyString {
        Dict.set(errors, "organization_name", errorMessage->JSON.Encode.string)
      }

      errors->JSON.Encode.object
    }

    let orgName = FormRenderer.makeFieldInfo(
      ~label="Org Name",
      ~name="organization_name",
      ~placeholder=`Eg: Hyperswitch`,
      ~customInput=InputFields.textInput(),
      ~isRequired=true,
    )

    let onSubmit = async (values, _) => {
      try {
        let url = getURL(~entityName=UPDATE_ORGANIZATION, ~methodType=Put, ~id=Some(orgId))
        let _ = await updateDetails(url, values, Put)
        let _ = await getOrgList()
        showToast(~message="Updated organization name!", ~toastType=ToastSuccess)
      } catch {
      | _ => showToast(~message="Failed to update organization name!", ~toastType=ToastError)
      }
      setShowModal(_ => false)
      Nullable.null
    }

    <>
      <Modal modalHeading="Edit Org name" showModal setShowModal modalClass="w-1/4 m-auto">
        <Form initialValues={initialValues->JSON.Encode.object} onSubmit validate={validateForm}>
          <div className="flex flex-col gap-12 h-full w-full">
            <FormRenderer.DesktopRow>
              <FormRenderer.FieldRenderer
                fieldWrapperClass="w-full"
                field={orgName}
                labelClass="!text-black font-medium !-ml-[0.5px]"
              />
            </FormRenderer.DesktopRow>
            <div className="flex justify-end w-full pr-5 pb-3">
              <FormRenderer.SubmitButton
                text="Submit changes" buttonSize={Small} loadingText="Processing..."
              />
            </div>
          </div>
        </Form>
      </Modal>
    </>
  }
}
