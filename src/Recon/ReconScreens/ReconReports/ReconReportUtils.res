open ReportsTypes
let getArrayDictFromRes = res => {
  open LogicUtils
  res->getDictFromJsonObject->getArrayFromDict("data", [])
}
let getSizeofRes = res => {
  open LogicUtils
  res->getDictFromJsonObject->getInt("size", 0)
}

let getTabFromUrl = search => {
  switch search {
  | "tab=exceptions" => Exceptions
  | _ => All
  }
}

let getHeadersForCSV = () => {
  "Transaction ID,Order ID,Payment Gateway,Payment Method,Txn Amount,Settlement Amount,Recon Status,Transaction Date"
}

let generateDropdownOptionsCustomComponent: array<OMPSwitchTypes.ompListTypes> => array<
  SelectBox.dropdownOption,
> = dropdownList => {
  let options: array<SelectBox.dropdownOption> = dropdownList->Array.map((
    item
  ): SelectBox.dropdownOption => {
    let option: SelectBox.dropdownOption = {
      label: item.name,
      value: item.id,
    }
    option
  })
  options
}

module ListBaseComp = {
  @react.component
  let make = (
    ~heading="",
    ~subHeading,
    ~arrow,
    ~showEditIcon=false,
    ~onEditClick=_ => (),
    ~isDarkBg=false,
    ~showDropdownArrow=true,
    ~placeHolder="Filters",
  ) => {
    let {globalUIConfig: {sidebarColor: {secondaryTextColor}}} = React.useContext(
      ThemeProvider.themeContext,
    )

    let arrowClassName = isDarkBg
      ? `${arrow
            ? "rotate-180"
            : "-rotate-0"} transition duration-[250ms] opacity-70 ${secondaryTextColor}`
      : `${arrow
            ? "rotate-0"
            : "rotate-180"} transition duration-[250ms] opacity-70 ${secondaryTextColor}`

    <div
      className={`flex flex-row cursor-pointer items-center py-5 px-4 gap-2 min-w-44 justify-between h-8 bg-white border rounded-lg border-nd_gray-100 shadow-sm`}>
      <div className="flex flex-row items-center gap-2">
        <RenderIf condition={subHeading->String.length > 0}>
          <GatewayIcon gateway={subHeading->String.toUpperCase} className="w-4 h-4" />
          <p
            className="overflow-scroll text-nowrap text-sm font-medium text-nd_gray-500 whitespace-pre  ">
            {subHeading->React.string}
          </p>
        </RenderIf>
        <RenderIf condition={subHeading->String.length == 0}>
          <Icon name="nd-filter-lines" size=15 />
          <p
            className="overflow-scroll text-nowrap text-sm font-medium text-nd_gray-500 whitespace-pre  ">
            {placeHolder->React.string}
          </p>
        </RenderIf>
      </div>
      <RenderIf condition={showDropdownArrow}>
        <Icon className={`${arrowClassName} ml-1`} name="arrow-without-tail-new" size=15 />
      </RenderIf>
    </div>
  }
}
