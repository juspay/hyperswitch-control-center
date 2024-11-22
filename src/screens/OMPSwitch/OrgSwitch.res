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

  <div className="w-full my-4 ">
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
        heading=""
        subHeading={currentOMPName(orgList, orgId)}
        arrow
        showEditIcon={userHasAccess(~groupAccess=OrganizationManage) === Access}
        onEditClick
        isDarkBg=true
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
