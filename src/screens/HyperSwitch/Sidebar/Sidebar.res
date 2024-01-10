open HeadlessUI
open SidebarTypes

let defaultLinkSelectionCheck = (firstPart, tabLink) => {
  firstPart === tabLink
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
    <button
      className={`px-4 py-3 flex text-sm w-full text-offset_white cursor-pointer bg-popover-background hover:bg-popover-background-hover`}
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
  let make = (~isExpanded, ~name, ~icon, ~isSelected) => {
    let textBoldStyles = isSelected ? "font-bold" : "font-semibold opacity-60"
    let iconColor = isSelected ? "text-white" : "text-white opacity-60"

    if isExpanded {
      <div className="flex items-center gap-5">
        <Icon size={getIconSize("small")} name=icon className=iconColor />
        <div className={`text-offset_white text-sm ${textBoldStyles} whitespace-nowrap`}>
          {React.string(name)}
        </div>
      </div>
    } else {
      <Icon size={getIconSize("small")} name=icon className=iconColor />
    }
  }
}

module SidebarSubOption = {
  @react.component
  let make = (~name, ~isSectionExpanded, ~isSelected, ~children=React.null, ~isSideBarExpanded) => {
    let subOptionClass = isSelected ? "bg-light_white" : ""
    let alignmentClasses = children == React.null ? "" : "flex flex-row items-center"

    <div
      className={`text-sm w-full ${alignmentClasses} ${isSectionExpanded
          ? "transition duration-[250ms] animate-textTransitionSideBar"
          : "transition duration-[1000ms] animate-textTransitionSideBarOff"} ${isSideBarExpanded
          ? "mx-2"
          : "mx-1"} border-l-2 border-light_grey`}>
      <div className="w-6" />
      <div
        className={`${subOptionClass} w-full pl-3 py-3 p-4.5 rounded-sm flex items-center hover:bg-light_white whitespace-nowrap my-0.5`}>
        {React.string(name)}
        {children}
      </div>
    </div>
  }
}

module SidebarItem = {
  @react.component
  let make = (~tabInfo, ~isSelected, ~isExpanded) => {
    let sidebarItemRef = React.useRef(Js.Nullable.null)
    let {getSearchParamByLink} = React.useContext(UserPrefContext.userPrefContext)
    let getSearchParamByLink = link => getSearchParamByLink(Js.String.substr(link, ~from=0))

    let selectedClass = if isSelected {
      "border-l-2 rounded-sm border-white bg-light_white"
    } else {
      `border-l-2 rounded-sm border-transparent rounded-sm hover:transition hover:duration-300 rounded-lg`
    }

    let textColor = if isSelected {
      "text-sm font-bold text-offset_white"
    } else {
      `text-sm font-semibold text-unselected_white`
    }
    let isMobileView = MatchMedia.useMobileChecker()
    let {setIsSidebarExpanded} = React.useContext(SidebarProvider.defaultContext)

    RippleEffectBackground.useHorizontalRippleHook(sidebarItemRef)

    let tabLinklement = switch tabInfo {
    | Link(tabOption) => {
        let {name, icon, link, access} = tabOption
        let redirectionLink = `${link}${getSearchParamByLink(link)}`

        <UIUtils.RenderIf condition={access !== NoAccess}>
          <Link to_=redirectionLink>
            <div
              ref={sidebarItemRef->ReactDOM.Ref.domRef}
              onClick={_ => isMobileView ? setIsSidebarExpanded(_ => false) : ()}
              className={`${textColor} relative overflow-hidden flex flex-row items-center rounded-lg cursor-pointer ${selectedClass} p-3 ${isExpanded
                  ? "mx-2"
                  : "mx-1"} hover:bg-light_white my-0.5`}>
              <SidebarOption name icon isExpanded isSelected />
            </div>
          </Link>
        </UIUtils.RenderIf>
      }

    | RemoteLink(tabOption) => {
        let {name, icon, link, access, ?remoteIcon} = tabOption
        let (remoteUi, link) = if remoteIcon->Belt.Option.getWithDefault(false) {
          (<Icon name="external-link-alt" size=14 className="ml-3" />, link)
        } else {
          (React.null, `${link}${getSearchParamByLink(link)}`)
        }
        <UIUtils.RenderIf condition={access !== NoAccess}>
          <a
            href={link}
            target="_blank"
            className={`${textColor} flex flex-row items-center cursor-pointer ${selectedClass} p-3`}>
            <SidebarOption name icon isExpanded isSelected />
            remoteUi
          </a>
        </UIUtils.RenderIf>
      }

    | LinkWithTag(tabOption) => {
        let {name, icon, iconTag, link, access, ?iconStyles, ?iconSize} = tabOption

        <UIUtils.RenderIf condition={access !== NoAccess}>
          <Link to_={`${link}${getSearchParamByLink(link)}`}>
            <div
              onClick={_ => isMobileView ? setIsSidebarExpanded(_ => false) : ()}
              className={`${textColor} flex flex-row items-center cursor-pointer transition duration-300 ${selectedClass} p-3 ${isExpanded
                  ? "mx-2"
                  : "mx-1"} hover:bg-light_white my-0.5`}>
              <SidebarOption name icon isExpanded isSelected />
              <UIUtils.RenderIf condition={isExpanded}>
                <Icon
                  size={iconSize->Belt.Option.getWithDefault(26)}
                  name=iconTag
                  className={`ml-2 ${iconStyles->Belt.Option.getWithDefault("w-26 h-26")}`}
                />
              </UIUtils.RenderIf>
            </div>
          </Link>
        </UIUtils.RenderIf>
      }

    | Heading(_) | Section(_) | CustomComponent(_) => React.null
    }

    tabLinklement
  }
}

