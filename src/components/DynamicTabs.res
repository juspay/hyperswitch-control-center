type tab = {
  title: string,
  value: string,
  isRemovable: bool,
  description?: string,
}

let getValueFromArrayTab = (tabsVal: array<tab>, index: int) => {
  switch tabsVal->Array.get(index) {
  | Some(val) => val.value
  | None => ""
  }
}
type boundingClient = {x: int, right: int}
type scrollIntoViewParams = {behavior: string, block: string, inline: string}
@send external scrollIntoView: (Dom.element, scrollIntoViewParams) => unit = "scrollIntoView"
@send external getBoundingClientRect: Dom.element => boundingClient = "getBoundingClientRect"

let setTabScroll = (
  firstTabRef,
  lastTabRef,
  scrollRef,
  setIsLeftArrowVisible,
  setIsRightArrowVisible,
  getBoundingRectInfo,
) => {
  let leftVal = firstTabRef->getBoundingRectInfo(val => val.x)
  let rightVal = lastTabRef->getBoundingRectInfo(val => val.right)
  let scrollValLeft = scrollRef->getBoundingRectInfo(val => val.x)
  let scrollValRight = scrollRef->getBoundingRectInfo(val => val.right)
  let newIsLeftArrowVisible = leftVal - scrollValLeft < 0
  let newIsRightArrowVisible = rightVal - scrollValRight >= 1
  setIsLeftArrowVisible(_ => newIsLeftArrowVisible)
  setIsRightArrowVisible(_ => newIsRightArrowVisible)
}

module TabInfo = {
  @react.component
  let make = (
    ~title,
    ~isSelected,
    ~index,
    ~isRemovable,
    ~setCollapsibleTabs,
    ~selectedIndex,
    ~tabNames,
    ~handleSelectedTab: (~tabValue: string, ~collapsibleTabs: array<tab>, ~removed: bool) => unit,
    ~tabStacksnames,
    ~setTabStacksnames,
    ~description="",
  ) => {
    let fontClass = "font-inter-style"

    let defaultThemeBasedClass = `${fontClass} px-6`

    let defaultClasses = `font-semibold ${defaultThemeBasedClass} w-max flex flex-auto flex-row items-center justify-center text-body mb-1`
    let selectionClasses = if isSelected {
      "font-semibold text-black"
    } else {
      "text-jp-gray-700 dark:text-jp-gray-tabset_gray dark:text-opacity-75  hover:text-jp-gray-800 dark:hover:text-opacity-100 font-medium"
    }
    let handleClick = React.useCallback(_ => {
      handleSelectedTab(
        ~tabValue={
          switch tabNames->Array.get(index) {
          | Some(tab) => tab.value
          | None => getValueFromArrayTab(tabNames, 0)
          }
        },
        ~collapsibleTabs=tabNames,
        ~removed=false,
      )
    }, (index, handleSelectedTab))

    let bottomBorderColor = ""
    let borderClass = ""

    let lineStyle = "bg-black w-full h-0.5 rounded-full"

    let crossIcon = switch isRemovable {
    | true =>
      <svg
        onClick={ev => {
          ReactEvent.Mouse.stopPropagation(ev)
          ReactEvent.Mouse.preventDefault(ev)

          setTabStacksnames(prev => {
            let updatedStackAfterRemovingTab =
              prev->Array.copy->Array.filter(item => item !== getValueFromArrayTab(tabNames, index))
            updatedStackAfterRemovingTab->Array.filterWithIndex((item, index) =>
              index === 0
                ? true
                : item !== updatedStackAfterRemovingTab->Array.get(index - 1)->Option.getOr("")
            )
          })

          let updatedTabNames = tabNames->Array.copy->Array.filterWithIndex((_, i) => i !== index)
          setCollapsibleTabs(_ => updatedTabNames)
          if selectedIndex === index {
            // if selected index is removed then url will be updated and to the previous tab in the tabstack or else just the removal of the current tab would do
            if Array.length(tabStacksnames) >= 1 {
              handleSelectedTab(
                ~tabValue={
                  switch tabStacksnames->Array.pop {
                  | Some(tabName) => tabName
                  | None => getValueFromArrayTab(updatedTabNames, 0)
                  }
                },
                ~collapsibleTabs=updatedTabNames,
                ~removed=true,
              )
            } else {
              handleSelectedTab(
                ~tabValue=getValueFromArrayTab(updatedTabNames, 0),
                ~collapsibleTabs=updatedTabNames,
                ~removed=true,
              )
            }
          } else {
            handleSelectedTab(
              ~tabValue=getValueFromArrayTab(updatedTabNames, 0),
              ~collapsibleTabs=updatedTabNames,
              ~removed=true,
            )
          }
        }}
        style={marginLeft: "15px"}
        height="10"
        width="10"
        fill="none"
        viewBox="0 0 12 12"
        xmlns="http://www.w3.org/2000/svg">
        <path
          d="M11.8339 1.34102L10.6589 0.166016L6.00057 4.82435L1.34224 0.166016L0.167236 1.34102L4.82557 5.99935L0.167236 10.6577L1.34224 11.8327L6.00057 7.17435L10.6589 11.8327L11.8339 10.6577L7.17557 5.99935L11.8339 1.34102Z"
          fill="#7c7d82"
        />
      </svg>
    | _ => React.null
    }

    let tab =
      <div className="flex flex-col">
        <div className={`${defaultClasses} ${selectionClasses}`} onClick={handleClick}>
          {React.string(
            title
            ->String.split("+")
            ->Array.map(String.trim)
            ->Array.map(LogicUtils.snakeToTitle)
            ->Array.joinWith(" + "),
          )}
          crossIcon
        </div>
        <div />
        <RenderIf condition={isSelected}>
          <FramerMotion.Motion.Div className=lineStyle layoutId="underline" />
        </RenderIf>
        <RenderIf condition={!isSelected}>
          <div className="w-full h-0.5 rounded-full" />
        </RenderIf>
      </div>

    <div
      className={`flex flex-row cursor-pointer pt-0.5 pb-0 ${borderClass} ${bottomBorderColor} items-center h-14`}>
      {tab}
    </div>
  }
}

