type retType = CheckBox(array<string>) | Radiobox(string)

external toDict: 'a => Dict.t<'t> = "%identity"
@send external getClientRects: Dom.element => Dom.domRect = "getClientRects"
@send external focus: Dom.element => unit = "focus"

external ffInputToSelectInput: ReactFinalForm.fieldRenderPropsInput => ReactFinalForm.fieldRenderPropsCustomInput<
  array<string>,
> = "%identity"

external ffInputToRadioInput: ReactFinalForm.fieldRenderPropsInput => ReactFinalForm.fieldRenderPropsCustomInput<
  string,
> = "%identity"

let regex = (a, searchString) => {
  let searchStringNew =
    searchString
    ->String.replaceRegExp(%re("/[<>\[\]';|?*\\]/g"), "")
    ->String.replaceRegExp(%re("/\(/g"), "\\(")
    ->String.replaceRegExp(%re("/\+/g"), "\\+")
    ->String.replaceRegExp(%re("/\)/g"), "\\)")
    ->String.replaceRegExp(%re("/\./g"), "")
  RegExp.fromStringWithFlags("(.*)(" ++ a ++ "" ++ searchStringNew ++ ")(.*)", ~flags="i")
}

module ListItem = {
  @react.component
  let make = (
    ~isDropDown,
    ~searchString,
    ~multiSelect,
    ~optionSize: CheckBoxIcon.size=Small,
    ~isSelectedStateMinus=false,
    ~isSelected,
    ~isPrevSelected=false,
    ~isNextSelected=false,
    ~onClick,
    ~text,
    ~fill="#0EB025",
    ~labelValue="",
    ~isDisabled=false,
    ~icon: Button.iconType,
    ~leftVacennt=false,
    ~showToggle=false,
    ~customStyle="",
    ~serialNumber=None,
    ~isMobileView=false,
    ~description=None,
    ~customLabelStyle=None,
    ~customMarginStyle="mx-3 py-2 gap-2",
    ~listFlexDirection="",
    ~customSelectStyle="",
    ~textOverflowClass=?,
    ~dataId,
    ~showDescriptionAsTool=true,
    ~optionClass="",
    ~selectClass="",
    ~toggleProps="",
    ~checkboxDimension="",
    ~iconStroke="",
    ~showToolTipOptions=false,
    ~textEllipsisForDropDownOptions=false,
    ~textColorClass="",
    ~customRowClass="",
  ) => {
    let {globalUIConfig: {font}} = React.useContext(ThemeProvider.themeContext)
    let labelText = switch labelValue->String.length {
    | 0 => text
    | _ => labelValue
    }
    let (toggleSelect, setToggleSelect) = React.useState(() => isSelected)
    let listText =
      searchString->LogicUtils.isEmptyString
        ? [text]
        : {
            switch Js.String2.match_(text, regex("\\b", searchString)) {
            | Some(r) => r->Array.sliceToEnd(~start=1)->Belt.Array.keepMap(x => x)
            | None =>
              switch Js.String2.match_(text, regex("_", searchString)) {
              | Some(a) => a->Array.sliceToEnd(~start=1)->Belt.Array.keepMap(x => x)
              | None => [text]
              }
            }
          }

    let bgClass = "md:bg-jp-gray-100 md:dark:bg-jp-gray-text_darktheme md:dark:bg-opacity-3 dark:hover:text-white dark:text-white"

    let hoverClass = "hover:bg-jp-gray-100 dark:hover:bg-jp-gray-text_darktheme dark:hover:bg-opacity-10 dark:hover:text-white dark:text-white"

    let customMarginStyle = if isMobileView {
      "py-2 gap-2"
    } else if !isDropDown {
      "mr-3 py-2 gap-2"
    } else {
      customMarginStyle
    }
    let backgroundClass = if showToggle {
      ""
    } else if isSelected && customStyle->LogicUtils.isNonEmptyString {
      customSelectStyle
    } else if isDropDown && isSelected && !isDisabled {
      `${bgClass} transition ease-[cubic-bezier(0.33, 1, 0.68, 1)]`
    } else {
      hoverClass
    }

    let justifyClass = if isDropDown {
      "justify-between"
    } else {
      ""
    }
    let selectedClass = if isSelected {
      "text-opacity-100 dark:text-opacity-100"
    } else if isDisabled {
      "text-opacity-50 dark:text-opacity-50"
    } else {
      "text-opacity-75 dark:text-opacity-75"
    }
    let leftElementClass = if leftVacennt {
      "px-4 "
    } else {
      ""
    }

    let labelStyle = customLabelStyle->Option.isSome ? customLabelStyle->Option.getOr("") : ""

    let onToggleSelect = val => {
      if !isDisabled {
        setToggleSelect(_ => val)
      }
    }
    React.useEffect(() => {
      setToggleSelect(_ => isSelected)
      None
    }, [isSelected])
    let cursorClass = if showToggle || !isDropDown {
      ""
    } else if isDisabled {
      "cursor-not-allowed"
    } else {
      "cursor-pointer"
    }
    let paddingClass = showToggle ? "pr-6 mr-4" : "pr-2"
    let onClickTemp = if showToggle {
      _ => ()
    } else {
      onClick
    }
    let parentRef = React.useRef(Nullable.null)

    let textColor = "text-jp-gray-900 dark:text-jp-gray-text_darktheme"

    let textColor = if textColorClass->LogicUtils.isNonEmptyString {
      textColorClass
    } else {
      textColor
    }

    let itemRoundedClass = ""
    let toggleClass = if showToggle {
      ""
    } else if multiSelect {
      "pr-2"
    } else {
      "pl-2"
    }
    let textGap = ""

    let selectedNoBadgeColor = "bg-blue-500"
    let optionIconStroke = ""

    let optionTextSize = !isDropDown && optionSize === Large ? "text-fs-16" : "text-base"
    let searchMatchTextColor = `dark:${font.textColor.primaryNormal} ${font.textColor.primaryNormal}`
    let optionDescPadding = if optionSize === Small {
      showToggle ? "pl-12" : "pl-7"
    } else if showToggle {
      "pl-15"
    } else {
      "pl-9"
    }

    let overFlowTextCustomClass = switch textOverflowClass {
    | Some(val) => val
    | None => "overflow-hidden"
    }

    let customCss =
      listFlexDirection->LogicUtils.isEmptyString ? `flex-row ${paddingClass}` : listFlexDirection
    RippleEffectBackground.useLinearRippleHook(parentRef, isDropDown)
    let comp =
      <AddDataAttributes
        attributes=[
          ("data-dropdown-numeric", (dataId + 1)->Int.toString),
          ("data-dropdown-value", labelText),
          ("data-dropdown-value-selected", {isSelected} ? "True" : "False"),
        ]>
        <div
          ref={parentRef->ReactDOM.Ref.domRef}
          onClick=onClickTemp
          className={`flex  relative mx-2 md:mx-0 my-3 md:my-0 pr-2 md:pr-0 md:w-full items-center font-medium  ${overFlowTextCustomClass} ${itemRoundedClass} ${textColor} ${justifyClass} ${cursorClass} ${backgroundClass} ${selectedClass} ${customStyle}  ${customCss} ${customRowClass}`}>
          {if !isDropDown {
            if showToggle {
              <div className={toggleClass ++ toggleProps} onClick>
                <BoolInput.BaseComponent
                  isSelected=toggleSelect size=optionSize setIsSelected=onToggleSelect isDisabled
                />
              </div>
            } else if multiSelect {
              <span className=toggleClass>
                {checkboxDimension->LogicUtils.isNonEmptyString
                  ? <CheckBoxIcon
                      isSelected isDisabled size=optionSize isSelectedStateMinus checkboxDimension
                    />
                  : <CheckBoxIcon isSelected isDisabled size=optionSize isSelectedStateMinus />}
              </span>
            } else {
              <div className=toggleClass>
                <RadioIcon isSelected size=optionSize fill isDisabled />
              </div>
            }
          } else if multiSelect && !isMobileView {
            <span className="pl-3">
              <CheckBoxIcon isSelected isDisabled isSelectedStateMinus />
            </span>
          } else {
            React.null
          }}
          <div
            className={`flex flex-row group ${optionTextSize} w-full text-left items-center ${customMarginStyle} overflow-hidden`}>
            <div
              className={`${leftElementClass} ${textGap} flex w-full overflow-x-auto whitespace-pre ${labelStyle}`}>
              {switch icon {
              | FontAwesome(iconName) =>
                <Icon
                  className={`align-middle ${iconStroke->LogicUtils.isEmptyString
                      ? optionIconStroke
                      : iconStroke} `}
                  size={20}
                  name=iconName
                />
              | CustomIcon(ele) => ele
              | Euler(iconName) =>
                <Icon className={`align-middle ${optionIconStroke}`} size={12} name=iconName />
              | _ => React.null
              }}
              <div className="w-full">
                {listText
                ->Array.filter(str => str->LogicUtils.isNonEmptyString)
                ->Array.mapWithIndex((item, i) => {
                  if (
                    (String.toLowerCase(item) == String.toLowerCase(searchString) ||
                      String.toLowerCase(item) == String.toLowerCase("_" ++ searchString)) &&
                      String.length(searchString) > 0
                  ) {
                    <AddDataAttributes
                      key={i->Int.toString} attributes=[("data-searched-text", item)]>
                      <mark
                        key={i->Int.toString} className={`${searchMatchTextColor} bg-transparent`}>
                        {item->React.string}
                      </mark>
                    </AddDataAttributes>
                  } else {
                    let className = isSelected ? `${selectClass}` : `${optionClass}`

                    let textClass = if textEllipsisForDropDownOptions {
                      `${className} text-ellipsis overflow-hidden `
                    } else {
                      className
                    }

                    let selectOptions =
                      <AddDataAttributes
                        attributes=[("data-text", labelText)] key={i->Int.toString}>
                        <span key={i->Int.toString} className=textClass value=labelText>
                          {item->React.string}
                        </span>
                      </AddDataAttributes>

                    {
                      if showToolTipOptions {
                        <ToolTip
                          key={i->Int.toString}
                          description=item
                          toolTipFor=selectOptions
                          contentAlign=Default
                          justifyClass="justify-start"
                        />
                      } else {
                        selectOptions
                      }
                    }
                  }
                })
                ->React.array}
              </div>
            </div>
            {switch icon {
            | CustomRightIcon(ele) => ele
            | _ => React.null
            }}
          </div>
          {if isMobileView && isDropDown {
            if multiSelect {
              <CheckBoxIcon isSelected />
            } else {
              <RadioIcon isSelected isDisabled />
            }
          } else if isDropDown {
            <div className="mr-2">
              <Tick isSelected />
            </div>
          } else {
            React.null
          }}
          {switch serialNumber {
          | Some(sn) =>
            <AddDataAttributes attributes=[("data-badge-value", sn)]>
              <div
                className={`mr-2 py-0.5 px-2 ${selectedNoBadgeColor} text-white font-semibold rounded-full`}>
                {React.string(sn)}
              </div>
            </AddDataAttributes>
          | None => React.null
          }}
        </div>
      </AddDataAttributes>
    <>
      {switch description {
      | Some(str) =>
        if isDropDown {
          showDescriptionAsTool
            ? {
                <ToolTip
                  description={str}
                  toolTipFor=comp
                  contentAlign=Default
                  justifyClass="justify-start"
                />
              }
            : {
                <div>
                  comp
                  <div> {React.string(str)} </div>
                </div>
              }
        } else {
          <>
            comp
            <div
              className={`text-jp-2-light-gray-1100 font-normal -mt-2 ${optionDescPadding} ${optionTextSize}`}>
              {str->React.string}
            </div>
          </>
        }

      | None => comp
      }}
    </>
  }
}