module NestedSidebarItem = {
  @react.component
  let make = (~tabInfo, ~isSelected, ~isSideBarExpanded, ~isSectionExpanded) => {
    let {getSearchParamByLink} = React.useContext(UserPrefContext.userPrefContext)
    let getSearchParamByLink = link => getSearchParamByLink(Js.String2.substr(link, ~from=0))

    let selectedClass = if isSelected {
      "font-semibold mx-1"
    } else {
      `font-semibold mx-1 rounded-sm hover:transition hover:duration-300`
    }

    let textColor = if isSelected {
      `text-md font-small text-offset_white`
    } else {
      `text-md font-small text-unselected_white`
    }
    let {setIsSidebarExpanded} = React.useContext(SidebarProvider.defaultContext)
    let paddingClass = if isSideBarExpanded {
      "pl-4"
    } else {
      ""
    }
    let isMobileView = MatchMedia.useMobileChecker()

    let nestedSidebarItemRef = React.useRef(Js.Nullable.null)

    <UIUtils.RenderIf condition={isSideBarExpanded}>
      {switch tabInfo {
      | SubLevelLink(tabOption) => {
          let {name, link, access, ?iconTag, ?iconStyles, ?iconSize} = tabOption
          let linkTagPadding = "pl-2"

          <UIUtils.RenderIf condition={access !== NoAccess}>
            <Link to_={`${link}${getSearchParamByLink(link)}`}>
              <div
                ref={nestedSidebarItemRef->ReactDOM.Ref.domRef}
                onClick={_ => isMobileView ? setIsSidebarExpanded(_ => false) : ()}
                className={`${textColor} relative overflow-hidden flex flex-row items-center cursor-pointer rounded-lg ${paddingClass} ${selectedClass}`}>
                <SidebarSubOption name isSectionExpanded isSelected isSideBarExpanded>
                  <UIUtils.RenderIf condition={iconTag->Belt.Option.isSome && isSideBarExpanded}>
                    <div className=linkTagPadding>
                      <Icon
                        size={iconSize->Belt.Option.getWithDefault(26)}
                        name={iconTag->Belt.Option.getWithDefault("")}
                        className={iconStyles->Belt.Option.getWithDefault("w-26 h-26")}
                      />
                    </div>
                  </UIUtils.RenderIf>
                </SidebarSubOption>
              </div>
            </Link>
          </UIUtils.RenderIf>
        }
      }}
    </UIUtils.RenderIf>
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
    let iconColor = isAnySubItemSelected ? "text-white" : "text-white opacity-60"

    let iconOuterClass = if !isSideBarExpanded {
      `${isAnySubItemSelected ? "" : ""} rounded-sm p-4 rounded-lg`
    } else {
      ""
    }

    let bgColor = if isSideBarExpanded && isAnySubItemSelected && !isSectionExpanded {
      ""
    } else {
      ""
    }

    let sidebarNestedSectionRef = React.useRef(Js.Nullable.null)

    let sectionExpandedAnimation = `rounded-sm transition duration-[250ms] ease-in-out`

    <div className={`transition duration-300`}>
      <div
        ref={sidebarNestedSectionRef->ReactDOM.Ref.domRef}
        className={`${isSideBarExpanded
            ? "mx-2"
            : "mx-1"} text-sm ${textColor} ${bgColor} relative overflow-hidden flex flex-row items-center justify-between p-3 ${cursor} ${isSectionExpanded
            ? ""
            : sectionExpandedAnimation} border-l-2 ${isAnySubItemSelected
            ? "border-white"
            : "border-transparent"} hover:bg-light_white`}
        onClick=toggleSectionExpansion>
        <div className="flex flex-row items-center select-none min-w-max flex items-center gap-5">
          {if isSideBarExpanded {
            <div className=iconOuterClass>
              <Icon size={getIconSize("medium")} name={section.icon} className=iconColor />
            </div>
          } else {
            <Icon size={getIconSize("small")} name=section.icon className=iconColor />
          }}
          <UIUtils.RenderIf condition={isSideBarExpanded}>
            <div className={`font-semibold text-sm ${expandedTextColor} whitespace-nowrap`}>
              {React.string(section.name)}
            </div>
          </UIUtils.RenderIf>
        </div>
        <UIUtils.RenderIf condition={isSideBarExpanded}>
          <Icon
            name={"Nested_arrow_down"}
            className={isSectionExpanded
              ? `-rotate-180 transition duration-[250ms] mr-2 text-white opacity-60`
              : `-rotate-0 transition duration-[250ms] mr-2 text-white opacity-60`}
            size=16
          />
        </UIUtils.RenderIf>
      </div>
      <UIUtils.RenderIf condition={isElementShown}>
        {section.links
        ->Array.mapWithIndex((subLevelItem, index) => {
          let isSelected = subLevelItem->isSubLevelItemSelected
          <NestedSidebarItem
            key={string_of_int(index)}
            isSelected
            isSideBarExpanded
            isSectionExpanded
            tabInfo=subLevelItem
          />
        })
        ->React.array}
      </UIUtils.RenderIf>
    </div>
  }
}