module IndicationArrow = {
  @react.component
  let make = (~iconName, ~side, ~refElement: React.ref<Js.nullable<Dom.element>>, ~isVisible) => {
    let isMobileView = MatchMedia.useMobileChecker()
    let onClick = {
      _ =>
        refElement.current
        ->Nullable.toOption
        ->Option.forEach(input =>
          input->(scrollIntoView(_, {behavior: "smooth", block: "nearest", inline: "nearest"}))
        )
    }
    let roundness = side == "left" ? "rounded-tr-md ml-2" : "rounded-tl-md"

    let className = {
      if isVisible {
        `mt-auto mb-1.5 ${roundness} drop-shadow-md`
      } else {
        "hidden"
      }
    }

    <RenderIf condition={isMobileView}>
      <div className>
        <Button
          buttonType=Secondary
          buttonState={isVisible ? Normal : Disabled}
          leftIcon={FontAwesome(iconName)}
          onClick
          flattenBottom=true
        />
      </div>
    </RenderIf>
  }
}

let getBoundingRectInfo = (ref: React.ref<Nullable.t<Dom.element>>, getter) => {
  ref.current->Nullable.toOption->Option.map(getBoundingClientRect)->Option.mapOr(0, getter)
}

@react.component
let make = (
  ~tabs: array<tab>,
  ~disableIndicationArrow=false,
  ~tabContainerClass="",
  ~showBorder=true,
  ~maxSelection=1,
  ~tabId="",
  ~setActiveTab: string => unit,
  ~updateUrlDict=?,
  ~initalTab: option<array<string>>=?,
  ~defaultTabs: option<array<tab>>=?,
  ~enableDescriptionHeader: bool=false,
  ~toolTipDescription="Add more tabs",
  ~updateCollapsableTabs=false,
  ~showAddMoreTabs=true,
) => {
  open LogicUtils
  let eulerBgClass = "bg-jp-gray-100 dark:bg-jp-gray-darkgray_background"
  let bgClass = eulerBgClass
  // this tabs will always loaded independent of user preference
  let isMobileView = MatchMedia.useMobileChecker()
  let defaultTabs =
    defaultTabs->Option.getOr(tabs->Array.copy->Array.filter(item => !item.isRemovable))

  let tabOuterClass = `gap-1.5`
  let bottomBorderClass = ""

  let outerAllignmentClass = ""

  let availableTabUserPrefKey = `dynamicTab_available_tab_${tabId}`
  let updateTabNameWith = switch updateUrlDict {
  | Some(fn) => fn
  | None => _ => ()
  }
  let {addConfig, getConfig} = React.useContext(UserPrefContext.userPrefContext)
  let {filterValueJson} = React.useContext(FilterContext.filterContext)
  let getTabNames = filterValueJson
  let getTitle = key => {
    (
      tabs
      ->Array.filter(item => {
        item.value == key
      })
      ->Array.get(0)
      ->Option.getOr({title: "", value: "", isRemovable: false})
    ).title
  }

  let (tabsDetails, setTabDetails) = React.useState(_ => tabs->Array.copy)

  let (selectedIndex, setSelectedIndex) = React.useState(_ => 0)

  let (initialIndex, updatedCollapsableTabs) = React.useMemo(() => {
    let defautTabValues = defaultTabs->Array.map(item => item.value)
    let collapsibleTabs = switch getConfig(availableTabUserPrefKey) {
    | Some(jsonVal) => {
        let tabsFromPreference =
          jsonVal
          ->getStrArryFromJson
          ->Array.filter(item => !(defautTabValues->Array.includes(item)))

        let tabsFromPreference =
          Array.concat(defautTabValues, tabsFromPreference)->Array.map(item =>
            item->String.split(",")
          )

        tabsFromPreference->Belt.Array.keepMap(tabName => {
          let tabName = tabName->getUniqueArray
          let validated =
            tabName
            ->Array.filter(item => !(tabs->Array.map(item => item.value)->Array.includes(item)))
            ->Array.length === 0

          let concatinatedTabNames = tabName->Array.map(getTitle)->Array.joinWith(" + ")
          if validated && tabName->Array.length <= maxSelection && tabName->Array.length > 0 {
            let newTab = {
              title: concatinatedTabNames,
              value: tabName->Array.joinWith(","),
              description: switch tabs->Array.find(
                item => {
                  item.value === tabName->Array.joinWith(",")
                },
              ) {
              | Some(tabValue) =>
                enableDescriptionHeader ? tabValue.description->Option.getOr("") : ""
              | None => ""
              },
              isRemovable: switch tabs->Array.find(
                item => {
                  item.value === tabName->Array.joinWith(",")
                },
              ) {
              | Some(tabValue) => tabValue.isRemovable
              | None => true
              },
            }

            Some(newTab)
          } else {
            None
          }
        })
      }

    | None => defaultTabs
    }
    let tabName = switch initalTab {
    | Some(value) => value
    | None =>
      getTabNames->getStrArrayFromDict("tabName", [])->Array.filter(item => item->isNonEmptyString)
    }
    let tabName = tabName->LogicUtils.getUniqueArray

    let validated =
      tabName
      ->Array.filter(item => !(tabs->Array.map(item => item.value)->Array.includes(item)))
      ->Array.length === 0

    let concatinatedTabNames = tabName->Array.map(getTitle)->Array.joinWith(" + ")

    if validated && tabName->Array.length <= maxSelection && tabName->Array.length > 0 {
      let concatinatedTabIndex =
        collapsibleTabs->Array.map(item => item.title)->Array.indexOf(concatinatedTabNames)

      if concatinatedTabIndex === -1 {
        let newTab = [
          {
            title: concatinatedTabNames,
            value: tabName->Array.joinWith(","),
            isRemovable: true,
          },
        ]
        let updatedColllapsableTab = Array.concat(collapsibleTabs, newTab)

        setTabDetails(_ => Array.concat(tabsDetails, newTab))

        (Array.length(collapsibleTabs), updatedColllapsableTab)
      } else {
        (concatinatedTabIndex, collapsibleTabs)
      }
    } else {
      setSelectedIndex(_ => 0)
      (0, collapsibleTabs)
    }
  }, [updateCollapsableTabs])

  let (collapsibleTabs, setCollapsibleTabs) = React.useState(_ => updatedCollapsableTabs)
  let (formattedOptions, setFormattedOptions) = React.useState(_ => [])

  React.useEffect(_ => {
    setSelectedIndex(_ => initialIndex)
    None
  }, [initialIndex])

  React.useEffect(_ => {
    setCollapsibleTabs(_ => updatedCollapsableTabs)
    None
  }, [updatedCollapsableTabs])

  // this will update the current available tabs to the userpreference
  React.useEffect(() => {
    let collapsibleTabsValues =
      collapsibleTabs
      ->Array.map(item => {
        item.value->JSON.Encode.string
      })
      ->JSON.Encode.array

    addConfig(availableTabUserPrefKey, collapsibleTabsValues)

    None
  }, [collapsibleTabs])
  let (tabStacksnames, setTabStacksnames) = React.useState(_ => [
    getValueFromArrayTab(updatedCollapsableTabs, 0),
    getValueFromArrayTab(updatedCollapsableTabs, initialIndex),
  ])

  let (isLeftArrowVisible, setIsLeftArrowVisible) = React.useState(() => false)
  let (isRightArrowVisible, setIsRightArrowVisible) = React.useState(() => true)

  let firstTabRef = React.useRef(Nullable.null)
  let scrollRef = React.useRef(Nullable.null)
  let lastTabRef = React.useRef(Nullable.null)

  let onScroll = _ => {
    setTabScroll(
      firstTabRef,
      lastTabRef,
      scrollRef,
      setIsLeftArrowVisible,
      setIsRightArrowVisible,
      getBoundingRectInfo,
    )
  }

  let (showModal, setShowModal) = React.useState(() => false)

  let handleSelectedTab: (
    ~tabValue: string,
    ~collapsibleTabs: array<tab>,
    ~removed: bool,
  ) => unit = (~tabValue: string, ~collapsibleTabs: array<tab>, ~removed: bool) => {
    if !removed {
      if (
        tabValue !== tabStacksnames->Array.get(tabStacksnames->Array.length - 1)->Option.getOr("")
      ) {
        setTabStacksnames(prev => {
          Array.concat(prev, [tabValue])
        })
      }
      updateTabNameWith(Dict.fromArray([("tabName", `[${tabValue}]`)]))
      setActiveTab(tabValue)
      setSelectedIndex(_ =>
        Math.Int.max(0, collapsibleTabs->Array.map(item => item.value)->Array.indexOf(tabValue))
      )
    } else {
      updateTabNameWith(
        Dict.fromArray([
          (
            "tabName",
            `[${tabStacksnames->Array.get(tabStacksnames->Array.length - 1)->Option.getOr("")}]`,
          ),
        ]),
      )
      setActiveTab(tabStacksnames->Array.get(tabStacksnames->Array.length - 1)->Option.getOr(""))

      setSelectedIndex(_ =>
        Math.Int.max(
          0,
          collapsibleTabs
          ->Array.map(item => item.value)
          ->Array.indexOf(
            tabStacksnames->Array.get(tabStacksnames->Array.length - 1)->Option.getOr(""),
          ),
        )
      )
    }
  }

  let onSubmit = values => {
    let tabName = values->Array.map(getTitle)->Array.joinWith(" + ")
    let tabValue = values->Array.joinWith(",")
    if !Array.includes(collapsibleTabs->Array.map(item => item.title), tabName) {
      let newTab = [
        {
          title: tabName,
          value: tabValue,
          isRemovable: true,
        },
      ]
      let updatedCollapsableTabs = Array.concat(collapsibleTabs, newTab)

      setCollapsibleTabs(_ => updatedCollapsableTabs)
      setTabDetails(_ => Array.concat(tabsDetails, newTab))
      setSelectedIndex(_ => Array.length(updatedCollapsableTabs) - 1)
      setTabStacksnames(prev => Array.concat(prev, [getValueFromArrayTab(newTab, 0)]))
      updateTabNameWith(Dict.fromArray([("tabName", `[${getValueFromArrayTab(newTab, 0)}]`)]))
      setActiveTab(getValueFromArrayTab(newTab, 0))

      setTimeout(_ => {
        lastTabRef.current
        ->Nullable.toOption
        ->Option.forEach(input =>
          input->(scrollIntoView(_, {behavior: "smooth", block: "nearest", inline: "start"}))
        )
      }, 200)->ignore
    } else {
      setSelectedIndex(_ => Array.indexOf(collapsibleTabs->Array.map(item => item.value), tabValue))
      updateTabNameWith(Dict.fromArray([("tabName", `[${values->Array.joinWith(",")}]`)]))
      setActiveTab(values->Array.joinWith(","))
    }
    setShowModal(_ => false)
  }

  React.useEffect(() => {
    let options =
      tabs
      ->Array.filter(tab => !(tab.value->String.split(",")->Array.length > 1))
      ->Array.map((x): SelectBox.dropdownOption => {
        switch x.description {
        | Some(description) => {
            label: x.title,
            value: x.value,
            icon: CustomRightIcon(
              description->LogicUtils.isNonEmptyString
                ? <ToolTip
                    customStyle="-mr-1.5"
                    arrowCustomStyle={isMobileView ? "" : "ml-1.5"}
                    description
                    toolTipPosition={ToolTip.BottomLeft}
                    justifyClass="ml-2 h-auto mb-0.5"
                  />
                : React.null,
            ),
          }
        | _ => {label: x.title, value: x.value}
        }
      })

    setFormattedOptions(_ => options)
    None
  }, [collapsibleTabs])

  let addBtnTextStyle = "text-md text-black !px-0 mx-0"
  let headerTextClass = None
  <div className={isMobileView ? `sticky top-0 z-15 ${bgClass}` : ""}>
    <ErrorBoundary>
      <div className="py-0 flex flex-row">
        <RenderIf condition={!isMobileView}>
          <IndicationArrow
            iconName="caret-left" side="left" refElement=firstTabRef isVisible=isLeftArrowVisible
          />
        </RenderIf>
        <div
          className={`overflow-x-auto no-scrollbar overflow-y-hidden ${outerAllignmentClass}`}
          ref={scrollRef->ReactDOM.Ref.domRef}
          onScroll>
          <div className="flex flex-row">
            <div
              className={`flex flex-row mt-5 ${tabOuterClass}
             ${tabContainerClass}`}>
              {collapsibleTabs
              ->Array.mapWithIndex((tab, i) => {
                let ref = if i == 0 {
                  firstTabRef->ReactDOM.Ref.domRef->Some
                } else {
                  setTimeout(_ => {
                    setTabScroll(
                      firstTabRef,
                      lastTabRef,
                      scrollRef,
                      setIsLeftArrowVisible,
                      setIsRightArrowVisible,
                      getBoundingRectInfo,
                    )
                  }, 200)->ignore
                  lastTabRef->ReactDOM.Ref.domRef->Some
                }
                <div ?ref key={Int.toString(i)}>
                  <TabInfo
                    title={tab.title}
                    isSelected={selectedIndex === i}
                    index={i}
                    isRemovable={tab.isRemovable}
                    setCollapsibleTabs
                    selectedIndex
                    tabNames=collapsibleTabs
                    handleSelectedTab
                    tabStacksnames
                    setTabStacksnames
                    description=?{tab.description}
                  />
                </div>
              })
              ->React.array}
            </div>
            <div className={disableIndicationArrow ? "hidden" : "block"} />
          </div>
        </div>
        <div className="flex flex-row">
          <RenderIf condition={!isMobileView}>
            <IndicationArrow
              iconName="caret-right"
              side="right"
              refElement=lastTabRef
              isVisible=isRightArrowVisible
            />
          </RenderIf>
          <RenderIf condition={showAddMoreTabs && formattedOptions->Array.length > 0}>
            <div className="flex flex-row" style={marginTop: "20px", marginLeft: "7px"}>
              <ToolTip
                description=toolTipDescription
                toolTipFor={<Button
                  text="+"
                  buttonType={Secondary}
                  buttonSize=Small
                  customButtonStyle="!w-10"
                  textStyle=addBtnTextStyle
                  onClick={_ => setShowModal(_ => true)}
                />}
                toolTipPosition=Top
                tooltipWidthClass="w-fit"
              />
            </div>
          </RenderIf>
        </div>
      </div>
      <SelectModal
        modalHeading="Add Segment"
        modalHeadingDescription={`You can select up to ${maxSelection->Int.toString} options`}
        ?headerTextClass
        showModal
        setShowModal
        onSubmit
        initialValues=[]
        options=formattedOptions
        submitButtonText="Add Segment"
        showSelectAll=false
        showDeSelectAll=true
        maxSelection
        headerClass="h-fit"
      />
      <div className=bottomBorderClass />
    </ErrorBoundary>
  </div>
}
