open LottieFiles
@react.component
let make = (
  ~onChange,
  ~inputText,
  ~autoFocus=true,
  ~placeholder="",
  ~searchIconCss="ml-2",
  ~roundedBorder=true,
  ~widthClass="w-full",
  ~heightClass="h-10",
  ~searchRef=?,
  ~shouldSubmitForm=true,
  ~placeholderCss="bg-transparent",
  ~bgColor="bg-white border-jp-gray-600 border-opacity-75 focus-within:border-blue-800",
  ~iconName="new_search_icon",
  ~onKeyDown=_ => {()},
  ~showSearchIcon=true,
) => {
  let (prevVal, setPrevVal) = React.useState(_ => "")
  let showPopUp = PopUpState.useShowPopUp()

  let defaultRef = React.useRef(Js.Nullable.null)
  let searchRef = searchRef->Belt.Option.getWithDefault(defaultRef)

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

  let form = shouldSubmitForm ? None : Some("fakeForm")

  let borderClass = roundedBorder
    ? "border rounded-md pl-1 pr-2"
    : "border-b-2 focus-within:border-b"

  let exitCross = useLottieJson(exitSearchCross)
  let enterCross = useLottieJson(enterSearchCross)
  <div
    className={`${widthClass} ${borderClass} ${heightClass} ${bgColor} flex flex-row items-center justify-between
    dark:bg-jp-gray-lightgray_background
    dark:focus-within:border-blue-800 hover:border-opacity-100 
    dark:border-jp-gray-850 dark:border-opacity-50 dark:hover:border-opacity-100`}>
    <UIUtils.RenderIf condition=showSearchIcon>
      <Icon className={`align-begin 16`} size=16 name=iconName />
    </UIUtils.RenderIf>
    <input
      ref={searchRef->ReactDOM.Ref.domRef}
      type_="text"
      value=inputText
      onChange=handleSearch
      placeholder
      className={`rounded-md w-full pl-2 focus:outline-none ${placeholderCss}`}
      autoFocus
      ?form
      onKeyDown
    />
    <AddDataAttributes attributes=[("data-icon", "searchExit")]>
      <div className="h-6 my-auto w-6" onClick=clearSearch>
        <ReactSuspenseWrapper loadingText="">
          <Lottie
            animationData={(prevVal != "" && inputText == "") || (prevVal == "" && inputText == "")
              ? exitCross
              : enterCross}
            autoplay=true
            loop=false
          />
        </ReactSuspenseWrapper>
      </div>
    </AddDataAttributes>
  </div>
}
