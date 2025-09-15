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
      className={`px-4 py-3 flex text-sm w-full ${secondaryTextColor} cursor-pointer ${backgroundColor.sidebarSecondary} ${hoverColor} !bg-sidebar-hoverColor`}
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
  let make = (~isSidebarExpanded, ~name, ~icon, ~isSelected, ~showIcon=false) => {
    let {globalUIConfig: {sidebarColor: {primaryTextColor, secondaryTextColor}}} = React.useContext(
      ThemeProvider.themeContext,
    )
    let textBoldStyles = isSelected
      ? `${primaryTextColor} font-semibold`
      : `${secondaryTextColor} font-medium`
    let iconColor = isSelected ? `${primaryTextColor}` : `${secondaryTextColor}  `

    if isSidebarExpanded {
      <div className="flex items-center gap-2 px-3 py-1.5">
        <RenderIf condition={showIcon}>
          <Icon size=18 name=icon className={iconColor} />
        </RenderIf>
        <div className={`text-sm ${textBoldStyles} whitespace-nowrap ${showIcon ? "" : "ml-3"}`}>
          {React.string(name)}
        </div>
      </div>
    } else {
      <Icon size=18 name=icon className=iconColor />
    }
  }
}

module SidebarSubOption = {
  @react.component
  let make = (~name, ~isSectionExpanded, ~isSelected, ~children=React.null) => {
    let {globalUIConfig: {sidebarColor: {hoverColor}}} = React.useContext(
      ThemeProvider.themeContext,
    )
    let subOptionClass = isSelected ? `${hoverColor} !bg-sidebar-hoverColor` : ""
    let alignmentClasses = children == React.null ? "" : "flex flex-row items-center"

    <div
      className={`text-sm w-full ${alignmentClasses} ${isSectionExpanded
          ? "transition duration-[250ms] animate-textTransitionSideBar"
          : "transition duration-[1000ms] animate-textTransitionSideBarOff"}}`}>
      <div className="w-4" />
      <div
        className={`${subOptionClass} w-full py-1.5 px-3 flex items-center ${hoverColor} whitespace-nowrap rounded-lg`}>
        {React.string(name)}
        {children}
      </div>
    </div>
  }
}

