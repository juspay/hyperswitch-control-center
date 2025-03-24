module SwitchOrg = {
  @react.component
  let make = (~setShowModal) => {
    let showToast = ToastState.useShowToast()
    let showPopUp = PopUpState.useShowPopUp()
    let internalSwitch = OMPSwitchHooks.useInternalSwitch()
    let (value, setValue) = React.useState(() => "")
    let {globalUIConfig: {sidebarColor: {backgroundColor}}} = React.useContext(
      ThemeProvider.themeContext,
    )

    let input = React.useMemo((): ReactFinalForm.fieldRenderPropsInput => {
      {
        name: "-",
        onBlur: _ => (),
        onChange: ev => {
          let value = {ev->ReactEvent.Form.target}["value"]
          if value->String.includes("<script>") || value->String.includes("</script>") {
            showPopUp({
              popUpType: (Warning, WithIcon),
              heading: `Script Tags are not allowed`,
              description: React.string(`Input cannot contain <script>, </script> tags`),
              handleConfirm: {text: "OK"},
            })
          }
          let val = value->String.replace("<script>", "")->String.replace("</script>", "")
          setValue(_ => val)
        },
        onFocus: _ => (),
        value: JSON.Encode.string(value),
        checked: false,
      }
    }, [value])

    let switchOrg = async () => {
      try {
        setShowModal(_ => true)
        let _ = await internalSwitch(~expectedOrgId=Some(value))
        setShowModal(_ => false)
      } catch {
      | _ => {
          showToast(~message="Failed to switch the org! Try again.", ~toastType=ToastError)
          setShowModal(_ => false)
        }
      }
    }

    let handleKeyUp = event => {
      if event->ReactEvent.Keyboard.keyCode === 13 {
        switchOrg()->ignore
      }
    }

    <TextInput
      input
      customWidth="w-80"
      placeholder="Switch org"
      onKeyUp=handleKeyUp
      customStyle={`!text-grey-300 !placeholder-grey-200 placeholder: text-sm font-inter-style ${backgroundColor.sidebarSecondary}`}
      customDashboardClass="h-11 text-base font-normal shadow-jp-2-xs"
    />
  }
}
module NewOrgCreationModal = {
  @react.component
  let make = (~setShowModal, ~showModal, ~getOrgList) => {
    open APIUtils
    let getURL = useGetURL()
    let mixpanelEvent = MixpanelHook.useSendEvent()
    let updateDetails = useUpdateMethod()
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
  open OMPSwitchHelper
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let showToast = ToastState.useShowToast()
  let internalSwitch = OMPSwitchHooks.useInternalSwitch()
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let {userInfo: {orgId, roleId}} = React.useContext(UserInfoProvider.defaultContext)
  let (orgList, setOrgList) = Recoil.useRecoilState(HyperswitchAtom.orgListAtom)
  let {tenantUser} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let (showSwitchingOrg, setShowSwitchingOrg) = React.useState(_ => false)
  let (showEditOrgModal, setShowEditOrgModal) = React.useState(_ => false)
  let (showAddOrgModal, setShowAddOrgModal) = React.useState(_ => false)
  let (arrow, setArrow) = React.useState(_ => false)
  let isTenantAdmin = roleId->HyperSwitchUtils.checkIsTenantAdmin
  let {globalUIConfig: {sidebarColor: {backgroundColor, secondaryTextColor}}} = React.useContext(
    ThemeProvider.themeContext,
  )
  let getOrgList = async () => {
    try {
      let url = getURL(~entityName=V1(USERS), ~userType=#LIST_ORG, ~methodType=Get)
      let response = await fetchDetails(url)
      setOrgList(_ => response->getArrayDataFromJson(orgItemToObjMapper))
    } catch {
    | _ => {
        setOrgList(_ => [ompDefaultValue(orgId, "")])
        showToast(~message="Failed to fetch organisation list", ~toastType=ToastError)
      }
    }
  }

  React.useEffect(() => {
    getOrgList()->ignore
    None
  }, [])

  let orgSwitch = async value => {
    try {
      setShowSwitchingOrg(_ => true)
      let _ = await internalSwitch(~expectedOrgId=Some(value))
      setShowSwitchingOrg(_ => false)
    } catch {
    | _ => {
        showToast(~message="Failed to switch organisation", ~toastType=ToastError)
        setShowSwitchingOrg(_ => false)
      }
    }
  }

  let onEditClick = e => {
    setShowEditOrgModal(_ => true)
    e->ReactEvent.Mouse.stopPropagation
  }

  let input: ReactFinalForm.fieldRenderPropsInput = {
    name: "name",
    onBlur: _ => (),
    onChange: ev => {
      let value = ev->Identity.formReactEventToString
      orgSwitch(value)->ignore
    },
    onFocus: _ => (),
    value: orgId->JSON.Encode.string,
    checked: true,
  }

  let toggleChevronState = () => {
    setArrow(prev => !prev)
  }

  let customHRTagStyle = "border-t border-blue-830"
  let customPadding = "py-1 w-full"
  let customStyle = `w-56 ${secondaryTextColor} ${backgroundColor.sidebarSecondary} dark:bg-black hover:text-gray-100 !w-full`

  let customScrollStyle = `${backgroundColor.sidebarSecondary} max-h-72 overflow-scroll px-1 pt-1`
  let dropdownContainerStyle = "min-w-[15rem] rounded"

  let showOrgDropdown = !(tenantUser && isTenantAdmin && orgList->Array.length >= 20)
  let orgDropdown =
    <SelectBox.BaseDropdown
      allowMultiSelect=false
      buttonText=""
      input
      deselectDisable=true
      customButtonStyle="!rounded-md"
      options={orgList->generateDropdownOptions(~customIconCss="text-grey-200")}
      marginTop="mt-14"
      hideMultiSelectButtons=true
      addButton=false
      customStyle={`${backgroundColor.sidebarSecondary} hover:!bg-black/10 rounded !w-full`}
      customSelectStyle={`${backgroundColor.sidebarSecondary} hover:!bg-black/10 rounded`}
      searchable=false
      baseComponent={<ListBaseComp
        user=#Organization
        heading="Org"
        subHeading={currentOMPName(orgList, orgId)}
        arrow
        showEditIcon={userHasAccess(~groupAccess=OrganizationManage) === Access}
        onEditClick
        isDarkBg=true
      />}
      baseComponentCustomStyle={`border-blue-820 rounded ${backgroundColor.sidebarSecondary} rounded text-white`}
      bottomComponent={<RenderIf condition={tenantUser && isTenantAdmin}>
        <OMPSwitchHelper.AddNewOMPButton
          user=#Organization
          setShowModal={setShowAddOrgModal}
          customPadding
          customStyle
          customHRTagStyle
        />
      </RenderIf>}
      optionClass={`${secondaryTextColor} text-fs-14`}
      selectClass={`${secondaryTextColor} text-fs-14`}
      customDropdownOuterClass="!border-none !w-full"
      fullLength=true
      toggleChevronState
      customScrollStyle
      dropdownContainerStyle
      shouldDisplaySelectedOnTop=true
    />

  let orgBaseComp =
    <ListBaseComp
      user=#Organization
      heading="Org"
      subHeading=orgId
      arrow
      showEditIcon={userHasAccess(~groupAccess=OrganizationManage) === Access}
      onEditClick
      isDarkBg=true
      showDropdownArrow=false
    />

  let orgComp = showOrgDropdown ? orgDropdown : orgBaseComp

  <div className="w-full py-3.5 px-2 ">
    <div className="flex flex-col gap-4">
      {orgComp}
      <RenderIf condition={!showOrgDropdown}>
        <SwitchOrg setShowModal={setShowSwitchingOrg} />
      </RenderIf>
    </div>
    <EditOrgName
      showModal={showEditOrgModal} setShowModal={setShowEditOrgModal} orgList orgId getOrgList
    />
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
