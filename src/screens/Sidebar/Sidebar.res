open HeadlessUI
open SidebarTypes

let defaultLinkSelectionCheck = (firstPart, tabLink) => {
  firstPart->LogicUtils.removeTrailingSlash === tabLink->LogicUtils.removeTrailingSlash
}

let getIconSize = buttonType => {
  switch buttonType {
  | "large" => 42
  | "larger" => 65
  | _ => 20
  }
}

module MenuOption = {
  @react.component
  let make = (~text=?, ~children=?, ~onClick=?) => {
    let {
      globalUIConfig: {sidebarColor: {backgroundColor, secondaryTextColor, hoverColor}},
    } = React.useContext(ThemeProvider.themeContext)
    <button
      className={`px-4 py-3 flex text-sm w-full ${secondaryTextColor} cursor-pointer ${backgroundColor.sidebarSecondary} ${hoverColor}`}
      ?onClick>
      {switch text {
      | Some(str) => React.string(str)
      | None => React.null
      }}
      {switch children {
      | Some(elem) => elem
      | None => React.null
      }}
    </button>
  }
}

module SidebarOption = {
  @react.component
  let make = (~isSidebarExpanded, ~name, ~icon, ~isSelected, ~selectedIcon=icon) => {
    let {globalUIConfig: {sidebarColor: {primaryTextColor, secondaryTextColor}}} = React.useContext(
      ThemeProvider.themeContext,
    )
    let textBoldStyles = isSelected
      ? `${primaryTextColor} font-semibold`
      : `${secondaryTextColor} font-medium  `
    let iconColor = isSelected ? `${primaryTextColor}` : `${secondaryTextColor}  `
    let iconName = isSelected ? selectedIcon : icon
    if isSidebarExpanded {
      <div className="flex items-center gap-5">
        <Icon size=18 name=iconName className=iconColor />
        <div className={`text-sm ${textBoldStyles} whitespace-nowrap`}> {React.string(name)} </div>
      </div>
    } else {
      <Icon size=18 name=iconName className=iconColor />
    }
  }
}

module SidebarSubOption = {
  @react.component
  let make = (~name, ~isSectionExpanded, ~isSelected, ~children=React.null, ~isSideBarExpanded) => {
    let {globalUIConfig: {sidebarColor: {hoverColor}}} = React.useContext(
      ThemeProvider.themeContext,
    )
    let subOptionClass = isSelected ? `${hoverColor}` : ""
    let alignmentClasses = children == React.null ? "" : "flex flex-row items-center"
    <div
      className={`text-sm w-full ${alignmentClasses} ${isSectionExpanded
          ? "transition duration-[250ms] animate-textTransitionSideBar"
          : "transition duration-[1000ms] animate-textTransitionSideBarOff"} ${isSideBarExpanded
          ? "mx-2"
          : "mx-1"} border-light_grey `}>
      <div className="w-8" />
      <div
        className={`${subOptionClass} w-full py-2.5 px-3 flex items-center ${hoverColor} whitespace-nowrap my-1 rounded-lg`}>
        {React.string(name)}
        {children}
      </div>
    </div>
  }
}