module SidebarNestedSection = {
  @react.component
  let make = (
    ~section: sectionType,
    ~linkSelectionCheck,
    ~firstPart,
    ~isSideBarExpanded,
    ~setIsSidebarExpanded,
  ) => {
    let isSubLevelItemSelected = tabInfo => {
      switch tabInfo {
      | SubLevelLink(item) => linkSelectionCheck(firstPart, item.link)
      }
    }

    let (isSectionExpanded, setIsSectionExpanded) = React.useState(_ => false)
    let (isElementShown, setIsElementShown) = React.useState(_ => false)

    let isAnySubItemSelected = section.links->Array.find(isSubLevelItemSelected)->Js.Option.isSome

    React.useEffect2(() => {
      if isSectionExpanded {
        setIsElementShown(_ => true)
      } else if isElementShown {
        let _ = Js.Global.setTimeout(() => {
          setIsElementShown(_ => false)
        }, 200)
      }
      None
    }, (isSectionExpanded, isSideBarExpanded))

    React.useEffect2(() => {
      if isSideBarExpanded {
        setIsSectionExpanded(_ => isAnySubItemSelected)
      } else {
        setIsSectionExpanded(_ => false)
      }
      None
    }, (isSideBarExpanded, isAnySubItemSelected))

    let toggleSectionExpansion = React.useCallback4(_ev => {
      if !isSideBarExpanded {
        setIsSidebarExpanded(_ => true)
        Js.Global.setTimeout(() => {
          setIsSectionExpanded(_ => true)
        }, 200)->ignore
      } else if isAnySubItemSelected {
        setIsSectionExpanded(_ => true)
      } else {
        setIsSectionExpanded(p => !p)
      }
    }, (setIsSectionExpanded, isSideBarExpanded, setIsSidebarExpanded, isAnySubItemSelected))

    let textColor = {
      if isSideBarExpanded {
        if isAnySubItemSelected {
          "text-gray-900"
        } else {
          "text-unselected_white"
        }
      } else if isAnySubItemSelected {
        "text-white"
      } else {
        "text-unselected_white"
      }
    }

    let cursor = if isAnySubItemSelected && isSideBarExpanded {
      `cursor-default rounded-lg rounded-sm`
    } else {
      `cursor-pointer rounded-lg rounded-sm`
    }
    let expandedTextColor = isAnySubItemSelected ? "text-white" : "!text-offset_white !opacity-60"
    let areAllSubLevelsHidden = section.links->Array.reduce(true, (acc, subLevelItem) => {
      acc &&
      switch subLevelItem {
      | SubLevelLink({access}) => access === NoAccess
      }
    })
    <UIUtils.RenderIf condition={!areAllSubLevelsHidden}>
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
    </UIUtils.RenderIf>
  }
}

