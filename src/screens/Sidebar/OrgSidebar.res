module OrgTile = {
  open Typography
  @react.component
  let make = (
    ~orgID: string,
    ~isActive,
    ~orgSwitch,
    ~orgName: string,
    ~index: int,
    ~currentlyEditingId: option<int>,
    ~handleIdUnderEdit,
    ~isPlatformOrganization,
  ) => {
    open LogicUtils
    open APIUtils
    let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
    let getURL = useGetURL()
    let updateDetails = useUpdateMethod()
    let fetchDetails = useGetMethod()
    let showToast = ToastState.useShowToast()
    let setOrgList = Recoil.useSetRecoilState(HyperswitchAtom.orgListAtom)
    let {userInfo: {orgId}} = React.useContext(UserInfoProvider.defaultContext)
    let {
      globalUIConfig: {
        sidebarColor: {backgroundColor, primaryTextColor, secondaryTextColor, borderColor},
      },
    } = React.useContext(ThemeProvider.themeContext)

    let sortByOrgName = (org1: OMPSwitchTypes.ompListTypes, org2: OMPSwitchTypes.ompListTypes) => {
      compareLogic(org2.name->String.toLowerCase, org1.name->String.toLowerCase)
    }

    let getOrgList = async () => {
      try {
        let url = getURL(~entityName=V1(USERS), ~userType=#LIST_ORG, ~methodType=Get)
        let response = await fetchDetails(url)
        let orgData = response->getArrayDataFromJson(OMPSwitchUtils.orgItemToObjMapper)
        orgData->Array.sort(sortByOrgName)
        setOrgList(_ => orgData)
      } catch {
      | _ => {
          setOrgList(_ => [OMPSwitchUtils.ompDefaultValue(orgId, "")])
          showToast(~message="Failed to fetch organisation list", ~toastType=ToastError)
        }
      }
    }

    let onSubmit = async (newOrgName: string) => {
      try {
        let values = {"organization_name": newOrgName}->Identity.genericTypeToJson
        let url = getURL(~entityName=V1(ORGANIZATION_RETRIEVE), ~methodType=Put, ~id=Some(orgID))
        let _ = await updateDetails(url, values, Put)
        let _ = await getOrgList()

        showToast(~message="Updated organization name!", ~toastType=ToastSuccess)
      } catch {
      | _ => showToast(~message="Failed to update organization name!", ~toastType=ToastError)
      }
    }
    let validateInput = (organizationName: string) => {
      let errors = Dict.make()
      let regexForOrganizationName = "^([a-z]|[A-Z]|[0-9]|_|\\s)+$"
      let errorMessage = if organizationName->LogicUtils.isEmptyString {
        "Organization name cannot be empty"
      } else if organizationName->String.length > 64 {
        "Organization name cannot exceed 64 characters"
      } else if !RegExp.test(RegExp.fromString(regexForOrganizationName), organizationName) {
        "Organization name should not contain special characters"
      } else {
        ""
      }

      if errorMessage->LogicUtils.isNonEmptyString {
        errors->Dict.set("organizationName", errorMessage)
      }
      errors
    }
    let displayText = {
      let firstLetter = orgName->String.charAt(0)->String.toUpperCase
      if orgName == orgID {
        orgID
        ->String.slice(~start=orgID->String.length - 2, ~end=orgID->String.length)
        ->String.toUpperCase
      } else {
        firstLetter
      }
    }
    let isUnderEdit =
      currentlyEditingId->Option.isSome && currentlyEditingId->Option.getOr(0) == index

    let isEditingAnotherIndex =
      currentlyEditingId->Option.isSome && currentlyEditingId->Option.getOr(0) != index

    // Hover label and visibility class
    let hoverLabel1 = !isUnderEdit ? `group/parent` : ``
    let hoverInput2 = !isUnderEdit ? `invisible group-hover/parent:visible` : ``
    // Common CSS
    let baseCSS = `absolute max-w-xs left-full top-0 rounded-md z-50 shadow-md ${backgroundColor.sidebarSecondary}`
    let currentEditCSS = isUnderEdit
      ? `p-2 ${baseCSS} border-grey-400 border-opacity-40`
      : `${baseCSS} ${hoverInput2} shadow-lg `
    let nonEditCSS = !isEditingAnotherIndex ? `p-2` : ``
    let ringClass = switch isActive {
    | true => "border-primary ring-primary/20 ring-offset-0 ring-2"
    | false => "ring-grey-outline"
    }

    let handleClick = () => {
      if !isActive {
        orgSwitch(orgID)->ignore
      }
    }

    <div
      onClick={_ => handleClick()}
      className={`w-10 h-10 rounded-lg flex items-center justify-center relative cursor-pointer ${hoverLabel1}`}>
      <div
        className={`w-8 h-8 border cursor-pointer flex items-center justify-center rounded-md shadow-md relative ${ringClass} ${isActive
            ? `bg-white/20 ${primaryTextColor} border-sidebar-textColorPrimary`
            : `${secondaryTextColor} hover:bg-white/10 border-sidebar-textColor/30`}`}>
        <RenderIf condition={isPlatformOrganization}>
          <div
            className={`absolute top-5-px right-5-px w-0 h-0 border-t-[10px] border-l-[10px] ${isActive
                ? "border-t-blue-600"
                : "border-t-sidebar-textColor/30"}  border-l-transparent translate-x-1/2 -translate-y-1/2 rounded-tr-[5px]`}
          />
        </RenderIf>
        <span className={body.xs.medium}> {displayText->React.string} </span>
        <div className={` ${currentEditCSS} ${nonEditCSS} border ${borderColor} border-opacity-40`}>
          <InlineEditInput
            index
            labelText={orgName}
            subText={isPlatformOrganization ? "Platform Organization" : "Organization"}
            customStyle={`p-3 !h-12 ${backgroundColor.sidebarSecondary} ${hoverInput2}`}
            showEditIconOnHover=false
            customInputStyle={`${backgroundColor.sidebarSecondary} ${secondaryTextColor} text-sm h-4 ${hoverInput2}`}
            customIconComponent={<ToolTip
              description={orgID}
              customStyle="!whitespace-nowrap"
              toolTipFor={<div className="cursor-pointer">
                <HelperComponents.CopyTextCustomComp
                  customIconCss={`${secondaryTextColor}`}
                  displayValue=Some("")
                  copyValue=Some(orgID)
                />
              </div>}
              toolTipPosition=ToolTip.Right
            />}
            showEditIcon={isActive && userHasAccess(~groupAccess=OrganizationManage) === Access}
            handleEdit=handleIdUnderEdit
            isUnderEdit
            displayHoverOnEdit={currentlyEditingId->Option.isNone}
            validateInput
            labelTextCustomStyle={`${secondaryTextColor} truncate max-w-40`}
            customWidth="min-w-64"
            customIconStyle={`${secondaryTextColor}`}
            onSubmit
          />
        </div>
      </div>
    </div>
  }
}

module OrgTileGroup = {
  @react.component
  let make = (
    ~heading: string="",
    ~customHeading=?,
    ~hasPlatformOrg,
    ~orgList: array<OMPSwitchTypes.ompListTypes>,
    ~orgSwitch,
    ~currentlyEditingId,
    ~handleIdUnderEdit,
  ) => {
    let {userInfo: {orgId}} = React.useContext(UserInfoProvider.defaultContext)

    <div className="flex flex-col justify-center gap-3">
      <RenderIf condition={hasPlatformOrg}>
        {switch customHeading {
        | Some(customHeading) => customHeading
        | None =>
          <div className="text-nd_gray-400 uppercase leading-12 text-fs-8 font-bold">
            <div className="flex justify-center"> {heading->React.string} </div>
          </div>
        }}
      </RenderIf>
      {orgList
      ->Array.mapWithIndex((org, i) => {
        <OrgTile
          key={Int.toString(i)}
          orgID={org.id}
          isActive={org.id === orgId}
          isPlatformOrganization={org.\"type"->Option.getOr(#standard) === #platform}
          orgSwitch
          orgName={org.name}
          index={i}
          handleIdUnderEdit
          currentlyEditingId
        />
      })
      ->React.array}
    </div>
  }
}

module NewOrgCreationModal = {
  @react.component
  let make = (~setShowModal, ~showModal, ~getOrgList) => {
    open APIUtils
    let getURL = useGetURL()
    let updateDetails = useUpdateMethod()
    let mixpanelEvent = MixpanelHook.useSendEvent()
    let showToast = ToastState.useShowToast()
    let createNewOrg = async values => {
      try {
        let url = getURL(~entityName=V1(USERS), ~userType=#CREATE_ORG, ~methodType=Post)
        mixpanelEvent(~eventName="create_new_org", ~metadata=values)
        let _ = await updateDetails(url, values, Post)
        getOrgList()->ignore
        showToast(~toastType=ToastSuccess, ~message="Org Created Successfully!", ~autoClose=true)
      } catch {
      | _ => showToast(~toastType=ToastError, ~message="Org Creation Failed", ~autoClose=true)
      }
      setShowModal(_ => false)
      Nullable.null
    }

    let onSubmit = (values, _) => {
      createNewOrg(values)
    }

    let orgName = FormRenderer.makeFieldInfo(
      ~label="Org Name",
      ~name="organization_name",
      ~placeholder="Eg: My New Org",
      ~customInput=InputFields.textInput(),
      ~isRequired=true,
    )

    let merchantName = FormRenderer.makeFieldInfo(
      ~label="Merchant Name",
      ~name="merchant_name",
      ~placeholder="Eg: My New Merchant",
      ~customInput=InputFields.textInput(),
      ~isRequired=true,
    )

    let validateForm = (
      ~values: JSON.t,
      ~fieldstoValidate: array<OMPSwitchTypes.addOrgFormFields>,
    ) => {
      open LogicUtils
      let errors = Dict.make()
      let regexForOrgName = "^([a-z]|[A-Z]|[0-9]|_|\\s)+$"

      fieldstoValidate->Array.forEach(field => {
        let name = switch field {
        | OrgName => "Org"
        | MerchantName => "Merchant"
        }

        let value = switch field {
        | OrgName => "organization_name"
        | MerchantName => "merchant_name"
        }

        let fieldValue = values->getDictFromJsonObject->getString(value, "")->String.trim

        let errorMsg = if fieldValue->isEmptyString {
          `${name} name cannot be empty`
        } else if fieldValue->String.length > 64 {
          `${name} name too long`
        } else if !RegExp.test(RegExp.fromString(regexForOrgName), fieldValue) {
          `${name} name should not contain special characters`
        } else {
          ""
        }
        if errorMsg->isNonEmptyString {
          Dict.set(errors, value, errorMsg->JSON.Encode.string)
        }
      })
      errors->JSON.Encode.object
    }

    let modalBody = {
      <div className="p-2 m-2">
        <div className="py-5 px-3 flex justify-between align-top ">
          <CardUtils.CardHeader
            heading="Add a new org" subHeading="" customSubHeadingStyle="w-full !max-w-none pr-10"
          />
          <div className="h-fit" onClick={_ => setShowModal(_ => false)}>
            <Icon
              name="close" className="border-2 p-2 rounded-2xl bg-gray-100 cursor-pointer" size=30
            />
          </div>
        </div>
        <Form
          key="new-org-creation"
          onSubmit
          validate={values => validateForm(~values, ~fieldstoValidate=[OrgName, MerchantName])}>
          <div className="flex flex-col gap-12 h-full w-full">
            <FormRenderer.DesktopRow>
              <div className="flex flex-col gap-5">
                <FormRenderer.FieldRenderer
                  fieldWrapperClass="w-full"
                  field={orgName}
                  showErrorOnChange=true
                  errorClass={ProdVerifyModalUtils.errorClass}
                  labelClass="!text-black font-medium !-ml-[0.5px]"
                />
                <FormRenderer.FieldRenderer
                  fieldWrapperClass="w-full"
                  field={merchantName}
                  showErrorOnChange=true
                  errorClass={ProdVerifyModalUtils.errorClass}
                  labelClass="!text-black font-medium !-ml-[0.5px]"
                />
              </div>
            </FormRenderer.DesktopRow>
            <div className="flex justify-end w-full pr-5 pb-3">
              <FormRenderer.SubmitButton text="Add Org" buttonSize={Small} />
            </div>
          </div>
        </Form>
      </div>
    }

    <Modal
      showModal
      closeOnOutsideClick=true
      setShowModal
      childClass="p-0"
      borderBottom=true
      modalClass="w-full max-w-xl mx-auto my-auto dark:!bg-jp-gray-lightgray_background">
      modalBody
    </Modal>
  }
}

@react.component
let make = () => {
  open APIUtils
  open LogicUtils
  open OMPSwitchUtils
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let (orgList, setOrgList) = Recoil.useRecoilState(HyperswitchAtom.orgListAtom)
  let (showSwitchingOrg, setShowSwitchingOrg) = React.useState(_ => false)
  let fetchOrganizationDetails = OrganizationDetailsHook.useFetchOrganizationDetails()
  let internalSwitch = OMPSwitchHooks.useInternalSwitch()
  let {userInfo: {orgId, roleId, version}} = React.useContext(UserInfoProvider.defaultContext)
  let {tenantUser} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let (showAddOrgModal, setShowAddOrgModal) = React.useState(_ => false)
  let isTenantAdmin = roleId->HyperSwitchUtils.checkIsTenantAdmin
  let isInternalUser = roleId->HyperSwitchUtils.checkIsInternalUser
  let showToast = ToastState.useShowToast()
  let (showAllOrgs, setShowAllOrgs) = React.useState(_ => false)
  let (maxVisibleOrgs, setMaxVisibleOrgs) = React.useState(_ => 15)
  let calculateMaxOrgs = () => {
    let screenHeight = Window.innerHeight->Int.toFloat
    let orgTileHeight = 50.
    let reservedSpace = 170.
    let availableHeight = screenHeight -. reservedSpace
    let calculated = (availableHeight /. orgTileHeight)->Float.toInt
    setMaxVisibleOrgs(_ => calculated)
  }
  React.useEffect(() => {
    calculateMaxOrgs()
    let handler = _ => calculateMaxOrgs()
    Window.addEventListener("resize", handler) //for window resize cases
    Some(() => Window.removeEventListener("resize", handler))
  }, [])

  let visibleOrgList = if showAllOrgs {
    orgList->Array.slice(~start=maxVisibleOrgs, ~end=orgList->Array.length)
  } else {
    orgList->Array.slice(~start=0, ~end=maxVisibleOrgs)
  }

  let getOrgsListBasedOnType = ompType =>
    visibleOrgList->Array.filter(item =>
      switch item.\"type" {
      | Some(userType) => userType === ompType
      | None => false
      }
    )

  let standardOrgList = getOrgsListBasedOnType(#standard)
  let platformOrgList = getOrgsListBasedOnType(#platform)

  let sortByOrgName = (org1: OMPSwitchTypes.ompListTypes, org2: OMPSwitchTypes.ompListTypes) => {
    compareLogic(org2.name->String.toLowerCase, org1.name->String.toLowerCase)
  }

  let {
    globalUIConfig: {sidebarColor: {backgroundColor, hoverColor, secondaryTextColor, borderColor}},
  } = React.useContext(ThemeProvider.themeContext)

  let fetchOrgDetails = async () => {
    try {
      let _ = await fetchOrganizationDetails()
    } catch {
    | _ => showToast(~message="Failed to fetch organization details", ~toastType=ToastError)
    }
  }

  let getOrgList = async () => {
    try {
      let url = getURL(~entityName=V1(USERS), ~userType=#LIST_ORG, ~methodType=Get)
      let response = await fetchDetails(url)
      let orgData = response->getArrayDataFromJson(orgItemToObjMapper)
      if version === V1 {
        fetchOrgDetails()->ignore
      }
      orgData->Array.sort(sortByOrgName)
      setOrgList(_ => orgData)
    } catch {
    | _ => {
        setOrgList(_ => [ompDefaultValue(orgId, "")])
        showToast(~message="Failed to fetch organisation list", ~toastType=ToastError)
      }
    }
  }

  React.useEffect(() => {
    if !isInternalUser {
      getOrgList()->ignore
    } else {
      setOrgList(_ => [ompDefaultValue(orgId, "")])
    }
    None
  }, [])

  let orgSwitch = async value => {
    try {
      setShowSwitchingOrg(_ => true)
      let _ = await internalSwitch(~expectedOrgId=Some(value), ~changePath=true)
      setShowSwitchingOrg(_ => false)
    } catch {
    | _ => {
        showToast(~message="Failed to switch organisation", ~toastType=ToastError)
        setShowSwitchingOrg(_ => false)
      }
    }
  }
  let (currentlyEditingId, setUnderEdit) = React.useState(_ => None)
  let handleIdUnderEdit = (selectedEditId: option<int>) => {
    setUnderEdit(_ => selectedEditId)
  }

  <div className={`${backgroundColor.sidebarNormal}  p-2 pt-3 border-r w-14 ${borderColor}`}>
    <div className="flex flex-col gap-5 pt-2 px-2 items-center justify-center ">
      <RenderIf condition={showAllOrgs}>
        <Icon
          name="nd-angle-up"
          size=13
          className="mt-3 ml-1 text-primary cursor-pointer"
          onClick={_ => setShowAllOrgs(_ => false)}
        />
      </RenderIf>
      <RenderIf condition={platformOrgList->Array.length > 0}>
        <OrgTileGroup
          customHeading={<div
            className="text-nd_gray-400 uppercase leading-12 text-fs-8 font-bold flex flex-col items-center">
            <div> {"Platform"->React.string} </div>
            <div> {"Org"->React.string} </div>
          </div>}
          hasPlatformOrg={platformOrgList->Array.length > 0}
          orgList=platformOrgList
          orgSwitch
          currentlyEditingId
          handleIdUnderEdit
        />
        <hr className="w-full" />
      </RenderIf>
      <OrgTileGroup
        heading="Org"
        hasPlatformOrg={platformOrgList->Array.length > 0}
        orgList=standardOrgList
        orgSwitch
        currentlyEditingId
        handleIdUnderEdit
      />
      <RenderIf condition={orgList->Array.length > maxVisibleOrgs && !showAllOrgs}>
        <Icon
          name="nd-angle-down"
          size=14
          className="ml-1 text-primary -mt-3 cursor-pointer"
          onClick={_ => setShowAllOrgs(_ => true)}
        />
      </RenderIf>
      <RenderIf condition={tenantUser && isTenantAdmin}>
        <div
          onClick={_ => setShowAddOrgModal(_ => true)}
          className={`w-8 h-8 mt-2 flex items-center justify-center cursor-pointer 
      rounded-md border shadow-sm ${hoverColor}  border-${backgroundColor.sidebarSecondary}`}>
          <Icon name="plus" size=20 className={secondaryTextColor} />
        </div>
      </RenderIf>
    </div>
    <RenderIf condition={showAddOrgModal}>
      <NewOrgCreationModal
        setShowModal={setShowAddOrgModal} showModal={showAddOrgModal} getOrgList
      />
    </RenderIf>
    <LoaderModal
      showModal={showSwitchingOrg}
      setShowModal={setShowSwitchingOrg}
      text="Switching organisation..."
    />
  </div>
}
