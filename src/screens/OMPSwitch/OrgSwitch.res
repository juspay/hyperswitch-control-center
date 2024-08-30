@react.component
let make = () => {
  open APIUtils
  open LogicUtils
  open OMPSwitchUtils
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let showToast = ToastState.useShowToast()
  let {userInfo: {orgId}} = React.useContext(UserInfoProvider.defaultContext)
  let (orgList, setOrgList) = Recoil.useRecoilState(HyperswitchAtom.orgListAtom)

  let getOrgList = async () => {
    try {
      let url = getURL(~entityName=USERS, ~userType=#LIST_ORG, ~methodType=Get)
      let response = await fetchDetails(url)
      setOrgList(_ => response->getArrayDataFromJson(orgItemToObjMapper))
    } catch {
    | _ => {
        setOrgList(_ => defaultOrg(orgId, ""))
        showToast(~message="Failed to fetch organisation list", ~toastType=ToastError)
      }
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
      baseComponent={<ListBaseComp heading="Org" subHeading=orgId />}
      baseComponentCustomStyle="border-blue-820 rounded bg-popover-background rounded text-white"
      optionClass="text-gray-200 text-fs-14"
      selectClass="text-gray-200 text-fs-14"
      customDropdownOuterClass="!border-none"
    />
  </div>
}