module SidebarItem = {
  @react.component
  let make = (
    ~tabInfo,
    ~isSelected,
    ~isSidebarExpanded,
    ~setOpenItem=_ => (),
    ~onItemClickCustom=_ => (),
  ) => {
    let sidebarItemRef = React.useRef(Nullable.null)
    let {getSearchParamByLink} = React.useContext(UserPrefContext.userPrefContext)
    let getSearchParamByLink = link => getSearchParamByLink(String.substringToEnd(link, ~start=0))
    let {
      globalUIConfig: {sidebarColor: {primaryTextColor, secondaryTextColor, hoverColor}},
    } = React.useContext(ThemeProvider.themeContext)
    let selectedClass = if isSelected {
      ` ${hoverColor}`
    } else {
      ` hover:transition hover:duration-300 `
    }

    let textColor = if isSelected {
      `text-sm font-semibold ${primaryTextColor}`
    } else {
      `text-sm font-medium  ${secondaryTextColor} `
    }
    let isMobileView = MatchMedia.useMobileChecker()
    let {setIsSidebarExpanded} = React.useContext(SidebarProvider.defaultContext)

    RippleEffectBackground.useHorizontalRippleHook(sidebarItemRef)

    let tabLinklement = switch tabInfo {
    | Link(tabOption) => {
        let {name, icon, link, access, ?selectedIcon} = tabOption
        let redirectionLink = `${link}${getSearchParamByLink(link)}`

        let onSidebarItemClick = _ => {
          isMobileView ? setIsSidebarExpanded(_ => false) : ()
          setOpenItem(prev => {prev == name ? "" : name})
          onItemClickCustom()
        }
        <RenderIf condition={access !== NoAccess}>
          <Link to_={GlobalVars.appendDashboardPath(~url=redirectionLink)}>
            <AddDataAttributes
              attributes=[
                ("data-testid", name->String.replaceRegExp(%re("/\s/g"), "")->String.toLowerCase),
              ]>
              <div
                ref={sidebarItemRef->ReactDOM.Ref.domRef}
                onClick={onSidebarItemClick}
                className={`${textColor} relative overflow-hidden flex flex-row rounded-lg items-center cursor-pointer ${selectedClass} p-3 ${isSidebarExpanded
                    ? ""
                    : "mx-1"} ${hoverColor} my-0.5 `}>
                {switch selectedIcon {
                | Some(selectedIcon) =>
                  <SidebarOption name icon isSidebarExpanded isSelected selectedIcon />
                | None => <SidebarOption name icon isSidebarExpanded isSelected />
                }}
              </div>
            </AddDataAttributes>
          </Link>
        </RenderIf>
      }

    | RemoteLink(tabOption) => {
        let {name, icon, link, access, ?remoteIcon, ?selectedIcon} = tabOption
        let (remoteUi, link) = if remoteIcon->Option.getOr(false) {
          (<Icon name="external-link-alt" size=14 className="ml-3" />, link)
        } else {
          (React.null, `${link}${getSearchParamByLink(link)}`)
        }
        <RenderIf condition={access !== NoAccess}>
          <a
            href={link}
            target="_blank"
            className={`${textColor} flex flex-row items-center cursor-pointer ${selectedClass} p-3`}>
            {switch selectedIcon {
            | Some(selectedIcon) =>
              <SidebarOption name icon isSidebarExpanded isSelected selectedIcon />
            | None => <SidebarOption name icon isSidebarExpanded isSelected />
            }}
            remoteUi
          </a>
        </RenderIf>
      }

    | LinkWithTag(tabOption) => {
        let {name, icon, iconTag, link, access, ?iconStyles, ?iconSize} = tabOption

        <RenderIf condition={access !== NoAccess}>
          <Link to_={GlobalVars.appendDashboardPath(~url=`${link}${getSearchParamByLink(link)}`)}>
            <div
              onClick={_ => isMobileView ? setIsSidebarExpanded(_ => false) : ()}
              className={`${textColor} flex flex-row items-center cursor-pointer transition duration-300 ${selectedClass} p-3 ${isSidebarExpanded
                  ? "mx-2"
                  : "mx-1"} ${hoverColor} my-0.5`}>
              <SidebarOption name icon isSidebarExpanded isSelected />
              <RenderIf condition={isSidebarExpanded}>
                <Icon
                  size={iconSize->Option.getOr(26)}
                  name=iconTag
                  className={`ml-2 ${iconStyles->Option.getOr("w-26 h-26")}`}
                />
              </RenderIf>
            </div>
          </Link>
        </RenderIf>
      }

    | Heading(_) | Section(_) | CustomComponent(_) => React.null
    }

    tabLinklement
  }
}

