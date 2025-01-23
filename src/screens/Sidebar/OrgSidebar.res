module OrgTile = {
  @react.component
  let make = (~orgID: string, ~isActive, ~orgSwitch, ~onEdit, ~orgName: string, ~index: int) => {
    let {
      globalUIConfig: {sidebarColor: {backgroundColor, secondaryTextColor, hoverColor}},
    } = React.useContext(ThemeProvider.themeContext)
    let (showDetails, setShowDetails) = React.useState(_ => false)
    let (orgList, _) = Recoil.useRecoilState(HyperswitchAtom.orgListAtom)
    let {
      globalUIConfig: {sidebarColor: {backgroundColor, primaryTextColor, secondaryTextColor}},
    } = React.useContext(ThemeProvider.themeContext)

    let displayText = {
      let firstLetter = orgName->String.charAt(0)->String.toUpperCase

      if orgName == orgID {
        let count =
          orgList
          ->Array.slice(~start=0, ~end=index + 1)
          ->Array.filter(org => org.name == org.id)
          ->Array.length
        `O${count->Int.toString}`
      } else {
        firstLetter
      }
    }

    <div
      className={`w-8 h-8 border relative  cursor-pointer flex items-center justify-center rounded-md shadow-md ${isActive
          ? `bg-white/20 ${primaryTextColor} border-sidebar-secondaryTextColor`
          : ` ${secondaryTextColor} hover:bg-white/10 border-sidebar-secondaryTextColor/30`}`}
      onClick={_ => setShowDetails(prev => !prev)}>
      <span className="text-xs font-medium"> {displayText->React.string} </span>
      <RenderIf condition={showDetails}>
        <div
          className={`absolute ${backgroundColor.sidebarSecondary} border border-transparent left-[3rem] top-0 rounded-lg shadow-lg z-50 p-2 `}>
          <InlineEditInput
            labelText={orgName}
            subText={"organization"}
            showSubText=true
            customStyle={` p-3 ${backgroundColor.sidebarSecondary} min-w-[250px]transition-all duration-200 ease-in-out `}
            onHoverEdit=false
            customInputStyle={`${backgroundColor.sidebarSecondary} h-4`}
            customIconComponent={<OMPSwitchHelper.OMPCopyTextCustomComp
              displayValue=" " copyValue=Some({orgID})
            />}
          />
        </div>
      </RenderIf>
    </div>
  }
}
module NewOrgCreationModal = {
  @react.component
  let make = (~setShowModal, ~showModal, ~getOrgList) => {
    open APIUtils
    let getURL = useGetURL()
    let updateDetails = useUpdateMethod()
    let showToast = ToastState.useShowToast()
    let createNewOrg = async values => {
      try {
        let url = getURL(~entityName=USERS, ~userType=#CREATE_ORG, ~methodType=Post)
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
  let url = RescriptReactRouter.useUrl()
  let (orgList, setOrgList) = Recoil.useRecoilState(HyperswitchAtom.orgListAtom)
  let (showSwitchingOrg, setShowSwitchingOrg) = React.useState(_ => false)
  let (showEditOrgModal, setShowEditOrgModal) = React.useState(_ => false)
  let internalSwitch = OMPSwitchHooks.useInternalSwitch()
  let {userInfo: {orgId, roleId}} = React.useContext(UserInfoProvider.defaultContext)
  let {tenantUser} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let (showAddOrgModal, setShowAddOrgModal) = React.useState(_ => false)
  let isTenantAdmin = roleId->HyperSwitchUtils.checkIsTenantAdmin
  let showToast = ToastState.useShowToast()

  let {
    globalUIConfig: {sidebarColor: {backgroundColor, hoverColor, secondaryTextColor}},
  } = React.useContext(ThemeProvider.themeContext)
  let getOrgList = async () => {
    try {
      let url = getURL(~entityName=USERS, ~userType=#LIST_ORG, ~methodType=Get)
      let response = await fetchDetails(url)
      setOrgList(_ => response->getArrayDataFromJson(orgItemToObjMapper))
    } catch {
    | _ => {
        setOrgList(_ => ompDefaultValue(orgId, ""))
        showToast(~message="Failed to fetch organisation list", ~toastType=ToastError)
      }
    }
  }
  React.useEffect(() => {
    getOrgList()->ignore
    None
  }, [])

  let onEditClick = e => {
    setShowEditOrgModal(_ => true)
    e->ReactEvent.Mouse.stopPropagation
  }

  let orgSwitch = async value => {
    try {
      setShowSwitchingOrg(_ => true)
      let _ = await internalSwitch(~expectedOrgId=Some(value))
      RescriptReactRouter.replace(GlobalVars.extractModulePath(url))
      showToast(~message="Switched organisation successfully", ~toastType=ToastSuccess)
      setShowSwitchingOrg(_ => false)
    } catch {
    | _ => {
        showToast(~message="Failed to switch organisation", ~toastType=ToastError)
        setShowSwitchingOrg(_ => false)
      }
    }
  }
  <div className={`${backgroundColor.sidebarNormal} p-2 border-r border-secondary`}>
    // the org tiles
    <div className="flex flex-col gap-2 m-1 mt-4 items-center justify-center shadow-sm ">
      {orgList
      ->Array.toSorted((org1, org2) => {
        if org1.id === orgId {
          -1.
        } else if org2.id === orgId {
          1.
        } else {
          0.
        }
      })
      ->Array.mapWithIndex((org, i) => {
        <OrgTile
          orgID={org.id}
          isActive={org.id === orgId}
          orgSwitch
          onEdit=onEditClick
          orgName={org.name}
          index={i}
        />
      })
      ->React.array}
      <RenderIf condition={tenantUser && isTenantAdmin}>
        <div
          onClick={_ => setShowAddOrgModal(_ => true)}
          className={`w-8 h-8 mt-2 flex items-center justify-center cursor-pointer 
      rounded-md shadow-sm ${hoverColor}  border-${backgroundColor.sidebarSecondary}`}>
          <Icon name="plus" size=20 className={secondaryTextColor} />
        </div>
      </RenderIf>
    </div>
    <RenderIf condition={showAddOrgModal}>
      <NewOrgCreationModal
        setShowModal={setShowAddOrgModal} showModal={showAddOrgModal} getOrgList
      />
    </RenderIf>
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