type dropdownOptionWithoutOptional = {
  label: string,
  value: string,
  isDisabled: bool,
  icon: Button.iconType,
  description: option<string>,
  iconStroke: string,
  textColor: string,
  optGroup: string,
  customRowClass: string,
}
type dropdownOption = {
  label: string,
  value: string,
  optGroup?: string,
  isDisabled?: bool,
  icon?: Button.iconType,
  description?: string,
  iconStroke?: string,
  textColor?: string,
  customRowClass?: string,
}

let makeNonOptional = (dropdownOption: dropdownOption): dropdownOptionWithoutOptional => {
  {
    label: dropdownOption.label,
    value: dropdownOption.value,
    isDisabled: dropdownOption.isDisabled->Option.getOr(false),
    icon: dropdownOption.icon->Option.getOr(NoIcon),
    description: dropdownOption.description,
    iconStroke: dropdownOption.iconStroke->Option.getOr(""),
    textColor: dropdownOption.textColor->Option.getOr(""),
    optGroup: dropdownOption.optGroup->Option.getOr("-"),
    customRowClass: dropdownOption.customRowClass->Option.getOr(""),
  }
}

let useTransformed = options => {
  React.useMemo(() => {
    options->Array.map(makeNonOptional)
  }, [options])
}

type allSelectType = Icon | Text

type opt = {name_: string}

let makeOptions = (options: array<string>): array<dropdownOption> => {
  options->Array.map(str => {label: str, value: str})
}

