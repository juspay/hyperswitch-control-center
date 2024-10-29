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

    let businessName = FormRenderer.makeFieldInfo(
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
                field={businessName}
                labelClass="!text-black font-medium !-ml-[0.5px]"
              />
            </FormRenderer.DesktopRow>
            <div className="flex justify-end w-full pr-5 pb-3">
              <FormRenderer.SubmitButton text="Submit changes" buttonSize={Small} />
            </div>
          </div>
        </Form>
      </Modal>
    </>
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
  let orgSwitch = OMPSwitchHooks.useOrgSwitch()
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let {userInfo: {orgId}} = React.useContext(UserInfoProvider.defaultContext)
  let (orgList, setOrgList) = Recoil.useRecoilState(HyperswitchAtom.orgListAtom)
  let (showSwitchingOrg, setShowSwitchingOrg) = React.useState(_ => false)
  let (showModal, setShowModal) = React.useState(_ => false)
  let (arrow, setArrow) = React.useState(_ => false)

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

  let orgSwitch = async value => {
    try {
      setShowSwitchingOrg(_ => true)
      let _ = await orgSwitch(~expectedOrgId=value, ~currentOrgId=orgId)
      setShowSwitchingOrg(_ => false)
    } catch {
    | _ => {
        showToast(~message="Failed to switch organisation", ~toastType=ToastError)
        setShowSwitchingOrg(_ => false)
      }
    }
  }

  let onEditClick = e => {
    setShowModal(_ => true)
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

  let customScrollStyle = "max-h-72 overflow-scroll px-1 pt-1"

  <div className="border border-blue-820 rounded w-full">
    <SelectBox.BaseDropdown
      allowMultiSelect=false
      buttonText=""
      input
      deselectDisable=true
      customButtonStyle="!rounded-md"
      options={orgList->generateDropdownOptions}
      marginTop="mt-14"
      hideMultiSelectButtons=true
      addButton=false
      customStyle="bg-blue-840 hover:bg-popover-background-hover rounded !w-full"
      customSelectStyle="md:bg-blue-840 hover:bg-popover-background-hover rounded"
      searchable=false
      baseComponent={<ListBaseComp
        heading="Org"
        subHeading={currentOMPName(orgList, orgId)}
        arrow
        showEditIcon={userHasAccess(~groupAccess=OrganizationManage) === Access}
        onEditClick
      />}
      baseComponentCustomStyle="border-blue-820 rounded bg-popover-background rounded text-white"
      optionClass="text-gray-200 text-fs-14"
      selectClass="text-gray-200 text-fs-14"
      customDropdownOuterClass="!border-none !w-full"
      fullLength=true
      toggleChevronState
      customScrollStyle
      shouldDisplaySelectedOnTop=true
    />
    <EditOrgName showModal setShowModal orgList orgId getOrgList />
    <LoaderModal
      showModal={showSwitchingOrg}
      setShowModal={setShowSwitchingOrg}
      text="Switching organisation..."
    />
  </div>
}