module NestedSidebarItem = {
  @react.component
  let make = (~tabInfo, ~isSelected, ~isSideBarExpanded, ~isSectionExpanded) => {
    let {globalUIConfig: {sidebarColor: {primaryTextColor, secondaryTextColor}}} = React.useContext(
      ThemeProvider.themeContext,
    )

    let {getSearchParamByLink} = React.useContext(UserPrefContext.userPrefContext)
    let getSearchParamByLink = link => getSearchParamByLink(Js.String2.substr(link, ~from=0))

    let selectedClass = if isSelected {
      "font-semibold"
    } else {
      "font-medium rounded-lg hover:transition hover:duration-300"
    }
    let textColor = if isSelected {
      `${primaryTextColor}`
    } else {
      `${secondaryTextColor}`
    }
    let {setIsSidebarExpanded} = React.useContext(SidebarProvider.defaultContext)
    let isMobileView = MatchMedia.useMobileChecker()
    let nestedSidebarItemRef = React.useRef(Nullable.null)

    <RenderIf condition={isSideBarExpanded}>
      {switch tabInfo {
      | SubLevelLink(tabOption) => {
          let {name, link, access, ?iconTag, ?iconStyles, ?iconSize} = tabOption

          <RenderIf condition={access !== NoAccess}>
            <Link to_={GlobalVars.appendDashboardPath(~url=`${link}${getSearchParamByLink(link)}`)}>
              <AddDataAttributes
                attributes=[
                  ("data-testid", name->String.replaceRegExp(%re("/\s/g"), "")->String.toLowerCase),
                ]>
                <div
                  ref={nestedSidebarItemRef->ReactDOM.Ref.domRef}
                  onClick={_ => isMobileView ? setIsSidebarExpanded(_ => false) : ()}
                  className={`${textColor} ${selectedClass} text-md relative overflow-hidden flex flex-row items-center cursor-pointer rounded-lg ml-3`}>
                  <SidebarSubOption name isSectionExpanded isSelected isSideBarExpanded>
                    <RenderIf condition={iconTag->Belt.Option.isSome && isSideBarExpanded}>
                      <div className="ml-2">
                        <Icon
                          size={iconSize->Option.getOr(26)}
                          name={iconTag->Option.getOr("")}
                          className={iconStyles->Option.getOr("w-26 h-26")}
                        />
                      </div>
                    </RenderIf>
                  </SidebarSubOption>
                </div>
              </AddDataAttributes>
            </Link>
          </RenderIf>
        }
      }}
    </RenderIf>
  }
}

module NestedSectionItem = {
  @react.component
  let make = (
    ~section: sectionType,
    ~isSectionExpanded,
    ~isAnySubItemSelected,
    ~textColor,
    ~cursor,
    ~toggleSectionExpansion,
    ~expandedTextColor,
    ~isElementShown,
    ~isSubLevelItemSelected,
    ~isSideBarExpanded,
  ) => {
    let {
      globalUIConfig: {sidebarColor: {primaryTextColor, secondaryTextColor, hoverColor}},
    } = React.useContext(ThemeProvider.themeContext)

    let iconColor = isAnySubItemSelected ? `${primaryTextColor}` : `${secondaryTextColor}  `

    let iconOuterClass = if !isSideBarExpanded {
      `${isAnySubItemSelected ? "" : ""} rounded-lg p-4 rounded-lg`
    } else {
      ""
    }

    let bgColor = if isSideBarExpanded && isAnySubItemSelected && !isSectionExpanded {
      ""
    } else {
      ""
    }

    let sidebarNestedSectionRef = React.useRef(Nullable.null)

    let sectionExpandedAnimation = `rounded-lg transition duration-[250ms] ease-in-out`
    let iconName = isAnySubItemSelected
      ? section.selectedIcon->Option.getOr(section.icon)
      : section.icon

    <AddDataAttributes
      attributes=[
        ("data-testid", section.name->String.replaceRegExp(%re("/\s/g"), "")->String.toLowerCase),
      ]>
      <div className={`transition duration-300`}>
        <div
          ref={sidebarNestedSectionRef->ReactDOM.Ref.domRef}
          className={`${isSideBarExpanded
              ? ""
              : "mx-1"} text-sm ${textColor} ${bgColor} relative overflow-hidden flex flex-row items-center justify-between p-3 rounded-lg ${cursor} ${isSectionExpanded
              ? ""
              : sectionExpandedAnimation} ${hoverColor} `}
          onClick=toggleSectionExpansion>
          <div className="flex-row items-center select-none min-w-max flex  gap-5">
            {if isSideBarExpanded {
              <div className=iconOuterClass>
                <Icon size=18 name=iconName className=iconColor />
              </div>
            } else {
              <Icon size=18 name=iconName className=iconColor />
            }}
            <RenderIf condition={isSideBarExpanded}>
              <div className={`text-sm ${expandedTextColor} whitespace-nowrap`}>
                {React.string(section.name)}
              </div>
            </RenderIf>
          </div>
          <RenderIf condition={isSideBarExpanded}>
            <Icon
              name={"nd-angle-down"}
              className={isSectionExpanded
                ? `-rotate-180 transition duration-[250ms] mr-2 ${secondaryTextColor} opacity-70`
                : `-rotate-0 transition duration-[250ms] mr-2 ${secondaryTextColor} opacity-70`}
              size=12
            />
          </RenderIf>
        </div>
        <RenderIf condition={isElementShown}>
          {section.links
          ->Array.mapWithIndex((subLevelItem, index) => {
            let isSelected = subLevelItem->isSubLevelItemSelected
            <NestedSidebarItem
              key={Int.toString(index)}
              isSelected
              isSideBarExpanded
              isSectionExpanded
              tabInfo=subLevelItem
            />
          })
          ->React.array}
        </RenderIf>
      </div>
    </AddDataAttributes>
  }
}