module PinIconComponentStates = {
  @react.component
  let make = (~isHSSidebarPinned, ~setIsSidebarExpanded, ~isSidebarExpanded) => {
    let isMobileView = MatchMedia.useMobileChecker()
    let {setIsSidebarDetails} = React.useContext(SidebarProvider.defaultContext)

    let toggleExpand = React.useCallback0(_ => {
      setIsSidebarExpanded(x => !x)
    })

    let onClick = ev => {
      ev->ReactEvent.Mouse.preventDefault
      ev->ReactEvent.Mouse.stopPropagation
      ev->toggleExpand
      setIsSidebarDetails("isPinned", !isHSSidebarPinned->Js.Json.boolean)
    }

    <>
      <UIUtils.RenderIf condition={isSidebarExpanded && !isHSSidebarPinned && !isMobileView}>
        <Icon size=35 name="sidebar-pin-default" onClick className="cursor-pointer" />
      </UIUtils.RenderIf>
      <UIUtils.RenderIf condition={isHSSidebarPinned && !isMobileView}>
        <Icon size=35 name="sidebar-pin-pinned" onClick className="cursor-pointer" />
      </UIUtils.RenderIf>
      <UIUtils.RenderIf condition={isMobileView}>
        <div className="flex align-center mt-4 pl-3 mb-6 pr-4 ml-1 gap-5 cursor-default">
          <Icon
            className="mr-1"
            size=20
            name="collapse-cross"
            customIconColor="#FEFEFE"
            onClick={_ => setIsSidebarExpanded(_ => false)}
          />
        </div>
      </UIUtils.RenderIf>
    </>
  }
}