module BaseSelect = {
  @react.component
  let make = (
    ~showSelectAll=true,
    ~showDropDown=false,
    ~isDropDown=true,
    ~options: array<dropdownOption>,
    ~optionSize: CheckBoxIcon.size=Small,
    ~isSelectedStateMinus=false,
    ~onSelect: array<string> => unit,
    ~value as values: JSON.t,
    ~onBlur=?,
    ~showClearAll=true,
    ~isHorizontal=false,
    ~insertselectBtnRef=?,
    ~insertclearBtnRef=?,
    ~customLabelStyle=?,
    ~showToggle=false,
    ~showSerialNumber=false,
    ~heading="Some heading",
    ~showSelectionAsChips=true,
    ~maxHeight="md:max-h-72",
    ~searchable=?,
    ~optionRigthElement=?,
    ~searchInputPlaceHolder="",
    ~showSearchIcon=true,
    ~customStyle="",
    ~customMargin="",
    ~disableSelect=false,
    ~deselectDisable=?,
    ~hideBorder=false,
    ~allSelectType=Icon,
    ~isMobileView=false,
    ~isModalView=false,
    ~customSearchStyle="bg-jp-gray-100 dark:bg-jp-gray-950 p-2",
    ~hasApplyButton=false,
    ~setShowDropDown=?,
    ~dropdownCustomWidth="w-full md:max-w-md min-w-[10rem]",
    ~sortingBasedOnDisabled=true,
    ~customMarginStyle="mx-3 py-2 gap-2",
    ~listFlexDirection="",
    ~onApply=?,
    ~showAllSelectedOptions=true,
    ~showDescriptionAsTool=true,
    ~optionClass="",
    ~selectClass="",
    ~toggleProps="",
    ~showSelectCountButton=false,
    ~customSelectAllStyle="",
    ~checkboxDimension="",
    ~dropdownClassName="",
    ~onItemSelect=(_, _) => (),
    ~wrapBasis="",
    ~preservedAppliedOptions=[],
  ) => {
    let {globalUIConfig: {font}} = React.useContext(ThemeProvider.themeContext)
    let (searchString, setSearchString) = React.useState(() => "")
    let maxHeight = if maxHeight->String.includes("72") {
      "md:max-h-66.5"
    } else {
      maxHeight
    }

    let saneValue = React.useMemo(() =>
      switch values->JSON.Decode.array {
      | Some(jsonArr) => jsonArr->LogicUtils.getStrArrayFromJsonArray
      | _ => []
      }
    , [values])

    let initialSelectedOptions = React.useMemo(() => {
      options->Array.filter(item => saneValue->Array.includes(item.value))
    }, [])

    options->Array.sort((item1, item2) => {
      let item1Index = initialSelectedOptions->Array.findIndex(item => item.label === item1.label)
      let item2Index = initialSelectedOptions->Array.findIndex(item => item.label === item2.label)

      item1Index <= item2Index ? 1. : -1.
    })

    let transformedOptions = useTransformed(options)

    let (filteredOptions, setFilteredOptions) = React.useState(() => transformedOptions)
    React.useEffect(() => {
      setFilteredOptions(_ => transformedOptions)
      None
    }, [transformedOptions])
    React.useEffect(() => {
      let shouldDisplay = (option: dropdownOption) => {
        switch Js.String2.match_(option.label, regex("\\b", searchString)) {
        | Some(_) => true
        | None =>
          switch Js.String2.match_(option.label, regex("_", searchString)) {
          | Some(_) => true
          | None => false
          }
        }
      }
      let filterOptions = options->Array.filter(shouldDisplay)->Array.map(makeNonOptional)

      setFilteredOptions(_ => filterOptions)
      None
    }, [searchString])

    let onItemClick = (itemDataValue, isDisabled) => e => {
      if !isDisabled {
        let data = if Array.includes(saneValue, itemDataValue) {
          let values =
            deselectDisable->Option.getOr(false)
              ? saneValue
              : saneValue->Array.filter(x => x !== itemDataValue)
          onItemSelect(e, itemDataValue)->ignore
          values
        } else {
          Array.concat(saneValue, [itemDataValue])
        }
        onSelect(data)
        switch onBlur {
        | Some(fn) =>
          "blur"->Webapi.Dom.FocusEvent.make->Identity.webAPIFocusEventToReactEventFocus->fn
        | None => ()
        }
      }
    }

    let handleSearch = str => {
      setSearchString(_ => str)
    }

    let selectAll = select => _ => {
      let newValues = if select {
        let newVal =
          filteredOptions
          ->Array.filter(x => !x.isDisabled && !(saneValue->Array.includes(x.value)))
          ->Array.map(x => x.value)
        Array.concat(saneValue, newVal)
      } else {
        []
      }

      onSelect(newValues)
      switch onBlur {
      | Some(fn) =>
        "blur"->Webapi.Dom.FocusEvent.make->Identity.webAPIFocusEventToReactEventFocus->fn
      | None => ()
      }
    }

    let borderClass = if !hideBorder {
      if isDropDown {
        "bg-white border dark:bg-jp-gray-lightgray_background border-jp-gray-lightmode_steelgray border-opacity-75 dark:border-jp-gray-960 rounded  shadow-generic_shadow dark:shadow-generic_shadow_dark animate-textTransition transition duration-400"
      } else if showToggle {
        "bg-white border rounded dark:bg-jp-gray-darkgray_background border-jp-gray-lightmode_steelgray border-opacity-75 dark:border-jp-gray-960 rounded  "
      } else {
        ""
      }
    } else {
      ""
    }

    let minWidth = isDropDown ? "min-w-65" : ""
    let widthClass = if showToggle {
      ""
    } else if isMobileView {
      "w-full"
    } else {
      `${minWidth} ${dropdownCustomWidth}`
    }
    let textIconPresent = options->Array.some(op => op.icon->Option.getOr(NoIcon) !== NoIcon)

    let _ = if sortingBasedOnDisabled {
      options->Array.toSorted((m1, m2) => {
        let m1Disabled = m1.isDisabled->Option.getOr(false)
        let m2Disabled = m2.isDisabled->Option.getOr(false)
        if m1Disabled === m2Disabled {
          0.
        } else if m1Disabled {
          1.
        } else {
          -1.
        }
      })
    } else {
      options
    }

    let noOfSelected = saneValue->Array.length
    let applyBtnDisabled =
      noOfSelected === preservedAppliedOptions->Array.length &&
        saneValue->Array.reduce(true, (acc, val) => {
          preservedAppliedOptions->Array.includes(val) && acc
        })

    let searchRef = React.useRef(Nullable.null)
    let selectBtnRef = insertselectBtnRef->Option.map(ReactDOM.Ref.callbackDomRef)
    let clearBtnRef = insertclearBtnRef->Option.map(ReactDOM.Ref.callbackDomRef)
    let (isChooseAllToggleSelected, setChooseAllToggleSelected) = React.useState(() => false)
    let gapClass = switch optionRigthElement {
    | Some(_) => "flex gap-4"
    | None => ""
    }
    let onClick = ev => {
      switch setShowDropDown {
      | Some(fn) => fn(_ => false)
      | None => ()
      }
      switch onApply {
      | Some(fn) => fn(ev)
      | None => ()
      }
    }

    React.useEffect(() => {
      searchRef.current->Nullable.toOption->Option.forEach(input => input->focus)
      None
    }, (searchRef.current, showDropDown))

    let listPadding = ""

    React.useEffect(() => {
      if noOfSelected === options->Array.length {
        setChooseAllToggleSelected(_ => true)
      } else {
        setChooseAllToggleSelected(_ => false)
      }
      None
    }, (noOfSelected, options))
    let toggleSelectAll = val => {
      if !disableSelect {
        selectAll(val)("")

        setChooseAllToggleSelected(_ => val)
      }
    }
    let disabledClass = disableSelect ? "cursor-not-allowed" : ""

    let marginClass = if customMargin->LogicUtils.isEmptyString {
      "mt-4"
    } else {
      customMargin
    }
    let dropdownAnimation = showDropDown
      ? "animate-textTransition transition duration-400"
      : "animate-textTransitionOff transition duration-400"
    let searchInputUI =
      <div className={`${customSearchStyle} pb-0`}>
        <div className="pb-2 z-50">
          <SearchInput
            inputText=searchString
            searchRef
            onChange=handleSearch
            placeholder={searchInputPlaceHolder->LogicUtils.isEmptyString
              ? "Search..."
              : searchInputPlaceHolder}
            showSearchIcon
          />
        </div>
      </div>
    let animationClass = isModalView ? `` : dropdownAnimation
    let outerClass = if isModalView {
      "h-full"
    } else if isDropDown {
      "overflow-auto"
    } else {
      ""
    }

    <div
      id="neglectTopbarTheme"
      className={`${widthClass} ${outerClass} ${borderClass} ${animationClass} ${dropdownClassName}`}>
      {switch searchable {
      | Some(val) =>
        if val {
          searchInputUI
        } else {
          React.null
        }
      | None =>
        if isDropDown && options->Array.length > 5 {
          searchInputUI
        } else {
          React.null
        }
      }}
      {if showSelectAll && isDropDown {
        if !isMobileView {
          <div
            className={`${customSearchStyle} border-b border-jp-gray-lightmode_steelgray border-opacity-75 dark:border-jp-gray-960 z-index: 50`}>
            <div className="flex flex-row justify-between">
              <div ref=?selectBtnRef onClick={selectAll(true)}>
                <Button
                  text="SELECT ALL"
                  buttonType=NonFilled
                  buttonSize=Small
                  customButtonStyle="w-32 text-fs-11 mx-1"
                  buttonState={noOfSelected !== options->Array.length ? Normal : Disabled}
                />
              </div>
              <div ref=?clearBtnRef onClick={selectAll(false)}>
                <Button
                  text="CLEAR ALL"
                  buttonType=NonFilled
                  buttonSize=Small
                  customButtonStyle="w-32 text-fs-11 mx-1"
                  buttonState={noOfSelected !== 0 && showClearAll ? Normal : Disabled}
                />
              </div>
            </div>
            {if (
              noOfSelected !== options->Array.length && noOfSelected !== 0 && showSelectionAsChips
            ) {
              <div className="text-sm text-gray-500 text-start mt-1 ml-1.5 font-bold">
                {React.string(
                  `${noOfSelected->Int.toString} items selected out of ${options
                    ->Array.length
                    ->Int.toString} options`,
                )}
              </div>
            } else {
              React.null
            }}
          </div>
        } else if !isMobileView {
          let clearAllCondition = noOfSelected > 0
          <RenderIf
            condition={filteredOptions->Array.length > 1 &&
              filteredOptions->Array.find(item => item.value === "Loading...")->Option.isNone}>
            <div
              onClick={selectAll(noOfSelected === 0)}
              className={`flex px-3 pt-2 pb-1 mx-1 rounded-lg gap-3 text-jp-2-gray-300 items-center text-fs-14 font-medium cursor-pointer`}>
              <CheckBoxIcon
                isSelected={noOfSelected !== 0}
                size=optionSize
                isSelectedStateMinus=clearAllCondition
              />
              {{clearAllCondition ? "Clear All" : "Select All"}->React.string}
            </div>
          </RenderIf>
        } else {
          <div
            onClick={selectAll(noOfSelected !== options->Array.length)}
            className={`flex ${isHorizontal
                ? "flex-col"
                : "flex-row"} justify-between pr-4 pl-5 pt-6 pb-1 text-base font-semibold ${font.textColor.primaryNormal} cursor-pointer`}>
            {"SELECT ALL"->React.string}
            <CheckBoxIcon isSelected={noOfSelected === options->Array.length} />
          </div>
        }
      } else {
        React.null
      }}
      {if showToggle {
        <div>
          <div className={`grid grid-cols-2 items-center ${marginClass}`}>
            <div
              className="ml-5 font-bold text-fs-16 text-jp-gray-900 text-opacity-50 dark:text-jp-gray-text_darktheme dark:text-opacity-50">
              {React.string(heading)}
            </div>
            {if showSelectAll {
              <div className="flex  mr-5 justify-end">
                {switch allSelectType {
                | Icon =>
                  <BoolInput.BaseComponent
                    isSelected=isChooseAllToggleSelected
                    setIsSelected=toggleSelectAll
                    isDisabled=disableSelect
                    size=optionSize
                  />
                | Text =>
                  <AddDataAttributes
                    attributes=[
                      (
                        "data-select-box",
                        {isChooseAllToggleSelected ? "deselectAll" : "selectAll"},
                      ),
                    ]>
                    <div
                      className={`font-semibold ${font.textColor.primaryNormal} ${disabledClass} ${customSelectAllStyle}`}
                      onClick={_ => {
                        toggleSelectAll(!isChooseAllToggleSelected)
                      }}>
                      {if isChooseAllToggleSelected {
                        "Deselect All"->React.string
                      } else {
                        "Select All"->React.string
                      }}
                    </div>
                  </AddDataAttributes>
                }}
              </div>
            } else {
              React.null
            }}
          </div>
          {if !hideBorder {
            <div
              className="my-2 bg-jp-gray-lightmode_steelgray dark:bg-jp-gray-960  "
              style={height: "1px"}
            />
          } else {
            React.null
          }}
        </div>
      } else {
        React.null
      }}
      <div
        className={`overflow-auto ${listPadding} ${isHorizontal
            ? "flex flex-row grow"
            : ""}  ${showToggle ? "ml-3" : maxHeight}` ++ {
          wrapBasis->LogicUtils.isEmptyString ? "" : " flex flex-wrap justify-between"
        }}>
        {if filteredOptions->Array.length === 0 {
          <div className="flex justify-center items-center m-4">
            {React.string("No matching records found")}
          </div>
        } else if filteredOptions->Array.find(item => item.value === "Loading...")->Option.isSome {
          <Loader />
        } else {
          {
            filteredOptions
            ->Array.mapWithIndex((item, indx) => {
              let valueToConsider = item.value
              let index = Array.findIndex(saneValue, sv => sv === valueToConsider)
              let isPrevSelected = switch filteredOptions->Array.get(indx - 1) {
              | Some(prevItem) => Array.findIndex(saneValue, sv => sv === prevItem.value) > -1
              | None => false
              }
              let isNextSelected = switch filteredOptions->Array.get(indx + 1) {
              | Some(nextItem) => Array.findIndex(saneValue, sv => sv === nextItem.value) > -1
              | None => false
              }
              let isSelected = index > -1
              let serialNumber =
                isSelected && showSerialNumber ? Some(Int.toString(index + 1)) : None
              let leftVacennt = isDropDown && textIconPresent && item.icon === NoIcon
              <div className={`${gapClass} ${wrapBasis}`} key={item.value}>
                <ListItem
                  isDropDown
                  isSelected
                  optionSize
                  isSelectedStateMinus
                  isPrevSelected
                  isNextSelected
                  searchString
                  onClick={onItemClick(valueToConsider, item.isDisabled || disableSelect)}
                  text=item.label
                  labelValue=item.label
                  multiSelect=true
                  customLabelStyle
                  icon=item.icon
                  leftVacennt
                  isDisabled={item.isDisabled || disableSelect}
                  showToggle
                  customStyle
                  serialNumber
                  isMobileView
                  description=item.description
                  customMarginStyle
                  listFlexDirection
                  dataId=indx
                  showDescriptionAsTool
                  optionClass
                  selectClass
                  toggleProps
                  checkboxDimension
                  iconStroke=item.iconStroke
                />
                {switch optionRigthElement {
                | Some(rightElement) => rightElement
                | None => React.null
                }}
              </div>
            })
            ->React.array
          }
        }}
      </div>
      {if hasApplyButton {
        <Button
          buttonType=Primary
          text="Apply"
          flattenTop=false
          customButtonStyle="w-full items-center"
          buttonState={!applyBtnDisabled ? Normal : Disabled}
          onClick
        />
      } else {
        <RenderIf condition={isDropDown && noOfSelected > 0 && showSelectCountButton}>
          <Button
            buttonType=Primary
            text={`Select ${noOfSelected->Int.toString}`}
            flattenTop=true
            customButtonStyle="w-full items-center"
            onClick
          />
        </RenderIf>
      }}
    </div>
  }
}

