module DisplayKeyValueParams = {
  @react.component
  let make = (
    ~showTitle: bool=true,
    ~heading: Table.header,
    ~value: Table.cell,
    ~isInHeader=false,
    ~isHorizontal=false,
    ~customMoneyStyle="",
    ~labelMargin="",
    ~customDateStyle="",
    ~wordBreak=true,
    ~overiddingHeadingStyles="",
    ~textColor="!font-medium !text-nd_gray-600",
  ) => {
    let marginClass = if labelMargin->LogicUtils.isEmptyString {
      "mt-4 py-0"
    } else {
      labelMargin
    }

    let fontClass = if isInHeader {
      "text-fs-20"
    } else {
      "text-fs-13"
    }

    let textColor =
      textColor->LogicUtils.isEmptyString ? "text-jp-gray-900 dark:text-white" : textColor

    let description = heading.description->Option.getOr("")

    {
      <AddDataAttributes attributes=[("data-label", heading.title)]>
        <div
          className={`flex ${isHorizontal ? "flex-row justify-between" : "flex-col gap-2"} py-4`}>
          <div
            className={`flex flex-row text-fs-11  ${isHorizontal
                ? "flex justify-start"
                : ""} text-jp-gray-900 text-opacity-50 dark:text-jp-gray-text_darktheme dark:text-opacity-50 `}>
            <div className={overiddingHeadingStyles}>
              {React.string(showTitle ? heading.title : " x")}
            </div>
            <RenderIf condition={description->LogicUtils.isNonEmptyString}>
              <div className="text-sm text-gray-500 mx-2 -mt-1 ">
                <ToolTip description={description} toolTipPosition={ToolTip.Top} />
              </div>
            </RenderIf>
          </div>
          <div
            className={`${isHorizontal
                ? "flex justify-end"
                : ""} ${fontClass} font-semibold text-left ${textColor}`}>
            <Table.TableCell
              cell=value
              textAlign=Table.Left
              fontBold=true
              customMoneyStyle
              labelMargin=marginClass
              customDateStyle
            />
          </div>
        </div>
      </AddDataAttributes>
    }
  }
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
      className={`flex flex-row cursor-pointer items-center px-4 gap-2 min-w-44 justify-between h-36-px ${bgClass} border rounded-lg border-nd_gray-150 shadow-sm`}>
      <div className="flex flex-row items-center gap-2">
        <RenderIf condition={subHeading->String.length > 0}>
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
        <Icon className={`${arrowClassName} ml-1`} name="nd-angle-down" size=12 />
      </RenderIf>
    </div>
  }
}
