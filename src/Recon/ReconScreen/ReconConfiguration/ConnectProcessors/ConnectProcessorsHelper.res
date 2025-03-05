open HSwitchUtils
let p1MediumTextStyle = HSwitchUtils.getTextClass((P1, Medium))
let p1RegularText = getTextClass((P1, Regular))

let generateDropdownOptionsCustomComponent: array<OMPSwitchTypes.ompListTypes> => array<
  SelectBox.dropdownOption,
> = dropdownList => {
  let options: array<SelectBox.dropdownOption> = dropdownList->Array.map((
    item
  ): SelectBox.dropdownOption => {
    let option: SelectBox.dropdownOption = {
      label: item.name,
      value: item.id,
      icon: Button.CustomIcon(
        <GatewayIcon gateway={item.name->String.toUpperCase} className="mt-0.5 mr-2 w-4 h-4" />,
      ),
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
    ~placeHolder="Select Processor",
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

    let bgClass = subHeading->String.length > 0 ? "bg-white" : "bg-nd_gray-50"

    <div
      className={`flex flex-row cursor-pointer items-center py-5 px-4 gap-2 min-w-44 justify-between h-8 ${bgClass} border rounded-lg border-nd_gray-100 shadow-sm`}>
      <div className="flex flex-row items-center gap-2">
        <RenderIf condition={subHeading->String.length > 0}>
          <GatewayIcon gateway={subHeading->String.toUpperCase} className="w-4 h-4" />
          <p
            className="overflow-scroll text-nowrap text-sm font-medium text-nd_gray-500 whitespace-pre  ">
            {subHeading->React.string}
          </p>
        </RenderIf>
        <RenderIf condition={subHeading->String.length == 0}>
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

module AddNewOMPButton = {
  @react.component
  let make = (
    ~user: UserInfoTypes.entity,
    ~customPadding="",
    ~customHRTagStyle="",
    ~addItemBtnStyle="",
  ) => {
    open ConnectorUtils

    let allowedRoles = switch user {
    | #Organization => [#tenant_admin]
    | #Merchant => [#tenant_admin, #org_admin]
    | #Profile => [#tenant_admin, #org_admin, #merchant_admin]
    | _ => []
    }
    let hasOMPCreateAccess = OMPCreateAccessHook.useOMPCreateAccessHook(allowedRoles)
    let cursorStyles = GroupAccessUtils.cursorStyles(hasOMPCreateAccess)
    let connectorsList =
      ConnectorUtils.connectorListForLive->Array.filter(connector =>
        connector != Processors(STRIPE)
      )

    <ACLDiv
      authorization={hasOMPCreateAccess}
      noAccessDescription="You do not have the required permissions for this action. Please contact your admin."
      onClick={_ => ()}
      isRelative=false
      contentAlign=Default
      tooltipForWidthClass="!h-full"
      className={`${cursorStyles} ${customPadding} ${addItemBtnStyle}`}
      showTooltip={hasOMPCreateAccess == Access}>
      {<>
        <hr className={customHRTagStyle} />
        <div className="flex flex-col items-start gap-3.5 font-medium  px-3.5 py-3">
          <p
            className="uppercase text-nd_gray-400 font-semibold leading-3 text-fs-10 tracking-wider bg-white">
            {"Available for production"->React.string}
          </p>
          <div className="flex flex-col gap-2.5 h-40 overflow-scroll cursor-not-allowed w-full">
            {connectorsList
            ->Array.mapWithIndex((connector: ConnectorTypes.connectorTypes, _) => {
              let connectorName = connector->getConnectorNameString
              let size = "w-4 h-4 rounded-sm"

              <div className="flex flex-row gap-3 items-center">
                <GatewayIcon gateway={connectorName->String.toUpperCase} className=size />
                <p className="text-sm font-medium normal-case text-nd_gray-600/40">
                  {connectorName
                  ->getDisplayNameForConnector(~connectorType=ConnectorTypes.Processor)
                  ->React.string}
                </p>
              </div>
            })
            ->React.array}
          </div>
        </div>
      </>}
    </ACLDiv>
  }
}