module BaseSelectButton = {
  @react.component
  let make = (
    ~showDropDown=false,
    ~isDropDown=true,
    ~isHorizontal=false,
    ~options: array<dropdownOption>,
    ~optionSize: CheckBoxIcon.size=Small,
    ~isSelectedStateMinus=false,
    ~onSelect: string => unit,
    ~value: JSON.t,
    ~deselectDisable=false,
    ~onBlur=?,
    ~setShowDropDown=?,
    ~onAssignClick=?,
    ~customSearchStyle,
    ~disableSelect=false,
    ~isMobileView=false,
    ~hideAssignBtn=false,
    ~searchInputPlaceHolder="",
    ~showSearchIcon=true,
    ~allowButtonTextMinWidth=?,
  ) => {
    let options = useTransformed(options)
    let (searchString, setSearchString) = React.useState(() => "")
    let (itemdata, setItemData) = React.useState(() => "")
    let (assignButtonState, setAssignButtonState) = React.useState(_ => false)
    let searchRef = React.useRef(Nullable.null)
    let onItemClick = itemData => _ => {
      if !disableSelect {
        let isSelected = value->JSON.Decode.string->Option.mapOr(false, str => itemData === str)

        if isSelected && !deselectDisable {
          onSelect("")
        } else {
          setItemData(_ => itemData)
          onSelect(itemData)
        }
        setAssignButtonState(_ => true)

        switch onBlur {
        | Some(fn) =>
          "blur"->Webapi.Dom.FocusEvent.make->Identity.webAPIFocusEventToReactEventFocus->fn
        | None => ()
        }
      }
    }

    React.useEffect(() => {
      searchRef.current->Nullable.toOption->Option.forEach(input => input->focus)
      None
    }, (searchRef.current, showDropDown))

    let handleSearch = str => {
      setSearchString(_ => str)
    }

    let searchable = isDropDown && options->Array.length > 5

    let width = isHorizontal ? "w-auto" : "w-full md:w-72"
    let inlineClass = isHorizontal ? "inline-flex" : ""

    let textIconPresent = options->Array.some(op => op.icon !== NoIcon)

    let onButtonClick = itemdata => {
      switch onAssignClick {
      | Some(fn) => fn(itemdata)
      | None => ()
      }
      switch setShowDropDown {
      | Some(fn) => fn(_ => false)
      | None => ()
      }
    }

    let listPadding = ""
    let optionsOuterClass = !isDropDown ? "" : "md:max-h-72 overflow-auto"
    let overflowClass = !isDropDown ? "" : "overflow-auto"

    <div
      className={`bg-white dark:bg-jp-gray-lightgray_background ${width} ${overflowClass} font-medium flex flex-col ${showDropDown
          ? "animate-textTransition transition duration-400"
          : "animate-textTransitionOff transition duration-400"}`}>
      {if searchable {
        <div
          className={`${customSearchStyle} border-b border-jp-gray-lightmode_steelgray border-opacity-75 dark:border-jp-gray-960 `}>
          <div className="pb-2">
            <SearchInput
              inputText=searchString
              onChange=handleSearch
              searchRef
              placeholder={searchInputPlaceHolder->LogicUtils.isEmptyString
                ? "Search..."
                : searchInputPlaceHolder}
              showSearchIcon
            />
          </div>
        </div>
      } else {
        React.null
      }}
      <div className={`${optionsOuterClass} ${listPadding} ${inlineClass}`}>
        {options
        ->Array.mapWithIndex((option, i) => {
          let isSelected = switch value->JSON.Decode.string {
          | Some(str) => option.value === str
          | None => false
          }

          let shouldDisplay = {
            switch Js.String2.match_(option.label, regex("\\b", searchString)) {
            | Some(_) => true
            | None =>
              switch Js.String2.match_(option.label, regex("_", searchString)) {
              | Some(_) => true
              | None => false
              }
            }
          }

          let leftVacennt = isDropDown && textIconPresent && option.icon === NoIcon
          if shouldDisplay {
            <ListItem
              key={Int.toString(i)}
              isDropDown
              isSelected
              optionSize
              isSelectedStateMinus
              searchString
              onClick={onItemClick(option.value)}
              text=option.label
              labelValue=option.label
              multiSelect=false
              icon=option.icon
              leftVacennt
              isMobileView
              dataId=i
              iconStroke=option.iconStroke
              customRowClass={option.customRowClass}
            />
          } else {
            React.null
          }
        })
        ->React.array}
      </div>
      {if !hideAssignBtn {
        <div id="neglectTopbarTheme" className="px-3 py-3">
          <Button
            text="Assign"
            buttonType=Primary
            buttonSize=Small
            isSelectBoxButton=isDropDown
            buttonState={assignButtonState ? Normal : Disabled}
            onClick={_ => onButtonClick(itemdata)}
            ?allowButtonTextMinWidth
          />
        </div>
      } else {
        React.null
      }}
    </div>
  }
}

module RenderListItemInBaseRadio = {
  @react.component
  let make = (
    ~newOptions: array<dropdownOptionWithoutOptional>,
    ~value,
    ~descriptionOnHover,
    ~isDropDown,
    ~textIconPresent,
    ~searchString,
    ~optionSize,
    ~isSelectedStateMinus,
    ~onItemClick,
    ~fill,
    ~customStyle,
    ~isMobileView,
    ~listFlexDirection,
    ~customSelectStyle,
    ~textOverflowClass,
    ~showToolTipOptions,
    ~textEllipsisForDropDownOptions,
    ~isHorizontal,
    ~customMarginStyleOfListItem="mx-3 py-2 gap-2",
    ~bottomComponent=?,
    ~optionClass="",
    ~selectClass="",
    ~customScrollStyle=?,
  ) => {
    let dropdownList =
      newOptions
      ->Array.mapWithIndex((option, i) => {
        let isSelected = switch value->JSON.Decode.string {
        | Some(str) => option.value === str
        | None => false
        }

        let description = descriptionOnHover ? option.description : None
        let leftVacennt = isDropDown && textIconPresent && option.icon === NoIcon
        let listItemComponent =
          <ListItem
            key={Int.toString(i)}
            isDropDown
            isSelected
            fill
            searchString
            onClick={onItemClick(option.value, option.isDisabled)}
            text=option.label
            optionSize
            isSelectedStateMinus
            labelValue=option.label
            multiSelect=false
            icon=option.icon
            leftVacennt
            isDisabled=option.isDisabled
            isMobileView
            description
            listFlexDirection
            customStyle
            customSelectStyle
            ?textOverflowClass
            dataId=i
            iconStroke=option.iconStroke
            showToolTipOptions
            textEllipsisForDropDownOptions
            textColorClass={option.textColor}
            customMarginStyle=customMarginStyleOfListItem
            customRowClass={option.customRowClass}
            optionClass
            selectClass
          />

        if !descriptionOnHover {
          switch option.description {
          | Some(str) =>
            <div key={i->Int.toString} className="flex flex-row">
              listItemComponent
              <RenderIf condition={!isHorizontal}>
                <ToolTip
                  description={str}
                  toolTipFor={<div className="py-4 px-4">
                    <Icon size=12 name="info-circle" />
                  </div>}
                />
              </RenderIf>
            </div>
          | None => listItemComponent
          }
        } else {
          listItemComponent
        }
      })
      ->React.array

    let sidebarScrollbarCss = `
      @supports (-webkit-appearance: none) {
        .sidebar-scrollbar {
          scrollbar-width: thin !important;
          scrollbar-color: #8a8c8f;
        }

        .sidebar-scrollbar::-webkit-scrollbar-thumb {
          background-color: #8a8c8f;
          border-radius: 3px;
        }

        .sidebar-scrollbar::-webkit-scrollbar-track {
          display: none;
        }
      }
    `
    let (className, styleElement) = switch customScrollStyle {
    | None => ("", React.null)
    | Some(style) => (
        `${style}  sidebar-scrollbar`,
        <style> {React.string(sidebarScrollbarCss)} </style>,
      )
    }
    <>
      <div className={className}>
        {styleElement}
        {dropdownList}
      </div>
      <div className="sticky bottom-0">
        {switch bottomComponent {
        | Some(comp) => <span> {comp} </span>
        | None => React.null
        }}
      </div>
    </>
  }
}

let getHashMappedOptionValues = (options: array<dropdownOptionWithoutOptional>) => {
  let hashMappedOptions = options->Array.reduce(Dict.make(), (
    acc,
    ele: dropdownOptionWithoutOptional,
  ) => {
    if acc->Dict.get(ele.optGroup)->Option.isNone {
      acc->Dict.set(ele.optGroup, [ele])
    } else {
      acc->Dict.get(ele.optGroup)->Option.getOr([])->Array.push(ele)->ignore
    }
    acc
  })

  hashMappedOptions
}