@react.component
let make = (
  ~sidebars: Js.Array2.t<topLevelItem>,
  ~path,
  ~linkSelectionCheck=defaultLinkSelectionCheck,
  ~verticalOffset="120px",
) => {
  let fetchApi = AuthHooks.useApiFetcher()
  let isMobileView = MatchMedia.useMobileChecker()
  let sideBarRef = React.useRef(Js.Nullable.null)
  let email = HSLocalStorage.getFromMerchantDetails("email")
  let (_authStatus, setAuthStatus) = React.useContext(AuthInfoProvider.authStatusContext)
  let {getFromSidebarDetails} = React.useContext(SidebarProvider.defaultContext)
  let {isSidebarExpanded, setIsSidebarExpanded} = React.useContext(SidebarProvider.defaultContext)
  let {setIsSidebarDetails} = React.useContext(SidebarProvider.defaultContext)
  let minWidthForPinnedState = MatchMedia.useMatchMedia("(min-width: 1280px)")

  React.useEffect1(() => {
    if minWidthForPinnedState {
      setIsSidebarDetails("isPinned", true->Js.Json.boolean)
      setIsSidebarExpanded(_ => true)
    } else {
      setIsSidebarDetails("isPinned", false->Js.Json.boolean)
      setIsSidebarExpanded(_ => false)
    }

    None
  }, [minWidthForPinnedState])

  let isHSSidebarPinned = getFromSidebarDetails("isPinned")
  let isExpanded = isSidebarExpanded || isHSSidebarPinned

  let sidebarWidth = isExpanded ? isMobileView ? "100%" : "270px" : "55px"
  let profileMaxWidth = "145px"

  let firstPart = switch Belt.List.head(path) {
  | Some(x) => `/${x}`
  | None => "/"
  }

  let expansionClass = !isExpanded ? "-translate-x-full" : ""

  let sidebarClass = "shadow-md"
  let sidebarMaxWidth = isMobileView ? "w-screen" : "w-max"

  let onMouseHoverEvent = () => {
    if !isHSSidebarPinned {
      setIsSidebarExpanded(_ => true)
    } else {
      ()
    }
  }

  let onMouseHoverLeaveEvent = () => {
    if !isHSSidebarPinned {
      setIsSidebarExpanded(_ => false)
    } else {
      ()
    }
  }
  let sidebarContainerClassWidth = isMobileView ? "0px" : isHSSidebarPinned ? "270px" : "50px"

  let transformClass = "transform md:translate-x-0 transition"

  let handleLogout = _ => {
    let _ = APIUtils.handleLogout(~fetchApi, ~setAuthStatus, ~setIsSidebarExpanded)
  }

  <div className={`bg-sidebar-blue flex group border-r border-jp-gray-500 relative`}>
    <div
      ref={sideBarRef->ReactDOM.Ref.domRef}
      className={`flex h-full flex-col transition-all duration-100 ${sidebarClass} relative inset-0`}
      style={ReactDOMStyle.make(~width=sidebarContainerClassWidth, ())}
    />
    <div
      className={`absolute z-40 h-screen flex ${transformClass} duration-300 ease-in-out ${sidebarMaxWidth} ${expansionClass}`}
      onMouseOver={_ => onMouseHoverEvent()}
      onMouseLeave={_ => onMouseHoverLeaveEvent()}>
      <div
        ref={sideBarRef->ReactDOM.Ref.domRef}
        className={`bg-sidebar-blue flex h-full flex-col transition-all duration-100 ${sidebarClass} relative inset-0`}
        style={ReactDOMStyle.make(~width=sidebarWidth, ())}>
        <div className="flex items-center justify-between p-1 mr-2">
          <div
            className={`flex align-center mt-4 pl-3 mb-6 pr-4 ml-1 gap-5 cursor-default`}
            onClick={ev => {
              ev->ReactEvent.Mouse.preventDefault
              ev->ReactEvent.Mouse.stopPropagation
            }}>
            <Icon size=20 name="hamburger-new" />
          </div>
          <PinIconComponentStates isHSSidebarPinned setIsSidebarExpanded isSidebarExpanded />
        </div>
        <div
          className="h-full overflow-y-scroll transition-transform duration-1000 overflow-x-hidden show-scrollbar"
          style={ReactDOMStyle.make(~height=`calc(100vh - ${verticalOffset})`, ())}>
          {sidebars
          ->Array.mapWithIndex((tabInfo, index) => {
            switch tabInfo {
            | RemoteLink(record)
            | Link(record) => {
                let isSelected = linkSelectionCheck(firstPart, record.link)
                <SidebarItem
                  key={string_of_int(index)} tabInfo isSelected isExpanded={isExpanded}
                />
              }

            | LinkWithTag(record) => {
                let isSelected = linkSelectionCheck(firstPart, record.link)
                <SidebarItem
                  key={string_of_int(index)} tabInfo isSelected isExpanded={isExpanded}
                />
              }

            | Section(section) =>
              <UIUtils.RenderIf condition={section.showSection} key={string_of_int(index)}>
                <SidebarNestedSection
                  key={string_of_int(index)}
                  section
                  linkSelectionCheck
                  firstPart
                  isSideBarExpanded={isExpanded}
                  setIsSidebarExpanded
                />
              </UIUtils.RenderIf>
            | Heading(headingOptions) =>
              <div
                key={string_of_int(index)}
                className={`text-xs font-semibold leading-5 text-[#5B6376] overflow-hidden border-l-2 rounded-sm border-transparent px-3 ${isExpanded
                    ? "mx-2"
                    : "mx-1"} mt-5 mb-3`}>
                {{isExpanded ? headingOptions.name : ""}->React.string}
              </div>

            | CustomComponent(customComponentOptions) =>
              <UIUtils.RenderIf condition={isExpanded} key={string_of_int(index)}>
                customComponentOptions.component
              </UIUtils.RenderIf>
            }
          })
          ->React.array}
        </div>
        <div className="flex items-center justify-between mb-5 mt-2 mx-2 mr-2 hover:bg-[#334264]">
          <UIUtils.RenderIf condition={isExpanded}>
            <Popover className="relative inline-block text-left">
              {popoverProps => <>
                <Popover.Button
                  className={
                    let openClasses = if popoverProps["open"] {
                      `group pl-3 border py-2 rounded-md inline-flex items-center text-base font-medium hover:text-opacity-100 focus:outline-none`
                    } else {
                      `text-opacity-90 group pl-3 border py-2 rounded-md inline-flex items-center text-base font-medium hover:text-opacity-100 focus:outline-none`
                    }
                    `${openClasses} border-none`
                  }>
                  {buttonProps => <>
                    <div className="flex items-center">
                      <div
                        className="inline-block text-offset_white bg-profile-sidebar-blue text-center w-10 h-10 leading-10 rounded-full mr-4">
                        {email->String.charAt(0)->String.toUpperCase->React.string}
                      </div>
                      <ToolTip
                        description=email
                        toolTipFor={<UIUtils.RenderIf condition={isExpanded}>
                          <div
                            className={`w-[${profileMaxWidth}] text-sm font-medium text-gray-400 dark:text-gray-600 text-ellipsis overflow-hidden`}>
                            {email->React.string}
                          </div>
                        </UIUtils.RenderIf>}
                        toolTipPosition=ToolTip.Top
                        tooltipWidthClass="!w-fit !z-50"
                      />
                    </div>
                    <div
                      className={`flex flex-row border-transparent dark:border-transparent rounded-2xl p-2 border-2`}>
                      <Icon name="dropdown-menu" className="cursor-pointer" />
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
                  <Popover.Panel className={`absolute !z-30 bottom-[100%] right-2`}>
                    {panelProps => {
                      <div
                        id="neglectTopbarTheme"
                        className="relative flex flex-col py-3 rounded-lg shadow-lg ring-1 ring-black ring-opacity-5 w-60 bg-popover-background">
                        <MenuOption
                          onClick={_ => {
                            RescriptReactRouter.replace(
                              `${HSwitchGlobalVars.hyperSwitchFEPrefix}/account-settings/profile`,
                            )
                          }}
                          text="Profile"
                        />
                        <MenuOption onClick={handleLogout} text="Sign out" />
                      </div>
                    }}
                  </Popover.Panel>
                </Transition>
              </>}
            </Popover>
          </UIUtils.RenderIf>
        </div>
      </div>
    </div>
  </div>
}