module SidebarNestedSection = {
  @react.component
  let make = (
    ~section: sectionType,
    ~linkSelectionCheck,
    ~firstPart,
    ~isSideBarExpanded,
    ~openItem="",
    ~setOpenItem=_ => (),
    ~isSectionAutoCollapseEnabled=false,
  ) => {
    let {globalUIConfig: {sidebarColor: {primaryTextColor, secondaryTextColor}}} = React.useContext(
      ThemeProvider.themeContext,
    )

    let isSubLevelItemSelected = tabInfo => {
      switch tabInfo {
      | SubLevelLink(item) => linkSelectionCheck(firstPart, item.link)
      }
    }

    let (isSectionExpanded, setIsSectionExpanded) = React.useState(_ => false)
    let (isElementShown, setIsElementShown) = React.useState(_ => false)

    let isAnySubItemSelected = section.links->Array.find(isSubLevelItemSelected)->Option.isSome

    React.useEffect(() => {
      if isSectionExpanded {
        setIsElementShown(_ => true)
      } else if isElementShown {
        let _ = setTimeout(() => {
          setIsElementShown(_ => false)
        }, 200)
      }
      None
    }, (isSectionExpanded, isSideBarExpanded))

    React.useEffect(() => {
      if isSideBarExpanded {
        setIsSectionExpanded(_ => isAnySubItemSelected)
      } else {
        setIsSectionExpanded(_ => false)
      }
      None
    }, (isSideBarExpanded, isAnySubItemSelected))

    let toggleSectionExpansion = React.useCallback(_ => {
      if !isSideBarExpanded {
        setTimeout(() => {
          setIsSectionExpanded(_ => true)
        }, 200)->ignore
      } else if isAnySubItemSelected {
        setIsSectionExpanded(_ => true)
      } else {
        setIsSectionExpanded(p => !p)
      }
    }, (setIsSectionExpanded, isSideBarExpanded, isAnySubItemSelected))

    let textColor = {
      if isSideBarExpanded {
        if isAnySubItemSelected {
          `${primaryTextColor}`
        } else {
          `${secondaryTextColor}  `
        }
      } else if isAnySubItemSelected {
        `${primaryTextColor}`
      } else {
        `${secondaryTextColor}  `
      }
    }

    let cursor = if isAnySubItemSelected && isSideBarExpanded {
      `cursor-default`
    } else {
      `cursor-pointer`
    }
    let expandedTextColor = isAnySubItemSelected
      ? `${primaryTextColor} font-semibold`
      : `${secondaryTextColor} font-medium`
    let areAllSubLevelsHidden = section.links->Array.reduce(true, (acc, subLevelItem) => {
      acc &&
      switch subLevelItem {
      | SubLevelLink({access}) => access === NoAccess
      }
    })

    let isSectionExpanded = if isSectionAutoCollapseEnabled {
      openItem === section.name || isAnySubItemSelected
    } else {
      isSectionExpanded
    }

    let toggleSectionExpansion = if isSectionAutoCollapseEnabled {
      _ => setOpenItem(prev => {prev == section.name ? "" : section.name})
    } else {
      toggleSectionExpansion
    }

    let isElementShown = if isSectionAutoCollapseEnabled {
      openItem == section.name || isAnySubItemSelected
    } else {
      isElementShown
    }

    <RenderIf condition={!areAllSubLevelsHidden}>
      <NestedSectionItem
        section
        isSectionExpanded
        isAnySubItemSelected
        textColor
        cursor
        toggleSectionExpansion
        expandedTextColor
        isElementShown
        isSubLevelItemSelected
        isSideBarExpanded
      />
    </RenderIf>
  }
}