let getSortedKeys = hashMappedOptions => {
  hashMappedOptions
  ->Dict.keysToArray
  ->Array.toSorted((a, b) => {
    switch (a, b) {
    | ("-", _) => 1.
    | (_, "-") => -1.
    | (_, _) => String.compare(a, b)
    }
  })
}

module BaseRadio = {
  @react.component
  let make = (
    ~showDropDown=false,
    ~isDropDown=true,
    ~isHorizontal=false,
    ~options: array<dropdownOption>,
    ~optionSize: CheckBoxIcon.size=Small,
    ~isSelectedStateMinus=false,
    ~onSelect: string => unit,
    ~value: JSON.t,
    ~deselectDisable=false,
    ~onBlur=?,
    ~fill="#0EB025",
    ~customStyle="",
    ~searchable=?,
    ~isMobileView=false,
    ~customSearchStyle="bg-jp-gray-100 dark:bg-jp-gray-950 p-2",
    ~descriptionOnHover=false,
    ~addDynamicValue=false,
    ~dropdownCustomWidth="w-80",
    ~dropdownRef=?,
    ~showMatchingRecordsText=true,
    ~fullLength=false,
    ~selectedString="",
    ~setSelectedString=_ => (),
    ~setExtSearchString=_ => (),
    ~listFlexDirection="",
    ~baseComponentCustomStyle="",
    ~customSelectStyle="",
    ~maxHeight="md:max-h-72",
    ~textOverflowClass=?,
    ~searchInputPlaceHolder="",
    ~showSearchIcon=true,
    ~showToolTipOptions=false,
    ~textEllipsisForDropDownOptions=false,
    ~bottomComponent=React.null,
    ~optionClass="",
    ~selectClass="",
    ~customScrollStyle=?,
    ~dropdownContainerStyle="",
  ) => {
    let options = React.useMemo(() => {
      options->Array.map(makeNonOptional)
    }, [options])

    let hashMappedOptions = getHashMappedOptionValues(options)

    let isNonGrouped =
      hashMappedOptions->Dict.get("-")->Option.getOr([])->Array.length === options->Array.length

    let (optgroupKeys, setOptgroupKeys) = React.useState(_ => getSortedKeys(hashMappedOptions))

    let (searchString, setSearchString) = React.useState(() => "")
    React.useEffect(() => {
      setExtSearchString(_ => searchString)
      None
    }, [searchString])

    OutsideClick.useOutsideClick(
      ~refs={ArrayOfRef([dropdownRef->Option.getOr(React.useRef(Nullable.null))])},
      ~isActive=showDropDown,
      ~callback=() => {
        setSearchString(_ => "")
      },
    )
    let onItemClick = (itemData, isDisabled) => _ => {
      if !isDisabled {
        let isSelected = value->JSON.Decode.string->Option.mapOr(false, str => itemData === str)

        if isSelected && !deselectDisable {
          setSelectedString(_ => "")
          onSelect("")
        } else {
          if (
            addDynamicValue && !(options->Array.map(item => item.value)->Array.includes(itemData))
          ) {
            setSelectedString(_ => itemData)
          } else if selectedString->LogicUtils.isNonEmptyString {
            setSelectedString(_ => "")
          }

          onSelect(itemData)
        }
        setSearchString(_ => "")
        switch onBlur {
        | Some(fn) =>
          "blur"->Webapi.Dom.FocusEvent.make->Identity.webAPIFocusEventToReactEventFocus->fn
        | None => ()
        }
      }
    }
    let handleSearch = str => {
      setSearchString(_ => str)
    }

    let isSearchable =
      isDropDown &&
      switch searchable {
      | Some(isSearch) => isSearch
      | None => options->Array.length > 5
      }
    let widthClass =
      isMobileView || !isSearchable ? "w-auto" : fullLength ? "w-full" : dropdownCustomWidth

    let searchRef = React.useRef(Nullable.null)

    let width =
      isHorizontal || !isDropDown || customStyle->LogicUtils.isEmptyString
        ? widthClass
        : customStyle

    let inlineClass = isHorizontal ? "inline-flex" : ""

    let textIconPresent = options->Array.some(op => op.icon !== NoIcon)

    React.useEffect(() => {
      searchRef.current->Nullable.toOption->Option.forEach(input => input->focus)
      None
    }, (searchRef.current, showDropDown))

    let roundedClass = ""
    let listPadding = ""

    let dropDownbgClass = isDropDown ? "bg-white" : ""
    let shouldDisplay = (option: dropdownOptionWithoutOptional) => {
      switch Js.String2.match_(option.label, regex("\\b", searchString)) {
      | Some(_) => true
      | None =>
        switch Js.String2.match_(option.label, regex("_", searchString)) {
        | Some(_) => true
        | None => false
        }
      }
    }

    let newOptions = React.useMemo(() => {
      let options = if selectedString->LogicUtils.isNonEmptyString {
        options->Array.concat([selectedString]->makeOptions->Array.map(makeNonOptional))
      } else {
        options
      }
      if searchString->String.length != 0 {
        let options = options->Array.filter(option => {
          shouldDisplay(option)
        })
        if (
          addDynamicValue && !(options->Array.map(item => item.value)->Array.includes(searchString))
        ) {
          if isNonGrouped {
            options->Array.concat([searchString]->makeOptions->Array.map(makeNonOptional))
          } else {
            options
          }
        } else {
          let hashMappedSearchedOptions = getHashMappedOptionValues(options)
          let optgroupKeysForSearch = getSortedKeys(hashMappedSearchedOptions)
          setOptgroupKeys(_ => optgroupKeysForSearch)
          options
        }
      } else {
        setOptgroupKeys(_ => getSortedKeys(hashMappedOptions))
        options
      }
    }, (searchString, options, selectedString))
    let overflowClass = !isDropDown ? "" : "overflow-auto"

    let searchInputUI =
      <div
        className={`${customSearchStyle} border-b border-jp-gray-lightmode_steelgray border-opacity-75 dark:border-jp-gray-960 `}>
        <div>
          <SearchInput
            inputText=searchString
            onChange=handleSearch
            searchRef
            placeholder={searchInputPlaceHolder->LogicUtils.isEmptyString
              ? "Search..."
              : searchInputPlaceHolder}
            showSearchIcon
          />
        </div>
      </div>
    <div
      className={`${dropDownbgClass} ${roundedClass} dark:bg-jp-gray-lightgray_background ${dropdownContainerStyle} ${width} ${overflowClass} font-medium flex flex-col ${showDropDown
          ? "animate-textTransition transition duration-400"
          : "animate-textTransitionOff transition duration-400"}`}>
      {switch searchable {
      | Some(val) => <RenderIf condition={val}> searchInputUI </RenderIf>
      | None =>
        <RenderIf condition={isDropDown && (options->Array.length > 5 || addDynamicValue)}>
          searchInputUI
        </RenderIf>
      }}
      <div
        className={`${maxHeight} ${listPadding} ${overflowClass} text-fs-13 font-semibold text-jp-gray-900 text-opacity-75 dark:text-jp-gray-text_darktheme dark:text-opacity-75 ${inlineClass} ${baseComponentCustomStyle}`}>
        {if newOptions->Array.length === 0 && showMatchingRecordsText {
          <div className="flex justify-center items-center m-4">
            {React.string("No matching records found")}
          </div>
        } else if isNonGrouped {
          <RenderListItemInBaseRadio
            newOptions
            value
            descriptionOnHover
            isDropDown
            textIconPresent
            searchString
            optionSize
            isSelectedStateMinus
            onItemClick
            fill
            customStyle
            isMobileView
            listFlexDirection
            customSelectStyle
            textOverflowClass
            showToolTipOptions
            textEllipsisForDropDownOptions
            isHorizontal
            bottomComponent
            optionClass
            selectClass
            ?customScrollStyle
          />
        } else {
          {
            optgroupKeys
            ->Array.mapWithIndex((ele, index) => {
              <React.Fragment key={index->Int.toString}>
                <h2 className="p-3 font-bold"> {ele->React.string} </h2>
                <RenderListItemInBaseRadio
                  newOptions={getHashMappedOptionValues(newOptions)
                  ->Dict.get(ele)
                  ->Option.getOr([])}
                  value
                  descriptionOnHover
                  isDropDown
                  textIconPresent
                  searchString
                  optionSize
                  isSelectedStateMinus
                  onItemClick
                  fill
                  customStyle
                  isMobileView
                  listFlexDirection
                  customSelectStyle
                  textOverflowClass
                  showToolTipOptions
                  textEllipsisForDropDownOptions
                  isHorizontal
                  customMarginStyleOfListItem="ml-8 mx-3 py-2 gap-2"
                  ?customScrollStyle
                />
              </React.Fragment>
            })
            ->React.array
          }
        }}
      </div>
    </div>
  }
}

type direction =
  | BottomLeft
  | BottomMiddle
  | BottomRight
  | TopLeft
  | TopMiddle
  | TopRight

