@react.component
let make = () => {
  open APIUtils
  open LogicUtils
  open OMPSwitchUtils
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let showToast = ToastState.useShowToast()
  let orgSwitch = OMPSwitchHooks.useOrgSwitch()
  let {userInfo: {orgId}} = React.useContext(UserInfoProvider.defaultContext)
  let (orgList, setOrgList) = Recoil.useRecoilState(HyperswitchAtom.orgListAtom)
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
      let _ = await orgSwitch(~expectedOrgId=value, ~currentOrgId=orgId)
    } catch {
    | _ => showToast(~message="Failed to switch organisation", ~toastType=ToastError)
    }
  }

  let currOrgName = switch orgList->Array.find(org => org.id == orgId) {
  | Some(org) => org.name
  | None => ""
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

  <div className="border border-blue-820 rounded mx-2 ">
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
      baseComponent={<OMPSwitchHelper.ListBaseComp heading="Org" subHeading=currOrgName arrow />}
      baseComponentCustomStyle="border-blue-820 rounded bg-popover-background rounded text-white"
      optionClass="text-gray-200 text-fs-14"
      selectClass="text-gray-200 text-fs-14"
      customDropdownOuterClass="!border-none"
      toggleChevronState
    />
  </div>
}
