module ListBaseComp = {
  @react.component
  let make = () => {
    let {userInfo: {orgId}} = React.useContext(UserInfoProvider.defaultContext)
    let (arrow, setArrow) = React.useState(_ => false)

    <div
      className="flex items-center justify-center text-sm text-center text-white font-medium rounded hover:bg-opacity-80 bg-sidebar-blue"
      onClick={_ => setArrow(prev => !prev)}>
      <div className="flex flex-col items-start px-2 py-2">
        <p className="text-xs text-gray-400"> {"Org"->React.string} </p>
        <p className="fs-10"> {orgId->React.string} </p>
      </div>
      <div className="px-2 py-2">
        <Icon
          className={arrow
            ? "-rotate-180 transition duration-[250ms] opacity-70"
            : "rotate-0 transition duration-[250ms] opacity-70"}
          name="arrow-without-tail-new"
          size=15
        />
      </div>
    </div>
  }
}

@react.component
let make = () => {
  open APIUtils
  open LogicUtils
  open OrgSwitchUtils
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let showToast = ToastState.useShowToast()
  let {userInfo: {orgId}} = React.useContext(UserInfoProvider.defaultContext)
  let (orgList, setOrgList) = React.useState(_ => defaultOrg(orgId, ""))

  let getOrgList = async () => {
    try {
      let url = getURL(~entityName=USERS, ~userType=#LIST_ORG, ~methodType=Get)
      let response = await fetchDetails(url)
      setOrgList(_ => response->getArrayDataFromJson(itemToObjMapper))
    } catch {
    | _ => showToast(~message="Failed to fetch org list", ~toastType=ToastError)
    }
  }

  let options: array<SelectBox.dropdownOption> = React.useMemo(() => {
    orgList->Array.map((item): SelectBox.dropdownOption => {label: item.name, value: item.id})
  }, [orgList])

  React.useEffect(() => {
    getOrgList()->ignore
    None
  }, [])

  let input: ReactFinalForm.fieldRenderPropsInput = {
    name: "name",
    onBlur: _ => (),
    onChange: _ => (),
    onFocus: _ => (),
    value: orgId->JSON.Encode.string,
    checked: true,
  }

  <div className="border border-blue-820 rounded mx-2 ">
    <SelectBox.BaseDropdown
      allowMultiSelect=false
      buttonText=""
      input
      deselectDisable=true
      customButtonStyle="!rounded-md"
      options
      marginTop="mt-14"
      hideMultiSelectButtons=true
      addButton=false
      customStyle="bg-blue-840 hover:bg-popover-background-hover rounded !w-full"
      customSelectStyle="md:bg-blue-840 hover:bg-popover-background-hover rounded"
      searchable=false
      baseComponent={<ListBaseComp />}
      baseComponentCustomStyle="border-blue-820 rounded bg-popover-background rounded text-white"
      optionClass="text-gray-200 text-fs-14"
      selectClass="text-gray-200 text-fs-14"
      customDropdownOuterClass="!border-none"
    />
  </div>
}