@react.component
let make = (
  ~sidebars: array<topLevelItem>,
  ~path,
  ~linkSelectionCheck=defaultLinkSelectionCheck,
  ~verticalOffset="120px",
  ~productSiebars: array<topLevelItem>,
) => {
  open CommonAuthHooks
  let {
    globalUIConfig: {sidebarColor: {backgroundColor, secondaryTextColor, hoverColor, borderColor}},
  } = React.useContext(ThemeProvider.themeContext)
  let handleLogout = APIUtils.useHandleLogout(~eventName="user_signout_manual")
  let isMobileView = MatchMedia.useMobileChecker()
  let {onProductSelectClick} = React.useContext(ProductSelectionProvider.defaultContext)
  let sideBarRef = React.useRef(Nullable.null)
  let {email} = useCommonAuthInfo()->Option.getOr(defaultAuthInfo)
  let {userInfo: {roleId}} = React.useContext(UserInfoProvider.defaultContext)
  let isInternalUser = roleId->HyperSwitchUtils.checkIsInternalUser
  let (openItem, setOpenItem) = React.useState(_ => "")
  let {isSidebarExpanded, setIsSidebarExpanded} = React.useContext(SidebarProvider.defaultContext)
  let {showSideBar} = React.useContext(GlobalProvider.defaultContext)

  React.useEffect(() => {
    setIsSidebarExpanded(_ => !isMobileView)
    None
  }, [isMobileView])

  let sidebarWidth = {
    switch isSidebarExpanded {
    | true =>
      switch isMobileView {
      | true => "100%"
      | false => "275px"
      }
    | false => "275px"
    }
  }
  let profileMaxWidth = "150px"

  let level3 = tail => {
    switch List.tail(tail) {
    | Some(tail2) =>
      switch List.head(tail2) {
      | Some(value2) => `/${value2}`
      | None => "/"
      }
    | None => "/"
    }
  }

  let level2 = tail => {
    switch List.tail(tail) {
    | Some(tail2) =>
      switch List.head(tail2) {
      | Some(value2) => `/${value2}` ++ level3(tail2)
      | None => "/"
      }
    | None => "/"
    }
  }

  let firstPart = switch List.tail(path) {
  | Some(tail) =>
    switch List.head(tail) {
    | Some(x) =>
      /* condition is added to check for v2 routes . Eg: /v2/${productName}/${routeName} */
      if x === "v2" || x === "v1" {
        `/${x}` ++ level2(tail)
      } else {
        `/${x}`
      }
    | None => "/"
    }
  | None => "/"
  }

  let expansionClass = !isSidebarExpanded ? "-translate-x-full" : ""

  let sidebarMaxWidth = isMobileView ? "w-screen" : "w-max"
  let sidebarCollapseWidth = showSideBar ? "325px" : "56px"
  let sidebarContainerClassWidth = isMobileView ? "0px" : `${sidebarCollapseWidth}`

  let transformClass = "transform md:translate-x-0 transition"

  let sidebarScrollbarCss = `
  @supports (-webkit-appearance: none){
    .sidebar-scrollbar {
        scrollbar-width: auto;
        scrollbar-color: #CACFD8;
      }
      
      .sidebar-scrollbar::-webkit-scrollbar {
        display: block;
        overflow: scroll;
        height: 4px;
        width: 5px;
      }
      
      .sidebar-scrollbar:hover::-webkit-scrollbar-thumb {
        background-color: #CACFD8;
        border-radius: 3px;
      }
      
      .sidebar-scrollbar::-webkit-scrollbar-track {
        display: none;
      }
}
  `

  let onItemClickCustom = (valueSelected: SidebarTypes.optionType) => {
    onProductSelectClick(valueSelected.name)
  }

  <div className={`${backgroundColor.sidebarNormal} flex group relative `}>
    <div
      ref={sideBarRef->ReactDOM.Ref.domRef}
      className={`flex h-full flex-col transition-all ease-in-out duration-200 relative inset-0`}
      style={
        width: sidebarContainerClassWidth,
      }
    />
    <div
      className={`absolute z-30 h-screen flex ${transformClass} duration-300 ease-in-out ${sidebarMaxWidth} ${expansionClass}`}>
      <OrgSidebar />
      <RenderIf condition={showSideBar}>
        <div
          ref={sideBarRef->ReactDOM.Ref.domRef}
          className={`${backgroundColor.sidebarNormal} flex h-full flex-col transition-all duration-100 border-r ${borderColor} relative inset-0`}
          style={width: sidebarWidth}>
          <RenderIf condition={isMobileView}>
            <div className="flex align-center mt-4 mb-6 ml-1 pl-3 pr-4 gap-5 cursor-default">
              <Icon
                className="mr-1"
                size=20
                name="collapse-cross"
                customIconColor={`${secondaryTextColor}`}
                onClick={_ => setIsSidebarExpanded(_ => false)}
              />
            </div>
          </RenderIf>
          <RenderIf condition={!isInternalUser}>
            <SidebarSwitch isSidebarExpanded />
          </RenderIf>
          <div
            className="h-full overflow-y-scroll transition-transform duration-1000 overflow-x-hidden sidebar-scrollbar mt-4"
            style={height: `calc(100vh - ${verticalOffset})`}>
            <style> {React.string(sidebarScrollbarCss)} </style>
            <div className="p-2.5 pt-0">
              {sidebars
              ->Array.mapWithIndex((tabInfo, index) => {
                switch tabInfo {
                | RemoteLink(record)
                | Link(record) => {
                    let isSelected = linkSelectionCheck(firstPart, record.link)
                    <SidebarItem
                      key={Int.toString(index)} tabInfo isSelected isSidebarExpanded setOpenItem
                    />
                  }

                | LinkWithTag(record) => {
                    let isSelected = linkSelectionCheck(firstPart, record.link)
                    <SidebarItem key={Int.toString(index)} tabInfo isSelected isSidebarExpanded />
                  }

                | Section(section) =>
                  <RenderIf condition={section.showSection} key={Int.toString(index)}>
                    <SidebarNestedSection
                      key={Int.toString(index)}
                      section
                      linkSelectionCheck
                      firstPart
                      isSideBarExpanded={isSidebarExpanded}
                      openItem
                      setOpenItem
                      isSectionAutoCollapseEnabled=true
                    />
                  </RenderIf>
                | Heading(headingOptions) =>
                  <div
                    key={Int.toString(index)}
                    className={`text-xs font-medium leading-5 text-[#5B6376] overflow-hidden border-l-2 rounded-lg border-transparent px-3 ${isSidebarExpanded
                        ? "mx-2"
                        : "mx-1"} mt-5 mb-3`}>
                    {{isSidebarExpanded ? headingOptions.name : ""}->React.string}
                  </div>

                | CustomComponent(customComponentOptions) =>
                  <RenderIf condition={isSidebarExpanded} key={Int.toString(index)}>
                    customComponentOptions.component
                  </RenderIf>
                }
              })
              ->React.array}
            </div>
            <RenderIf condition={productSiebars->Array.length > 0}>
              <div className={"p-2.5"}>
                <div
                  className={`text-xs font-semibold px-3 pt-6 pb-2 text-nd_gray-400 tracking-widest`}>
                  {React.string("Other modular services"->String.toUpperCase)}
                </div>
                {productSiebars
                ->Array.mapWithIndex((tabInfo, index) => {
                  switch tabInfo {
                  | Section(section) =>
                    <RenderIf condition={section.showSection} key={Int.toString(index)}>
                      <SidebarNestedSection
                        key={Int.toString(index)}
                        section
                        linkSelectionCheck
                        firstPart
                        isSideBarExpanded={isSidebarExpanded}
                        openItem
                        setOpenItem
                        isSectionAutoCollapseEnabled=true
                      />
                    </RenderIf>
                  | Link(record) => {
                      let isSelected = linkSelectionCheck(firstPart, record.link)
                      <SidebarItem
                        key={Int.toString(index)}
                        tabInfo
                        isSelected
                        isSidebarExpanded
                        setOpenItem
                        onItemClickCustom={_ => onItemClickCustom(record)}
                      />
                    }
                  | _ => React.null
                  }
                })
                ->React.array}
              </div>
            </RenderIf>
          </div>
          <div
            className={`flex items-center justify-between p-3 border-t ${borderColor} ${hoverColor}`}>
            <RenderIf condition={isSidebarExpanded}>
              <Popover className="relative inline-block text-left">
                {popoverProps => <>
                  <Popover.Button
                    className={
                      let openClasses = if popoverProps["open"] {
                        `group pl-3 border py-2 rounded-lg inline-flex items-center text-base font-medium hover:text-opacity-100 focus:outline-none`
                      } else {
                        `text-opacity-90 group pl-3 border py-2 rounded-lg inline-flex items-center text-base font-medium hover:text-opacity-100 focus:outline-none`
                      }
                      `${openClasses} border-none`
                    }>
                    {_ => <>
                      <div className="flex items-center justify-between gap-x-3  ">
                        <div className="bg-nd_gray-600 rounded-full p-1">
                          <Icon name="nd-user" size=16 />
                        </div>
                        <ToolTip
                          description=email
                          toolTipFor={<RenderIf condition={isSidebarExpanded}>
                            <div
                              className={`w-[${profileMaxWidth}] text-sm font-medium text-left ${secondaryTextColor} dark:text-gray-600 text-ellipsis overflow-hidden`}>
                              {email->React.string}
                            </div>
                          </RenderIf>}
                          toolTipPosition=ToolTip.Top
                          tooltipWidthClass="!w-fit !z-50"
                        />
                        <div className={`flex flex-row`}>
                          <Icon
                            name="nd-dropdown-menu"
                            size=18
                            className={`cursor-pointer ${secondaryTextColor}`}
                          />
                        </div>
                      </div>
                    </>}
                  </Popover.Button>
                  <Transition
                    \"as"="span"
                    enter={"transition ease-out duration-200"}
                    enterFrom="opacity-0 translate-y-1"
                    enterTo="opacity-100 translate-y-0"
                    leave={"transition ease-in duration-150"}
                    leaveFrom="opacity-100 translate-y-0"
                    leaveTo="opacity-0 translate-y-1">
                    <Popover.Panel className={`absolute !z-30 bottom-[100%] left-1 `}>
                      {panelProps => {
                        <div
                          id="neglectTopbarTheme"
                          className={`relative flex flex-col py-3 rounded-lg shadow-lg ring-1 ring-black ring-opacity-5 w-60 ${backgroundColor.sidebarSecondary}`}>
                          <MenuOption
                            onClick={_ => {
                              panelProps["close"]()
                              RescriptReactRouter.replace(
                                GlobalVars.appendDashboardPath(~url="/account-settings/profile"),
                              )
                            }}
                            text="Profile"
                          />
                          <MenuOption
                            onClick={_ => {
                              handleLogout()->ignore
                            }}
                            text="Sign out"
                          />
                        </div>
                      }}
                    </Popover.Panel>
                  </Transition>
                </>}
              </Popover>
            </RenderIf>
          </div>
        </div>
      </RenderIf>
    </div>
  </div>
}
