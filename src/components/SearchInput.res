open LottieFiles
open LogicUtils
open Typography

type searchTypeOption = {
  label: string,
  value: string,
}

@react.component
let make = (
  ~onChange,
  ~inputText,
  ~autoFocus=true,
  ~placeholder="",
  ~searchIconCss="ml-2",
  ~roundedBorder=true,
  ~widthClass="w-full",
  ~heightClass="h-8",
  ~searchRef=?,
  ~shouldSubmitForm=true,
  ~placeholderCss="bg-transparent text-fs-14",
  ~bgColor="border-jp-gray-600 border-opacity-75 focus-within:border-primary",
  ~iconName="new_search_icon",
  ~onKeyDown=_ => {()},
  ~showSearchIcon=false,
  ~showTypeSelector=false,
  ~typeSelectorOptions=?,
  ~onSubmitSearchDropdown=?,
) => {
  let (prevVal, setPrevVal) = React.useState(_ => "")
  let showPopUp = PopUpState.useShowPopUp()
  let (showDropdown, setShowDropdown) = React.useState(_ => false)
  let dropdownRef = React.useRef(Nullable.null)

  let defaultRef = React.useRef(Nullable.null)
  let searchRef = searchRef->Option.getOr(defaultRef)

  let (selectedType, setSelectedType) = React.useState(_ =>
    typeSelectorOptions->Option.map(options =>
      getValueFromArray(options, 0, {label: "", value: ""}).value
    )
  )

  let handleSearch = e => {
    setPrevVal(_ => inputText)
    let value = {e->ReactEvent.Form.target}["value"]
    if value->String.includes("<script>") || value->String.includes("</script>") {
      showPopUp({
        popUpType: (Warning, WithIcon),
        heading: `Script Tags are not allowed`,
        description: React.string(`Input cannot contain <script>, </script> tags`),
        handleConfirm: {text: "OK"},
      })
    }
    let searchStr = value->String.replace("<script>", "")->String.replace("</script>", "")
    // let searchStr = (e->ReactEvent.Form.target)["value"]

    onChange(searchStr)
  }

  let clearSearch = e => {
    e->ReactEvent.Mouse.stopPropagation
    onChange("")
  }

  let handleToggleDropdown = _ => {
    setShowDropdown(prev => !prev)
  }

  let currentLabel = switch (typeSelectorOptions, selectedType) {
  | (Some(options), Some(currentType)) =>
    options
    ->Array.find(option => option.value === currentType)
    ->Option.mapOr("Select", opt => opt.label)
  | _ => "Select"
  }

  let handleTypeChange = value => {
    setSelectedType(_ => Some(value))
    setShowDropdown(_ => false)
  }

  let handleOptionClick = (event, optionValue) => {
    ReactEvent.Mouse.preventDefault(event)
    handleTypeChange(optionValue)
  }

  let form = shouldSubmitForm ? None : Some("fakeForm")

  let borderClass = roundedBorder
    ? "border rounded-md pl-1 pr-2"
    : "border-b-2 focus-within:border-b"

  let handleKeyDown = e => {
    let keyPressed = e->ReactEvent.Keyboard.key
    let keyCode = e->ReactEvent.Keyboard.keyCode
    if keyPressed == "Enter" || keyCode == 13 {
      switch onSubmitSearchDropdown {
      | Some(callback) => callback(selectedType)
      | None => ()
      }
    }
    onKeyDown(e)
  }

  OutsideClick.useOutsideClick(
    ~refs=ArrayOfRef([dropdownRef]),
    ~isActive=showDropdown && showTypeSelector,
    ~callback=() => {
      setShowDropdown(_ => false)
    },
  )

  let exitCross = useLottieJson(exitSearchCross)
  let enterCross = useLottieJson(enterSearchCross)

  let borderColorClass = showDropdown
    ? "border-nd_primary_blue-500 dark:border-nd_primary_blue-500"
    : "border-nd_br_gray-200 border-opacity-75 hover:border-opacity-100 focus-within:!border-nd_primary_blue-500 focus-within:!border-opacity-100 dark:border-jp-gray-850"

  let containerClass = showTypeSelector
    ? {
        `${widthClass} relative flex items-center border rounded-lg transition-all duration-200 bg-nd_gray-0 hover:bg-nd_gray-50 dark:bg-jp-gray-lightgray_background ${borderColorClass}`
      }
    : {
        `${widthClass} ${borderClass} ${heightClass} flex flex-row items-center justify-between
      dark:bg-jp-gray-lightgray_background
      dark:focus-within:border-primary hover:border-opacity-100
      dark:border-jp-gray-850 dark:border-opacity-50 dark:hover:border-opacity-100 ${bgColor}`
      }

  <div className=containerClass>
    <RenderIf condition={showSearchIcon}>
      <div className={showTypeSelector ? "flex items-center pl-4" : ""}>
        <Icon name="nd-search" className="w-4 h-4" />
      </div>
    </RenderIf>
    <input
      ref={searchRef->ReactDOM.Ref.domRef}
      type_="text"
      value=inputText
      onChange=handleSearch
      placeholder
      className={showTypeSelector
        ? `flex-1 px-3 py-2 bg-transparent ${body.md.regular} text-gray-700 dark:text-gray-300 placeholder-gray-400 placeholder:opacity-90 focus:outline-none h-10`
        : `rounded-md w-full pl-2 focus:outline-none ${placeholderCss}`}
      autoFocus
      ?form
      onKeyDown=handleKeyDown
    />
    <RenderIf condition={!showTypeSelector}>
      <AddDataAttributes attributes=[("data-icon", "searchExit")]>
        <div className="h-6 flex w-6" onClick=clearSearch>
          <ReactSuspenseWrapper loadingText="">
            <Lottie
              animationData={(prevVal->isNonEmptyString && inputText->isEmptyString) ||
                (prevVal->isEmptyString && inputText->isEmptyString)
                ? exitCross
                : enterCross}
              autoplay=true
              loop=false
            />
          </ReactSuspenseWrapper>
        </div>
      </AddDataAttributes>
    </RenderIf>
    <RenderIf condition={showTypeSelector && typeSelectorOptions->Option.isSome}>
      <div className="flex items-center">
        <div className="h-6 w-px bg-gray-300 dark:bg-gray-600" />
        <div className="relative">
          <button
            type_="button"
            onClick={handleToggleDropdown}
            className={`flex items-center gap-1 px-3 h-10 ${body.sm.regular} text-gray-700 dark:text-gray-300 bg-transparent rounded-r-lg transition-all duration-200 focus:outline-none active:outline-none outline-none border-0 shadow-none active:shadow-none focus:shadow-none active:border-0 focus:border-0 select-none`}>
            <span className={`${body.sm.regular} whitespace-nowrap`}>
              {currentLabel->React.string}
            </span>
            <Icon
              size=10
              name="chevron-down"
              className={`transition-transform duration-200 text-gray-500 ${showDropdown
                  ? "rotate-180"
                  : ""}`}
            />
          </button>
          <RenderIf condition=showDropdown>
            <div
              ref={dropdownRef->ReactDOM.Ref.domRef}
              className="absolute right-0 top-full mt-1 bg-white dark:bg-jp-gray-lightgray_background border border-gray-200 dark:border-jp-gray-850 rounded-lg shadow-lg z-50 min-w-28 overflow-hidden">
              {typeSelectorOptions
              ->Option.getOr([{label: "Select", value: ""}])
              ->Array.map(option => {
                let isSelected = selectedType->Option.mapOr(false, st => st === option.value)
                let optionClassName = `w-full px-3 py-2 text-xs text-left transition-colors ${isSelected
                    ? "bg-gray-100 dark:bg-jp-gray-850 text-gray-700 dark:text-gray-300"
                    : "text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-jp-gray-800"}`
                <button
                  key={option.value}
                  type_="button"
                  onMouseDown={event => handleOptionClick(event, option.value)}
                  className=optionClassName>
                  <div className="flex items-center justify-between gap-2">
                    <span> {option.label->React.string} </span>
                    <Tick isSelected />
                  </div>
                </button>
              })
              ->React.array}
            </div>
          </RenderIf>
        </div>
      </div>
    </RenderIf>
  </div>
}
