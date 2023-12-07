@react.component
let make = () => {
  let (isToggle, setIsToggle) = React.useState(_ => false)

  let handleToggleClick = () => {
    setIsToggle(prev => !prev)
  }

  React.useEffect0(() => {
    handleToggleClick()
    Js.Global.setTimeout(() => {
      handleToggleClick()
    }, 1500)->ignore
    None
  })

  <div
    className={`box-content fixed right-[60px] flex flex-col w-[200px] h-[280px] bg-[#2a2f45] text-white rounded-tr-lg rounded-tl-lg py-5 px-8 transition-[bottom] delay-[400] ease-in-out ${isToggle
        ? "bottom-0"
        : "-bottom-[265px]"}`}>
    <div
      className="flex cursor-pointer items-center justify-between leading-5 mb-4 uppercase"
      onClick={_ => handleToggleClick()}>
      <div className="flex items-center text-[13px] font-medium leading-5">
        <Icon name="default-card" size=12 className="mr-[10px]" />
        <div> {React.string("Test Cards")} </div>
      </div>
      <Icon name={`${isToggle ? "arrow-down-hs" : "arrow-up-hs"}`} size=12 />
    </div>
    <div className="testInput__cards">
      <HSwitchCardData
        icon="tickMark" label="Success" number=HSwitchSDKUtils.successTestCardNumber color="#09825d"
      />
      <HSwitchCardData
        icon="authentication"
        label="Authentication"
        number=HSwitchSDKUtils.authenticationTestCardNumber
        color="#635bff"
      />
      <HSwitchCardData
        icon="decline" label="Decline" number=HSwitchSDKUtils.declineTestCardNumber color="#dc2727"
      />
    </div>
    <div className="text-sm text-white mt-5 text-justify">
      {React.string(HSwitchSDKUtils.testCardsInfo)}
    </div>
  </div>
}