module BaseDropdown = {
  @react.component
  let make = (
    ~buttonText,
    ~buttonSize=Button.Small,
    ~allowMultiSelect,
    ~input,
    ~showClearAll=true,
    ~showSelectAll=true,
    ~options: array<dropdownOption>,
    ~optionSize: CheckBoxIcon.size=Small,
    ~isSelectedStateMinus=false,
    ~hideMultiSelectButtons,
    ~deselectDisable=?,
    ~buttonType=Button.SecondaryFilled,
    ~baseComponent=?,
    ~baseComponentMethod=?,
    ~disableSelect=false,
    ~textStyle=?,
    ~buttonTextWeight=?,
    ~defaultLeftIcon: Button.iconType=NoIcon,
    ~autoApply=true,
    ~fullLength=false,
    ~customButtonStyle="",
    ~onAssignClick=?,
    ~fixedDropDownDirection=?,
    ~addButton=false,
    ~marginTop="mt-10", //to position dropdown below the button,
    ~customStyle="",
    ~customSearchStyle="bg-jp-gray-100 dark:bg-jp-gray-950 p-2",
    ~showSelectionAsChips=true,
    ~showToolTip=false,
    ~showNameAsToolTip=false,
    ~searchable=?,
    ~showBorder=?,
    ~dropDownCustomBtnClick=false,
    ~showCustomBtnAtEnd=false,
    ~customButton=React.null,
    ~descriptionOnHover=false,
    ~addDynamicValue=false,
    ~showMatchingRecordsText=true,
    ~hasApplyButton=false,
    ~dropdownCustomWidth=?,
    ~allowButtonTextMinWidth=?,
    ~customMarginStyle=?,
    ~customButtonLeftIcon: option<Button.iconType>=?,
    ~customTextPaddingClass=?,
    ~customButtonPaddingClass=?,
    ~customButtonIconMargin=?,
    ~textStyleClass=?,
    ~buttonStyleOnDropDownOpened="",
    ~selectedString="",
    ~setSelectedString=_ => (),
    ~setExtSearchString=_ => (),
    ~listFlexDirection="",
    ~ellipsisOnly=false,
    ~isPhoneDropdown=false,
    ~onApply=?,
    ~showAllSelectedOptions=true,
    ~buttonClickFn=?,
    ~toggleChevronState: option<unit => unit>=?,
    ~showSelectCountButton=false,
    ~maxHeight=?,
    ~customBackColor=?,
    ~showToolTipOptions=false,
    ~textEllipsisForDropDownOptions=false,
    ~showBtnTextToolTip=false,
    ~dropdownClassName="",
    ~searchInputPlaceHolder="",
    ~showSearchIcon=true,
    ~sortingBasedOnDisabled=?,
    ~customSelectStyle="",
    ~baseComponentCustomStyle="",
    ~bottomComponent=React.null,
    ~optionClass="",
    ~selectClass="",
    ~customDropdownOuterClass="",
    ~customScrollStyle=?,
    ~dropdownContainerStyle="",
  ) => {
    let transformedOptions = useTransformed(options)
    let isMobileView = MatchMedia.useMobileChecker()
    let isSelectTextDark = React.useContext(
      DropdownTextWeighContextWrapper.selectedTextWeightContext,
    )
    let isFilterSection = React.useContext(TableFilterSectionContext.filterSectionContext)

    let showBorder = isFilterSection && !isMobileView ? Some(false) : showBorder

    let dropdownOuterClass = "border border-jp-gray-lightmode_steelgray border-opacity-75 dark:border-jp-gray-960 rounded  shadow-generic_shadow dark:shadow-generic_shadow_dark"

    let newInputSelect = input->ffInputToSelectInput
    let newInputRadio = input->ffInputToRadioInput
    let isMobileView = MatchMedia.useMobileChecker()
    let (showDropDown, setShowDropDown) = React.useState(() => false)
    let (isGrowDown, setIsGrowDown) = React.useState(_ => false)
    let (isInitialRender, setIsInitialRender) = React.useState(_ => true)
    let selectBoxRef = React.useRef(Nullable.null)
    let dropdownRef = React.useRef(Nullable.null)
    let selectBtnRef = React.useRef(Nullable.null)
    let (preservedAppliedOptions, setPreservedAppliedOptions) = React.useState(_ =>
      newInputSelect.value->LogicUtils.getStrArryFromJson
    )

    let onApply = ev => {
      switch onApply {
      | Some(fn) => fn(ev)
      | None => ()
      }

      setPreservedAppliedOptions(_ => newInputSelect.value->LogicUtils.getStrArryFromJson)
    }

    let clearBtnRef = React.useRef(Nullable.null)
    let insertselectBtnRef = element => {
      if !Js.Nullable.isNullable(element) {
        selectBtnRef.current = element
      }
    }
    React.useEffect(() => {
      setShowDropDown(_ => false)
      None
    }, [dropDownCustomBtnClick])
    let insertclearBtnRef = element => {
      if !Js.Nullable.isNullable(element) {
        clearBtnRef.current = element
      }
    }
    let refs = autoApply
      ? [selectBoxRef, dropdownRef]
      : [selectBoxRef, dropdownRef, selectBtnRef, clearBtnRef]
    OutsideClick.useOutsideClick(~refs=ArrayOfRef(refs), ~isActive=showDropDown, ~callback=() => {
      setShowDropDown(_ => false)
      hasApplyButton ? newInputSelect.onChange(preservedAppliedOptions) : ()
    })

    React.useEffect(() => {
      switch toggleChevronState {
      | Some(fn) => fn()
      | None => ()
      }
      None
    }, [showDropDown])

    let onClick = _ => {
      switch buttonClickFn {
      | Some(fn) => fn(input.name)
      | None => ()
      }
      setShowDropDown(_ => !showDropDown)
      setIsGrowDown(_ => true)
      let _id = setTimeout(() => setIsGrowDown(_ => false), 250)
      if isInitialRender {
        setIsInitialRender(_ => false)
      }
    }

    let removeOption = text => _ => {
      let actualValue = switch Array.find(transformedOptions, option => option.value == text) {
      | Some(str) => str.value
      | None => ""
      }
      newInputSelect.onChange(
        switch newInputSelect.value->JSON.Decode.array {
        | Some(jsonArr) =>
          jsonArr->LogicUtils.getStrArrayFromJsonArray->Array.filter(str => str !== actualValue)
        | _ => []
        },
      )
    }

    let downArrowIcon = "angle-down"
    let arrowIconSize = 14

    let (dropDowntext, leftIcon: Button.iconType, iconStroke) = allowMultiSelect
      ? (buttonText, defaultLeftIcon, "")
      : switch newInputRadio.value->JSON.Decode.string {
        | Some(str) =>
          switch transformedOptions->Array.find(x => x.value === str) {
          | Some(x) => (x.label, x.icon, x.iconStroke)
          | None => (buttonText, defaultLeftIcon, "")
          }
        | None => (buttonText, defaultLeftIcon, "")
        }

    let dropDirection = React.useMemo(() => {
      switch fixedDropDownDirection {
      | Some(dropDownDirection) => dropDownDirection
      | None =>
        selectBoxRef.current
        ->Nullable.toOption
        ->Option.flatMap(elem => elem->getClientRects->toDict->Dict.get("0"))
        ->Option.flatMap(firstEl => {
          let bottomVacent = Window.innerHeight - firstEl["bottom"]->Float.toInt > 375
          let topVacent = firstEl["top"]->Float.toInt > 470
          let rightVacent = Window.innerWidth - firstEl["left"]->Float.toInt > 270
          let leftVacent = firstEl["right"]->Float.toInt > 270

          if bottomVacent {
            rightVacent ? BottomRight : leftVacent ? BottomLeft : BottomMiddle
          } else if topVacent {
            rightVacent ? TopRight : leftVacent ? TopLeft : TopMiddle
          } else if rightVacent {
            BottomRight
          } else if leftVacent {
            BottomLeft
          } else {
            BottomMiddle
          }->Some
        })
        ->Option.getOr(BottomMiddle)
      }
    }, [showDropDown])

    let flexWrapper = switch dropDirection {
    | BottomLeft => "flex-row-reverse flex-wrap"
    | BottomRight => "flex-row flex-wrap"
    | BottomMiddle => "flex-row flex-wrap justify-center"
    | TopLeft => "flex-row-reverse flex-wrap-reverse"
    | TopRight => "flex-row flex-wrap-reverse"
    | TopMiddle => "flex-row flex-wrap-reverse justify-center"
    }
    let marginBottom = switch dropDirection {
    | BottomLeft | BottomRight | BottomMiddle | TopMiddle => ""
    | TopLeft | TopRight => "mb-12"
    }

    let onRadioOptionSelect = ev => {
      newInputRadio.onChange(ev)
      addButton ? setShowDropDown(_ => true) : setShowDropDown(_ => false)
    }

    let allSellectedOptions = React.useMemo(() => {
      newInputSelect.value
      ->JSON.Decode.array
      ->Option.getOr([])
      ->Belt.Array.keepMap(JSON.Decode.string)
      ->Belt.Array.keepMap(str => {
        transformedOptions->Array.find(x => x.value == str)->Option.map(x => x.label)
      })
      ->Array.joinWith(", ")
      ->LogicUtils.getNonEmptyString
      ->Option.getOr(buttonText)
    }, (transformedOptions, newInputSelect.value))

    let title = showAllSelectedOptions ? allSellectedOptions : buttonText

    let badgeForSelect = React.useMemo((): Button.badge => {
      let count = newInputSelect.value->JSON.Decode.array->Option.getOr([])->Array.length
      let condition = count > 1

      {
        value: count->Int.toString,
        color: condition ? BadgeBlue : NoBadge,
      }
    }, [newInputSelect.value])
    let widthClass = isMobileView ? "w-full" : dropdownCustomWidth->Option.getOr("")

    let optionsElement = if allowMultiSelect {
      <BaseSelect
        options
        optionSize
        showDropDown
        onSelect=newInputSelect.onChange
        value={newInputSelect.value}
        isDropDown=true
        showClearAll
        onBlur=newInputSelect.onBlur
        showSelectAll
        insertselectBtnRef
        insertclearBtnRef
        showSelectionAsChips
        ?searchable
        disableSelect
        ?dropdownCustomWidth
        ?deselectDisable
        isMobileView
        hasApplyButton
        setShowDropDown
        ?customMarginStyle
        listFlexDirection
        onApply
        showSelectCountButton
        ?maxHeight
        dropdownClassName
        customStyle
        searchInputPlaceHolder
        showSearchIcon
        ?sortingBasedOnDisabled
        preservedAppliedOptions
      />
    } else if addButton {
      <BaseSelectButton
        options
        optionSize
        isSelectedStateMinus
        showDropDown
        onSelect=onRadioOptionSelect
        onBlur=newInputRadio.onBlur
        value=newInputRadio.value
        isDropDown=true
        ?deselectDisable
        isHorizontal=false
        setShowDropDown
        ?onAssignClick
        isMobileView
        customSearchStyle
        disableSelect
        hideAssignBtn={true}
        searchInputPlaceHolder
        showSearchIcon
      />
    } else {
      <BaseRadio
        options
        optionSize
        isSelectedStateMinus
        showDropDown
        onSelect=onRadioOptionSelect
        onBlur=newInputRadio.onBlur
        value=newInputRadio.value
        isDropDown=true
        ?deselectDisable
        isHorizontal=false
        customStyle
        ?searchable
        isMobileView
        descriptionOnHover
        showMatchingRecordsText
        ?dropdownCustomWidth
        addDynamicValue
        dropdownRef
        fullLength
        selectedString
        setSelectedString
        setExtSearchString
        listFlexDirection
        showToolTipOptions
        textEllipsisForDropDownOptions
        searchInputPlaceHolder
        showSearchIcon
        customSelectStyle
        baseComponentCustomStyle
        bottomComponent
        optionClass
        selectClass
        ?customScrollStyle
        dropdownContainerStyle
      />
    }

    let selectButtonText = if !showSelectionAsChips {
      title
    } else if selectedString->LogicUtils.isNonEmptyString {
      selectedString
    } else {
      dropDowntext
    }

    let buttonIcon =
      <Icon
        name=downArrowIcon
        size=arrowIconSize
        className={`transition duration-[250ms] ease-out-[cubic-bezier(0.33, 1, 0.68, 1)] ${showDropDown
            ? "-rotate-180"
            : ""}`}
      />

    let textStyle = if isSelectTextDark && selectButtonText !== buttonText {
      Some("text-black dark:text-white")
    } else {
      textStyle
    }

    <div className={`flex relative  flex-row  flex-wrap`}>
      <div className={`flex relative ${flexWrapper} ${fullLength ? "w-full" : ""}`}>
        <div
          ref={selectBoxRef->ReactDOM.Ref.domRef}
          className={`text-opacity-50 ${fullLength ? "w-full" : ""}`}>
          {switch baseComponent {
          | Some(comp) => <span onClick> {comp} </span>
          | None =>
            switch baseComponentMethod {
            | Some(compFn) => <span onClick> {compFn(showDropDown)} </span>
            | None =>
              switch buttonType {
              | FilterAdd =>
                <Button
                  text=buttonText
                  leftIcon={customButtonLeftIcon->Option.getOr(FontAwesome({"plus"}))}
                  buttonType
                  isSelectBoxButton=true
                  buttonSize
                  onClick
                  ?textStyle
                  textWeight=?buttonTextWeight
                  buttonState={disableSelect ? Disabled : Normal}
                  fullLength
                  ?showBorder
                  customButtonStyle
                  ?customTextPaddingClass
                  customPaddingClass=?customButtonPaddingClass
                  customIconMargin=?customButtonIconMargin
                  ?customBackColor
                />
              | _ => {
                  let selectButton =
                    <AddDataAttributes attributes=[("data-dropdown-for", buttonText)]>
                      <div>
                        {<Button
                          text=selectButtonText
                          leftIcon
                          onClick
                          ?textStyle
                          buttonSize
                          ellipsisOnly={ellipsisOnly || !showSelectionAsChips}
                          badge={!showSelectionAsChips
                            ? badgeForSelect
                            : {value: 0->Int.toString, color: NoBadge}}
                          rightIcon={CustomIcon(buttonIcon)}
                          buttonState={disableSelect ? Disabled : Normal}
                          fullLength
                          buttonType={Dropdown}
                          isPhoneDropdown
                          isDropdownOpen=showDropDown
                          iconBorderColor={iconStroke}
                          isSelectBoxButton=true
                          customButtonStyle={`${customButtonStyle} ${showDropDown
                              ? buttonStyleOnDropDownOpened
                              : ""} transition duration-[250ms] ease-out-[cubic-bezier(0.33, 1, 0.68, 1)]`}
                          ?showBorder
                          ?allowButtonTextMinWidth
                          ?textStyleClass
                          showBtnTextToolTip
                        />}
                      </div>
                    </AddDataAttributes>
                  if (
                    showToolTip &&
                    newInputSelect.value !== ""->JSON.Encode.string &&
                    !showDropDown &&
                    showNameAsToolTip
                  ) {
                    <ToolTip
                      description={showNameAsToolTip
                        ? `Select ${LogicUtils.snakeToTitle(newInputSelect.name)}`
                        : newInputSelect.value
                          ->LogicUtils.getStrArryFromJson
                          ->Array.joinWith(",\n")}
                      toolTipFor=selectButton
                      toolTipPosition=Bottom
                      tooltipWidthClass=""
                    />
                  } else {
                    selectButton
                  }
                }
              }
            }
          }}
        </div>
        {if showDropDown {
          if !isMobileView {
            <AddDataAttributes attributes=[("data-dropdown", "dropdown")]>
              <div
                className={`${marginTop} absolute ${isGrowDown
                    ? "animate-growDown"
                    : ""} ${dropDirection == BottomLeft ||
                  dropDirection == BottomMiddle ||
                  dropDirection == BottomRight
                    ? "origin-top"
                    : "origin-bottom"} ${dropdownOuterClass} ${customDropdownOuterClass} z-20 ${marginBottom} bg-gray-50 dark:bg-jp-gray-950 ${fullLength
                    ? "w-full"
                    : ""}`}
                ref={dropdownRef->ReactDOM.Ref.domRef}>
                optionsElement
                {showCustomBtnAtEnd ? customButton : React.null}
              </div>
            </AddDataAttributes>
          } else {
            <BottomModal headerText={buttonText} onCloseClick={onClick}>
              optionsElement
            </BottomModal>
          }
        } else if !isInitialRender && isGrowDown && !isMobileView {
          <div
            className={`${marginTop} absolute animate-growUp ${widthClass} ${dropDirection ==
                BottomLeft ||
              dropDirection == BottomMiddle ||
              dropDirection == BottomRight
                ? "origin-top"
                : "origin-bottom"} ${dropdownOuterClass} ${customDropdownOuterClass} z-20 ${marginBottom} bg-gray-50 dark:bg-jp-gray-950`}
            ref={dropdownRef->ReactDOM.Ref.domRef}>
            optionsElement
          </div>
        } else {
          React.null
        }}
      </div>
      {if allowMultiSelect && !hideMultiSelectButtons && showSelectionAsChips {
        switch newInputSelect.value->JSON.Decode.array {
        | Some(jsonArr) =>
          jsonArr
          ->LogicUtils.getStrArrayFromJsonArray
          ->Array.mapWithIndex((str, i) => {
            let actualValueIndex = Array.findIndex(options->Array.map(x => x.value), item =>
              item == str
            )
            if actualValueIndex !== -1 {
              let (text, leftIcon) = switch options[actualValueIndex] {
              | Some(ele) => (ele.label, ele.icon->Option.getOr(NoIcon))
              | None => ("", NoIcon)
              }

              <div key={Int.toString(i)} className="m-2">
                <Button
                  buttonFor=buttonText
                  buttonSize=Small
                  isSelectBoxButton=true
                  leftIcon
                  rightIcon={FontAwesome("times")}
                  text
                  onClick={removeOption(str)}
                />
              </div>
            } else {
              React.null
            }
          })
          ->React.array
        | _ => React.null
        }
      } else {
        React.null
      }}
    </div>
  }
}

