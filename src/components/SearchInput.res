open LottieFiles

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
  ~selectedType=?,
  ~onTypeChange=?,
  ~onEnterPress=?,
) => {
  let (prevVal, setPrevVal) = React.useState(_ => "")
  let showPopUp = PopUpState.useShowPopUp()
  let (showDropdown, setShowDropdown) = React.useState(_ => false)
  let dropdownRef = React.useRef(Nullable.null)

  let defaultRef = React.useRef(Nullable.null)
  let searchRef = searchRef->Option.getOr(defaultRef)

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

  let currentLabel = React.useMemo(() => {
    switch (typeSelectorOptions, selectedType) {
    | (Some(options), Some(currentType)) =>
      switch options->Array.find(option => option.value === currentType) {
      | Some(option) => option.label
      | None => options->Array.get(0)->Option.mapOr("Type", opt => opt.label)
      }
    | _ => "Type"
    }
  }, (typeSelectorOptions, selectedType))

  let handleTypeChange = value => {
    onTypeChange->Option.forEach(callback => callback(value))
    setShowDropdown(_ => false)
  }

  let form = shouldSubmitForm ? None : Some("fakeForm")

  let borderClass = roundedBorder
    ? "border rounded-md pl-1 pr-2"
    : "border-b-2 focus-within:border-b"

  let handleKeyDown = e => {
    let keyPressed = e->ReactEvent.Keyboard.key
    if keyPressed == "Enter" {
      onEnterPress->Option.forEach(callback => callback())
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

  let containerClass = React.useMemo(() => {
    if showTypeSelector {
      `${widthClass} relative flex items-center border rounded-lg transition-all duration-200 bg-nd_gray-0 hover:bg-nd_gray-50 dark:bg-jp-gray-lightgray_background ${showDropdown
          ? "border-nd_primary_blue-500 dark:border-nd_primary_blue-500"
          : "border-nd_br_gray-200 border-opacity-75 hover:border-opacity-100 focus-within:!border-nd_primary_blue-500 focus-within:!border-opacity-100 dark:border-jp-gray-850"}`
    } else {
      `${widthClass} ${borderClass} ${heightClass} flex flex-row items-center justify-between
      dark:bg-jp-gray-lightgray_background
      dark:focus-within:border-primary hover:border-opacity-100
      dark:border-jp-gray-850 dark:border-opacity-50 dark:hover:border-opacity-100 ${bgColor}`
    }
  }, (showTypeSelector, widthClass, borderClass, heightClass, showDropdown, bgColor))

  <div className=containerClass>
    <RenderIf condition={showSearchIcon}>
      <div className={showTypeSelector ? "flex items-center pl-4" : ""}>
        <Icon
          name={showTypeSelector ? "search" : "nd-search"}
          size={showTypeSelector ? 14 : 16}
          className={showTypeSelector ? "text-gray-400 dark:text-gray-500" : "w-4 h-4"}
        />
      </div>
    </RenderIf>
    <input
      ref={searchRef->ReactDOM.Ref.domRef}
      type_="text"
      value=inputText
      onChange=handleSearch
      placeholder
      className={showTypeSelector
        ? "flex-1 px-3 py-2 bg-transparent text-sm text-gray-700 dark:text-gray-300 placeholder-gray-400 placeholder:opacity-90 focus:outline-none h-10"
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
              animationData={(prevVal->LogicUtils.isNonEmptyString &&
                inputText->LogicUtils.isEmptyString) ||
                (prevVal->LogicUtils.isEmptyString && inputText->LogicUtils.isEmptyString)
                ? exitCross
                : enterCross}
              autoplay=true
              loop=false
            />
          </ReactSuspenseWrapper>
        </div>
      </AddDataAttributes>
    </RenderIf>
    <RenderIf condition={showTypeSelector}>
      {switch typeSelectorOptions {
      | Some(options) =>
        <>
          <div className="h-6 w-px bg-gray-300 dark:bg-gray-600" />
          <div className="relative">
            <button
              type_="button"
              onClick={_ => setShowDropdown(prev => !prev)}
              className="flex items-center gap-1 px-3 h-10 text-sm text-gray-700 dark:text-gray-300 bg-transparent rounded-r-lg transition-all duration-200 focus:outline-none active:outline-none outline-none border-0 shadow-none active:shadow-none focus:shadow-none active:border-0 focus:border-0 select-none">
              <span className="whitespace-nowrap text-xs"> {currentLabel->React.string} </span>
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
                {options
                ->Array.map(option => {
                  let isSelected = selectedType->Option.mapOr(false, st => st === option.value)
                  <button
                    key={option.value}
                    type_="button"
                    onMouseDown={event => {
                      ReactEvent.Mouse.preventDefault(event)
                      handleTypeChange(option.value)
                    }}
                    className={`w-full px-3 py-2 text-xs text-left transition-colors ${isSelected
                        ? "bg-gray-100 dark:bg-jp-gray-850 text-gray-700 dark:text-gray-300"
                        : "text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-jp-gray-800"}`}>
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
        </>
      | None => React.null
      }}
    </RenderIf>
  </div>
}