module SidebarItem = {
  @react.component
  let make = (
    ~product,
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
    let {activeProduct} = React.useContext(ProductSelectionProvider.defaultContext)
    let activeProductDisplayName = activeProduct->ProductUtils.getProductDisplayName
    let activeProductVariant =
      activeProductDisplayName->ProductUtils.getProductVariantFromDisplayName

    let selectedClass = if isSelected {
      `${hoverColor} !bg-sidebar-hoverColor`
    } else {
      `hover:transition hover:duration-300 `
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
        let {name, icon, link, access} = tabOption
        let redirectionLink = `${link}${getSearchParamByLink(link)}`

        let onSidebarItemClick = _ => {
          isMobileView ? setIsSidebarExpanded(_ => false) : ()
          setOpenItem(prev => {prev == name ? "" : name})

          switch (activeProductVariant, product) {
          | (a, b) if a == b => ()
          | _ => onItemClickCustom()
          }
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
                className={`${textColor} relative overflow-hidden flex flex-row rounded-lg items-center cursor-pointer ${hoverColor}`}>
                <SidebarOption name icon isSidebarExpanded isSelected />
              </div>
            </AddDataAttributes>
          </Link>
        </RenderIf>
      }

    | RemoteLink(tabOption) => {
        let {name, icon, link, access, ?remoteIcon} = tabOption
        let (remoteUi, link) = if remoteIcon->Option.getOr(false) {
          (<Icon name="external-link-alt" size=14 className="ml-3" />, link)
        } else {
          (React.null, `${link}${getSearchParamByLink(link)}`)
        }
        <RenderIf condition={access !== NoAccess}>
          <a
            href={link}
            target="_blank"
            className={`${textColor} flex flex-row items-center cursor-pointer ${selectedClass} px-3 py-1.5`}>
            <SidebarOption name icon isSidebarExpanded isSelected />
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
              className={`${textColor} flex flex-row items-center cursor-pointer transition duration-300 ${selectedClass} px-3 py-1.5 mx-1 ${hoverColor}`}>
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
  let make = (
    ~product,
    ~tabInfo,
    ~isSelected,
    ~isSideBarExpanded,
    ~isSectionExpanded,
    ~onItemClickCustom,
  ) => {
    let {globalUIConfig: {sidebarColor: {primaryTextColor, secondaryTextColor}}} = React.useContext(
      ThemeProvider.themeContext,
    )
    let {activeProduct} = React.useContext(ProductSelectionProvider.defaultContext)
    let activeProductDisplayName = activeProduct->ProductUtils.getProductDisplayName
    let activeProductVariant =
      activeProductDisplayName->ProductUtils.getProductVariantFromDisplayName

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
                  onClick={_ => {
                    isMobileView ? setIsSidebarExpanded(_ => false) : ()

                    switch onItemClickCustom {
                    | Some(fn) =>
                      switch (activeProductVariant, product) {
                      | (a, b) if a == b => ()
                      | _ => fn()
                      }
                    | None => ()
                    }
                  }}
                  className={`${textColor} ${selectedClass} text-md relative overflow-hidden flex flex-row items-center cursor-pointer rounded-lg`}>
                  <SidebarSubOption name isSectionExpanded isSelected>
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
    ~product,
    ~section: sectionType,
    ~isSectionExpanded,
    ~textColor,
    ~cursor,
    ~toggleSectionExpansion,
    ~expandedTextColor,
    ~isElementShown,
    ~isSubLevelItemSelected,
    ~isSideBarExpanded,
    ~onItemClickCustom,
  ) => {
    let {globalUIConfig: {sidebarColor: {secondaryTextColor, hoverColor}}} = React.useContext(
      ThemeProvider.themeContext,
    )

    let sidebarNestedSectionRef = React.useRef(Nullable.null)

    let sectionExpandedAnimation = `rounded-lg transition duration-[250ms] ease-in-out`

    <AddDataAttributes
      attributes=[
        ("data-testid", section.name->String.replaceRegExp(%re("/\s/g"), "")->String.toLowerCase),
      ]>
      <div className={`transition duration-300`}>
        <div
          ref={sidebarNestedSectionRef->ReactDOM.Ref.domRef}
          className={`text-sm ${textColor} relative overflow-hidden flex flex-row items-center justify-between px-3 py-1.5 rounded-lg ${cursor} ${isSectionExpanded
              ? ""
              : sectionExpandedAnimation} ${hoverColor}`}
          onClick=toggleSectionExpansion>
          <div className="flex-row items-center select-none min-w-max flex gap-5">
            <RenderIf condition={isSideBarExpanded}>
              <div className={`text-sm ${expandedTextColor} whitespace-nowrap ml-3`}>
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
          <div className="flex flex-1 w-full mt-4">
            <div className="w-8" />
            <div className="border-l border-nd_gray-200" />
            <div className="flex flex-col gap-1.5 w-full leading-20">
              {section.links
              ->Array.mapWithIndex((subLevelItem, index) => {
                let isSelected = subLevelItem->isSubLevelItemSelected
                <NestedSidebarItem
                  key={Int.toString(index)}
                  product
                  isSelected
                  isSideBarExpanded
                  isSectionExpanded
                  tabInfo=subLevelItem
                  onItemClickCustom
                />
              })
              ->React.array}
            </div>
          </div>
        </RenderIf>
      </div>
    </AddDataAttributes>
  }
}

module SidebarNestedSection = {
  @react.component
  let make = (
    ~product,
    ~section: sectionType,
    ~linkSelectionCheck,
    ~firstPart,
    ~isSideBarExpanded,
    ~openItem="",
    ~setOpenItem=_ => (),
    ~isSectionAutoCollapseEnabled=false,
    ~onItemClickCustom,
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
        product
        section
        isSectionExpanded
        textColor
        cursor
        toggleSectionExpansion
        expandedTextColor
        isElementShown
        isSubLevelItemSelected
        isSideBarExpanded
        onItemClickCustom
      />
    </RenderIf>
  }
}

module ProductTypeSectionItem = {
  @react.component
  let make = (
    ~section: SidebarTypes.productTypeSection,
    ~isExpanded: bool,
    ~onToggle: unit => unit,
    ~isSidebarExpanded: bool,
    ~linkSelectionCheck,
    ~firstPart,
    ~openItem,
    ~setOpenItem,
    ~isExploredModule: bool,
    ~allowProductToggle: bool,
  ) => {
    open Typography

    let {
      globalUIConfig: {sidebarColor: {primaryTextColor, secondaryTextColor, hoverColor}},
    } = React.useContext(ThemeProvider.themeContext)
    let {activeProduct, onProductSelectClick} = React.useContext(
      ProductSelectionProvider.defaultContext,
    )

    let activeProductDisplayName = activeProduct->ProductUtils.getProductDisplayName
    let activeProductVariant =
      activeProductDisplayName->ProductUtils.getProductVariantFromDisplayName
    let sectionProductVariant = section.name->ProductUtils.getProductVariantFromDisplayName
    let isActiveProduct = activeProductVariant === sectionProductVariant

    let textColor = isActiveProduct ? `${primaryTextColor}` : `${secondaryTextColor}`

    let iconClassName = isExpanded
      ? `-rotate-180 transition duration-[250ms] mr-2 ${secondaryTextColor} opacity-70`
      : `-rotate-0 transition duration-[250ms] mr-2 ${secondaryTextColor} opacity-70`

    let handleClick = _ => {
      if isExploredModule && allowProductToggle {
        onToggle()
      } else {
        onProductSelectClick(section.name)
      }
    }

    <div className="flex flex-col">
      <div
        onClick=handleClick
        className={`flex items-center justify-between px-3 py-1.5 cursor-pointer ${hoverColor} rounded-lg`}>
        <div className="flex items-center gap-2">
          <Icon size=14 name={section.icon} className={textColor} />
          <div
            className={`whitespace-nowrap ${isActiveProduct
                ? `${primaryTextColor} ${body.md.regular}`
                : `${secondaryTextColor}`} ${body.md.medium}`}>
            {React.string(section.name)}
          </div>
        </div>
        <RenderIf condition={isSidebarExpanded && isExploredModule && allowProductToggle}>
          <Icon name="nd-angle-down" className=iconClassName size=12 />
        </RenderIf>
      </div>
      <RenderIf condition={isExpanded && isExploredModule}>
        <div className="flex flex-col gap-1 mt-2 ml-2">
          {section.links
          ->Array.mapWithIndex((tabInfo, index) => {
            switch tabInfo {
            | RemoteLink(record)
            | Link(record) => {
                let isSelected = linkSelectionCheck(firstPart, record.link)
                <SidebarItem
                  key={Int.toString(index)}
                  product={section.name->ProductUtils.getProductVariantFromDisplayName}
                  tabInfo
                  isSelected
                  isSidebarExpanded
                  setOpenItem
                  onItemClickCustom={_ => onProductSelectClick(section.name)}
                />
              }
            | LinkWithTag(record) => {
                let isSelected = linkSelectionCheck(firstPart, record.link)
                <SidebarItem
                  key={Int.toString(index)}
                  product={section.name->ProductUtils.getProductVariantFromDisplayName}
                  tabInfo
                  isSelected
                  isSidebarExpanded
                />
              }
            | Section(thisSection) =>
              <RenderIf condition={thisSection.showSection} key={Int.toString(index)}>
                <SidebarNestedSection
                  product=sectionProductVariant
                  key={Int.toString(index)}
                  section=thisSection
                  linkSelectionCheck
                  firstPart
                  isSideBarExpanded={isSidebarExpanded}
                  openItem
                  setOpenItem
                  isSectionAutoCollapseEnabled=true
                  onItemClickCustom={Some(_ => onProductSelectClick(section.name))}
                />
              </RenderIf>
            | Heading(headingOptions) =>
              <div
                key={Int.toString(index)}
                className={`${body.sm.medium} leading-20 text-nd_gray-600 overflow-hidden border-l-2 rounded-lg border-transparent px-3 mx-1 mt-5 mb-3`}>
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
      </RenderIf>
    </div>
  }
}

@react.component
let make = (
  ~path,
  ~linkSelectionCheck=defaultLinkSelectionCheck,
  ~verticalOffset="120px",
  ~isReconEnabled,
  ~sidebars,
  ~productSiebars: array<topLevelItem>,
) => {
  open CommonAuthHooks
  open Typography
  let {
    globalUIConfig: {sidebarColor: {backgroundColor, secondaryTextColor, hoverColor, borderColor}},
  } = React.useContext(ThemeProvider.themeContext)
  let handleLogout = APIUtils.useHandleLogout(~eventName="user_signout_manual")
  let isMobileView = MatchMedia.useMobileChecker()
  let sideBarRef = React.useRef(Nullable.null)
  let {email} = useCommonAuthInfo()->Option.getOr(defaultAuthInfo)
  let {userInfo: {roleId}} = React.useContext(UserInfoProvider.defaultContext)
  let isInternalUser = roleId->HyperSwitchUtils.checkIsInternalUser
  let (openItem, setOpenItem) = React.useState(_ => "")
  let {isSidebarExpanded, setIsSidebarExpanded} = React.useContext(SidebarProvider.defaultContext)
  let {showSideBar} = React.useContext(GlobalProvider.defaultContext)
  let (expandedSections, setExpandedSections) = React.useState(_ => [])
  let {devModularityV2, devSidebarV2} =
    HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let {activeProduct, onProductSelectClick} = React.useContext(
    ProductSelectionProvider.defaultContext,
  )

  let merchantList = Recoil.useRecoilValueFromAtom(HyperswitchAtom.merchantListAtom)
  let hasMerchantData = React.useMemo(() => {
    merchantList->Array.length > 0 &&
      merchantList->Array.some(merchant => merchant.id->LogicUtils.isNonEmptyString)
  }, [merchantList])

  let exploredModules = SidebarHooks.useGetSidebarProductModules(~isExplored=true)
  let unexploredModules = SidebarHooks.useGetSidebarProductModules(~isExplored=false)
  let exploredSidebars = SidebarHooks.useGetAllProductSections(
    ~isReconEnabled,
    ~products=hasMerchantData ? exploredModules : [],
  )
  let unexploredSidebars = SidebarHooks.useGetAllProductSections(
    ~isReconEnabled,
    ~products=hasMerchantData ? unexploredModules : [],
  )

  let allowProductToggle = exploredSidebars->Array.length > 0
  React.useEffect(() => {
    let activeProductDisplayName = activeProduct->ProductUtils.getProductDisplayName
    if !Array.includes(expandedSections, activeProductDisplayName) {
      setExpandedSections(prev => [activeProductDisplayName, ...prev])
    }
    None
  }, (activeProduct, exploredSidebars))

  React.useEffect(() => {
    setIsSidebarExpanded(_ => !isMobileView)
    None
  }, [isMobileView])

  let sidebarWidth = {
    switch isSidebarExpanded {
    | true =>
      switch isMobileView {
      | true => "100%"
      | false => "248px"
      }
    | false => "248px"
    }
  }
  let profileMaxWidth = "160px"

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
  let sidebarCollapseWidth = showSideBar ? "304px" : "56px"
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

  let toggleSection = sectionName => {
    setExpandedSections(prev => {
      if Array.includes(prev, sectionName) {
        prev->Array.filter(name => name !== sectionName)
      } else {
        [sectionName]
      }
    })
  }

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
          <RenderIf condition={!devSidebarV2 || isInternalUser}>
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
                        product={activeProduct}
                        key={Int.toString(index)}
                        tabInfo
                        isSelected
                        isSidebarExpanded
                        setOpenItem
                      />
                    }

                  | LinkWithTag(record) => {
                      let isSelected = linkSelectionCheck(firstPart, record.link)
                      <SidebarItem
                        product={activeProduct}
                        key={Int.toString(index)}
                        tabInfo
                        isSelected
                        isSidebarExpanded
                      />
                    }

                  | Section(section) =>
                    <RenderIf condition={section.showSection} key={Int.toString(index)}>
                      <SidebarNestedSection
                        product={activeProduct}
                        key={Int.toString(index)}
                        section
                        linkSelectionCheck
                        firstPart
                        isSideBarExpanded={isSidebarExpanded}
                        openItem
                        setOpenItem
                        isSectionAutoCollapseEnabled=true
                        onItemClickCustom=None
                      />
                    </RenderIf>
                  | Heading(headingOptions) =>
                    <div
                      key={Int.toString(index)}
                      className={`text-xs font-medium leading-5 text-nd_gray-600 overflow-hidden border-l-2 rounded-lg border-transparent px-3 ${isSidebarExpanded
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
                    | Link(record) => {
                        let isSelected = linkSelectionCheck(firstPart, record.link)
                        <SidebarItem
                          product={record.name->ProductUtils.getProductVariantFromDisplayName} ///
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
          </RenderIf>
          <RenderIf condition={devSidebarV2 && !isInternalUser}>
            <div
              className="h-full overflow-y-scroll transition-transform duration-1000 overflow-x-hidden sidebar-scrollbar mt-4"
              style={height: `calc(100vh - ${verticalOffset})`}>
              <style> {React.string(sidebarScrollbarCss)} </style>
              <div className="p-3 pt-0">
                <RenderIf condition={devModularityV2 && exploredSidebars->Array.length > 0}>
                  <Link to_={GlobalVars.appendDashboardPath(~url="/v2/home")}>
                    <div
                      className={`${body.md.medium} ${secondaryTextColor} relative overflow-hidden flex flex-row rounded-lg items-center cursor-pointer hover:transition hover:duration-300 px-3 py-1.5 ${isSidebarExpanded
                          ? ""
                          : "mx-1"} ${hoverColor}`}>
                      <SidebarOption
                        name="Home"
                        icon="nd-home"
                        isSidebarExpanded
                        isSelected={false}
                        showIcon=true
                      />
                    </div>
                  </Link>
                  <div
                    className={`${body.sm.semibold} px-3 py-2 text-nd_gray-400 tracking-widest leading-18`}>
                    {React.string("My Modules"->String.toUpperCase)}
                  </div>
                </RenderIf>
                <div className="my-2 flex flex-col gap-2">
                  {exploredSidebars
                  ->Array.mapWithIndex((section, index) => {
                    let isExpanded = Array.includes(expandedSections, section.name)
                    <ProductTypeSectionItem
                      key={Int.toString(index)}
                      section
                      isExpanded
                      onToggle={_ => toggleSection(section.name)}
                      isSidebarExpanded
                      linkSelectionCheck
                      firstPart
                      openItem
                      setOpenItem
                      isExploredModule=true
                      allowProductToggle
                    />
                  })
                  ->React.array}
                </div>
                <RenderIf condition={unexploredSidebars->Array.length > 0}>
                  <hr className="mt-4" />
                  <div
                    className={`${body.sm.semibold} px-3 py-2 text-nd_gray-400 tracking-widest ${borderColor} leading-18`}>
                    {React.string("Other Modules"->String.toUpperCase)}
                  </div>
                  <div className="flex flex-col gap-2">
                    {unexploredSidebars
                    ->Array.mapWithIndex((section, index) => {
                      let isExpanded = Array.includes(expandedSections, section.name)
                      <ProductTypeSectionItem
                        key={Int.toString(index)}
                        section
                        isExpanded
                        onToggle={_ => toggleSection(section.name)}
                        isSidebarExpanded
                        linkSelectionCheck
                        firstPart
                        openItem
                        setOpenItem
                        isExploredModule=false
                        allowProductToggle
                      />
                    })
                    ->React.array}
                  </div>
                </RenderIf>
              </div>
            </div>
          </RenderIf>
          <div
            className={`flex items-center justify-between px-4 py-3 border-t ${borderColor} ${hoverColor}`}>
            <RenderIf condition={isSidebarExpanded}>
              <Popover className="relative inline-block text-left">
                {popoverProps => <>
                  <Popover.Button
                    className={
                      let openClasses = if popoverProps["open"] {
                        `group border rounded-lg inline-flex items-center ${body.lg.medium} hover:text-opacity-100 focus:outline-none`
                      } else {
                        `text-opacity-90 group border rounded-lg inline-flex items-center ${body.lg.medium} hover:text-opacity-100 focus:outline-none`
                      }
                      `${openClasses} border-none`
                    }>
                    {_ => <>
                      <div className="flex items-center justify-between gap-x-2">
                        <Icon name="nd-user" size=24 />
                        <div className={`flex flex-col gap-0.5 max-w-[${profileMaxWidth}]`}>
                          <div
                            className={`${body.md.medium} text-left text-nd_gray-600 dark:text-nd_gray-600 text-ellipsis overflow-hidden`}>
                            {email->React.string}
                          </div>
                          <div
                            className={`${body.md.medium} leading-18 text-left text-nd_gray-400 dark:text-nd_gray-400 text-ellipsis overflow-hidden`}>
                            {roleId->LogicUtils.snakeToTitle->React.string}
                          </div>
                        </div>
                        <div className="flex flex-row">
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
                    <Popover.Panel className={`absolute !z-30 bottom-[100%] -ml-3`}>
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