module InfraSelectBox = {
  @react.component
  let make = (
    ~options: array<dropdownOption>,
    ~input: ReactFinalForm.fieldRenderPropsInput,
    ~deselectDisable=false,
    ~allowMultiSelect=true,
    ~borderRadius="rounded-full",
    ~selectedClass="border-jp-gray-600 dark:border-jp-gray-800 text-jp-gray-850 dark:text-jp-gray-400",
    ~nonSelectedClass="border-jp-gray-900 dark:border-jp-gray-300 text-jp-gray-900 dark:text-jp-gray-300 font-semibold",
    ~showTickMark=true,
  ) => {
    let transformedOptions = useTransformed(options)

    let newInputSelect = input->ffInputToSelectInput
    let values = newInputSelect.value
    let saneValue = React.useMemo(() =>
      switch values->JSON.Decode.array {
      | Some(jsonArr) => jsonArr->LogicUtils.getStrArrayFromJsonArray
      | _ => []
      }
    , [values])

    let onItemClick = (itemDataValue, isDisabled) => {
      if !isDisabled {
        if allowMultiSelect {
          let data = if Array.includes(saneValue, itemDataValue) {
            if deselectDisable {
              saneValue
            } else {
              saneValue->Array.filter(x => x !== itemDataValue)
            }
          } else {
            Array.concat(saneValue, [itemDataValue])
          }
          newInputSelect.onChange(data)
        } else {
          newInputSelect.onChange([itemDataValue])
        }
      }
    }

    <div className={`md:max-h-72 overflow-auto font-medium flex flex-wrap gap-y-4 gap-x-2.5`}>
      {transformedOptions
      ->Array.mapWithIndex((option, i) => {
        let isSelected = saneValue->Array.includes(option.value)
        let selectedClass = isSelected ? selectedClass : nonSelectedClass

        <div
          key={Int.toString(i)}
          onClick={_ => onItemClick(option.value, option.isDisabled)}
          className={`px-4 py-1 border ${borderRadius} flex flex-row gap-2 items-center cursor-pointer ${selectedClass}`}>
          {if isSelected && showTickMark {
            <Icon
              className="align-middle font-thin text-jp-gray-900 dark:text-jp-gray-300"
              size=12
              name="check"
            />
          } else {
            React.null
          }}
          {React.string(option.label)}
        </div>
      })
      ->React.array}
    </div>
  }
}

