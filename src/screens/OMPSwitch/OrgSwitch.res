module ListBaseComp = {
  @react.component
  let make = () => {
    let {orgId} = React.useContext(UserInfoProvider.defaultContext)
    let (arrow, setArrow) = React.useState(_ => false)

    <div className="flex flex-col items-end gap-2 mr-2" onClick={_ => setArrow(prev => !prev)}>
      <div
        className="flex items-center justify-end text-sm text-center text-white font-medium rounded hover:bg-opacity-80 bg-popover-background w-fit">
        <img
          src="" alt={orgId->String.slice(~start=0, ~end=1)->String.toUpperCase} className="px-2"
        />
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
    </div>
  }
}

@react.component
let make = () => {
  open APIUtils
  open LogicUtils
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let (orgList, setOrgList) = React.useState(_ => Dict.make()->JSON.Encode.object)
  let {orgId} = React.useContext(UserInfoProvider.defaultContext)

  let getOrgList = async () => {
    try {
      let url = getURL(~entityName=USERS, ~userType=#LIST_ORG, ~methodType=Get)
      let response = await fetchDetails(url)
      setOrgList(_ => response)
    } catch {
    | _ => ()
    }
  }

  React.useEffect(() => {
    getOrgList()->ignore
    None
  }, [])

  let orgListArray =
    orgList
    ->getArrayFromJson([])
    ->Array.map(item => {
      item->getDictFromJsonObject->getString("org_id", "")
    })

  let options = orgListArray->SelectBox.makeOptions

  let input: ReactFinalForm.fieldRenderPropsInput = {
    name: "name",
    onBlur: _ => (),
    onChange: _ => (),
    onFocus: _ => (),
    value: orgId->JSON.Encode.string,
    checked: true,
  }

  <SelectBox.BaseDropdown
    allowMultiSelect=false
    buttonText=""
    input
    deselectDisable=true
    customButtonStyle="!rounded-md"
    options
    hideMultiSelectButtons=true
    addButton=false
    // dropdownCustomWidth="w-full"
    customStyle="hover:bg-popover-background-hover"
    customSelectStyle="md:bg-popover-background hover:bg-popover-background-hover"
    searchable=false
    fullLength=true
    baseComponent={<ListBaseComp />}
    baseComponentCustomStyle="bg-popover-background"
    optionClass="text-gray-200 text-fs-14"
    selectClass="text-gray-200 text-fs-14"
    customDropdownOuterClass="!border-none"
  />
}