module ChipFilterSelectBox = {
  @react.component
  let make = (
    ~options: array<dropdownOption>,
    ~input: ReactFinalForm.fieldRenderPropsInput,
    ~deselectDisable=false,
    ~allowMultiSelect=true,
    ~isTickRequired=true,
    ~customStyleForChips="",
  ) => {
    let transformedOptions = useTransformed(options)

    let initalClassName = " m-2 bg-gray-200 dark:text-gray-800 border-jp-gray-800 inline-block text-s px-2 py-1 rounded-2xl"
    let passedClassName = "flex items-center m-2 bg-blue-400 dark:text-gray-800 border-gray-300 inline-block text-s px-2 py-1 rounded-2xl"
    let newInputSelect = input->ffInputToSelectInput
    let values = newInputSelect.value
    let saneValue = React.useMemo(() => {
      values->LogicUtils.getArrayFromJson([])->LogicUtils.getStrArrayFromJsonArray
    }, [values])

    let onItemClick = (itemDataValue, isDisabled) => {
      if !isDisabled {
        if allowMultiSelect {
          let data = if Array.includes(saneValue, itemDataValue) {
            if deselectDisable {
              saneValue
            } else {
              saneValue->Array.filter(x => x !== itemDataValue)
            }
          } else {
            Array.concat(saneValue, [itemDataValue])
          }
          newInputSelect.onChange(data)
        } else {
          newInputSelect.onChange([itemDataValue])
        }
      }
    }

    <div className={`md:max-h-72 overflow-auto font-medium flex flex-wrap gap-4 `}>
      {transformedOptions
      ->Array.mapWithIndex((option, i) => {
        let isSelected = saneValue->Array.includes(option.value)
        let selectedClass = isSelected ? passedClassName : initalClassName
        let chipsCss =
          customStyleForChips->LogicUtils.isEmptyString ? selectedClass : customStyleForChips

        <div
          key={Int.toString(i)}
          onClick={_ => onItemClick(option.value, option.isDisabled)}
          className={`px-4 py-1 mr-1 mt-0.5 border rounded-full flex flex-row gap-2 items-center cursor-pointer ${chipsCss}`}>
          {if isTickRequired {
            if isSelected {
              <Icon name="check-circle" size=9 className="fill-blue-150 mr-1 mt-0.5" />
            } else {
              <Icon name="check-circle" size=9 className="fill-gray-150 mr-1 mt-0.5" />
            }
          } else {
            React.null
          }}
          {React.string(option.label)}
        </div>
      })
      ->React.array}
    </div>
  }
}

@react.component
let make = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~buttonText="Normal Selection",
  ~buttonSize=?,
  ~allowMultiSelect=false,
  ~isDropDown=true,
  ~hideMultiSelectButtons=false,
  ~options: array<'a>,
  ~optionSize: CheckBoxIcon.size=Small,
  ~isSelectedStateMinus=false,
  ~isHorizontal=false,
  ~deselectDisable=false,
  ~showClearAll=true,
  ~showSelectAll=true,
  ~buttonType=Button.SecondaryFilled,
  ~disableSelect=false,
  ~fullLength=false,
  ~customButtonStyle="",
  ~textStyle="",
  ~marginTop="mt-12",
  ~customStyle="",
  ~showSelectionAsChips=true,
  ~showToggle=false,
  ~maxHeight=?,
  ~searchable=?,
  ~fill="#0EB025",
  ~optionRigthElement=?,
  ~hideBorder=false,
  ~allSelectType=Icon,
  ~customSearchStyle="bg-jp-gray-100 dark:bg-jp-gray-950 p-2",
  ~searchInputPlaceHolder=?,
  ~showSearchIcon=true,
  ~customLabelStyle=?,
  ~customMargin="",
  ~showToolTip=false,
  ~showNameAsToolTip=false,
  ~showBorder=?,
  ~showCustomBtnAtEnd=false,
  ~dropDownCustomBtnClick=false,
  ~addDynamicValue=false,
  ~showMatchingRecordsText=true,
  ~customButton=React.null,
  ~descriptionOnHover=false,
  ~fixedDropDownDirection=?,
  ~dropdownCustomWidth=?,
  ~allowButtonTextMinWidth=?,
  ~baseComponent=?,
  ~baseComponentMethod=?,
  ~customMarginStyle=?,
  ~buttonTextWeight=?,
  ~customButtonLeftIcon=?,
  ~customTextPaddingClass=?,
  ~customButtonPaddingClass=?,
  ~customButtonIconMargin=?,
  ~textStyleClass=?,
  ~setExtSearchString=_ => (),
  ~buttonStyleOnDropDownOpened="",
  ~listFlexDirection="",
  ~baseComponentCustomStyle="",
  ~ellipsisOnly=false,
  ~customSelectStyle="",
  ~isPhoneDropdown=false,
  ~hasApplyButton=?,
  ~onApply=?,
  ~showAllSelectedOptions=?,
  ~buttonClickFn=?,
  ~showDescriptionAsTool=true,
  ~optionClass="",
  ~selectClass="",
  ~toggleProps="",
  ~showSelectCountButton=false,
  ~leftIcon=?,
  ~customBackColor=?,
  ~customSelectAllStyle=?,
  ~checkboxDimension="",
  ~showToolTipOptions=false,
  ~textEllipsisForDropDownOptions=false,
  ~showBtnTextToolTip=false,
  ~dropdownClassName="",
  ~onItemSelect=(_, _) => (),
  ~wrapBasis="",
  ~customScrollStyle=?,
  (),
) => {
  let isMobileView = MatchMedia.useMobileChecker()
  let (selectedString, setSelectedString) = React.useState(_ => "")
  let newInputSelect = input->ffInputToSelectInput
  let newInputRadio = input->ffInputToRadioInput
  if isDropDown {
    <BaseDropdown
      buttonText
      ?buttonSize
      allowMultiSelect
      input
      options
      optionSize
      isSelectedStateMinus
      showClearAll
      showSelectAll
      hideMultiSelectButtons
      deselectDisable
      buttonType
      disableSelect
      fullLength
      customButtonStyle
      textStyle // to change style of text inside dropdown
      marginTop
      customStyle
      showSelectionAsChips
      addDynamicValue
      showMatchingRecordsText
      ?searchable
      customSearchStyle
      showToolTip
      showNameAsToolTip
      ?showBorder
      dropDownCustomBtnClick
      showCustomBtnAtEnd
      customButton
      descriptionOnHover
      ?dropdownCustomWidth
      ?fixedDropDownDirection
      ?allowButtonTextMinWidth
      ?baseComponent
      ?baseComponentMethod
      ?customMarginStyle
      ?buttonTextWeight
      ?customButtonLeftIcon
      ?customTextPaddingClass
      ?customButtonPaddingClass
      ?customButtonIconMargin
      ?textStyleClass
      buttonStyleOnDropDownOpened
      selectedString
      setSelectedString
      setExtSearchString
      listFlexDirection
      ellipsisOnly
      isPhoneDropdown
      ?hasApplyButton
      ?onApply
      ?showAllSelectedOptions
      ?buttonClickFn
      showSelectCountButton
      defaultLeftIcon=?leftIcon
      ?maxHeight
      ?customBackColor
      showToolTipOptions
      textEllipsisForDropDownOptions
      showBtnTextToolTip
      dropdownClassName
      ?searchInputPlaceHolder
      showSearchIcon
      ?customScrollStyle
    />
  } else if allowMultiSelect {
    <BaseSelect
      options
      optionSize
      isSelectedStateMinus
      ?optionRigthElement
      onSelect=newInputSelect.onChange
      value=newInputSelect.value
      isDropDown
      showClearAll
      showSelectAll
      onBlur=newInputSelect.onBlur
      isHorizontal
      showToggle
      heading=buttonText
      ?maxHeight
      ?searchable
      isMobileView
      hideBorder
      allSelectType
      showSelectionAsChips
      ?searchInputPlaceHolder
      showSearchIcon
      ?customLabelStyle
      customStyle
      customMargin
      customSearchStyle
      disableSelect
      ?customMarginStyle
      ?dropdownCustomWidth
      listFlexDirection
      ?hasApplyButton
      ?onApply
      ?showAllSelectedOptions
      showDescriptionAsTool
      optionClass
      selectClass
      toggleProps
      ?customSelectAllStyle
      checkboxDimension
      dropdownClassName
      onItemSelect
      wrapBasis
    />
  } else {
    <BaseRadio
      options
      optionSize
      isSelectedStateMinus
      onSelect=newInputRadio.onChange
      value=newInputRadio.value
      onBlur=newInputRadio.onBlur
      isDropDown
      fill
      isHorizontal
      deselectDisable
      ?searchable
      customSearchStyle
      isMobileView
      listFlexDirection
      customStyle
      baseComponentCustomStyle
      customSelectStyle
      ?maxHeight
      ?searchInputPlaceHolder
      showSearchIcon
      descriptionOnHover
      showToolTipOptions
      ?customScrollStyle
    />
  }
}
